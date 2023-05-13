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

#include "TwxCoreTest.h"

#include "DefaultBinaryPaths.h"

#include "Core/TwxConst.h"
#include "Core/TwxInfo.h"
#include "Core/TwxSettings.h"
#include "Core/TwxPathManager.h"

namespace Twx {
namespace Core {
namespace Test {

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.TWX");
  QCoreApplication::setOrganizationDomain("TWX.tug.org");
  QCoreApplication::setApplicationName("You can trash me");
}

Main::~Main()
{
	Settings settings;
	QFile::remove(settings.fileName());
}

using PM = PathManager;

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
	PM::rawBinaryPaths().clear();
	PE_m = QProcessEnvironment();
	Settings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
	qDebug() << "===> CWD:" << QDir::currentPath();
}

void Main::cleanup()
{
}

void Main::testConst()
{
	QCOMPARE(pathListSeparator.length(), 1);
	QCOMPARE(Core::dot, QStringLiteral("."));

	QCOMPARE(Key::binaryPaths, QStringLiteral("binaryPaths"));
	QCOMPARE(Key::defaultbinpaths, QStringLiteral("defaultbinpaths"));
	QCOMPARE(Key::PATH, QStringLiteral("PATH"));
}

void Main::testPathManager_setRawBinaryPaths()
{
	QVERIFY(PM::rawBinaryPaths().empty());
	QStringList expected {
		QStringLiteral("//A"),
		QStringLiteral("//B"),
		QStringLiteral("//C")
	};
	PM::setRawBinaryPaths(expected);
	QCOMPARE(PM::rawBinaryPaths(), expected);
	Settings settings;
	QVERIFY(settings.contains(Key::binaryPaths));
  QVariant v = settings.value(Key::binaryPaths);
	QStringList actual = v.toStringList();
	QCOMPARE(actual, expected);
}

void Main::testPathManager_resetDefaultBinaryPaths()
{
}

void Main::testPathManager_resetRawBinaryPaths()
{
	PM::rawBinaryPaths().clear();
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
  PM::resetRawBinaryPaths(PE);
	QDir d = QDir::current();
	// All was made for d to contain directories A, B and C
  QStringList expected;
	expected
		<< d.absoluteFilePath("A")
		<< d.absoluteFilePath("B")
		<< d.absoluteFilePath("C");
  QCOMPARE(PM::rawBinaryPaths(), expected);
	PM::rawBinaryPaths().clear();
  PM::resetRawBinaryPaths(PE);
	QCOMPARE(PM::rawBinaryPaths(), expected);
}

void Main::testPathManager_getRawBinaryPaths()
{
	PM::rawBinaryPaths().clear();
	// rawBinaryPaths() already filled
	QStringList expected {
		QStringLiteral("ABC")
	};
	PM::rawBinaryPaths() << expected;
  auto paths = PM::getRawBinaryPaths();
	QCOMPARE(PM::rawBinaryPaths(), expected);
	// void rawBinaryPaths(), from settings
	expected << QStringLiteral("DEF");
	Settings settings;
	settings.setValue(Key::binaryPaths, expected);
	PM::rawBinaryPaths().clear();
  paths = PM::getRawBinaryPaths();
	QCOMPARE(PM::rawBinaryPaths(), expected);
	// Otherwise tested with resetRawBinaryPaths
}

void Main::testPathManager_getBinaryPaths()
{
	// No PATH
	auto dir = QCoreApplication::applicationDirPath();
  auto program = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
  QProcessEnvironment PE;
	PE.remove(Key::PATH);
	PE.insert(QStringLiteral("TWX_DUMMY"), dir);
  PM::rawBinaryPaths().clear();
#if defined(Q_OS_WIN)
	PM::rawBinaryPaths()
		<< QStringLiteral("%TWX_DUMMY%");
#else
	PM::rawBinaryPaths() << QStringLiteral("$TWX_DUMMY");
#endif
	QStringList actual = PM::getBinaryPaths(PE);
	QStringList expected {
		dir
	};
	QCOMPARE(actual, expected);
}

void Main::testPathManager_programPath_1()
{
	// We can rely on the test itself
	auto dir = QCoreApplication::applicationDirPath();
	auto expected = QCoreApplication::applicationFilePath();
  auto program = QFileInfo(expected).fileName();
	PM::rawBinaryPaths().clear();
	PM::rawBinaryPaths() << dir;
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
	auto actual = PM::programPath(program, PE);
	QCOMPARE(actual, expected);
	actual = PM::programPath(QString(), PE);
	QVERIFY(actual.isEmpty());
}

void Main::testPathManager_programPath_2()
{
	auto program = QStringLiteral("program");
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
	auto actual = PM::programPath(program, PE);
	auto d = QDir();
	QVERIFY(d.cd(QStringLiteral("A")));
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testPathManager_programPath_3()
{
	auto program = QStringLiteral("program.program");
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
	auto actual = PM::programPath(program, PE);
	auto d = QDir();
	QVERIFY(d.cd(QStringLiteral("A")));
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testInfo()
{
	QCOMPARE(Info::name(), QStringLiteral("TwxCoreTest"));
	QCOMPARE(Info::authors(), QString::fromUtf8("Ò∂ƒﬁ🥹"));
	QCOMPARE(Info::copyrightYears(), QString::fromUtf8("1234-5678"));
	QCOMPARE(Info::copyrightHolders(), QString::fromUtf8("æê®†\"Úºîœπ‡Ò∂\"ƒﬁÌÏÈ"));

	QCOMPARE(Info::versionMajor(), 1);
	QCOMPARE(Info::versionMinor(), 7);
	QCOMPARE(Info::versionPatch(), 8);
	QCOMPARE(Info::versionTweak(), 9);
}

} // namespace Test
} // namespace Core
} // namespace Twx

QTEST_MAIN(Twx::Core::Test::Main)
