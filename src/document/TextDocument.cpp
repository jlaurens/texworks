/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019  Stefan Löffler

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

//TODO: Next should move to Tw::String. (linker problem)
const QString Tag::TypeName::Any      = QStringLiteral("Any");
const QString Tag::TypeName::Bookmark = QStringLiteral("Bookmark");
const QString Tag::TypeName::Outline  = QStringLiteral("Outline");

const QString Tag::SubtypeName::Any     = QStringLiteral("Any");
const QString Tag::SubtypeName::MARK    = QStringLiteral("MARK");
const QString Tag::SubtypeName::TODO    = QStringLiteral("TODO");

// name of a capture group
namespace __ {
static const QString kKeyContent = QStringLiteral("content");
static const QString kKeyType = QStringLiteral("type");
}

//MARK: Tag
Tag::Type Tag::typeForName(const QString &name) {
    if (name == Tag::TypeName::Outline) {
        return Tag::Type::Outline;
    }
    if (name == Tag::TypeName::Bookmark) {
        return Tag::Type::Bookmark;
    }
    return Type::Any;
}

const QString Tag::nameForType(Tag::Type type) {
    if (type == Tag::Type::Outline) {
        return Tag::TypeName::Outline;
    }
    if (type == Tag::Type::Bookmark) {
        return Tag::TypeName::Bookmark;
    }
    return Tag::TypeName::Any;
}

Tag::Subtype Tag::subtypeForName(const QString &name) {
    if (name == Tag::SubtypeName::MARK) {
        return Tag::Subtype::MARK;
    }
    if (name == Tag::SubtypeName::TODO) {
        return Tag::Subtype::TODO;
    }
    return Subtype::Any;
}

const QString Tag::nameForSubtype(Tag::Subtype subtype) {
    if (subtype == Tag::Subtype::MARK) {
        return Tag::SubtypeName::MARK;
    }
    if (subtype == Tag::Subtype::TODO) {
        return Tag::SubtypeName::TODO;
    }
    return Tag::SubtypeName::Any;
}

Tag::Tag(const Type     type,
         const Subtype  subtype,
         const int      level,
         const QTextCursor & cursor,
         const QString& text,
         const QString& tooltip,
         QObject *parent_p /* = nullptr */):
QObject(parent_p),
__type(type),
__subtype(subtype),
__level(level),
__cursor(cursor),
__text(text),
__tooltip(tooltip)
{
    Q_ASSERT(!__cursor.isNull());
}

Tag::Tag(const QTextCursor &cursor,
         const int level,
         const QString &text,
         QObject *parent_p /* = nullptr */):
QObject(parent_p),
__type(Type::Any),
__subtype(Subtype::Any),
__level(level),
__cursor(cursor),
__text(text),
__tooltip(QString())
{
    Q_ASSERT(!cursor.isNull());
}

Tag::Tag(const Tag::Type type,
         const int level,
         const QTextCursor &cursor,
         const QRegularExpressionMatch & match,
         QObject *parent_p /* = nullptr */):
QObject(parent_p),
__type(type),
__level(level),
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

//MARK: ArrayTagP

ArrayTagP::ArrayTagP(TextDocument    *p,
                   ArrayTagP::Filter f): QObject(p), __filter(f)
{
    __document_p = p;
    __active     = false;
}

QList<const Tag *> ArrayTagP::getTagPs()
{
    update(true);
    return QList<const Tag *>(__tagPs);
}

/// \note
void ArrayTagP::update(bool activate/* = false */)
{
    if (!__document_p)
        return;
    if (activate)
        __active = true;
    if (__active) {
        const QList<const Tag *> &tagPs = __document_p->getTagPs();
        foreach(const Tag *tag_p, tagPs) {
            if (tag_p && __filter(tag_p))
                __tagPs << tag_p;
        }
        emit changed();
    }
}

const Tag * ArrayTagP::get_p(const int i)
{
    update(true);
    return 0 <= i && i < __tagPs.count() ? __tagPs[i] : nullptr;
}

/// \brief manage the cursor for a contiguous selection
/// \param yorn select when true , deselect when false
/// \param cursor
void ArrayTagP::select(bool yorn, const QTextCursor &cursor)
{
    if (cursor.isNull()) {
        if (yorn) {
            if (!__document_p)
                return;
            __cursor = QTextCursor(__document_p);
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
bool ArrayTagP::isSelected(const Tag *tag_p) const
{
    if (__cursor.isNull() || !tag_p) return false;
    int i = tag_p->selectionStart();
    return __cursor.selectionStart() <= i && i <= __cursor.selectionEnd();
}

//MARK: TextDocument
TextDocument::TextDocument(const QString & text, QObject * parent) : QTextDocument(text, parent),
_arrayTagP     (this, [](const Tag *p) { return p;                    }),
_arrayBookmarkP(this, [](const Tag *p) { return p && p->isBookmark(); }),
_arrayOutlineP (this, [](const Tag *p) { return p && p->isOutline();  })
{
}

QList<const Tag *> TextDocument::getTagPs() const
{
    QList<const Tag *> ans;
    for(const auto &tag: _tags) {
        ans << &tag;
    }
    return ans;
}

void TextDocument::addTag(const Tag *tag_p)
{
    if (!tag_p) return;
    auto index = tag_p->selectionStart();
    auto it = _tags.rbegin();
    while(it != _tags.rend() && it->selectionStart() > index) {
        ++it;
    }
    _tags.insert(it.base(), tag_p);
    tag_p->setParent(this);
    emit tagsChanged();
    _arrayTagP.update();
    _arrayBookmarkP.update();
    _arrayOutlineP.update();
}

void TextDocument::addTag(const QTextCursor & c, const int level, const QString & text)
{
    addTag(new Tag(c, level, text));
}

void TextDocument::addTag(const Tag::Type type,
                          const int level,
                          const int index,
                          const int length,
                          const QRegularExpressionMatch & match)
{
    QTextCursor c = QTextCursor(this);
    c.setPosition(index);
    c.setPosition(index+length, QTextCursor::KeepAnchor);
    c.movePosition(QTextCursor::StartOfBlock);
    addTag(new Tag(type, level, c, match));
}
unsigned int TextDocument::removeTags(int offset, int len)
{
    unsigned int removed = 0;
    auto start = _tags.begin();
    while(start != _tags.end() && start->selectionStart() < offset) {
        ++start;
    }
    auto end = start;
    offset += len;
    while(end != _tags.end() && end->selectionStart() < offset) {
        (*end)->setParent(nullptr); // no more ownership.
        delete *end;
        ++removed;
        ++end;
    }
    if (removed > 0) {
        _tags.erase(start, end);
        emit tagsChanged();
        _arrayTagP.update();
        _arrayBookmarkP.update();
        _arrayOutlineP.update();
    }
    return removed;
}

} // namespace Document
} // namespace Tw
