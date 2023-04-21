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

#include <QDebug>
#include <QFile>

namespace Twx {
namespace Typeset {

using TM = Manager;

namespace Test {

void Main::testConnection()
{
	auto fileA = QStringLiteral("a");
	auto fileB = QStringLiteral("b");
	TM::test_count = 0;
	{
		QObject owner;
		QVERIFY(TM::startTypesetting(fileA, &owner));
		// There is a listener to ~owner()
		TM::stopTypesetting(&owner);
		// No more listener
	}
	// On destruction, TM::test_count is not incremented
	QCOMPARE(TM::test_count, 0);
	{
		QObject owner;
		QVERIFY(TM::startTypesetting(fileA, &owner));
		TM::stopTypesetting(&owner);
		QVERIFY(TM::startTypesetting(fileA, &owner));
		TM::stopTypesetting(&owner);
	}
	// idem twice
	QCOMPARE(TM::test_count, 0);
	TM::test_count = 0;
	{
		QObject owner;
		QVERIFY(TM::startTypesetting(fileA, &owner));
		// There is a listener of ~owner()
	}
	// On destruction of owner, test_count is incremented by 1
	QCOMPARE(TM::test_count, 1);
	TM::test_count = 0;
	{
		QObject owner;
		QVERIFY(TM::startTypesetting(fileA, &owner));
	  // There is a listener of ~owner()
		QVERIFY(TM::startTypesetting(fileB, &owner));
	  // There is no more listener
	}
	// On destruction of owner, test_count is incremented by 1
	QCOMPARE(TM::test_count, 1);
}

void Main::testTypesetManager()
{
	QString empty;
	QString fileA{QStringLiteral("a")};
	QString fileB{QStringLiteral("b")};
	QObject owner;
#if QT_VERSION < QT_VERSION_CHECK(5, 4, 0)
	QSignalSpy started(TM::emitter(), SIGNAL(typesettingStarted(QString)));
	QSignalSpy stopped(TM::emitter(), SIGNAL(typesettingStopped(QString)));
#else
	QSignalSpy started(TM::emitter(), &TM::typesettingStarted);
	QSignalSpy stopped(TM::emitter(), &TM::typesettingStopped);
#endif

	QVERIFY(started.isValid());
	QVERIFY(stopped.isValid());

	// 1) no process running
	QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(empty), false);
	QVERIFY(TM::getOwnerForRootFile(fileA) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileA), false);
	QVERIFY(TM::getOwnerForRootFile(fileB) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileB), false);

	// 2a) start process
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	QCOMPARE(TM::startTypesetting(fileA, &owner), true);
	QCOMPARE(started.count(), 1);
	QCOMPARE(started.takeFirst().at(0).toString(), fileA);
	QCOMPARE(stopped.count(), 0);

	// 2b) one process running
	QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(empty), false);
	QVERIFY(TM::getOwnerForRootFile(fileA) == &owner);
	QCOMPARE(TM::isFileBeingTypeset(fileA), true);
	QVERIFY(TM::getOwnerForRootFile(fileB) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileB), false);

	// 2c) Can't start again
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	QCOMPARE(TM::startTypesetting(fileA, &owner), false);
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2d) Can't start with invalid file
	QCOMPARE(TM::startTypesetting(empty, &owner), false);
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2e) Can't start with invalid window
	QCOMPARE(TM::startTypesetting(fileB, nullptr), false);
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);

	// 2f) still one process running
	QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(empty), false);
	QVERIFY(TM::getOwnerForRootFile(fileA) == &owner);
	QCOMPARE(TM::isFileBeingTypeset(fileA), true);
	QVERIFY(TM::getOwnerForRootFile(fileB) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileB), false);

	// 3a) Start second process but destroy window
	{
		QObject owner2;
		QCOMPARE(started.count(), 0);
		QCOMPARE(stopped.count(), 0);
		QCOMPARE(TM::startTypesetting(fileB, &owner2), true);
		QCOMPARE(started.count(), 1);
		QCOMPARE(started.takeFirst().at(0).toString(), fileB);
		QCOMPARE(stopped.count(), 0);

		// two processes running
		QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
		QCOMPARE(TM::isFileBeingTypeset(empty), false);
		QVERIFY(TM::getOwnerForRootFile(fileA) == &owner);
		QCOMPARE(TM::isFileBeingTypeset(fileA), true);
		QVERIFY(TM::getOwnerForRootFile(fileB) == &owner2);
		QCOMPARE(TM::isFileBeingTypeset(fileB), true);

		// 3b) destroying the typesetting window (at the end of the scope) should stop
		QCOMPARE(started.count(), 0);
		QCOMPARE(stopped.count(), 0);
	}
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 1);
	QCOMPARE(stopped.takeFirst().at(0).toString(), fileB);

	// 3c) one process running
	QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(empty), false);
	QVERIFY(TM::getOwnerForRootFile(fileA) == &owner);
	QCOMPARE(TM::isFileBeingTypeset(fileA), true);
	QVERIFY(TM::getOwnerForRootFile(fileB) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileB), false);

	// 4a) stop process
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 0);
	TM::stopTypesetting(&owner);
	QCOMPARE(started.count(), 0);
	QCOMPARE(stopped.count(), 1);
	QCOMPARE(stopped.takeFirst().at(0).toString(), fileA);

	// 3b) no process running
	QVERIFY(TM::getOwnerForRootFile(empty) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(empty), false);
	QVERIFY(TM::getOwnerForRootFile(fileA) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileA), false);
	QVERIFY(TM::getOwnerForRootFile(fileB) == nullptr);
	QCOMPARE(TM::isFileBeingTypeset(fileB), false);
}

} // namespace Test
} // namespace Engine
} // namespace Twx

QTEST_MAIN(Twx::Typeset::Test::Main)
