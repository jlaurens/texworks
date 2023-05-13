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

#include "TwxConst.h"
#include "TwxLocate.h"
#include "TwxSettings.h"

#include <algorithm>

#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>
#include <QMessageBox>
#include <QCoreApplication>
#include <QUrl>

#include <QDebug>

#if not defined(TWX_CONST)
#define TWX_CONST const 
#endif

namespace Twx {

namespace Core {

QStringList Locate::listPATHRaw_m;

#if defined(TwxCore_TEST)
QStringList Locate::messages_TwxCore_TEST;
#endif


void Locate::setup(Settings & settings)
{
	listPATHRaw_m = settings.listPATH();
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

TWX_CONST QStringList Locate::listPATHFactory = QStringLiteral("@TWX_CFG_FACTORY_PATH@").split(QDir::listSeparator(), Qt::SkipEmptyParts);

void Locate::setListPATH(const QStringList &paths)
{
	listPATHRaw_m.clear();
	listPATHRaw_m.append(paths);
	Settings settings;
	settings.setListPATH(listPATHRaw_m);
}

// Recursive replacements are not supported.
static QString stringByReplacingEnvironmentVariables(
	QString s,
	const QProcessEnvironment & env
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
		[] (QString & a, QString & b) {
			return a.length() > b.length();
		}
	);
  QStringList parts = s.split(sep);
	for (auto var: vars) {
		auto value = env.value(var);
		QRegularExpression re{base.arg(QRegularExpression::escape(var))};
		for (auto & part: parts) {
      part = part.replace(re, value);
		}
	}
	return parts.join(sep);
}

QString Locate::rootTeXLive;
QString Locate::w32tex_bin;

/** \brief Private
	* 
	* For testing purposes: bypass by defining `rootTeXLive`
	*/
void Locate::appendListPATH_TeXLive_Windows(QStringList & listPATH)
{
	if (rootTeXLive.isEmpty()) {
		rootTeXLive = QStringLiteral("c:/texlive");
	}
	struct NFileInfo {
		int n;
		QFileInfo fileInfo;
	};
	QList<NFileInfo> list;
	auto dir = QDir(rootTeXLive);
	dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
	auto fileInfoList = dir.entryInfoList();
#if defined(TwxCore_TEST)
	std::random_shuffle(fileInfoList.begin(), fileInfoList.end());
#endif
	for (auto const & fileInfo: fileInfoList) {
		bool ok;
		int year = fileInfo.fileName().toInt(&ok);
		if (ok) {
			list << NFileInfo{year, fileInfo};
		}
	}
	auto compare = [](const NFileInfo & a, const NFileInfo & b) -> bool { 
		return a.n > b.n; 
	};
	std::sort(list.begin(), list.end(),	compare);
  for ( auto const & pair: list) {
		listPATH << pair.fileInfo.absoluteFilePath()
			+ QStringLiteral("/bin");
	}
	// https://w32tex.org
	if (w32tex_bin.isEmpty()) {
		w32tex_bin = QStringLiteral("c:/w32tex/bin");
	}
	listPATH << w32tex_bin;  
}

QStringList Locate::appendListPATH_TeXLive_Other_m;

/** \brief Private
 	*
	* Allways append "/Library/TeX/texbin" and its
	* "<home>/Library/TeX/texbin" counterpart.
	*
	* `rootTeXLive` is set to "/usr/local/texlive"
	* when not defined. Feature used for testing.
	*
	* Looks for YYYY/bin folders
	*/
void Locate::appendListPATH_TeXLive_Other(QStringList & listPATH)
{
	if (appendListPATH_TeXLive_Other_m.isEmpty()) {
		appendListPATH_TeXLive_Other_m = QStringList{
			QStringLiteral("/Library/TeX/texbin"),
			QDir::home().absoluteFilePath(QStringLiteral("Library/TeX/texbin"))
		};
	}
	for (const auto & p: appendListPATH_TeXLive_Other_m) {
		listPATH.removeAll(p);
		listPATH.insert(0, p);
	}
	if (rootTeXLive.isEmpty()) {
		rootTeXLive = QStringLiteral("/usr/local/texlive");
	}
	struct NFileInfo {
		int n;
		QFileInfo fileInfo;
	};
	QList<NFileInfo> list;
	auto dir = QDir(rootTeXLive);
	dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
	auto fileInfoList = dir.entryInfoList();
#if defined(TwxCore_TEST)
	std::random_shuffle(fileInfoList.begin(), fileInfoList.end());
#endif
	for (auto const & fileInfo: fileInfoList) {
		bool ok;
		int year = fileInfo.fileName().toInt(&ok);
		if (ok) {
			list << NFileInfo{year, fileInfo};
		}
	}
	auto compare = [](const NFileInfo & a, const NFileInfo & b) -> bool { 
		return a.n > b.n; 
	};
	std::sort(list.begin(), list.end(),	compare);
	for ( auto const & pair: list) {
		QDir dir(pair.fileInfo.absoluteFilePath());
		if (dir.cd(Path::bin)) {
			QList<NFileInfo> list2;
			dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
			auto fileInfoList = dir.entryInfoList();
#if defined(TwxCore_TEST)
			std::random_shuffle(fileInfoList.begin(), fileInfoList.end());
#endif
  		for (auto const & fileInfo: fileInfoList) {
				const auto afp = fileInfo.absoluteFilePath();
				const auto afp_tex = afp +
#if defined(Q_OS_WIN)
					QStringLiteral("/tex.exe")
#else
					QStringLiteral("/tex")
#endif
				;
				if (QFileInfo(afp_tex).isExecutable()) {
					listPATH << afp;
				}
			}
		}
	}
}

QString Locate::LOCALAPPDATA_Windows;
QString Locate::SystemDrive_Windows;

/** \brief Private
 	* 
	* For testing: set LOCALAPPDATA_Windows or SystemDrive_Windows
	* beforehand.
	*/
void Locate::appendListPATH_MiKTeX_Windows(
	QStringList & listPATH,
	const QProcessEnvironment & env
)
{
	if (LOCALAPPDATA_Windows.isEmpty()) {
		LOCALAPPDATA_Windows = env.value(Env::LOCALAPPDATA);
	}
	if (SystemDrive_Windows.isEmpty()) {
		SystemDrive_Windows = env.value(Env::SystemDrive);
	}
	QStringList programList{
		QFileInfo(LOCALAPPDATA_Windows, QStringLiteral(
			"Programs"
		)).absoluteFilePath(),
		QFileInfo(SystemDrive_Windows, QStringLiteral(
			"Program Files"
		)).absoluteFilePath(),
			QFileInfo(SystemDrive_Windows, QStringLiteral(
			"Program Files (x86)"
		)).absoluteFilePath()
	};
	QRegularExpression re(QStringLiteral("^MiKTeX(?: (.+))?"));
	for ( auto & dirPath: programList) {
		struct SFileInfo {
			QString s;
			QFileInfo fileInfo;
		};
		QList<SFileInfo> list;
		QDir dir(dirPath);
		dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
		auto fileInfoList = dir.entryInfoList();
#if defined(TwxCore_TEST)
		std::random_shuffle(fileInfoList.begin(), fileInfoList.end());
#endif
		for ( auto const & fileInfo: fileInfoList) {
			auto m = re.match(fileInfo.fileName());
			if (m.hasMatch()) {
				list << SFileInfo{m.captured(1), fileInfo};
			}
		}
		std::sort(
			list.begin(),
			list.end(),
			[](const SFileInfo & a, const SFileInfo & b)->bool {
				return a.s > b.s;
			}
		);
		for ( const auto & pair: list) {
			listPATH
				<< QDir(pair.fileInfo.absoluteFilePath())
					.absoluteFilePath(QStringLiteral("miktex/bin"));
		}
	}
}

/** \brief Private
 	* 
	* Add "<home>/bin" and " /usr/local/bin".
	*/
void Locate::appendListPATH_MiKTeX_Other(QStringList & listPATH)
{
	listPATH
		<< QDir::home().absoluteFilePath(Path::bin)
	 	<< QStringLiteral("/usr/local/bin");
}

/** \brief Private
 	* 
	* Append the TeXLive binary paths and then the MiKTeX binary paths.
	* These are system dependents.
	*/
void Locate::appendListPATH_TeX(
	QStringList & listPATH,
	const QProcessEnvironment & env
)
{
#if defined(Q_OS_WIN)
	appendListPATH_TeXLive_Windows(listPATH);
	appendListPATH_MiKTeX_Windows(listPATH, env);
#else
  Q_UNUSED(env);
	appendListPATH_TeXLive_Other(listPATH);
	appendListPATH_MiKTeX_Other(listPATH);
#endif
}

void Locate::consolidateListPATH(
	QStringList & listPATH,
	const QProcessEnvironment & env
)
{
	for (auto i = listPATH.count() - 1; i >= 0; --i) {
		// Note: Only replace the environmental variables for testing directory
		// existence but do not alter the PATH themselves. Those might
		// get stored, e.g., in the preferences and we want to keep
		// environmental variables intact in there (as they may be (re)defined
		// later on).
		// All binary paths are properly expanded in listPATH().
		QDir dir(stringByReplacingEnvironmentVariables(
			listPATH.at(i),
			env
		));
		if (!dir.exists()) {
			listPATH.removeAt(i);
		}
	}
}

bool Locate::resetListPATHRaw(
  const QProcessEnvironment &env
) {
	listPATHRaw_m.clear();
	appendListPATH_TeX(listPATHRaw_m, env);
	for (auto s: listPATHFactory) {
#if TwxCore_TEST
		// while testing, the factory binary paths need to be portable
		// We do not know in advance really existing directories
		// except those actually in the source.
		// Replace any occurrence of "<<<pwd>>>" with the current working directory.
		auto before = QStringLiteral("<<<pwd>>>");
		auto after = QDir::currentPath();
		s.replace(before, after);
#endif
		if (!listPATHRaw_m.contains(s))
			listPATHRaw_m.append(s);
	}
#if !defined(TwxCore_TEST)
	// TODO: TEXEDIT support for mac.
	auto path = QCoreApplication::applicationDirPath();
	if (!listPATHRaw_m.contains(path))
		listPATHRaw_m.insert(0,path);
#endif
  QString PATH = env.value(Env::PATH);
	if (!PATH.isEmpty()) {
		foreach (const QString& s, PATH.split(QDir::listSeparator(), Qt::SkipEmptyParts)) {
			if (!listPATHRaw_m.contains(s)) {
				listPATHRaw_m.append(s);
			}
		}
	}
	consolidateListPATH(listPATHRaw_m, env);
	if (listPATHRaw_m.empty()) {
#if defined(TwxCore_TEST)
    messages_TwxCore_TEST = QStringList{
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

const QStringList Locate::listPATHRaw(
  const QProcessEnvironment &env
) {
		// QTextStream out(stdout, QIODevice::WriteOnly);
    // out << "1****************************************";
    // out << "THIS IS A TRY TO FIND A WAY TO THE OUTPUT\n";
    // out.flush(); //a stream flush might be necessary to see the results immediately
	if (listPATHRaw_m.empty()) {
  	Settings settings;
		if (settings.hasListPATH()) {
			listPATHRaw_m.append(settings.listPATH());
			appendListPATH_TeX(listPATHRaw_m, env);
		} else
			resetListPATHRaw(env);
	}
	return listPATHRaw_m;
}

const QStringList Locate::listPATH(
	const QObject & controller,
  QProcessEnvironment const& env
) {
	QStringList ansListPATH;
	for (auto path: controller.property(PropertyKey::listPATH).toStringList()) {
		path = stringByReplacingEnvironmentVariables(path, env);
		if (QFileInfo::exists(path)) {
			ansListPATH << path;
		}
	}
	for (auto path: listPATH(env)) {
		if (!ansListPATH.contains(path)) {
			ansListPATH << path;
		}
	}
	return ansListPATH;
}

const QStringList Locate::listPATH(
  QProcessEnvironment const& env
) {
	QStringList ansListPATH = listPATHRaw(env);
	for (auto & path: ansListPATH) {
		path = stringByReplacingEnvironmentVariables(path, env);
	}
	auto PATH = env.value(Env::PATH);
	for (auto path: PATH.split(QDir::listSeparator(), Qt::SkipEmptyParts)) {
		path = stringByReplacingEnvironmentVariables(path, env);
		if (!ansListPATH.contains(path)) {
			ansListPATH << path;
		}
	}
	return ansListPATH;
}

void Locate::setPATH(
  QProcessEnvironment & env,
	const QDir & extraDir
) {
	auto list = listPATH(env);
	const auto path = extraDir.absolutePath();
  list.removeAll(path);
	list.insert(0, path);
	env.insert(Env::PATH,	list.join(QDir::listSeparator()));
}

QString Locate::absoluteProgramPath (
	const QString & program,
	const QStringList & listPATH
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
  for (auto path: listPATH) {
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

QString Locate::absoluteProgramPath (
	const QString & program,
	const QObject & controller,
  const QProcessEnvironment & env
) {
	return absoluteProgramPath(program, listPATH(controller, env));
}

QString Locate::absoluteProgramPath (
	const QString& program,
  const QProcessEnvironment &env
) {
	return absoluteProgramPath(program, listPATH(env));
}

#if defined(TwxCore_TEST)
  const QFileInfo Locate::fileInfoMustExist_TwxCore_TEST = QFileInfo("MustExist:99775f3fc7471fca1808438060defe83cb3b724b");
  const QFileInfo Locate::fileInfoNone_TwxCore_TEST 		 = QFileInfo("None:8438060defe83cb3b724b99775f3fc7471fca180");
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
				fileInfoMustExist_TwxCore_TEST
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
		fileInfoNone_TwxCore_TEST
#else
		QFileInfo()
#endif
	};
}

} // namespace Core
} // namespace Twx
