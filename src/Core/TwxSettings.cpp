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
#include "Core/TwxSettings.h"

#include "Core/TwxConst.h"
#include "Core/TwxInfo.h"
#include "Core/TwxLocate.h"

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

} // namespace Core
} // namespace Twx
