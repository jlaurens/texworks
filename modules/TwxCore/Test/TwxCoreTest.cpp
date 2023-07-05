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

#include "TwxConst.h"
#include "TwxTool.h"
#include "TwxInfo.h"
#include "TwxLocate.h"
#include "TwxAssetsTrackDB.h"
#include "TwxAssets.h"
#include "TwxSettings.h"

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
	QCoreApplication::setOrganizationName("org.tug.TwxCore");
  QCoreApplication::setOrganizationDomain("TwxCore.tug.org");
  QCoreApplication::setApplicationName("You can definitely trash me (TwxCore)");
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

const QStringList Main::listPATHFactory_original = Locate::listPATHFactory;

void Main::init()
{
	Locate::listPATHRaw_m.clear();
	Locate::rootTeXLive = Path::dot;
	Locate::w32tex_bin  = "w32tex_bin";
	Locate::appendListPATH_TeXLive_Other_m = QStringList{
		QStringLiteral("/")
	};
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
	Locate::listPATHFactory = listPATHFactory_original;
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

void Main::testConst()
{
	QCOMPARE(Path::dot, ".");
	QCOMPARE(Path::bin, "bin");

	QCOMPARE(Key::PATH, "Twx_PATH");
	QCOMPARE(Key::binaryPaths, "binaryPaths");
	QCOMPARE(Env::PATH, "PATH");
	for (const auto & s: QStringList{
		Path::dot,
		Path::applicationImage,
		Path::applicationImage128,
		Path::setup_ini,
		Key::__data,
		Key::__status,
		Key::__type,
		Key::__version,
		Key::PATH,
		Key::binaryPaths,
		Key::configuration,
		Key::completion,
		Key::templates,
		Key::scripts,
		Key::dictionaries,
		Key::libpath,
		Key::inipath,
		Key::settings_ini,
		Key::translations,
		Env::PATH,
		Env::TWX_DICTIONARY_PATH,
		Env::TW_DICPATH,
		Env::TWX_SETUP_INI_PATH,
		Env::TWX_SETTINGS_INI_PATH,
		Env::TW_INIPATH,
		Env::TWX_ASSETS_LIBRARY_PATH,
		Env::TW_LIBPATH,
		Env::LOCALAPPDATA,
		Env::SystemDrive,
		PropertyKey::listPATH
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
		qDebug () << actual.bytes;
		qDebug () << expected.bytes;
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
	QCOMPARE(Info::organizationName, "test_ORGANIZATION_NAME");
	QCOMPARE(Info::organizationShortName, "test_ORGANIZATION_SHORT_NAME");
	QCOMPARE(Info::organizationDomain, "test_ORGANIZATION_DOMAIN");
	QCOMPARE(Info::authors, QString::fromUtf8("test.authors.Ò∂ƒﬁ🥹"));
	QCOMPARE(Info::copyrightYears, QString::fromUtf8("5678-9012"));
	QCOMPARE(Info::copyrightHolders, QString::fromUtf8("test.holders.æê®†\"Úºîœπ‡Ò∂\"ƒﬁÌÏÈ"));

	QCOMPARE(Info::buildId, "personal");

	QCOMPARE(Info::versionMajor, 1);
	QCOMPARE(Info::versionMinor, 2);
	QCOMPARE(Info::versionPatch, 3);
	QCOMPARE(Info::versionBugfix, 3);
	QCOMPARE(Info::versionTweak, 4);
	QCOMPARE(Info::versionMNP, (1 << 8 | 2) << 8 | 3);
	QCOMPARE(Info::versionMNPT, ((1 << 8 | 2) << 8 | 3) << 8 | 4);
	QCOMPARE(Info::version, "1.2.3");
	QVERIFY(Info::versionFull.startsWith("1.2.3 (personal)"));

	QVERIFY(Info::gitHash.startsWith("TEST(HASH):"));
	QVERIFY(Info::gitBranch.startsWith("TEST(BRANCH):"));
	auto date = QDateTime::fromSecsSinceEpoch(
		3+60*(4+60*5)-(1+2*60)*60,
		QTimeZone::utc()
	).addYears(8).addMonths(6).addDays(5);//1978-07-06T05:04:03+02:01
	QCOMPARE(Info::gitDate, date);
}

#if defined(Q_OS_DARWIN)
void Main::testInfo_MacOS()
{
	QVERIFY(Info::macOSVersionString().size()>0);
	QString version = Info::macOSVersionString();
	QRegularExpression pattern(QStringLiteral("^Mac OS X (\\d+)\\.(\\d+)\\.(\\d+)$"));
	QVERIFY2(version.contains(pattern), qPrintable(version));
}
#endif

void Main::testSettings_listPATH()
{
	Settings settings;
	QVERIFY(!settings.hasListPATH());
	settings.setListPATH(QStringList());
	QVERIFY(!settings.hasListPATH());
	settings.setListPATH(QStringList{
		"",
		"",
	});
	QVERIFY(!settings.hasListPATH());
	settings.setListPATH(QStringList{
		"ABC",
		"",
	});
	QVERIFY(settings.hasListPATH());
	QCOMPARE(settings.listPATH(), (QStringList{
		"ABC"
	}));
	settings.setListPATH(QStringList{
		"ABC",
		""
	});
	QVERIFY(settings.hasListPATH());
	settings.setListPATH(QStringList{
		"",
		"DEF"
	});
	QVERIFY(settings.hasListPATH());
	QCOMPARE(settings.listPATH(), (QStringList{
		"DEF"
	}));
	settings.setListPATH(QStringList{
		"ABC",
		"DEF"
	});
	QVERIFY(settings.hasListPATH());
	QCOMPARE(settings.listPATH(), (QStringList{
		"ABC",
		"DEF"
	}));
}

void Main::testSettings_assetsLibraryLocation()
{
	Settings settings;
	QVERIFY(!settings.hasAssetsLibraryLocation());
	settings.setAssetsLibraryLocation(QString());
	QVERIFY(!settings.hasAssetsLibraryLocation());
	settings.setAssetsLibraryLocation(QString("ABC"));
	QVERIFY(!settings.hasAssetsLibraryLocation());
	QVERIFY(QDir("Assets/setupLocation").exists());
	settings.setAssetsLibraryLocation(QString("Assets/setupLocation"));
	// qDebug() << Key::assets_library_location << "=>" << settings.value(Key::assets_library_location);
	// qDebug() << Key::libpath << "=>" << settings.value(Key::libpath);
	// if (path.isEmpty()) {
	// 	path = value(Key::libpath).toString();
	// 	if (path.isEmpty()) {
	// 		return path;
	// 	}
	// }
	// auto resolved = Locate::resolve(path, QDir(), true);
	// if (resolved.success) {
	// 	return resolved.fileInfo.absoluteFilePath();
	// }
	// return QString();

	QVERIFY(settings.hasAssetsLibraryLocation());
	QCOMPARE(settings.assetsLibraryLocation(), QDir("Assets/setupLocation").absolutePath());
}

void Main::testLocate_applicationDir()
{
	QDir d;
	QVERIFY(d.cdUp());
	QCOMPARE(Locate::applicationDir(),d);
}

void Main::testLocate_absoluteProgramPath_List()
{
	const auto program = QStringLiteral("program");
	auto dir = QDir();
	QVERIFY(dir.cd("Locate/absoluteProgramPath"));
  QVERIFY(QFileInfo(dir, program).isExecutable()
	 || QFileInfo(dir, "program.exe").isExecutable());
  auto actual = Locate::absoluteProgramPath(program, QStringList());
	QVERIFY(actual.isEmpty());
  actual = Locate::absoluteProgramPath(program, QStringList{
		dir.absolutePath()
	});
	QVERIFY(!actual.isEmpty());
	QCOMPARE(QFileInfo(actual).baseName(), program);
}

void Main::testLocate_appendListPATH_TeXLive_Windows()
{
	QStringList actual, expected;
	Locate::appendListPATH_TeXLive_Windows(actual);
	expected << "w32tex_bin";
	QCOMPARE(actual, expected);
	Locate::rootTeXLive = QDir().absoluteFilePath(
		"Locate/usr/local/texlive/"
	);
	auto dir = QDir(Locate::rootTeXLive);
	QVERIFY(dir.exists());
	actual.clear();
	expected.clear();
	Locate::appendListPATH_TeXLive_Windows(actual);
	expected << dir.absoluteFilePath("3333/bin");
	expected << dir.absoluteFilePath("2222/bin");
	expected << dir.absoluteFilePath("1111/bin");
	expected << "w32tex_bin";
	QCOMPARE(actual, expected);
}

void Main::testLocate_appendListPATH_TeXLive_Other()
{
	const QString tex =
#if defined(Q_OS_WIN)
	QStringLiteral("tex.exe")
#else
	QStringLiteral("tex")
#endif
	;
	QStringList actual, expected;
	Locate::rootTeXLive = QDir().absoluteFilePath(
		"Locate/usr/local/texlive/"
	);
	auto dir = QDir(Locate::rootTeXLive);
	QVERIFY(dir.exists());
	QVERIFY(dir.cd("1111/bin/windows"));
	QVERIFY(QFileInfo(dir, tex).isExecutable());
	expected << dir.absolutePath();
	QVERIFY(dir.cd("../../../2222/bin/windows"));
	QVERIFY(QFileInfo(dir, tex).isExecutable());
	expected << dir.absolutePath();
	QVERIFY(dir.cd("../../../3333/bin/windows"));
	QVERIFY(QFileInfo(dir, tex).isExecutable());
	expected << dir.absolutePath();
	actual.clear();
	Locate::appendListPATH_TeXLive_Other(actual);
	actual.removeAt(0);
	int l = 18; // the number of subfolders of bin
	QCOMPARE(actual.size(), 3 * l);
	for (auto const & p: expected) {
		QVERIFY(actual.contains(p));
	}
	for (auto const & p: actual.mid(0,l)) {
		QVERIFY(p.contains(QStringLiteral("3333")));
	}
	for (auto const & p: actual.mid(l,l)) {
		QVERIFY(p.contains(QStringLiteral("2222")));
	}
	for (auto const & p: actual.mid(2*l,l)) {
		QVERIFY(p.contains(QStringLiteral("1111")));
	}
}

void Main::testLocate_appendListPATH_MiKTeX_Windows()
{
	QStringList actual, expected;
	QProcessEnvironment PE;
	Locate::appendListPATH_MiKTeX_Windows(actual, PE);
	QCOMPARE(actual, expected);
	Locate::LOCALAPPDATA_Windows = QDir().absoluteFilePath(
		"Locate/appendListPATH/MiKTeX_Windows/LOCALAPPDATA/"
	);
	QVERIFY(QDir(Locate::LOCALAPPDATA_Windows).exists());
	Locate::SystemDrive_Windows = QDir().absoluteFilePath(
		"Locate/appendListPATH/MiKTeX_Windows/SystemDrive/"
	);
	QVERIFY(QDir(Locate::SystemDrive_Windows).exists());
	actual.clear();
	expected.clear();
	Locate::appendListPATH_MiKTeX_Windows(actual, PE);
	expected
	<< Locate::LOCALAPPDATA_Windows + "Programs/MiKTeX/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files/MiKTeX 3.33/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files/MiKTeX 2.22/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files/MiKTeX 1.11/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files/MiKTeX/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files (x86)/MiKTeX 3.3/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files (x86)/MiKTeX 2.2/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files (x86)/MiKTeX 1.1/miktex/bin"
	<< Locate::SystemDrive_Windows + "Program Files (x86)/MiKTeX/miktex/bin";
	QCOMPARE(actual, expected);
}

void Main::testLocate_appendListPATH_MiKTeX_Other()
{
}

void Main::testLocate_setRawBinaryPaths()
{
	QVERIFY(Locate::listPATHRaw_m.empty());
	QStringList expected {
		"//A",
		"//B",
		"//C"
	};
	Locate::setListPATH(expected);
	QCOMPARE(Locate::listPATHRaw_m, expected);
	Settings settings;
	QVERIFY(settings.hasListPATH());
  QStringList actual = settings.listPATH();
	QCOMPARE(actual, expected);
}

void Main::testLocate_resetListPATHRaw1()
{
	Locate::rootTeXLive = Path::dot;
	QDir d = QDir::current();
	Locate::listPATHFactory = QStringList {
		d.absoluteFilePath("Locate/A"),
		d.absoluteFilePath("Locate/B"),
		d.absoluteFilePath("Locate/C"),
	};
  Locate::listPATHRaw_m.clear();
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	Locate::resetListPATHRaw(PE);
	// All was made for d to contain directories Locate/A, Locate/B and Locate/C
  QStringList expected;
	Locate::appendListPATH_TeXLive_Other(expected);
	expected.clear();
	Locate::appendListPATH_MiKTeX_Other(expected);
	expected.clear();
	Locate::appendListPATH_TeX(expected, PE);
	expected << Locate::listPATHFactory;
	Locate::consolidateListPATH(expected, PE);
	QCOMPARE(Locate::listPATHRaw_m, expected);
	Locate::listPATHRaw_m.clear();
  QVERIFY(Locate::resetListPATHRaw(PE));
	QCOMPARE(Locate::listPATHRaw_m, expected);
}

void Main::testLocate_resetListPATHRaw2()
{
	Locate::rootTeXLive = Path::dot;
	QDir d = QDir::current();
	Locate::listPATHFactory = QStringList {
		d.absoluteFilePath("Locate/B"),
	};
  Locate::listPATHRaw_m.clear();
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	PE.insert(Env::PATH, QStringList{
		d.absoluteFilePath("Locate/A"),
		d.absoluteFilePath("Locate/C")
	}.join(QDir::listSeparator()));
	Locate::resetListPATHRaw(PE);
	// All was made for d to contain directories Locate/A, Locate/B and Locate/C
  QStringList expected;
	Locate::appendListPATH_TeXLive_Other(expected);
	expected.clear();
	Locate::appendListPATH_MiKTeX_Other(expected);
	expected.clear();
	Locate::appendListPATH_TeX(expected, PE);
	expected << QStringList {
		d.absoluteFilePath("Locate/B"),
		d.absoluteFilePath("Locate/A"),
		d.absoluteFilePath("Locate/C"),
	};
	Locate::consolidateListPATH(expected, PE);
	QCOMPARE(Locate::listPATHRaw_m, expected);
	Locate::listPATHRaw_m.clear();
  QVERIFY(Locate::resetListPATHRaw(PE));
	QCOMPARE(Locate::listPATHRaw_m, expected);
}

void Main::testLocate_listPATHRaw()
{
	Locate::listPATHRaw_m.clear();
	// listPATHRaw_m already filled
	QStringList expected {
		"ABC"
	};
	Locate::listPATHRaw_m << expected;
  auto paths = Locate::listPATHRaw();
	QCOMPARE(Locate::listPATHRaw_m, expected);
	QCOMPARE(paths, expected);
	// void listPATHRaw_m, from settings
	expected << "DEF";
	Settings settings;
	settings.setListPATH(expected);
	Locate::listPATHRaw_m.clear();
  paths = Locate::listPATHRaw();
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
  Locate::appendListPATH_TeX(expected, PE);
	QCOMPARE(Locate::listPATHRaw_m, expected);
	// Otherwise tested with resetListPATHRaw
}

void Main::testLocate_listPATH()
{
	// No PATH
	auto dir = QCoreApplication::applicationDirPath();
  auto program = QFileInfo(QCoreApplication::applicationFilePath()).fileName();
  QProcessEnvironment PE;
	PE.remove(Env::PATH);
	PE.insert("TWX_DUMMY", dir);
  Locate::listPATHRaw_m.clear();
#if defined(Q_OS_WIN)
	Locate::listPATHRaw_m
		<< "%TWX_DUMMY%";
#else
	Locate::listPATHRaw_m << "$TWX_DUMMY";
#endif
	QStringList actual = Locate::listPATH(PE);
	QStringList expected {
		dir
	};
	QCOMPARE(actual, expected);
}

void Main::testLocate_absoluteProgramPath_1()
{
	// We can rely on the test itself
	auto dir = QCoreApplication::applicationDirPath();
	auto expected = QCoreApplication::applicationFilePath();
  auto program = QFileInfo(expected).fileName();
	Locate::listPATHRaw_m.clear();
	Locate::listPATHRaw_m << dir;
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::absoluteProgramPath(program, PE);
	QCOMPARE(actual, expected);
	actual = Locate::absoluteProgramPath(QString(), PE);
	QVERIFY(actual.isEmpty());
}

void Main::testLocate_absoluteProgramPath_2()
{
	QString program = "program";
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::absoluteProgramPath(program, PE);
	QVERIFY(actual.isEmpty());
	auto d = QDir("Locate/absoluteProgramPath");
	QVERIFY(d.exists());
	PE.insert(Env::PATH, d.absolutePath());
	actual = Locate::absoluteProgramPath(program, PE);
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testLocate_absoluteProgramPath_3()
{
	QString program = "program.program";
	QProcessEnvironment PE;
	PE.remove(Env::PATH);
	auto actual = Locate::absoluteProgramPath(program, PE);
	QVERIFY(actual.isEmpty());
	auto d = QDir("Locate/absoluteProgramPath");
	QVERIFY(d.exists());
	PE.insert(Env::PATH, d.absolutePath());
	actual = Locate::absoluteProgramPath(program, PE);
	auto expected = d.absoluteFilePath(program);
	QCOMPARE(actual, expected);
}

void Main::testLocate_absoluteProgramPath_4()
{
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
	fileInfoNone = Locate::fileInfoNone_TwxCore_TEST;
	QVERIFY(!fileInfoNone.exists());
	QVERIFY(!fileInfoNone.filePath().isEmpty());
	fileInfoMustExist = Locate::fileInfoMustExist_TwxCore_TEST;
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
	Settings settings;
	Assets::setup(settings);
	QCOMPARE(Assets::setupLocation(), "");
	settings.setAssetsLibraryLocation("..........");
	Assets::setup(settings);
	QCOMPARE(Assets::setupLocation(), "");
	QVERIFY(QDir("Assets/setupLocation").exists());
	settings.setAssetsLibraryLocation("Assets/setupLocation");
	QCOMPARE(settings.assetsLibraryLocation(), QDir("Assets/setupLocation").absolutePath());
	Assets::setup(settings);
	QCOMPARE(QDir(Assets::setupLocation()).dirName(), "setupLocation");
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
