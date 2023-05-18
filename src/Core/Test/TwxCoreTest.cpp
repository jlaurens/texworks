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
#include "Core/TwxInfo.h"
#include "Core/TwxLocate.h"
#include "Core/TwxAssetsTrackDB.h"
#include "Core/TwxAssets.h"
#include "Core/TwxSettings.h"

#include <QFileInfo>
#include <QDir>

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
	Locate::rawBinaryPaths_m.clear();
	PE_m = QProcessEnvironment();
	QSettings settings;
	for (auto key: settings.allKeys()) {
		settings.remove(key);
	}
	Assets::setupLocation_m    = QString();
	Assets::factoryDir_m       = QDir("Assets/factoryDir/");
	Assets::legacyLocation_m   = QDir("Assets/legacyLocation/").absolutePath();
	Assets::standardLocation_m = QDir("Assets/AppDataLocation/").absolutePath();
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
	// rempove the whole "qttest" directory under %APPDATA%
	QDir d = QDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
	QVERIFY(d.removeRecursively());
#endif
}

void Main::testConst()
{
	QCOMPARE(Path::dot, ".");

	QCOMPARE(Key::binaryPaths, "binaryPaths");
	QCOMPARE(Key::defaultbinpaths, "defaultbinpaths");
	QCOMPARE(Env::PATH, "PATH");
	for (const auto & s: QStringList{
		Path::dot,
		Path::applicationImage,
		Path::applicationImage128,
		Path::setup_ini,
		Key::__data,
		Key:: __status,
		Key::__type,
		Key::__version,
		Env::PATH,
		Key::binaryPaths,
		Key::defaultbinpaths,
		Key::configuration,
		Key::completion,
		Key::templates,
		Key::scripts,
		Key::dictionaries,
		Key::libpath,
		Key::inipath,
		Key::settings_ini,
		Key::translations,
		Env::TWX_DICTIONARY_PATH,
		Env::TW_DICPATH,
		Env::TWX_SETUP_INI_PATH,
		Env::TWX_SETTINGS_INI_PATH,
		Env::TW_INIPATH,
		Env::TWX_ASSETS_LIBRARY_PATH,
		Env::TW_LIBPATH
	}) {
		QVERIFY(!s.isEmpty());
	}
}

void Main::testTool()
{
	QString input = "Whatever";
	auto input_hash =  md5Hash(input);
	QVERIFY(input_hash.bytes.length() > 0);
	QString dots = "..........";
	QString empty = "empty.txt";
	QString path = "checksum.md";
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

void Main::testInfo()
{
	QCOMPARE(Info::name, "TwxCoreTest");
	QCOMPARE(Info::organizationName, "organization.name");
	QCOMPARE(Info::organizationDomain, "organization.domain");
	QCOMPARE(Info::authors, QString::fromUtf8("Ò∂ƒﬁ🥹"));
	QCOMPARE(Info::copyrightYears, QString::fromUtf8("1234-5678"));
	QCOMPARE(Info::copyrightHolders, QString::fromUtf8("æê®†\"Úºîœπ‡Ò∂\"ƒﬁÌÏÈ"));

	QCOMPARE(Info::buildId, "personal");

	QCOMPARE(Info::versionMajor, 1);
	QCOMPARE(Info::versionMinor, 7);
	QCOMPARE(Info::versionPatch, 8);
	QCOMPARE(Info::versionBugfix, 8);
	QCOMPARE(Info::versionTweak, 9);
	QCOMPARE(Info::versionMNP, (1 << 8 | 7) << 8 | 8);
	QCOMPARE(Info::versionMNPT, ((1 << 8 | 7) << 8 | 8) << 8 | 9);
	QCOMPARE(Info::version, "1.7.8");
	QVERIFY(Info::versionFull.startsWith("1.7.8 (personal)"));

	QVERIFY(Info::gitHash.startsWith("TEST(HASH):"));
	QVERIFY(Info::gitBranch.startsWith("TEST(BRANCH):"));
	auto date = QDateTime::fromSecsSinceEpoch(
		3+60*(4+60*5)-(1+2*60)*60,
		QTimeZone::utc()
	).addYears(8).addMonths(6).addDays(5);//1978-07-06T05:04:03+02:01
	QCOMPARE(Info::gitDate, date);
}

void Main::testLocate_applicationDir()
{
	QDir d;
	QVERIFY(d.cdUp());
	QCOMPARE(Locate::applicationDir(),d);
}

void Main::testLocate_setRawBinaryPaths()
{
	QVERIFY(Locate::rawBinaryPaths_m.empty());
	QStringList expected {
		"//A",
		"//B",
		"//C"
	};
	Locate::setRawBinaryPaths(expected);
	QCOMPARE(Locate::rawBinaryPaths_m, expected);
	Settings settings;
	QVERIFY(settings.contains(Key::binaryPaths));
  QVariant v = settings.value(Key::binaryPaths);
	QStringList actual = v.toStringList();
	QCOMPARE(actual, expected);
}

void Main::testLocate_resetDefaultBinaryPaths()
{
}

void Main::testLocate_resetRawBinaryPaths()
{
	Locate::rawBinaryPaths_m.clear();
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
  Locate::resetRawBinaryPaths(PE);
	QDir d = QDir::current();
	// All was made for d to contain directories A, B and C
  QStringList expected;
	expected
		<< d.absoluteFilePath("A")
		<< d.absoluteFilePath("B")
		<< d.absoluteFilePath("C");
  QCOMPARE(Locate::rawBinaryPaths_m, expected);
	Locate::rawBinaryPaths_m.clear();
  Locate::resetRawBinaryPaths(PE);
	QCOMPARE(Locate::rawBinaryPaths_m, expected);
}

void Main::testLocate_getRawBinaryPaths()
{
	Locate::rawBinaryPaths_m.clear();
	// rawBinaryPaths_m already filled
	QStringList expected {
		"ABC"
	};
	Locate::rawBinaryPaths_m << expected;
  auto paths = Locate::getRawBinaryPaths();
	QCOMPARE(Locate::rawBinaryPaths_m, expected);
	// void rawBinaryPaths_m, from settings
	expected << "DEF";
	Settings settings;
	settings.setValue(Key::binaryPaths, expected);
	Locate::rawBinaryPaths_m.clear();
  paths = Locate::getRawBinaryPaths();
	QCOMPARE(Locate::rawBinaryPaths_m, expected);
	// Otherwise tested with resetRawBinaryPaths
}

void Main::testLocate_PATHList()
{
	// No PATH
	auto dir = QCoreApplication::applicationDirPath();
  auto program = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
  QProcessEnvironment PE;
	PE.remove(Env::PATH);
	PE.insert("TWX_DUMMY", dir);
  Locate::rawBinaryPaths_m.clear();
#if defined(Q_OS_WIN)
	Locate::rawBinaryPaths_m
		<< "%TWX_DUMMY%";
#else
	Locate::rawBinaryPaths_m << "$TWX_DUMMY";
#endif
	QStringList actual = Locate::PATHList(PE);
	QStringList expected {
		dir
	};
	QCOMPARE(actual, expected);
}

void Main::testLocate_programPath_1()
{
	// We can rely on the test itself
	auto dir = QCoreApplication::applicationDirPath();
	auto expected = QCoreApplication::applicationFilePath();
  auto program = QFileInfo(expected).fileName();
	Locate::rawBinaryPaths_m.clear();
	Locate::rawBinaryPaths_m << dir;
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::programPath(program, PE);
	QCOMPARE(actual, expected);
	actual = Locate::programPath(QString(), PE);
	QVERIFY(actual.isEmpty());
}

void Main::testLocate_programPath_2()
{
	QString program = "program";
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::programPath(program, PE);
	auto d = QDir("A");
	QVERIFY(d.exists());
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testLocate_programPath_3()
{
	QString program = "program.program";
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::programPath(program, PE);
	auto d = QDir("A");
	QVERIFY(d.exists());
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testLocate_resolve()
{
	// For locate:
	// Find the file info targets in the current, home and application directory
	QFileInfo fileInfoCustom;
	QFileInfo fileInfoKnown;
	QFileInfo fileInfoUnknown;
	QFileInfo fileInfoApplication;
	QFileInfo fileInfoCurrent;
	QFileInfo fileInfoHome;
	QFileInfo fileInfoMustExist;
	QFileInfo fileInfoNone;
	QDir dirCustom;
	QDir dirOther;
	fileInfoNone = Locate::TwxCore_TEST_fileInfoNone;
	QVERIFY(!fileInfoNone.exists());
	QVERIFY(!fileInfoNone.filePath().isEmpty());
	fileInfoMustExist = Locate::TwxCore_TEST_fileInfoMustExist;
	QVERIFY(!fileInfoMustExist.exists());
	QVERIFY(!fileInfoMustExist.filePath().isEmpty());
	fileInfoCustom = QFileInfo("./LocateCustom/d2f4f7504c2b514ce1fd1de7d4f6e1fd8cdfefa6.md");
	fileInfoCustom.makeAbsolute();
	QVERIFY(fileInfoCustom.exists());
	fileInfoKnown = QFileInfo("./LocateKnown/e7d4f6e1fd8cdfefa6d2f4f7504c2b514ce1fd1d.md");
	fileInfoKnown.makeAbsolute();
	QVERIFY(fileInfoKnown.exists());
	fileInfoUnknown = QFileInfo("14ce1fd1de7d4f6ed2f4f7504c2b51fd8cdfefa6");
	// fileInfoUnknown.makeAbsolute();
	QVERIFY(!fileInfoUnknown.exists());
	fileInfoApplication = QFileInfo(QCoreApplication::applicationFilePath());
	fileInfoApplication.makeAbsolute();
	QVERIFY(fileInfoApplication.exists());
	fileInfoCurrent = QFileInfo("./e2a7fb8a7d6b6103f2284b221fb00ca350be4f01.md");
	fileInfoCurrent.makeAbsolute();
	QVERIFY(fileInfoCurrent.exists());
	QSet<QString> fis{
		fileInfoCustom.absoluteFilePath(),
		fileInfoKnown.absoluteFilePath(),
		fileInfoUnknown.absoluteFilePath(),
		fileInfoCurrent.absoluteFilePath(),
		fileInfoApplication.absoluteFilePath()
	};
	QCOMPARE(fis.size(), 5);
  // Things are more complex for the home
	QDirIterator it(QDir::home());
	while (it.hasNext()) {
	  (void)it.next();
    fileInfoHome = it.fileInfo();
		if (fileInfoHome.fileName().size() < 3)
		  continue;
		fileInfoHome.makeAbsolute();
		if ( !fis.contains(fileInfoHome.absoluteFilePath()))
			break;
		else
		  fileInfoHome = fileInfoUnknown;
	}
	// The contrary is extremely unlikely to happen
	QVERIFY(fileInfoHome.exists());
	dirCustom = fileInfoCustom.absoluteDir();
	dirOther = QDir("Some true relative path");

	Locate::Resolved actual;
	for (const auto & fileInfo: QList<QFileInfo>{
		fileInfoCurrent,
		fileInfoHome,
		fileInfoApplication,
	}) {
		actual = Locate::resolve(fileInfo.fileName(), dirOther, false);
		QVERIFY(actual.success);
		QCOMPARE(actual.fileInfo, fileInfo);
		actual = Locate::resolve(fileInfo.fileName(), dirOther, true);
		QVERIFY(actual.success);
		QCOMPARE(actual.fileInfo, fileInfo);
		actual = Locate::resolve(fileInfo.fileName(), dirCustom, false);
		QVERIFY(actual.success);
		QCOMPARE(actual.fileInfo, fileInfo);
		actual = Locate::resolve(fileInfo.fileName(), dirCustom, true);
		QVERIFY(actual.success);
		QCOMPARE(actual.fileInfo, fileInfo);
	}
	QFileInfo fileInfo = fileInfoCustom;
	actual = Locate::resolve(fileInfo.fileName(), dirOther, false);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoNone);
	actual = Locate::resolve(fileInfo.fileName(), dirOther, true);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoNone);
	actual = Locate::resolve(fileInfo.fileName(), dirCustom, false);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	actual = Locate::resolve(fileInfo.fileName(), dirCustom, true);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	fileInfo = fileInfoKnown;
	actual = Locate::resolve(fileInfo.filePath(), dirOther, false);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	actual = Locate::resolve(fileInfo.filePath(), dirOther, true);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	actual = Locate::resolve(fileInfo.filePath(), dirCustom, false);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	actual = Locate::resolve(fileInfo.filePath(), dirCustom, true);
	QVERIFY(actual.success);
	QCOMPARE(actual.fileInfo, fileInfo);
	fileInfo = fileInfoUnknown;
	actual = Locate::resolve(fileInfo.filePath(), dirOther, false);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoNone);
	actual = Locate::resolve(fileInfo.filePath(), dirOther, true);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoMustExist);
	actual = Locate::resolve(fileInfo.filePath(), dirCustom, false);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoNone);
	actual = Locate::resolve(fileInfo.filePath(), dirCustom, true);
	QVERIFY(!actual.success);
	QCOMPARE(actual.fileInfo, fileInfoMustExist);
}

void Main::testAssetsTrackDB()
{
	QDir dir("AssetsTrackDB/A");
	QVERIFY(dir.exists());
	auto frdb = AssetsTrackDB::load(dir);
	frdb.removeStorage();
	frdb = AssetsTrackDB::load(dir);
	QVERIFY(frdb.getList().empty());
	QVERIFY(frdb.save());
	frdb = AssetsTrackDB::load(dir);
	QVERIFY(frdb.getList().empty());
	auto fileInfo = QFileInfo(dir.absolutePath(), "1");
	auto checksum = Checksum{"1789"};
	QString version = "9871";
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
  version = "1789";
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
	auto fileInfo = QFileInfo("blablabla");
	QString version  = "9871";
	auto checksum = Checksum{"2023"};
	auto hash     = Hash{"1789"};

	AssetsTrack r1 = { fileInfo,    version,   checksum,     Hash{} };
	AssetsTrack r2 = { fileInfo,    version,   Checksum{},   hash   };
	AssetsTrack r3 = { fileInfo,    "",        checksum,     hash   };
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
	QFileInfo fileInfo("..........");
	AssetsTrack empty;
	AssetsTrack r1 =    { fileInfo,    "v1", Checksum{}, Hash{}};
	AssetsTrack r2 =    { fileInfo,    "",   Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"}};

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
	QCOMPARE(AssetsTrackDB::load("does-not-exist").getList(), QList<AssetsTrack>());

	AssetsTrackDB frdb((QDir()));
	frdb.add(QFileInfo("/spaces test.tex"), "v1",  Checksum{}, Hash{"d41d8cd98f00b204e9800998ecf8427e"});
	frdb.add(QFileInfo("base14-fonts.pdf"), "4.2", Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"});

	QCOMPARE(AssetsTrackDB::load_legacy("fileversion.db"), frdb);

	// QEXPECT_FAIL("", "Invalid file version databases are not recognized", Continue);
	QCOMPARE(AssetsTrackDB::load("script.js"), AssetsTrackDB(QDir()));
}

void Main::testAssetsTrackDB_save()
{
	AssetsTrackDB frdb((QDir()));
	frdb.add(QFileInfo("/spaces test.tex"), "v1", Checksum{}, Hash{"d41d8cd98f00b204e9800998ecf8427e"});
	frdb.add(QFileInfo("base14-fonts.pdf"), "4.2", Checksum{}, Hash{"814514754a5680a57d172b6720d48a8d"});

	QVERIFY(frdb.save("does/not/exist.frdb") == false);

	QTemporaryFile tmpFile;
	tmpFile.open();
	tmpFile.close();
	QVERIFY(frdb.save_legacy(tmpFile.fileName()));
	QCOMPARE(AssetsTrackDB::load_legacy(tmpFile.fileName()), frdb);
}

void Main::testAssets_path()
{
	QCOMPARE(Assets::setupLocation(), "");
	QVERIFY(Assets::factoryDir().exists());
	QVERIFY(QDir(Assets::legacyLocation()).exists());
	QVERIFY(QDir(Assets::standardLocation()).exists());
	QVERIFY(QDir(Assets::path("Category_A")).exists());
	QVERIFY(QDir(Assets::path("")).exists());
}

void Main::testAssets_setup_PE()
{
	QFileInfo fileInfo = QFileInfo("Assets/AppDataLocation/");
	{
		QProcessEnvironment PE;
		PE.insert(
			Env::TWX_ASSETS_LIBRARY_PATH,
			fileInfo.filePath()
		);
		Assets::setup(PE);
		QCOMPARE(Assets::setupLocation(),fileInfo.absoluteFilePath());
	}
	{
		QProcessEnvironment PE;
		PE.insert(
			Env::TW_LIBPATH,
			fileInfo.filePath()
		);
		Assets::setup(PE);
		QCOMPARE(Assets::setupLocation(),fileInfo.absoluteFilePath());
	}
}

void Main::testAssets_setup_settings()
{
	QSettings settings;
	Assets::setup(settings);
	QCOMPARE(Assets::setupLocation(), "");
	settings.setValue(Key::libpath, "..........");
	Assets::setup(settings);
	QCOMPARE(Assets::setupLocation(), "");
	settings.setValue(Key::libpath, "test_TwxCore.TestCase/Assets/setupLocation");
	Assets::setup(settings);
	QCOMPARE(QDir(Assets::setupLocation()).dirName(), "setupLocation");
	QVERIFY(QDir(Assets::path("Category_B")).exists());
}

void Main::testAssets_getLibraryPath_data()
{
	QTest::addColumn<QString>("portableLibPath");
	QTest::addColumn<QString>("subdir");
	QTest::addColumn<QString>("result");

	const QString sConfig(Key::configuration);
	const QString sDicts(Key::dictionaries);
	const QString sInvalid(QStringLiteral("does-not-exist"));

	QString appDataLocation = QDir::current().absoluteFilePath("Assets/AppDataLocation/");
	QString stem = appDataLocation;

	QTest::newRow("root") << QString() << QString() << stem;
	QTest::newRow("configuration") << QString() << sConfig << stem + sConfig;
	QTest::newRow("does-not-exist") << QString() << sInvalid << stem + sInvalid;
#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN) // *nix
#	ifndef TW_DICPATH
	QTest::newRow(Key::dictionaries) << QString() << sDicts << QStringLiteral("/usr/share/hunspell:/usr/share/myspell/dicts");
#	else
	QTest::newRow(Key::dictionaries) << QString() << sDicts << TW_DICPATH;
#	endif
#else // not *nix
	QTest::newRow("dictionaries") << QString() << sDicts << stem + sDicts;
#endif

	stem = "/invented/portable/root/";
	QTest::newRow("portable-root") << stem << QString() << appDataLocation;
	QTest::newRow("portable-configuration") << stem << sConfig << appDataLocation + sConfig;
	QTest::newRow("portable-does-not-exist") << stem << sInvalid << appDataLocation + sInvalid;
	QTest::newRow("portable-dictionaries") << stem << sDicts << appDataLocation + sDicts;
}

void Main::testAssets_getLibraryPath()
{
	QFETCH(QString, portableLibPath);
	QFETCH(QString, subdir);
	QFETCH(QString, result);

	Assets::path(portableLibPath);
	QCOMPARE(Assets::path(subdir, false), result);
}

void Main::testAssets_portableLibPath()
{
	QString noDir;
	QString curDir(Path::dot);
	QString invalidDir(QStringLiteral("/does-not-exist/"));

	Assets::path(noDir);
	QCOMPARE(Assets::setupLocation_m, noDir);
	Assets::setupLocation_m = curDir;
	QCOMPARE(Assets::setupLocation_m, curDir);
	Assets::setupLocation_m = invalidDir;
	QCOMPARE(Assets::setupLocation_m, invalidDir);
}

} // namespace Test
} // namespace Core
} // namespace Twx

QTEST_MAIN(Twx::Core::Test::Main)
