/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Stefan Löffler, Jérôme Laurens

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

#include "TwxCoreLibTest.h"

#include <TwxAssets.h>
#include <TwxAssetsTrackDB.h>
#include <TwxConst.h>
#include <TwxInfo.h>
#include <TwxLocate.h>
#include <TwxSettings.h>
#include <TwxSetup.h>
#include <TwxTool.h>

#include <QFileInfo>
#include <QDir>
#include <QUuid>

namespace Twx {
namespace Test {

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.TwxUtilLib");
  QCoreApplication::setOrganizationDomain("TwxUtilLib.tug.org");
  QCoreApplication::setApplicationName("You can definitely trash me (TwxUtilLib)");
}

Main::~Main()
{
}

void Main::initTestCase()
{
	QStandardPaths::setTestModeEnabled(true);
}

void Main::cleanupTestCase()
{
	QStandardPaths::setTestModeEnabled(false);
}

void Main::init()
{
}

void Main::cleanup()
{
}

void Main::test()
{
}

} // namespace Test
} // namespace Twx

QTEST_MAIN(Twx::Test::Main)
