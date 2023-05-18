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

	void testLocate_applicationDir();
	void testLocate_setRawBinaryPaths();
	void testLocate_resetDefaultBinaryPaths();
	void testLocate_resetRawBinaryPaths();
	void testLocate_getRawBinaryPaths();	
	void testLocate_getBinaryPaths();
	void testLocate_programPath_1();
	void testLocate_programPath_2();
	void testLocate_programPath_3();
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

public:
  Main();
  ~Main();
};

} // namespace Test
} // namespace Core
} // namespace Twx
