/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2020  Stefan Löffler

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
#include "TwxSettings.h"

#include "TwxConst.h"
#include "TwxInfo.h"
#include "TwxLocate.h"

#include <QSettings>
#include <QProcessEnvironment>

namespace Twx {
namespace Core {

static bool setup(const QFileInfo & fileInfo)
{
	Q_ASSERT(fileInfo.isAbsolute());
	if (fileInfo.exists() ) {
		QSettings::setDefaultFormat(QSettings::IniFormat);
		QSettings::setPath(
			QSettings::IniFormat,
			QSettings::UserScope,
			fileInfo.absoluteFilePath()
		);
		return true;
	}
	return false;
}

/** \brief setup de settings state
 	*
 	*	This is where relative path are resolved
 	*	\param fileInfo is a `QFileInfo` instance, absolute or relative
  * \param dir is a `QDir` instance, ignored when not absolute
	* \param mustExist similar to other method/function
	*/
static bool setup_1(
	const QString & path,
	const QDir & dir,
	bool mustExist
)
{
	auto resolved = Locate::resolve(path, dir, mustExist);
	if (resolved.success) {
		return setup(resolved.fileInfo) || mustExist;
	}
	return false;
}

void Settings::setup(const QString & setup_ini_path, bool mustExist)
{
	QSettings settings(setup_ini_path, QSettings::IniFormat);
	QDir dir = QFileInfo(setup_ini_path).absoluteDir();
	setup_1(
		settings.value(Key::settings_ini, mustExist).toString(),
		dir,
		mustExist
	) ||
	setup_1(
		settings.value(Key::inipath, mustExist).toString(),
		dir,
		mustExist
	);
}

void Settings::setup(const QProcessEnvironment & PE)
{
	QDir dir = Locate::applicationDir();
	QString path = PE.value(Env::TWX_SETTINGS_INI_PATH);
	if (path.isNull()) {
		path = PE.value(Env::TW_INIPATH);
		if (path.isNull()) {
			return;
		}
	}
	setup_1(path, dir, true);
}

Settings::Settings(
	const QString &fileName,
	QSettings::Format format,
	QObject *parent): QSettings(fileName, format, parent)
{}

bool Settings::hasListPATH()
{
	return (contains(Key::PATH) || contains(Key::binaryPaths)) && !listPATH().isEmpty();
}

QStringList Settings::listPATH()
{
	return contains(Key::PATH)
		? value(Key::PATH).toStringList()
		: value(Key::binaryPaths).toStringList();
}

void Settings::setListPATH(QStringList listPATH)
{
	listPATH.removeAll(QString());
	if (listPATH.empty()) {
		remove(Key::PATH);
		remove(Key::binaryPaths);
	} else {
		setValue(Key::PATH, listPATH);
		setValue(Key::binaryPaths, listPATH);
	}
}

bool Settings::hasAssetsLibraryLocation()
{
	return !assetsLibraryLocation().isEmpty();
}

QString Settings::assetsLibraryLocation()
{
	QString path = value(Key::assets_library_location).toString();
	if (path.isEmpty()) {
		path = value(Key::libpath).toString();
		if (path.isEmpty()) {
			return path;
		}
	}
	auto resolved = Locate::resolve(path, QDir(), true);
	if (resolved.success) {
		return resolved.fileInfo.absoluteFilePath();
	}
	return QString();
}

void Settings::setAssetsLibraryLocation(const QString & path)
{
	if (path.isEmpty()) {
		remove(Key::assets_library_location);
		remove(Key::libpath);
	} else {
		setValue(Key::assets_library_location, path);
		setValue(Key::libpath, path);
	}
}

} // namespace Core
} // namespace Twx
