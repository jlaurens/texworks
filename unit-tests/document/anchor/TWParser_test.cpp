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

#include "document/anchor/TWTag.h"
#include "document/anchor/TWParser.h"
#include "utils/ResourcesLibrary.h"

#include <QSignalSpy>

namespace Tw {
namespace Utils {

const QString ResourcesLibrary::getTagPatternsPath()
{
    return QDir::currentPath()+QStringLiteral("/../../res/resfiles/configuration/tag-patterns.txt");
}

} //namespace Utils

namespace Document {
namespace Anchor {

namespace UnitTest {

void ParserTest::init()
{
    Parser::categories_m.clear();
    Parser::modes_m.clear();
}

void ParserTest::test_main1()
{
    QCOMPARE(Parser::categories_m.size(), 0);
    QCOMPARE(Parser::modes_m.size(), 0);
    Parser::categories_m << QStringLiteral("Yoko" );
    Parser::modes_m      << QStringLiteral("Tsuno");
    QCOMPARE(Parser::categories_m.size(), 1);
    QCOMPARE(Parser::modes_m.size(), 1);
}
void ParserTest::test_main2()
{
    QCOMPARE(Parser::categories_m.size(), 0);
    QCOMPARE(Parser::modes_m.size(), 0);
}

} // namespace UnitTest

} // namespace Anchor
} // namespace Document
} // namespace Tw

QTEST_MAIN(Tw::Document::Anchor::UnitTest::ParserTest)
