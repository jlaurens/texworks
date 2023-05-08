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

#include "Core/TwxConst.h"
#include "Core/TwxSettings.h"
using Settings = Twx::Core::Settings;

#include "Typeset/TwxEngine.h"
#include "Typeset/TwxEngineManager.h"
#include "Typeset/TwxTypesetManager.h"

#include "Core/TwxPathManager.h"
using PathManager = Twx::Core::PathManager;

#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>

namespace Twx {
namespace Typeset {

using TM = Manager;
using EM = EngineManager;

namespace Test {

static   QList<Engine> __EngineList;

Main::Main(): QObject()
{
	QCoreApplication::setOrganizationName("org.tug.TWX");
  QCoreApplication::setOrganizationDomain("TWX.tug.org");
  QCoreApplication::setApplicationName("You can trash me");
}

void Main::feedEngineList()
{
	__EngineList.clear();
	QFile file(EM::saveLocation(EM::saveComponent));
	QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
	QString json = file.readAll();
	file.close();
  auto d = QJsonDocument::fromJson(json.toUtf8());
	QVERIFY(d.isObject());
	auto engines = d.object()[Core::Key::__data].toArray();
  for (const auto &engine: engines) {
		QVERIFY(d.isObject());
		auto o = engine.toObject();
		QString name = o[Key::name].toString();
		QString program = o[Key::program].toString();
		QStringList arguments;
		for (const auto argument: o[Key::arguments].toArray()) {
			arguments << argument.toString();
		}
		bool showPdf = o[Key::showPdf].toBool();
	 	__EngineList << Engine(name, program, arguments, showPdf);
	}
}

Main::~Main()
{
	Settings settings;
	QFile::remove(settings.fileName());
}

void Main::initTestCase()
{
	QStandardPaths::setTestModeEnabled(true);
	Settings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
}

void Main::cleanupTestCase()
{
	QStandardPaths::setTestModeEnabled(false);
}

void Main::init()
{
	EM::rawEngineList().clear();
}

void Main::cleanup()
{
	Settings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
	QFile::remove(EM::saveLocation(QStringLiteral("engines.ini")));
	QFile::remove(EM::saveLocation(EM::saveComponent));
}

void Main::test_Settings()
{
	Settings settings;
	auto K = QStringLiteral("DUMMY KEY");
	auto V = QStringLiteral("DUMMY VALUE");
	settings.setValue(K, V);
	QCOMPARE(V,settings.value(K).toString());
}

void Main::test_Engine_json()
{
	Engine expected{
		QStringLiteral("NAME"),
		QStringLiteral("PROGRAM"),
		QStringList{
			QStringLiteral("ARGUMENT1"),
			QStringLiteral("ARGUMENT2"),
		},
		true
	};
	Engine actual{expected.toJsonObject()};
	QCOMPARE(actual, expected);
	QCOMPARE(actual.name(),QStringLiteral("NAME"));
	QCOMPARE(actual.program(),QStringLiteral("PROGRAM"));
	QCOMPARE(actual.arguments(),(QStringList{
		QStringLiteral("ARGUMENT1"),
		QStringLiteral("ARGUMENT2"),
	}));
	QCOMPARE(actual.showPdf(),true);
}

void Main::test_Engine()
{
	Engine engine;
	QCOMPARE(engine.name(), QString());
	QCOMPARE(engine.program(), QString());
	QCOMPARE(engine.arguments(), QStringList());
	QVERIFY(!engine.showPdf());
	QString ABCD = QStringLiteral("ABCD");
  engine.setName(ABCD);
	QCOMPARE(engine.name(), ABCD);
	QString EFGH = QStringLiteral("EFGH");
  engine.setProgram(EFGH);
	QCOMPARE(engine.program(), EFGH);
	QStringList arguments{
		QStringLiteral("one"),
		QStringLiteral("two")
	};
  engine.setArguments(arguments);
	QCOMPARE(engine.arguments(), arguments);
	engine.setShowPdf( true );
	QVERIFY(engine.showPdf());
	Engine copy = engine;
	QCOMPARE(copy.name(), ABCD);
	QCOMPARE(copy.program(), EFGH);
	QCOMPARE(copy.arguments(), arguments);
	QVERIFY(copy.showPdf());

	QVERIFY(!engine.isAvailable());

	auto dir = QDir();
	qDebug () << "dir" << dir.absolutePath();
#if defined(Q_OS_WINDOWS)
	QString program = dir.absoluteFilePath("engine_TwxTypeset.exe");
#else
	QString program = dir.absoluteFilePath("engine_TwxTypeset");
#endif
	engine.setProgram(program);
	QVERIFY(engine.isAvailable());
	QFileInfo FI;
	QProcess * P = engine.run(FI);
	P->waitForFinished(10000);
	auto output = QString(P->readAllStandardOutput());
	auto re = QRegularExpression(
		QStringLiteral(
			"<argc>(?'argc'.*?)<argc/>.*?"
			"<argv_1>(?'argv_1'.*?)<argv_1/>.*?"
			"<argv_2>(?'argv_2'.*?)<argv_2/>"
		)
	);
	auto match = re.match(output);
	QString argc = match.captured(QStringLiteral("argc"));
	QCOMPARE(argc, QStringLiteral("3"));
	QString argv_1 = match.captured(QStringLiteral("argv_1"));
	QCOMPARE(argv_1, QStringLiteral("one"));
	QString argv_2 = match.captured(QStringLiteral("argv_2"));
	QCOMPARE(argv_2, QStringLiteral("two"));
	delete(P);
}

Engine Main::makeEngine(const char * key, bool showPdf)
{
	const QString k = QString::fromUtf8(key);
	return Engine(
		QStringLiteral("NAME_").append(k),
		QStringLiteral("PROGRAM_").append(k),
		QStringList{
			QStringLiteral("ARGUMENT_1_").append(k),
			QStringLiteral("ARGUMENT_2_").append(k),
		},
		showPdf
	);
}

void Main::test_EngineManager_rawEngineList()
{
	EM::rawEngineList().clear();
	Engine::List list{ makeEngine() };
	EM::rawEngineList() << list[0];
	QCOMPARE(list, EM::getEngineList());
}

void Main::test_EngineManager_savedEngineList()
{
	// savedEngineList is empty
	auto savedEngineList = EM::savedEngineList();
	QVERIFY(savedEngineList.empty());
	EM::rawEngineList().clear();
	QCOMPARE(Engine::factoryEngineList(), EM::getEngineList());
	// This engine list is the factory one
	Engine::List list {
		makeEngine("A"),
		makeEngine("B"),
		makeEngine("C")
	};
	EM::rawEngineList().clear();
	EM::rawEngineList() << list;
	EM::saveEngineList();
	QCOMPARE(EM::savedEngineList(), list);
	EM::rawEngineList().clear();
	QVERIFY(!EM::savedEngineList().empty());
	EM::restoreEngineList();
	QCOMPARE(EM::savedEngineList(), EM::getEngineList());
	EM::rawEngineList().clear();
	QCOMPARE(EM::savedEngineList(), EM::getEngineList());
}

void Main::test_EngineManager_getEngineList()
{
	// savedEngineList is empty
	auto savedEngineList = EM::savedEngineList();
	QVERIFY(savedEngineList.empty());
	EM::rawEngineList().clear();
	QCOMPARE(Engine::factoryEngineList(), EM::getEngineList());
	// This engine list is the factory one
	Engine::List list {
		makeEngine("A"),
		makeEngine("B"),
		makeEngine("C")
	};
	EM::rawEngineList().clear();
	EM::rawEngineList() << list;
	EM::saveEngineList();
	QCOMPARE(EM::savedEngineList(), list);
	EM::rawEngineList().clear();
	QVERIFY(!EM::savedEngineList().empty());
	EM::restoreEngineList();
	QCOMPARE(EM::savedEngineList(), EM::getEngineList());
	EM::rawEngineList().clear();
	QCOMPARE(EM::savedEngineList(), EM::getEngineList());
}

void Main::test_EngineManager_setEngineList()
{
	Engine::List list {
		makeEngine("A"),
		makeEngine("B"),
		makeEngine("C")
	};
	EM::rawEngineList().clear();
	QVERIFY(EM::rawEngineList().empty());
	QVERIFY(EM::setEngineList(list));
	QCOMPARE(list, EM::getEngineList());
	// So far so good
	list << makeEngine("B");
	// now list contains two engines named after "B"
	EM::rawEngineList().clear();
	QVERIFY(EM::rawEngineList().empty());
	// `setEngineList` returns false due to the duplicate
	QVERIFY(!EM::setEngineList(list));
	QVERIFY(list != EM::getEngineList());
	// We can append the missing engine by hand
	EM::rawEngineList() << makeEngine("B");
	QCOMPARE(list, EM::getEngineList());
	EM::rawEngineList().clear();
}

void Main::test_EngineManager_getEngineWithName()
{
	EM::rawEngineList().clear();
	EM::rawEngineList()
		<< makeEngine("A") << makeEngine("B") << makeEngine("C");
	QStringList names {
		QStringLiteral("NAME_A"),
		QStringLiteral("NAME_B"),
		QStringLiteral("NAME_C"),
	};
	for (const auto& name: names) {
		auto const engine = EM::getEngineWithName(name);
		QCOMPARE(engine.name(), name);
	}
	auto const engine = EM::getEngineWithName(QStringLiteral("???"));
  QVERIFY(!engine.isValid());
}

void Main::test_EngineManager_defaultEngineName()
{
	const auto nullString = QStringLiteral("");
	QCOMPARE(EM::getDefaultEngineName(), nullString);
	QCOMPARE(EM::getSettingsEngineName(), Engine::factoryEngineName);
	const auto NAME = QStringLiteral("NAME");
  EM::setDefaultEngineName(NAME);
	QCOMPARE(EM::getDefaultEngineName(), NAME);
	Settings settings;
	auto actual = settings.value(Key::defaultEngineName).toString();
	QCOMPARE(NAME, actual);
	// Revert to the original state
  EM::setDefaultEngineName(nullString);
	settings.remove(Key::defaultEngineName);
	QCOMPARE(EM::getDefaultEngineName(), nullString);
	QCOMPARE(EM::getSettingsEngineName(), Engine::factoryEngineName);
}

void Main::test_EngineManager_defaultEngine()
{
	// If we change the engine list,
	// what happens to the default engine?
  // ## With no saved engine list: factory defaults
	QVERIFY(!Engine::factoryEngineList().empty());
	auto engine = EM::getDefaultEngine();
	// engine is one of the `factoryEngineList()`
	// Here we assume that `factoryEngineName` is the name
	// of a project in `factoryEngineList()`.
	QCOMPARE(EM::getEngineList(), Engine::factoryEngineList());
	QVERIFY(Engine::factoryEngineList().contains(engine));
	QVERIFY(EM::rawEngineList().contains(engine));
  EM::rawEngineList().removeOne(engine);
	QVERIFY(EM::getEngineList() != Engine::factoryEngineList());
	// The list no longer contains the engine
	QVERIFY(!EM::rawEngineList().contains(engine));
	// a new one must be computed
	engine = EM::getDefaultEngine();
	QVERIFY(EM::rawEngineList().contains(engine));
	// ## custom names
	Engine::List list {
		makeEngine("A"),
		makeEngine("B"),
		makeEngine("C")
	};
	EM::rawEngineList().clear();
	EM::rawEngineList() << list;
	EM::setDefaultEngineName(QStringLiteral("WHATEVER"));
	// There is no engine with that name
	// fall down on the first one
	QCOMPARE(EM::getDefaultEngine(), makeEngine("A"));
	QCOMPARE(EM::getDefaultEngineName(), QStringLiteral("NAME_A"));
  // Now we add a project with the factory default name
	EM::setDefaultEngineName(QStringLiteral("WHATEVER"));
	auto expected = makeEngine();
	expected.setName(Engine::factoryEngineName);
	EM::rawEngineList() << expected << makeEngine("D");
	engine = EM::getDefaultEngine();
	QCOMPARE(engine, expected);
	QCOMPARE(EM::getDefaultEngineName(), expected.name());
}

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
