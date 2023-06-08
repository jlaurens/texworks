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
#include <QtTest>
#include <QString>

namespace Twx {
namespace Core {
namespace Test {

class Main: public QObject
{
	Q_OBJECT
	QProcessEnvironment PE_m;

private slots:
	void initTestCase();
	void cleanupTestCase();

  void init();
  void cleanup();

	void testConst();

	void testTool();
	
	void testInfo();

#if defined(Q_OS_DARWIN)
	void testInfo_MacOS();
#endif

	void testSettings_listPATH();
	void testSettings_assetsLibraryLocation();

	void testLocate_applicationDir();
	void testLocate_absoluteProgramPath_List();
	void testLocate_appendListPATH_TeXLive_Windows();
	void testLocate_appendListPATH_TeXLive_Other();
	void testLocate_appendListPATH_MiKTeX_Windows();
	void testLocate_appendListPATH_MiKTeX_Other();
	void testLocate_setRawBinaryPaths();
	void testLocate_resetListPATHRaw1();
	void testLocate_resetListPATHRaw2();
	void testLocate_listPATHRaw();	
	void testLocate_listPATH();
	void testLocate_absoluteProgramPath_1();
	void testLocate_absoluteProgramPath_2();
	void testLocate_absoluteProgramPath_3();
	void testLocate_absoluteProgramPath_4();
	void testLocate_resolve();

	void testAssetsTrackDB();
	void testAssetsTrackDB_comparisons();
	void testAssetsTrackDB_add();
	void testAssetsTrackDB_load();
	void testAssetsTrackDB_save();

	void testAssets_path();
	void testAssets_setup_PE();
	void testAssets_setup_settings();

	void testAssets_getLibraryPath_data();
	void testAssets_getLibraryPath();
	void testAssets_portableLibPath();

private:
	static const QStringList listPATHFactory_original;

public:
  Main();
  ~Main();
};

} // namespace Test
} // namespace Core
} // namespace Twx
