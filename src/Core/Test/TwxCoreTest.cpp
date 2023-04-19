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

#include "Core/TwxConst.h"
#include "Core/TwxPathManager.h"
#include "Settings.h"
#include "DefaultBinaryPaths.h"

#include <QDebug>
#include <QFile>

namespace Twx {
namespace Core {
namespace Test {

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.texworks");
  QCoreApplication::setOrganizationDomain("texworks.tug.org");
  QCoreApplication::setApplicationName("You can trash me");
}

Main::~Main()
{
	Tw::Settings settings;
	QFile::remove(settings.fileName());
}

using PM = PathManager;

void Main::initTestCase()
{
	QStandardPaths::setTestModeEnabled(true);
	PM::rawBinaryPaths_m.clear();
	PM::defaultBinaryPaths_m.clear();
	PE_m = QProcessEnvironment();
	Tw::Settings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
}

void Main::cleanupTestCase()
{
	QStandardPaths::setTestModeEnabled(false);
	Tw::Settings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
}

void Main::testConst()
{
	QCOMPARE(Core::pathListSeparator.length(), 1);
	QCOMPARE(Core::dot, QStringLiteral("."));

	QCOMPARE(Key::binaryPaths, QStringLiteral("binaryPaths"));
	QCOMPARE(Key::defaultbinpaths, QStringLiteral("defaultbinpaths"));
	QCOMPARE(Key::defaultBinaryPaths, QStringLiteral("defaultBinaryPaths"));
	QCOMPARE(Key::PATH, QStringLiteral("PATH"));
}

void Main::testPathManager_setRawBinaryPaths()
{
	PM::rawBinaryPaths_m.clear();
	QVERIFY(PM::rawBinaryPaths_m.empty());
	QStringList expected {
		QStringLiteral("//A"),
		QStringLiteral("//B"),
		QStringLiteral("//C")
	};
	PM::setRawBinaryPaths(expected);
	QCOMPARE(PM::rawBinaryPaths_m, expected);
	Tw::Settings settings;
	QVERIFY(settings.contains(Key::binaryPaths));
  QVariant v = settings.value(Key::binaryPaths);
	QStringList actual = v.toStringList();
	QCOMPARE(actual, expected);
}

void Main::testPathManager_resetDefaultBinaryPaths()
{
	PM::defaultBinaryPaths_m.clear();
	QStringList expected {
		QStringLiteral("A"),
		QStringLiteral("B"),
		QStringLiteral("C")
	};
	PM::defaultBinaryPaths_m << expected;
	QCOMPARE(PM::defaultBinaryPaths_m, expected);
  PM::resetDefaultBinaryPaths();
	QVERIFY(PM::defaultBinaryPaths_m.empty());
	Tw::Settings settings;
	expected = QStringList {
		QStringLiteral("//A"),
		QStringLiteral("//B"),
		QStringLiteral("//C")
	};
	settings.setValue(
		Key::defaultbinpaths,
		expected.join(pathListSeparator)
	);
	{
		Tw::Settings settings;
		QVERIFY(settings.contains(Key::defaultbinpaths));
		auto value = settings.value(Key::defaultbinpaths).toString();
		auto defaultBinaryPaths = value.split(
			pathListSeparator,
			Qt::SkipEmptyParts
		);
		QCOMPARE(defaultBinaryPaths, expected);
		PM::defaultBinaryPaths_m.swap(defaultBinaryPaths);
		QVERIFY(defaultBinaryPaths.empty());
		QCOMPARE(PM::defaultBinaryPaths_m, expected);
		PM::defaultBinaryPaths_m.clear();
		QVERIFY(PM::defaultBinaryPaths_m.empty());
	}
  PM::resetDefaultBinaryPaths();
	QCOMPARE(PM::defaultBinaryPaths_m, expected);
	settings.remove(Key::defaultbinpaths);
  PM::resetDefaultBinaryPaths();
	QVERIFY(PM::defaultBinaryPaths_m.empty());
	settings.setValue(
		Key::defaultBinaryPaths,
		expected.join(pathListSeparator)
	);
  PM::resetDefaultBinaryPaths();
	QCOMPARE(PM::defaultBinaryPaths_m, expected);
	settings.remove(Key::defaultBinaryPaths);
  PM::resetDefaultBinaryPaths();
	QVERIFY(PM::defaultBinaryPaths_m.empty());
}

void Main::testPathManager_resetRawBinaryPaths()
{
	PM::defaultBinaryPaths_m.clear();
	PM::rawBinaryPaths_m.clear();
	// with DefaultBinaryPaths.h
  QVERIFY(PM::defaultBinaryPaths_m.empty());
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
  PM::resetRawBinaryPaths(PE);
  QVERIFY(PM::defaultBinaryPaths_m.empty());
  QStringList expected;
	QDir d = QDir::current();
	// d is .../src/Core/Test/TestCase
	// It is expected to contain directories A, B and C
	expected
		<< d.absoluteFilePath("A")
		<< d.absoluteFilePath("B")
		<< d.absoluteFilePath("C");
	PM::defaultBinaryPaths_m.clear();
  QCOMPARE(PM::rawBinaryPaths_m, expected);
	// with defaultBinaryPaths_m
  PM::defaultBinaryPaths_m.clear();
	PM::rawBinaryPaths_m.clear();
	expected.clear();
	expected
		<< d.absoluteFilePath("C")
		<< d.absoluteFilePath("A")
		<< d.absoluteFilePath("B");
	PM::defaultBinaryPaths_m << expected;
	QCOMPARE(PM::defaultBinaryPaths_m, expected);
	PM::resetRawBinaryPaths(PE);
	QCOMPARE(PM::rawBinaryPaths_m, expected);
	// with PATH
	PM::rawBinaryPaths_m.clear();
	PM::defaultBinaryPaths_m.clear();
	expected.clear();
	expected << d.absoluteFilePath("C");
	PM::defaultBinaryPaths_m << d.absoluteFilePath("C");
	QStringList PATHs;
	PATHs 	 << d.absoluteFilePath("A");
	expected << d.absoluteFilePath("A");
	PATHs 	 << d.absoluteFilePath("B");
	expected << d.absoluteFilePath("B");
	// Redundant components are ignores
	PATHs 	 << d.absoluteFilePath("B");
	// No existing directories are ignored
	PATHs 	 << d.absoluteFilePath("NoDirectoryThere...");
	PE.insert(Key::PATH, PATHs.join(pathListSeparator));
	PM::resetRawBinaryPaths(PE);
	QCOMPARE(PM::rawBinaryPaths_m, expected);
	PE.remove(Key::PATH);
}

void Main::testPathManager_getRawBinaryPaths()
{
	PM::rawBinaryPaths_m.clear();
	// rawBinaryPaths_m already filled
	QStringList expected {
		QStringLiteral("ABC")
	};
	PM::rawBinaryPaths_m << expected;
  auto paths = PM::getRawBinaryPaths();
	QCOMPARE(PM::rawBinaryPaths_m, expected);
	// void rawBinaryPaths_m, from settings
	expected << QStringLiteral("DEF");
	Tw::Settings settings;
	settings.setValue(Key::binaryPaths, expected);
	PM::rawBinaryPaths_m.clear();
  paths = PM::getRawBinaryPaths();
	QCOMPARE(PM::rawBinaryPaths_m, expected);
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
  PM::rawBinaryPaths_m.clear();
#if defined(Q_OS_WIN)
	PM::rawBinaryPaths_m
		<< QStringLiteral("%TWX_DUMMY%");
#else
	PM::rawBinaryPaths_m << QStringLiteral("$TWX_DUMMY");
#endif
	QStringList actual = PM::getBinaryPaths(PE);
	QStringList expected {
		dir
	};
	QCOMPARE(actual, expected);
}

void Main::testPathManager_programPath()
{
	// The only executable we can rely on is the test itself
	auto dir = QCoreApplication::applicationDirPath();
	auto expected = QCoreApplication::applicationFilePath();
  auto program = QFileInfo(expected).fileName();
	PM::rawBinaryPaths_m.clear();
	PM::rawBinaryPaths_m << dir;
	QProcessEnvironment PE;
	PE.remove(Key::PATH);
	auto actual = PM::programPath(program, PE);
	QCOMPARE(actual, expected);
	actual = PM::programPath(QString(), PE);
	QVERIFY(actual.isEmpty());
}

} // namespace Test
} // namespace Core
} // namespace Twx

QTEST_MAIN(Twx::Core::Test::Main)
