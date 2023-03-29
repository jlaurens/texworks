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
#ifndef Document_TextDocument_H
#define Document_TextDocument_H

#include "document/Document.h"

#include <QVariant>
#include <QTextCursor>
#include <QTextDocument>
#include <QRegularExpressionMatch>

namespace Tw {
namespace Document {

class TagArray;

struct Tag {
    enum class Type {Unknown, Bookmark, Outline};
    struct TypeName {
        static const QString Unknown;
        static const QString Bookmark;
        static const QString Outline;
    };
    static Type typeForName(const QString &name);
    static const QString nameForType(Type type);
    enum class Subtype {Unknown, MARK, TODO};
    struct SubtypeName {
        static const QString Unknown;
        static const QString MARK;
        static const QString TODO;
    };
    static Subtype subtypeForName(const QString &name);
    static const QString nameForSubtype(Subtype type);
    Type type;
    Subtype subtype;
    int level;
    QTextCursor cursor;
    QString text;
    QString tooltip;
    bool operator==(Tag &);
};

class TagArray: public QObject {
    Q_OBJECT
private:
    QVector<Tag> __tags;
    int __currentIndex;
public:
    const Tag *get_p(const int index) const;
    const Tag *getCurrent_p() const;
    int getCurrentIndex() const;
    void setCurrent(const int index);
    void setCurrent(const Tag &tag);
    void add(const Tag::Type type,
             const Tag::Subtype subype,
             const int level,
             const QTextCursor & cursor,
             const QString & text,
             const QString & tooltip);
    unsigned int remove(int offset, int len);
    const QVector<Tag> & getTags() const;
    QVector<Tag>::const_iterator begin() const;
    QVector<Tag>::const_iterator end() const;
    bool empty() const;
signals:
    void changed() const;
};

class TextDocument : public QTextDocument, public Document
{
	Q_OBJECT
public:
	explicit TextDocument(QObject * parent = nullptr);
	explicit TextDocument(const QString & text, QObject * parent = nullptr);

    const QVector<Tag> & getTags() const;
    void addTag(const QTextCursor & c, const int level, const QString & text);
    
    void addTag(const Tag::Type type,
                const int level,
                const int index,
                const int length,
                const QRegularExpressionMatch & match);
    unsigned int removeTags(int offset, int len);
    const TagArray & getTagArray()      const { return _tagArray;      }
    const TagArray & getBookmarkArray() const { return _bookmarkArray; }
    const TagArray & getOutlineArray()  const { return _outlineArray;  }
    TagArray & getMutableTagArray()      { return _tagArray;      }
    TagArray & getMutableBookmarkArray() { return _bookmarkArray; }
    TagArray & getMutableOutlineArray()  { return _outlineArray;  }

signals:
    void tagsChanged() const;
    void bookmarksChanged() const;
    void outlinesChanged() const;

protected:
    TagArray _tagArray;
    TagArray _bookmarkArray;
    TagArray _outlineArray;
};

} // namespace Document
} // namespace Tw

Q_DECLARE_METATYPE(Tw::Document::Tag *) // for QVariant usage
Q_DECLARE_METATYPE(const void *) // for QVariant usage

#endif // !defined(Document_TextDocument_H)
