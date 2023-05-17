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

#include "Core/TwxInfo.h"
#include "Core/TwxAssetsLookup.h"
#include "Core/TwxPathManager.h"
#include "Core/TwxSettings.h"

namespace Twx {
namespace Core {

namespace P {
	static const QString setup   = QStringLiteral("%1-setup.ini").arg(Info::name.toLower());
}
namespace K {
	static const QString inipath = QStringLiteral("inipath");
}
/*
PROBLEM: the TW_INIPATH and <app name>-setup.ini are in conflict.
*/
void Setup::initialize()
{
	// <Check for setup mode>
  QDir appDir = PathManager::getApplicationDir();
	QDir iniDir(appDir);
	if (appDir.exists(P::setup)) {
		// this is very unlikely to happen on natural macOS usage
		// contrary to testing situations.
		QSettings setupSettings(appDir.filePath(P::setup), QSettings::IniFormat);
		if (setupSettings.contains(K::inipath)) {
			if (iniDir.cd(setupSettings.value(K::inipath).toString())) {
				QSettings::setDefaultFormat(QSettings::IniFormat);
				QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, iniDir.absolutePath());
			}
		}
		AssetsLookup::setup(setupSettings);
		PathManager::setup(setupSettings);
	}
	QString envPath = QString::fromLocal8Bit(getenv("TW_INIPATH"));
	if (!envPath.isNull() && iniDir.cd(envPath)) {
		QSettings::setDefaultFormat(QSettings::IniFormat);
		QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, iniDir.absolutePath());
	}
	envPath = QString::fromLocal8Bit(getenv("TW_LIBPATH"));
	if (!envPath.isNull() && appDir.cd(envPath)) {
		AssetsLookup::setSetupLocation(appDir.absolutePath());
	}
}

} // namespace Core
} // namespace Twx
