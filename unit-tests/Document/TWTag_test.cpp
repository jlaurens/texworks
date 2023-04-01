/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2020-2022  Stefan Löffler

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

#include "TWTag_test.h"

#include "document/Document.h"
#include "document/TextDocument.h"
#include "document/TWTag.h"

#include <QSignalSpy>

namespace Tw {
namespace Document {

bool operator==(const Tag & t1, const Tag & t2) {
    return (t1.cursor() == t2.cursor() && t1.level() == t2.level() && t1.text() == t2.text() && t1.tooltip() == t2.tooltip());
}

namespace UnitTest {

void TagAll::main()
{
    TextDocument doc(QStringLiteral("Hello World"));
    TagBank *bank = doc.tagBank();
#if QT_VERSION < QT_VERSION_CHECK(5, 4, 0)
    QSignalSpy spy(bank, SIGNAL(changed()));
#else
    QSignalSpy spy(bank, &TagBank::changed);
#endif
    
    Tag tag1(Tag::Type::Bookmark,
             Tag::Subtype::Any,
             0,
             QTextCursor(&doc),
             QStringLiteral("tag1"),
             QStringLiteral("tooltip1"));
    tag1.cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, 2);
    
    Tag tag2(Tag::Type::Bookmark,
             Tag::Subtype::Any,
             0, QTextCursor(&doc),
             QStringLiteral("tag2"),
             QStringLiteral("tooltip2"));
    tag2.cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::MoveAnchor, 2);
    tag2.cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor, 1);
    
    QVERIFY(spy.isValid());
    QVERIFY(bank->tags()->isEmpty());
    bank->addTag(tag2.cursor, tag2.level, tag2.text);
    bank->addTag(tag1.cursor, tag1.level, tag1.text);
    QCOMPARE(spy.count(), 2);
    
    QList<const Tag *> tags = bank->tags();
    QCOMPARE(tags, QList<const Tag *>() << &tag1 << &tag2);
    
    spy.clear();
    QCOMPARE(bank->removeTags(3, 5), 0u);
    QCOMPARE(spy.count(), 0);
    
    QCOMPARE(bank->removeTags(0, 1), 1u);
    QCOMPARE(spy.count(), 1);
}

} // namespace UnitTest

} // namespace Document
} // namespace Tw

QTEST_MAIN(TW::UnitTest::Document::TagAll)
