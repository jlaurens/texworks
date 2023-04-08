/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023 Jérôme Laurens

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

#include "TWParser_test.h"

#include "anchor/TWTag.h"
#include "anchor/TWParser.h"
#include "utils/ResourcesLibrary.h"

#include <QSignalSpy>

namespace Tw {
namespace Utils {

const QString ResourcesLibrary::getTagPatternsPath()
{
    return QDir::currentPath()+QStringLiteral("/../../res/resfiles/configuration/tag-patterns.txt");
}

} //namespace Utils

namespace Anchor {

namespace UnitTest {

void ParserTest::init()
{
}

void ParserTest::test_main1()
{
    QVERIFY(true);
}
void ParserTest::test_main2()
{
    QVERIFY(true);
}

} // namespace UnitTest

} // namespace Anchor
} // namespace Tw

QTEST_MAIN(Tw::Anchor::UnitTest::ParserTest)
