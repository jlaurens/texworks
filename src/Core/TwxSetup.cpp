/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Jérôme Laurens

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
#include "Core/TwxSetup.h"

#include "Core/TwxConst.h"
#include "Core/TwxInfo.h"
#include "Core/TwxAssets.h"
#include "Core/TwxLocate.h"
#include "Core/TwxSettings.h"

namespace Twx {
namespace Core {

/*
PROBLEM: the TW_INIPATH and <app name>-setup.ini are in conflict.
*/
void Setup::initialize()
{
	// <Check for setup mode>
  QDir applicationDir = Locate::applicationDir();
	QDir iniDir(applicationDir);
	if (applicationDir.exists(Path::setup_ini)) {
		// this is very unlikely to happen on natural macOS usage
		// contrary to testing situations.
		Settings::setup(applicationDir.absoluteFilePath(Path::setup_ini));
		QSettings settings(applicationDir.filePath(Path::setup_ini), QSettings::IniFormat);
		Assets::setup(settings);
		Locate::setup(settings);
	}
	const auto PE = QProcessEnvironment::systemEnvironment();
	Settings::setup(PE);
	// QString envPath = PE.value(Key::TWX_SETUP_INI_PATH);
	// if (!envPath.isNull() && iniDir.cd(envPath)) {
	// 	QSettings::setDefaultFormat(QSettings::IniFormat);
	// 	QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, iniDir.absolutePath());
	// } else {
	// 	envPath = PE.value(QStringLiteral("TW_INIPATH"));
	// 	if (!envPath.isNull() && iniDir.cd(envPath)) {
	// 		QSettings::setDefaultFormat(QSettings::IniFormat);
	// 		QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, iniDir.absolutePath());
	// 	}
	// }
	Assets::setup(PE);
	// envPath = PE.value(QStringLiteral("TW_LIBPATH"));
	// if (!envPath.isNull() && applicationDir.cd(envPath)) {
	// 	Assets::setSetupLocation(applicationDir.absolutePath());
	// }
}

} // namespace Core
} // namespace Twx
