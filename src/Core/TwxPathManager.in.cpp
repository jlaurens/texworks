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

#include "Core/TwxConst.h"
#include "Core/TwxPathManager.h"
#include "Settings.h"

#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>
#include <QMessageBox>

#include <QDebug>

namespace Twx {
namespace Core {

const QString pathListSeparator = QStringLiteral("@TWX_PATH_LIST_SEPARATOR@");

const QStringList staticBinaryPaths = QStringLiteral("@TWX_STATIC_BINARY_PATHS@").split(pathListSeparator, Qt::SkipEmptyParts);
#if defined(TwxCore_TEST)
QStringList PathManager::altStaticBinaryPaths = QStringLiteral("@TWX_ALT_STATIC_BINARY_PATHS@").split(pathListSeparator, Qt::SkipEmptyParts);
#endif

QStringList PathManager::rawBinaryPaths_m;
QStringList PathManager::defaultBinaryPaths_m;

#if defined(TwxCore_TEST)
QStringList PathManager::messages_m;
#endif

void PathManager::setRawBinaryPaths(const QStringList &paths)
{
	rawBinaryPaths_m.clear();
	rawBinaryPaths_m.append(paths);
	Tw::Settings settings;
	settings.setValue(Key::binaryPaths, rawBinaryPaths_m);
}

void PathManager::resetDefaultBinaryPaths()
{
	Tw::Settings settings;
	if (settings.contains(Key::defaultBinaryPaths)) {
		auto value = settings.value(Key::defaultBinaryPaths).toString();
		auto defaultBinaryPaths = value.split(
			pathListSeparator,
			Qt::SkipEmptyParts
		);
		defaultBinaryPaths_m.swap(defaultBinaryPaths);
	} else if (settings.contains(Key::defaultbinpaths)) {
		auto value = settings.value(Key::defaultbinpaths).toString();
		auto defaultbinpaths = value.split(
			pathListSeparator,
			Qt::SkipEmptyParts
		);
		defaultBinaryPaths_m.swap(defaultbinpaths);
	} else {
		defaultBinaryPaths_m.clear();
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

bool PathManager::resetRawBinaryPaths(
  const QProcessEnvironment &env
) {
	rawBinaryPaths_m.clear();
	if (defaultBinaryPaths_m.empty()) {
		foreach (QString s, staticBinaryPaths) {
#if TwxCore_TEST
      // while testing, DEFAULT_BIN_PATHS needs to be portable
			// We do not know in advance existing directoris
			// except those in the source.
			// Replace any occurrence of "<<<pwd>>>" with the current working directory.
			auto before = QStringLiteral("<<<pwd>>>");
			auto after = QDir::currentPath();
			s.replace(before, after);
#endif
			if (!rawBinaryPaths_m.contains(s))
				rawBinaryPaths_m.append(s);
		}
	} else {
		rawBinaryPaths_m.append(defaultBinaryPaths_m);
	}
#if !defined(Q_OS_DARWIN) && !defined(TwxCore_TEST)
	// on OS X, this will be the path to {TW_APP_PACKAGE}/Contents/MacOS/
	// which doesn't make any sense as a search dir for TeX binaries
	// BUT it does make sense if we have to launch `TeXworks` with other
	// arguments.
	// TODO: TEXEDIT support for mac.
	auto path = QCoreApplication::applicationDirPath();
	QDir appDir(path);
	if (!binaryPaths_m.contains(appDir))
		binaryPaths_m.append(appDir);
#endif
  QString PATH = env.value(Key::PATH);
	if (!PATH.isEmpty()) {
		foreach (const QString& s, PATH.split(pathListSeparator, Qt::SkipEmptyParts)) {
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
		// All binary paths are properly expanded in getBinaryPaths().
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

const QStringList PathManager::getRawBinaryPaths(
  const QProcessEnvironment &env
) {
	if (rawBinaryPaths_m.empty()) {
  	Tw::Settings settings;
		if (settings.contains(Key::binaryPaths))
			rawBinaryPaths_m.append(
				settings.value(Key::binaryPaths).toStringList()
			);
		else
			resetRawBinaryPaths(env);
	}
	return rawBinaryPaths_m;
}

const QStringList PathManager::getBinaryPaths(
  QProcessEnvironment const& env
) {
	QStringList binPaths = getRawBinaryPaths(env);
	for (QString & path: binPaths) {
		path = stringByReplacingEnvironmentVariables(path, env);
	}
	auto PATH = env.value(Key::PATH);
	for (QString path : PATH.split(pathListSeparator, Qt::SkipEmptyParts)) {
		path = stringByReplacingEnvironmentVariables(path, env);
		if (!binPaths.contains(path)) {
			binPaths.append(path);
		}
	}
	return binPaths;
}

QString PathManager::programPath (
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
  for (auto path: getBinaryPaths(env)) {
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

} // namespace Core
} // namespace Twx
