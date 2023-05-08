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
#include "Typeset/TwxTypesetManager.h"
#include "Typeset/TwxEngine.h"

#include <QtTest/QtTest>

namespace Twx {
namespace Typeset {

namespace Test {

class Main: public QObject
{
	Q_OBJECT

private slots:
	void initTestCase();
	void cleanupTestCase();
	
  void init();
  void cleanup();

  void test_Settings();
	void test_Engine_json();
  void test_Engine();
  
	void test_EngineManager_savedEngineList();
	void test_EngineManager_getEngineList();
	void test_EngineManager_setEngineList();
	void test_EngineManager_getEngineWithName();
	void test_EngineManager_defaultEngineName();
	void test_EngineManager_rawEngineList();
	void test_EngineManager_defaultEngine();
	
	void testConnection();
	void testTypesetManager();

private:
	void feedEngineList();
  Engine makeEngine(const char * key = "", bool showPdf = false);
public:
  Main();
  ~Main();
};

} // namespace Test
} // namespace Core
} // namespace Twx
