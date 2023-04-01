/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2023  Stefan Löffler, Jérôme Laurens

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

#include "TWString.h"
#include "document/TextDocument.h"
#include "document/TWTag.h"
#include <QDebug>

namespace Tw {
namespace Document {

const QString Tag::TypeName::Any       = QStringLiteral("Any");
const QString Tag::TypeName::Magic     = QStringLiteral("Magic");
const QString Tag::TypeName::Bookmark  = QStringLiteral("Bookmark");
const QString Tag::TypeName::Outline   = QStringLiteral("Outline");

const QString Tag::SubtypeName::Any    = QStringLiteral("Any");
// This is the list of recognized anchor subtypes
const QString Tag::SubtypeName::MARK   = QStringLiteral("MARK");
const QString Tag::SubtypeName::TODO   = QStringLiteral("TODO");
const QString Tag::SubtypeName::BORDER = QStringLiteral("BORDER");

// name of a capture group, should be defined more globally because file "tag-patterns.txt" relies on it.
namespace __ {
static const QString kKeyContent = QStringLiteral("content");
static const QString kKeyType    = QStringLiteral("type");
}

//MARK: Tag
Tag::Type Tag::typeForName(const QString &name) {
    if (name == TypeName::Magic) {
        return Type::Magic;
    }
    if (name == TypeName::Outline) {
        return Type::Outline;
    }
    if (name == TypeName::Bookmark) {
        return Type::Bookmark;
    }
    return Type::Any;
}

const QString Tag::nameForType(Tag::Type type) {
    if (type == Type::Magic) {
        return TypeName::Magic;
    }
    if (type == Type::Outline) {
        return TypeName::Outline;
    }
    if (type == Type::Bookmark) {
        return TypeName::Bookmark;
    }
    return TypeName::Any;
}

Tag::Subtype Tag::subtypeForName(const QString &name) {
    if (name == SubtypeName::MARK) {
        return Subtype::MARK;
    }
    if (name == SubtypeName::TODO) {
        return Subtype::TODO;
    }
    if (  name == SubtypeName::BORDER) {
        return Subtype::BORDER;
    }
    return Subtype::Any;
}

const QString Tag::nameForSubtype(Tag::Subtype subtype) {
    if (subtype == Subtype::MARK) {
        return SubtypeName::MARK;
    }
    if (subtype == Subtype::TODO) {
        return SubtypeName::TODO;
    }
    if (subtype == Subtype::BORDER) {
        return SubtypeName::BORDER;
    }
    return SubtypeName::Any;
}

Tag::Tag(const Type     type,
         const Subtype  subtype,
         const int      level,
         const QTextCursor & cursor,
         const QString& text,
         const QString& tooltip,
         TagBank *parent /* = nullptr */):
QObject  (parent  ),
__type   (type    ),
__subtype(subtype ),
__level  (level   ),
__cursor (cursor  ),
__text   (text    ),
__tooltip(tooltip )
{
    Q_ASSERT(!__cursor.isNull());
}

Tag::Tag(const QTextCursor &cursor,
         const int level,
         const QString &text,
         TagBank *parent /* = nullptr */):
QObject  (parent      ),
__type   (Type::Any   ),
__subtype(Subtype::Any),
__level  (level       ),
__cursor (cursor      ),
__text   (text        ),
__tooltip(QString()   )
{
    Q_ASSERT(!cursor.isNull());
    int end = __cursor.selectionEnd();
    __cursor.movePosition(QTextCursor::StartOfBlock);
    __cursor.setPosition(end, QTextCursor::KeepAnchor);
    __cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
}

Tag::Tag(const Tag::Type type,
         const int level,
         const QTextCursor &cursor,
         const QRegularExpressionMatch & match,
         TagBank *parent):
QObject (parent),
__type  (type  ),
__level (level ),
__cursor(cursor)
{
    Q_ASSERT(!cursor.isNull());
    
    QString s = match.captured(__::kKeyType);
    __subtype = Tag::subtypeForName(s);
    
    int end = __cursor.selectionEnd();
    __cursor.movePosition(QTextCursor::StartOfBlock);
    __cursor.setPosition(end, QTextCursor::KeepAnchor);
    __cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
    
    s = match.captured(__::kKeyContent);
    if (s.isEmpty()) {
        s = match.captured(1);
    }
    if (s.isEmpty()) {
        __text = match.captured(0);
        __tooltip = QString();
    } else {
        __text = s;
        __tooltip = match.captured(0);
    }
}

const TagBank *Tag::bank() const
{
    return static_cast<TagBank *>(parent());
}

TextDocument *Tag::document() const
{
    return bank()->document();
}

//MARK: TagSuite

TagSuite::TagSuite(TagBank *bank, Filter f): QObject(bank), __filter(f)
{
    Q_ASSERT(bank);
    connect(bank, &TagBank::changed, this, [=]() {
        qDebug() << "CHANGED";
        __tags.clear();
        const auto tags = bank->tags();
        qDebug() << tags.size();
        for (const Tag *tag: tags) {
            if (tag && f(tag))
                __tags << tag;
        }
        qDebug() << __tags.size();
        emit changed();
    });
}

const TagBank *TagSuite::bank() const
{
    return static_cast<TagBank *>(parent());
}

TextDocument *TagSuite::document() const
{
    return bank()->document();
}

QList<const Tag *> TagSuite::tags()
{
    return QList<const Tag *>(__tags);
}

const Tag *TagSuite::get(const int i)
{
    return 0 <= i && i < __tags.count() ? __tags[i] : nullptr;
}

/// \brief manage the cursor for a contiguous selection
/// \param yorn select when true , deselect when false
/// \param cursor
void TagSuite::select(bool yorn, const QTextCursor &cursor)
{
    if (cursor.isNull()) {
        if (yorn) {
            __cursor = QTextCursor(document());
            __cursor.movePosition(QTextCursor::Start);
            __cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
        }
        return;
    }
    int start =  0;
    int end   = -1;
    if (yorn) {
        if (__cursor.isNull()) {
            __cursor = cursor;
            start = __cursor.selectionStart();
            end   = __cursor.selectionEnd();
heaven:
            if (start < end) {
                __cursor.setPosition(start);
                __cursor.movePosition(QTextCursor::StartOfBlock);
                __cursor.setPosition(end, QTextCursor::KeepAnchor);
                __cursor.movePosition(QTextCursor::EndOfBlock, QTextCursor::KeepAnchor);
                return;
            }
            __cursor = QTextCursor();
            return;
        }
        // expand the selection
        start = std::min(cursor.selectionStart(), __cursor.selectionStart());
        end =   std::max(cursor.selectionEnd(),   __cursor.selectionEnd());
        goto heaven;
    }
    if (__cursor.isNull()) {
        return;
    }
    // cut off the selection
    if (cursor.selectionStart()>=__cursor.selectionEnd()) {
        __cursor = QTextCursor();
        return;
    }
    if (__cursor.selectionStart()>=cursor.selectionEnd()) {
        __cursor = QTextCursor();
        return;
    }
    start = __cursor.selectionStart();
    end   =   cursor.selectionStart();
    if (start < end) {
        goto heaven;
    }
    start =   cursor.selectionEnd();
    end   = __cursor.selectionEnd();
    if (start < end) {
        goto heaven;
    }
    __cursor = QTextCursor();
}
bool TagSuite::isSelected(const Tag *tag) const
{
    if (__cursor.isNull() || !tag) return false;
    int i = tag->selectionStart();
    return __cursor.selectionStart() <= i && i <= __cursor.selectionEnd();
}

//MARK: TagBank
TagBank::TagBank(TextDocument *parent) : QObject(parent)
{
    _suiteAll      = new TagSuite(this, [](const Tag *tag) {
        return tag;
    });
    _suiteBookmark = new TagSuite(this, [](const Tag *tag) {
        return tag && ! tag->isOutline();
    });
    _suiteOutline  = new TagSuite(this, [](const Tag *tag) {
        return tag && (tag->isOutline() || tag->isBoundary());
    });
}

TextDocument *TagBank::document() const
{
    return static_cast<TextDocument *>(parent());
}

bool TagBank::addTag(Tag *tag)
{
    if (!tag) return false;
    
    tag->setParent(this); // take ownership
    
    auto index = tag->selectionStart();
    int i = _tags.size();
    while(i--) {
        const Tag *t = _tags.at(i);
        if (t->selectionStart() > index) {
            continue;
        }
        if (t->selectionStart() == index) {
            _tags.replace(i, tag);
        } else {
            _tags.insert(i, tag);
        }
        tag = nullptr;
        break;
    }
    if (tag) {
        _tags.insert(0, tag);
    }
    emit changed();
    return true;
}

void TagBank::addTag(const QTextCursor & c, const int level, const QString & text)
{
    Tag *tag = new Tag(c, level, text, this);
    if (! addTag(tag)) delete tag;
}

void TagBank::addTag(const Tag::Type type,
                     const int level,
                     const int index,
                     const QRegularExpressionMatch & match)
{
    QTextCursor c = QTextCursor(document());
    c.setPosition(index);
    c.setPosition(index+match.capturedLength(), QTextCursor::KeepAnchor);
    Tag *tag = new Tag(type, level, c, match, this);
    if (! addTag(tag)) delete tag;
}
unsigned int TagBank::removeTags(int offset, int len)
{
    unsigned int removed = 0;
    auto start = _tags.begin();
    while(start != _tags.end() && (*start)->selectionStart() < offset) {
        ++start;
    }
    auto end = start;
    offset += len;
    while(end != _tags.end() && (*end)->selectionStart() < offset) {
        delete *end;
        ++removed;
        ++end;
    }
    if (removed > 0) {
        _tags.erase(start, end);
        emit changed();
    }
    return removed;
}

} // namespace Document
} // namespace Tw
