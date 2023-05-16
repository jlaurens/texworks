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
#include "Core/TwxTool.h"
#include "Core/TwxAssetsTrackDB.h"
#include "Core/TwxInfo.h"
#include "Core/TwxSettings.h"
#include "Core/TwxPathManager.h"

namespace Twx {
namespace Core {

bool operator==(const Hash & h1, const Hash & h2)
{
	return h1.bytes == h2.bytes;
}
bool operator==(const Checksum & c1, const Checksum & c2)
{
	return c1.bytes == c2.bytes;
}
bool operator==(const AssetsTrack & r1, const AssetsTrack & r2)
{
	return r1.fileInfo.absolutePath() == r2.fileInfo.absolutePath()
		&& r1.version  == r2.version
		&& r1.checksum == r2.checksum
		&& r1.hash     == r2.hash;
}
bool operator==(const AssetsTrackDB & frdb1, const AssetsTrackDB & frdb2)
{
	return frdb1.getList() == frdb2.getList();
}
QDebug operator<< (QDebug d, const AssetsTrack &model) {
    d << Qt::endl << model.fileInfo.filePath()
		  << ":{" << model.version
		  << "," << model.checksum.bytes
		  << "," << model.hash.bytes 
		  << "}" << model.hash.bytes;
    return d;
}

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
}

void Main::cleanup()
{
}

void Main::testConst()
{
	QCOMPARE(Core::dot, QStringLiteral("."));

	QCOMPARE(Key::binaryPaths, QStringLiteral("binaryPaths"));
	QCOMPARE(Key::defaultbinpaths, QStringLiteral("defaultbinpaths"));
	QCOMPARE(Key::PATH, QStringLiteral("PATH"));
}

void Main::testTool()
{
	auto input = QStringLiteral("Whatever");
	auto input_hash =  md5Hash(input);
	QVERIFY(input_hash.bytes.length() > 0);
	auto dots = QStringLiteral("..........");
	auto empty = QStringLiteral("empty.txt");
	auto path = QStringLiteral("checksum.md");
  {
		auto actual = hashForFilePath(dots);
		auto expected = Hash();
		QCOMPARE(actual, expected);
		actual = hashForFilePath(empty);
		expected = Hash{"d41d8cd98f00b204e9800998ecf8427e"};
		QCOMPARE(actual, expected);
		actual = hashForFilePath(path);
		expected = Hash{"66f76eb1eaed0527a943a0e9e45d09e4"};
		QCOMPARE(actual, expected);
	}
  {
		auto actual = checksumForFilePath(dots);
		auto expected = Checksum();
		QCOMPARE(actual, expected);
		actual = checksumForFilePath(empty);
		expected = Checksum{"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"};
		QCOMPARE(actual, expected);
		actual = checksumForFilePath(path);
		expected = Checksum{"278660e88c824d3bfe581c0171547002e176855aad23179e3441efede0d32e7c"};
		QCOMPARE(actual, expected);
	}
}

using FRDB = AssetsTrackDB;

void Main::testAssetsTrackDB()
{
  QDir dir;
  QVERIFY(dir.cd(QStringLiteral("AssetsTrackDB")));
	QVERIFY(dir.cd(QStringLiteral("A")));
  auto frdb = AssetsTrackDB::load(dir);
	frdb.removeStorage();
	frdb = AssetsTrackDB::load(dir);
	QVERIFY(frdb.getList().empty());
	QVERIFY(frdb.save());
	frdb = AssetsTrackDB::load(dir);
	QVERIFY(frdb.getList().empty());
	auto path = QStringLiteral("1");
	auto fileInfo = QFileInfo(dir.absolutePath(), path);
	auto checksum = Checksum{"1789"};
	auto version = QStringLiteral("9871");
	frdb.add(fileInfo, version, checksum);
	QVERIFY(frdb.knows(fileInfo));
	auto record = frdb.get(fileInfo);
	QCOMPARE(record, (AssetsTrack{
		fileInfo,
		version,
		checksum,
		Hash{}
	}));
	QVERIFY(frdb.save());
	frdb = AssetsTrackDB::load(dir);
	QVERIFY(frdb.knows(fileInfo));
	record = frdb.get(fileInfo);
	QCOMPARE(record, (AssetsTrack{
		fileInfo,
		version,
		checksum,
		Hash{}
	}));
  version = QStringLiteral("1789");
	checksum = Checksum{"9871"};
	QCOMPARE(frdb.getList().size(), 1);
	frdb.add(fileInfo, version, checksum);
	QCOMPARE(frdb.getList().size(), 1);
	QVERIFY(frdb.knows(fileInfo));
	record = frdb.get(fileInfo);
	QCOMPARE(record, (AssetsTrack{
		fileInfo,
		version,
		checksum,
		Hash{}
	}));
}

void Main::testAssetsTrackDB_comparisons()
{
	auto fileInfo = QFileInfo(QStringLiteral("blablabla"));
	auto version  = QStringLiteral("9871");
	auto checksum = Checksum{"2023"};
	auto hash     = Hash{"1789"};

	AssetsTrack r1 = { fileInfo,    version,   checksum,     Hash{} };
	AssetsTrack r2 = { fileInfo,    version,   Checksum{},   hash   };
	AssetsTrack r3 = { fileInfo,    QString(), checksum,     hash   };
	AssetsTrack r4 = { QFileInfo(), version,   checksum,     hash   };

	QVERIFY(r1 == r1);
	QVERIFY(r2 == r2);
	QVERIFY(r3 == r3);
	QVERIFY(r4 == r4);

	QVERIFY(!(r1 == r2));
	QVERIFY(!(r1 == r3));
	QVERIFY(!(r1 == r4));
	QVERIFY(!(r2 == r3));
	QVERIFY(!(r2 == r4));
	QVERIFY(!(r3 == r4));
}

void Main::testAssetsTrackDB_add()
{
	AssetsTrackDB frdb((QDir()));
	QFileInfo fileInfo(QStringLiteral(".........."));
	AssetsTrack empty;
	AssetsTrack r1 =    { fileInfo,    QStringLiteral("v1"), Checksum{}, Hash{}};
	AssetsTrack r2 =    { fileInfo,    QString(), Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"}};

	QVERIFY (frdb.knows(r1.fileInfo) == false);
	QCOMPARE(frdb.get(r1.fileInfo), empty);
	QCOMPARE(frdb.getList(), QList<AssetsTrack>());
	frdb.add(r1.fileInfo, r1.version, r1.checksum, r1.hash);
	QVERIFY(frdb.knows(r1.fileInfo));
	QCOMPARE(frdb.get(r1.fileInfo), r1);
	QCOMPARE(frdb.getList(), QList<AssetsTrack>{r1});
	frdb.add(r2.fileInfo, r2.version, r2.checksum, r2.hash);
	QVERIFY(frdb.knows(r2.fileInfo));
	QCOMPARE(frdb.get(r2.fileInfo), r2);
	QCOMPARE(frdb.getList(), QList<AssetsTrack>{r2});
}

void Main::testAssetsTrackDB_load()
{
	QCOMPARE(AssetsTrackDB::load(QStringLiteral("does-not-exist")).getList(), QList<AssetsTrack>());

	AssetsTrackDB frdb((QDir()));
	frdb.add(QFileInfo(QStringLiteral("/spaces test.tex")), QStringLiteral("v1"),  Checksum{}, Hash{"d41d8cd98f00b204e9800998ecf8427e"});
	frdb.add(QFileInfo(QStringLiteral("base14-fonts.pdf")), QStringLiteral("4.2"), Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"});

	QCOMPARE(AssetsTrackDB::load_legacy(QStringLiteral("fileversion.db")), frdb);

	// QEXPECT_FAIL("", "Invalid file version databases are not recognized", Continue);
	QCOMPARE(AssetsTrackDB::load(QStringLiteral("script.js")), AssetsTrackDB(QDir()));
}

void Main::testAssetsTrackDB_save()
{
	AssetsTrackDB frdb((QDir()));
	frdb.add(QFileInfo(QStringLiteral("/spaces test.tex")), QStringLiteral("v1"), Checksum{}, Hash{"d41d8cd98f00b204e9800998ecf8427e"});
	frdb.add(QFileInfo(QStringLiteral("base14-fonts.pdf")), QStringLiteral("4.2"), Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"});

	QVERIFY(frdb.save(QStringLiteral("does/not/exist.frdb")) == false);

	QTemporaryFile tmpFile;
	tmpFile.open();
	tmpFile.close();
	QVERIFY(frdb.save_legacy(tmpFile.fileName()));
	QCOMPARE(AssetsTrackDB::load_legacy(tmpFile.fileName()), frdb);
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
