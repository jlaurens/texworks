/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2018-2023  Jonathan Kew, Stefan Löffler, Jérôme Laurens

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.

	For links to further information, or to contact the authors,
	see <http://www.tug.org/texworks/>.
*/

/** \file
 * @brief Path locator
 */

#include "Core/TwxConst.h"
#include "Core/TwxLocate.h"
#include "Core/TwxSettings.h"

#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>
#include <QMessageBox>
#include <QCoreApplication>
#include <QUrl>

#include <QDebug>

namespace Twx {

namespace Core {

QStringList Locate::rawBinaryPaths_m;

#if defined(TwxCore_TEST)
QStringList Locate::factoryBinaryPathsTest_m = QStringLiteral("@TWX_CFG_FACTORY_BINARY_PATHS_TEST@").split(QDir::listSeparator(), Qt::SkipEmptyParts);
QStringList Locate::messages_m;
#endif


void Locate::setup(const QSettings & settings)
{
	if (settings.contains(Key::defaultbinpaths)) {
		rawBinaryPaths_m = settings.value(Key::defaultbinpaths).toString().split(QDir::listSeparator(), Qt::SkipEmptyParts);
	}
}

QDir Locate::applicationDir()
{
	static QString path;
	if (path.isEmpty()) {
		path = QDir(QCoreApplication::applicationDirPath()).absolutePath();
#if defined(Q_OS_DARWIN)
  // problem with the bundle (iOS not supported)
	// Next is clean but needs to link with the extra core foundation framework
	// which is not very efficient
	// CFURLRef url = (CFURLRef)CFAutorelease((CFURLRef)CFBundleCopyBundleURL(CFBundleGetMainBundle()));
	// return QUrl::fromCFURL(url).path();
	auto fileInfo = QFileInfo(path, QStringLiteral("../.."));
	if (fileInfo.isBundle()) {
		path = fileInfo.absolutePath();
	}
#endif
	}
  return QDir(path);
}

static const QStringList factoryBinaryPaths = QStringLiteral("@TWX_CFG_FACTORY_BINARY_PATHS@").split(QDir::listSeparator(), Qt::SkipEmptyParts);

void Locate::setRawBinaryPaths(const QStringList &paths)
{
	rawBinaryPaths_m.clear();
	rawBinaryPaths_m.append(paths);
	Settings settings;
	if (paths.empty()) {
		settings.remove(Key::binaryPaths);
	} else {
		settings.setValue(Key::binaryPaths, rawBinaryPaths_m);
	}
}

// Recursive replacements are not supported.
static QString stringByReplacingEnvironmentVariables(
	QString s,
	const QProcessEnvironment &env
)
{
	// If there is nothing to replace, don't bother trying
#ifdef Q_OS_WINDOWS
	if (!s.contains(QStringLiteral("%"))) {
		return s;
	}
  QString sep  = QStringLiteral("%%");
	QString base = QStringLiteral("(?<!\\%)\\%(%1)\\%)");
#else
	if (!s.contains(QStringLiteral("$"))) {
		return s;
	}
  QString sep = QStringLiteral("\\\\");
	QString base = QStringLiteral("(?<!\\\\)\\$(%1|\\{%1\\})");
#endif
	QStringList vars = env.keys();
	// Sort the variable names from longest to shortest to appropriately
	// replace $HOMEPATH before $HOME
	std::sort(
		vars.begin(),
		vars.end(),
		[] (QString &a, QString &b) {
			return a.length() > b.length();
		}
	);
  QStringList parts = s.split(sep);
	for (auto var: vars) {
		auto value = env.value(var);
		QRegularExpression re{base.arg(QRegularExpression::escape(var))};
		for (auto &part: parts) {
      part = part.replace(re, value);
		}
	}
	return parts.join(sep);
}

/*
// Migrated from CMake build system
static  add_TeXLive_default_binary_paths ( QStringList & pathsVar )
#if defined(Q_OS_WIN)
	QStringLiteral("c:/w32tex/bin"),
	QStringLiteral("c:/texlive/%1/bin").arg(year);
#endif
QStringList OSList{
	QStringLiteral("freebsd"),
	QStringLiteral("netbsd"),
	QStringLiteral("solaris"),
	QStringLiteral("linux"),
	QStringLiteral("cygwin"),
};
// if this list does not fit, read a configuration


	QStringList ArchList{
		QStringLiteral("i386"),
		QStringLiteral("x86_64"),
		QStringLiteral("amd64"),
		QStringLiteral("arm64"),
	}
	for (const auto & OS: QStringList)
	  )
		endforeach()
	else ()
		if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 4)
			set(ARCH "i386")
		else ()
			set(ARCH "x86_64")
		endif ()
		if (CYGWIN)
			set(OS "cygwin")
		elseif (APPLE)
			set(OS "darwin")
		elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD")
			set(OS "freebsd")
			if ("${ARCH}" STREQUAL "x86_64")
				set(ARCH "amd64")
			endif ()
		elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "NetBSD")
			set(OS "netbsd")
			if ("${ARCH}" STREQUAL "x86_64")
				set(ARCH "amd64")
			endif ()
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "SunOS" )
			set ( OS "solaris" )
		# FIXME: darwinlegacy, linuxmusl
		else ()
			set( OS "linux" )
		endif ()
		set( _path "" )
		foreach( year RANGE ${yearMin} ${yearMax} )
			list( INSERT _path 0 "/usr/local/texlive/${year}/bin/${ARCH}-${OS}" )
		endforeach()
		if ( APPLE )
			foreach( year RANGE ${yearMin} ${yearMax} )
				list( INSERT _path 0 "/usr/local/texlive/${year}/bin/x86_64-darwinlegacy" )
			endforeach ()
			foreach ( year RANGE ${yearMin} ${yearMax} )
				list ( INSERT _path 0 "/usr/local/texlive/${year}/bin/universal-darwin" )
			endforeach ()
		endif ()
	endif ()
	list ( APPEND ${pathsVar} ${_path} )
	twx_export ( ${pathsVar} )
endfunction (twx__add_TeXLive_default_binary_paths pathsVar )

# ANCHOR: twx__add_MiKTeX_default_binary_paths
# MiKTeX
# Windows: Installs to "%LOCALAPPDATA%\Programs\MiKTeX" or "C:\Program Files\MiKTeX"
# (previously, versioned folders such as "C:\Program Files\MiKTeX 2.9" were used)
# Linux: Installs miktex-* binaries to /usr/bin and symlinks them to ~/bin or
# /usr/local/bin (https://miktex.org/howto/install-miktex-unx)
# Mac OS X uses the same symlink locations as Linux (https://miktex.org/howto/install-miktex-mac)
function (twx__add_MiKTeX_default_binary_paths pathsVar)
	if (WIN32)
		list(APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX/miktex/bin")
		list(APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX/miktex/bin")
		list(APPEND ${pathsVar} "%SystemDrive%/Program Files (x86)/MiKTeX/miktex/bin")
		foreach(_miktex_version IN ITEMS 3.0 2.9 2.8)
			# TODO: replace hard coded program files path with
			# %ProgramFiles% (might cause problems when running a 32bit application
			# on 64bit Windows) or %ProgramW6432% (added in Win7)
			list(APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX ${_miktex_version}/miktex/bin")
			list(APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX ${_miktex_version}/miktex/bin")
			list(APPEND ${pathsVar} "%SystemDrive%/Program Files (x86)/MiKTeX ${_miktex_version}/miktex/bin")
		endforeach()
	else ()
		list(APPEND ${pathsVar} "\${HOME}/bin" "/usr/local/bin")
	endif ()
	twx_export ( ${pathsVar} )
endfunction ( twx__add_MiKTeX_default_binary_paths pathsVar )

# ANCHOR: twx__add_TeX_binary_paths
#[=======[
This is only relevant when building the application on your own,
because it relies on an installed TeX distribution
available in the PATH while building the application.
Ignored when CMake is cross compiling.
#]=======]
function ( twx__add_TeX_binary_paths pathsVar )
	if ( CMAKE_CROSSCOMPILING )
		return()
	endif ()
	if ( WIN32 )
		get_filename_component ( _tex tex.exe PROGRAM )
	else ()
		get_filename_component ( _tex tex PROGRAM )
	endif ()
	if ( NOT _tex )
		return ()
	endif ()
	get_filename_component ( _path "${_tex}" DIRECTORY )
	list ( INSERT ${pathsVar} 0 "${_path}" )
	twx_export ( ${pathsVar} )
endfunction (twx__add_TeX_binary_paths pathsVar)

# ANCHOR: twx__add_system_default_binary_paths
function ( twx__add_system_default_binary_paths pathsVar )
	if ( APPLE )
		list ( INSERT ${pathsVar} 0 "/Library/TeX/texbin" "/usr/texbin" )
	endif ()
	if ( UNIX )
		list( APPEND ${pathsVar} "/usr/local/bin" "/usr/bin" )
	endif ()
	twx_export ( ${pathsVar} )
endfunction ( twx__add_system_default_binary_paths pathsVar )
*/
bool Locate::resetRawBinaryPaths(
  const QProcessEnvironment &env
) {
	rawBinaryPaths_m.clear();
	for (auto s: factoryBinaryPaths) {
#if TwxCore_TEST
		// while testing, the factory binary paths need to be portable
		// We do not know in advance really existing directories
		// except those actually in the source.
		// Replace any occurrence of "<<<pwd>>>" with the current working directory.
		auto before = QStringLiteral("<<<pwd>>>");
		auto after = QDir::currentPath();
		s.replace(before, after);
#endif
		if (!rawBinaryPaths_m.contains(s))
			rawBinaryPaths_m.append(s);
	}
#if !defined(TwxCore_TEST)
	// TODO: TEXEDIT support for mac.
	auto path = QCoreApplication::applicationDirPath();
	if (!rawBinaryPaths_m.contains(path))
		rawBinaryPaths_m.insert(0,path);
#endif
  QString PATH = env.value(Env::PATH);
	if (!PATH.isEmpty()) {
		foreach (const QString& s, PATH.split(QDir::listSeparator(), Qt::SkipEmptyParts)) {
			if (!rawBinaryPaths_m.contains(s)) {
				rawBinaryPaths_m.append(s);
			}
		}
	}
	for (auto i = rawBinaryPaths_m.count() - 1; i >= 0; --i) {
		// Note: Only replace the environmental variables for testing directory
		// existence but do not alter the binaryPaths themselves. Those might
		// get stored, e.g., in the preferences and we want to keep
		// environmental variables intact in there (as they may be (re)defined
		// later on).
		// All binary paths are properly expanded in PATHList().
		QDir dir(stringByReplacingEnvironmentVariables(
			rawBinaryPaths_m.at(i),
			env)
		);
		if (!dir.exists())
			rawBinaryPaths_m.removeAt(i);
	}
	if (rawBinaryPaths_m.empty()) {
#if defined(TwxCore_TEST)
    messages_m = QStringList{
#else
		QMessageBox::warning(
			nullptr,
#endif
			QObject::tr("No default binary directory found"),
			QObject::tr("None of the predefined directories for TeX-related programs could be found."
				"<p><small>To run any processes, you will need to set the binaries directory (or directories) "
				"for your TeX distribution using the Typesetting tab of the Preferences dialog.</small>")
#if !defined(TwxCore_TEST)
		);
#else
    };
#endif
		return false;
	}
	return true;
}

const QStringList Locate::getRawBinaryPaths(
  const QProcessEnvironment &env
) {
	if (rawBinaryPaths_m.empty()) {
  	Settings settings;
		if (settings.contains(Key::binaryPaths))
			rawBinaryPaths_m.append(
				settings.value(Key::binaryPaths).toStringList()
			);
		else
			resetRawBinaryPaths(env);
	}
	return rawBinaryPaths_m;
}

const QStringList Locate::PATHList(
  QProcessEnvironment const& env
) {
	QStringList paths = getRawBinaryPaths(env);
	for (QString & path: paths) {
		path = stringByReplacingEnvironmentVariables(path, env);
	}
	auto PATH = env.value(Env::PATH);
	for (QString path: PATH.split(QDir::listSeparator(), Qt::SkipEmptyParts)) {
		path = stringByReplacingEnvironmentVariables(path, env);
		if (!paths.contains(path)) {
			paths.append(path);
		}
	}
	return paths;
}

void Locate::setPATH(
  QProcessEnvironment & env
) {
	env.insert(
		Env::PATH,
		PATHList(env).join(QDir::listSeparator())
	);
}

QString Locate::programPath (
	const QString& program,
  const QProcessEnvironment &env
) {
	if (program.isEmpty())
		return QString();
	QFileInfo fileInfo;
#if defined(Q_OS_WIN)
	QStringList extensions {
		QStringLiteral("exe"),
		QStringLiteral("com"),
		QStringLiteral("cmd"),
		QStringLiteral("bat")
	};
#endif
  for (auto path: PATHList(env)) {
		fileInfo = QFileInfo(path, program);
		if (fileInfo.exists() && fileInfo.isExecutable())
		  return fileInfo.absoluteFilePath();
#if defined(Q_OS_WIN)
		// try adding common executable extensions,
		// if one was not already present
		if (!extensions.contains(fileInfo.suffix())) {
			for (auto extension: extensions) {
				fileInfo = QFileInfo(path, program + dot + extension);
				if (fileInfo.exists() && fileInfo.isExecutable())
				  return fileInfo.absoluteFilePath();
			}
		}
#endif
	}
	return QString();
}

#if defined(TwxCore_TEST)
  const QFileInfo Locate::TwxCore_TEST_fileInfoMustExist = QFileInfo("MustExist:99775f3fc7471fca1808438060defe83cb3b724b");
  const QFileInfo Locate::TwxCore_TEST_fileInfoNone 		 = QFileInfo("None:8438060defe83cb3b724b99775f3fc7471fca180");
#endif


const Locate::Resolved Locate::resolve(
	const QString & path,
	const QDir & customDir,
	bool mustExist
)
{
	QFileInfo fileInfo(path);
	if (fileInfo.isAbsolute()) {
		if (fileInfo.exists()) {
			return Resolved{true, fileInfo};
		}
		if (mustExist) {
			return Resolved{false, 
#if defined(TwxCore_TEST)
				TwxCore_TEST_fileInfoMustExist
#else
				QFileInfo()
#endif
			};
		}
	}
	auto dirs = QList<QDir>{
		QDir::current(),
		QDir::home(),
		Locate::applicationDir()
	};
	if (customDir.isAbsolute()) {
		dirs.insert(0, customDir);
	}
	for (auto d: dirs) {
		fileInfo = QFileInfo(d, path);
		if (fileInfo.exists()) {
			fileInfo.makeAbsolute();
			return Resolved{true, fileInfo};
		}
	}
	return Resolved{false,
#if defined(TwxCore_TEST)
		TwxCore_TEST_fileInfoNone
#else
		QFileInfo()
#endif
	};
}

} // namespace Core
} // namespace Twx
