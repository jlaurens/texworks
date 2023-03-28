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
#include <QDebug>

namespace Tw {
namespace Document {

//TODO: Next should move to TWString. (linker problem)
const QString Tag::TypeName::Unknown = QStringLiteral("Unknown");//
const QString Tag::TypeName::Bookmark = QStringLiteral("Bookmark");
const QString Tag::TypeName::Outline = QStringLiteral("Outline");

Tag::Type Tag::typeForName(const QString &name) {
    if (name == Tag::TypeName::Outline) {
        return Tag::Type::Outline;
    }
    if (name == Tag::TypeName::Bookmark) {
        return Tag::Type::Bookmark;
    }
    return Type::Unknown;
}

const QString Tag::nameForType(Tag::Type type) {
    if (type == Tag::Type::Outline) {
        return Tag::TypeName::Outline;
    }
    if (type == Tag::Type::Bookmark) {
        return Tag::TypeName::Bookmark;
    }
    return Tag::TypeName::Unknown;
}

// name of a capture group
static const QString constKeyContent = QStringLiteral("content");
static const QString constKeyType = QStringLiteral("type");

const QVector<Tag> & TagArray::getTags() const
{
    return __tags;
}

const Tag * TagArray::get_p(const int index) const
{
    return 0 <= index && index < __tags.count() ? &(__tags[index]) : nullptr;
}

void TagArray::add(const Tag::Type type, const int level, const QTextCursor & c, const QString & text, const QString & tooltip)
{
    QTextCursor cursor = QTextCursor(c);
    cursor.movePosition(QTextCursor::StartOfBlock);
    int position = cursor.position();
    auto it = __tags.rbegin();
    while(it != __tags.rend() && it->cursor.position() > position) {
        ++it;
    }
    __tags.insert(it.base(), {type, level, cursor, text, tooltip});
    emit changed();
}

unsigned int TagArray::remove(int offset, int len)
{
    unsigned int removed = 0;
    auto start = __tags.begin();
    while(start != __tags.end() && start->cursor.position() < offset) {
        ++start;
    }
    auto end = start;
    offset += len;
    while(end   != __tags.end() && end->cursor.position()   < offset) {
        ++removed;
        ++end;
    }
    if (removed > 0) {
        __tags.erase(start, end);
        emit changed();
    }
    return removed;
}

QVector<Tag>::const_iterator TagArray::begin() const
{
    return __tags.constBegin();
}

QVector<Tag>::const_iterator TagArray::end() const
{
    return __tags.constEnd();
}

const Tag * TagArray::getCurrent_p() const {
    if (__currentIndex >= 0 && __currentIndex < __tags.size())
        return &(__tags[__currentIndex]);
    return nullptr;
}

int TagArray::getCurrentIndex() const {
    return __currentIndex;
}

void TagArray::setCurrent(const int index) {
    __currentIndex = index;
}

void TagArray::setCurrent(const Tag &currentTag) {
    int index = -1;
    for (auto tag: __tags) {
        ++index;
        if(&currentTag == &tag) {
            break;
        }
    }
    __currentIndex = index;
}

bool TagArray::empty() const
{
    return __tags.empty();
}

TextDocument::TextDocument(QObject * parent) : QTextDocument(parent) { }

TextDocument::TextDocument(const QString & text, QObject * parent) : QTextDocument(text, parent) { }

const QVector<Tag> & TextDocument::getTags() const
{
    return _tagArray.getTags();
}

void TextDocument::addTag(const QTextCursor & c, const int level, const QString & text)
{
    _tagArray.add(Tag::Type::Bookmark, level, c, text, QString());
    emit tagsChanged();
}

void TextDocument::addTag(const Tag::Type type, const int level, const int index, const int length, const QRegularExpressionMatch & match)
{
    QString tooltip = QString();
    QString tagText = match.captured(constKeyContent);
    if (tagText.isEmpty()) {
        tagText = match.captured(1);
    }
    if (tagText.isEmpty()) {
        tagText = match.captured(0);
    } else {
        tooltip = match.captured(0);
    }
    // QString typeText = match.captured(constKeyType);
    QTextCursor cursor(this);
    cursor.setPosition(index);
    cursor.setPosition(index + length, QTextCursor::KeepAnchor);
    cursor.movePosition(QTextCursor::StartOfBlock);
    _tagArray.add(type, level, cursor, tagText, tooltip);
    if (type == Tag::Type::Bookmark) {
        _bookmarkArray.add(type, level, cursor, tagText, tooltip);
    } else {
        _outlineArray.add(type, level, cursor, tagText, tooltip);
    }
    emit tagsChanged();
}
unsigned int TextDocument::removeTags(int offset, int len)
{
    unsigned int removed = _tagArray.remove(offset, len);
    if (removed > 0) {
        _bookmarkArray.remove(offset, len);
        _outlineArray.remove(offset, len);
        emit tagsChanged();
    }
    return removed;
}

} // namespace Document
} // namespace Tw
