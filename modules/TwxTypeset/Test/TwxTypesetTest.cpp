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

#include "TwxTypesetTest.h"
#include "TwxTypesetManager.h"

#include <QFileInfo>
#include <QDir>

namespace Twx {
namespace Typeset {

namespace Test {

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.TwxCore");
  QCoreApplication::setOrganizationDomain("TwxEngine.tug.org");
  QCoreApplication::setApplicationName("You can definitely trash me");
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

const QString empty;
const auto fileA = QStringLiteral("a");
const auto fileB = QStringLiteral("b");

void Main::test_empty()
{
	QVERIFY(Manager::getOwnerForRootFile(empty) == nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(empty));
	QVERIFY(Manager::getOwnerForRootFile(fileA) == nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileA));
	QVERIFY(Manager::getOwnerForRootFile(fileB) == nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileB));
}

void Main::test()
{
	QObject owner;

	QSignalSpy started(Manager::emitter(), &Manager::typesettingStarted);
	QSignalSpy stopped(Manager::emitter(), &Manager::typesettingStopped);

	QVERIFY(started.isValid());
	QVERIFY(stopped.isValid());

	// 2a) start process
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	QCOMPARE(Manager::test_count,0);
	QVERIFY(Manager::startTypesetting(fileA, &owner));
	QCOMPARE(Manager::test_count,0);
	QCOMPARE(started.count(), 1);
	QCOMPARE(started.takeFirst().at(0).toString(), fileA);
	QCOMPARE(stopped.count(), 0);

	// 2b) one process running
	QCOMPARE(Manager::getOwnerForRootFile(empty),nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(empty));
	QCOMPARE(Manager::getOwnerForRootFile(fileA), &owner);
	QVERIFY(Manager::isFileBeingTypeset(fileA));
	QVERIFY(Manager::getOwnerForRootFile(fileB) == nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileB));

	// 2c) Can't start again
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	QVERIFY(!Manager::startTypesetting(fileA, &owner));
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2d) Can't start with invalid file
	QVERIFY(!Manager::startTypesetting(empty, &owner));
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2e) Can't start with invalid window
	QVERIFY(!Manager::startTypesetting(fileB, nullptr));
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2f) still one process running
	QCOMPARE(Manager::getOwnerForRootFile(empty), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(empty));
	QCOMPARE(Manager::getOwnerForRootFile(fileA), &owner);
	QVERIFY(Manager::isFileBeingTypeset(fileA));
	QCOMPARE(Manager::getOwnerForRootFile(fileB), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileB));

	// 3a) Start second process but destroy window
	{
		QObject owner2;
		QCOMPARE(started.count(), 0);
		QCOMPARE(stopped.count(), 0);
		QVERIFY(Manager::startTypesetting(fileB, &owner2));
		QCOMPARE(started.count(), 1);
		QCOMPARE(started.takeFirst().at(0).toString(), fileB);
		QCOMPARE(stopped.count(), 0);

		// two processes running
		QCOMPARE(Manager::getOwnerForRootFile(empty), nullptr);
		QVERIFY(!Manager::isFileBeingTypeset(empty));
		QCOMPARE(Manager::getOwnerForRootFile(fileA), &owner);
		QVERIFY(Manager::isFileBeingTypeset(fileA));
		QCOMPARE(Manager::getOwnerForRootFile(fileB), &owner2);
		QVERIFY(Manager::isFileBeingTypeset(fileB));

		// 3b) destroying the typesetting window (at the end of the scope) should stop
		QCOMPARE(started.count(), 0);
		QCOMPARE(stopped.count(), 0);
	}
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 1);
	QCOMPARE(stopped.takeFirst().at(0).toString(), fileB);
	QCOMPARE(Manager::test_count,1);
	Manager::test_count = 0;

	// 3c) Start second process but destroy window
	{
		QObject owner2;
		QVERIFY(Manager::startTypesetting(fileB, &owner2));
		QCOMPARE(started.count(), 1);
		QCOMPARE(started.takeFirst().at(0).toString(), fileB);
		QCOMPARE(stopped.count(), 0);
		Manager::stopTypesetting(&owner2);
		QCOMPARE(started.count(), 0);
		QCOMPARE(stopped.count(), 1);
		QCOMPARE(stopped.takeFirst().at(0).toString(), fileB);
		QVERIFY(Manager::startTypesetting(fileB, &owner2));
		QCOMPARE(started.count(), 1);
		QCOMPARE(started.takeFirst().at(0).toString(), fileB);
		QCOMPARE(stopped.count(), 0);
	}
	QCOMPARE(Manager::test_count,1);
	Manager::test_count = 0;
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 1);
	QCOMPARE(stopped.takeFirst().at(0).toString(), fileB);

	// 3c) one process running
	QCOMPARE(Manager::getOwnerForRootFile(empty), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(empty));
	QCOMPARE(Manager::getOwnerForRootFile(fileA), &owner);
	QVERIFY(Manager::isFileBeingTypeset(fileA));
	QCOMPARE(Manager::getOwnerForRootFile(fileB), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileB));

	// 4a) stop process
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	Manager::stopTypesetting(&owner);
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 1);
	QCOMPARE(stopped.takeFirst().at(0).toString(), fileA);

	// 3b) no process running
	QCOMPARE(Manager::getOwnerForRootFile(empty), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(empty));
	QCOMPARE(Manager::getOwnerForRootFile(fileA), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileA));
	QCOMPARE(Manager::getOwnerForRootFile(fileB), nullptr);
	QVERIFY(!Manager::isFileBeingTypeset(fileB));
}

} // namespace Test
} // namespace Core
} // namespace Twx

QTEST_MAIN(Twx::Typeset::Test::Main)
