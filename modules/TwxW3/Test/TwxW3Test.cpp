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

#include "TwxW3Test.h"

#include "TwxW3.h"

namespace Twx {

namespace Test {

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.TwxW3");
  QCoreApplication::setOrganizationDomain("TwxW3.tug.org");
  QCoreApplication::setApplicationName("You can definitely trash me (TwxW3)");
}

Main::~Main()
{
	QSettings settings;
	QFile::remove(settings.fileName());
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
	QStandardPaths::setTestModeEnabled(true);
}

void Main::cleanup()
{
	QStandardPaths::setTestModeEnabled(false);
/*!void QStandardPaths::setTestModeEnabled(bool testMode)
If testMode is true, this enables a special "test mode" in QStandardPaths, which changes writable locations to point to test directories. This prevents auto tests from reading or writing to the current user's configuration.
It affects the locations into which test programs might write files: GenericDataLocation, DataLocation, ConfigLocation, GenericConfigLocation, AppConfigLocation, GenericCacheLocation, and CacheLocation. Other locations are not affected.
On Unix, XDG_DATA_HOME is set to ~/.qttest/share, XDG_CONFIG_HOME is set to ~/.qttest/config, and XDG_CACHE_HOME is set to ~/.qttest/cache.
On macOS, data goes to ~/.qttest/Application Support, cache goes to ~/.qttest/Cache, and config goes to ~/.qttest/Preferences.
On Windows, everything goes to a "qttest" directory under %APPDATA%.
[static]
*/
#if defined(Q_OS_UNIX)
  // remove the whole ~/.qttest folder
  // On Unix, XDG_DATA_HOME is set to ~/.qttest/share, XDG_CONFIG_HOME is set to ~/.qttest/config, and XDG_CACHE_HOME is set to ~/.qttest/cache.
	// On macOS, data goes to ~/.qttest/Application Support, cache goes to ~/.qttest/Cache, and config goes to ~/.qttest/Preferences.
	QDir d = QDir::home().absoluteFilePath(QStringLiteral(".qttest"));
	QVERIFY(d.removeRecursively());
#else
	// remove the whole "qttest" directory under %APPDATA%
	QDir d = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
	QVERIFY(d.removeRecursively());
#endif
}

void Main::test_URL()
{
	QVERIFY(!W3::mail_address.isEmpty());
	for (const auto & url: QList<QUrl>{
		W3::URL::home,
		W3::URL::homeDev,
		W3::URL::issues
	}) {
		QVERIFY(!url.toString().isEmpty());
	}
}

void Main::test_openUrl_A()
{
#if !defined(TwxW3_TEST_NO_OpenUrl)
	auto path = QDir::current().absoluteFilePath(QStringLiteral("index_A.html"));
	auto url = QUrl::fromLocalFile(path);
	QVERIFY(Twx::W3::openUrl(url));
#endif	
}

void Main::test_openUrl_B()
{
#if !defined(TwxW3_TEST_NO_OpenUrl)
	auto path = QDir::current().absoluteFilePath(QStringLiteral("index_B.html"));
	auto url = QUrl::fromLocalFile(path);
	Twx::W3::gui_mode = false;
	QVERIFY(!Twx::W3::openUrl(url));
#endif	
}

} // namespace Test
} // namespace Twx

QTEST_MAIN(Twx::Test::Main)
