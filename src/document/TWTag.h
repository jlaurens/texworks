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
#ifndef TW_DOCUMENT_TAG_H
#define TW_DOCUMENT_TAG_H

#include "document/Document.h"

#include <QVariant>
#include <QTextCursor>
#include <QTextDocument>
#include <QRegularExpressionMatch>

/// \brief

namespace Tw {
namespace Document {
namespace UnitTest {
class TestTag;
}
class TextDocument;
class TagBank;

class Tag: public QObject {
    friend UnitTest::TestTag;
    Q_OBJECT
public:
    enum class Type {Any, Bookmark, Outline};
    struct TypeName {
        static const QString Any;
        static const QString Bookmark;
        static const QString Outline;
    };
    static Type typeForName(const QString &name);
    static const QString nameForType(Type type);
    enum class Subtype {Any, MARK, TODO, BEGIN_CONTENT, END_CONTENT};
    struct SubtypeName {
        static const QString Any;
        static const QString MARK;
        static const QString TODO;
        static const QString BEGIN_CONTENT;
        static const QString START_CONTENT;
        static const QString END_CONTENT;
        static const QString STOP_CONTENT;
    };
    static Subtype subtypeForName(const QString &name);
    static const QString nameForSubtype(Subtype type);
private:
    Type        __type;
    Subtype     __subtype;
    int         __level;
    QTextCursor __cursor;
    QString     __text;
    QString     __tooltip;
    bool        __error;
public:
    int level()             const { return __level;               };
    const QString text()    const { return __text;                };
    const QString tooltip() const { return __tooltip;             };
    QTextCursor   cursor()  const { return QTextCursor(__cursor); };
public:
    Tag(const Type,
        const Subtype,
        const int,
        const QTextCursor &,
        const QString& text,
        const QString& tooltip,
        TagBank *parent);
    Tag(const Type,
        const int,
        const QTextCursor &,
        const QRegularExpressionMatch &,
        TagBank *parent);
    Tag(const QTextCursor &,
        const int level,
        const QString &,
        TagBank *parent);
    const TagBank *bank() const;
    TextDocument *document() const;
    int  selectionStart()  const { return __cursor.selectionStart();  };
    bool isOfType(Type t)  const { return __type == t;                };
    bool isBookmark()      const { return __type == Type::Bookmark;   };
    bool isOutline()       const { return __type == Type::Outline;    };
    bool isMARK()          const { return __subtype == Subtype::MARK; };
    bool isTODO()          const { return __subtype == Subtype::TODO; };
    bool isCONTENT()       const {
        return __subtype == Subtype::BEGIN_CONTENT
            || __subtype == Subtype::END_CONTENT; };
    bool isBEGIN_CONTENT() const { return __subtype == Subtype::BEGIN_CONTENT; };
    bool isEND_CONTENT()   const { return __subtype == Subtype::END_CONTENT; };
    bool hasError()        const { return __error;                    };
    void setError(bool yorn)     { __error = yorn;                    };
    bool operator==(Tag &rhs)    { return __cursor == rhs.__cursor;   };
};

class TagSuite: QObject {
    friend UnitTest::TestTag;
    Q_OBJECT
    using Filter = std::function<bool(const Tag *)>; // to pick up only some tags
private:
    bool               __active;
    QList<const Tag *> __tags;
    QTextCursor        __cursor; // selection
    Filter             __filter;
public:
    TagSuite(TagBank *, Filter);
    const TagBank *bank() const;
    TextDocument * document() const;
    bool isEmpty() const { return __tags.isEmpty(); };
    QList<const Tag *> tags();
    void update(bool activate = false);
    void clear() { __tags.clear(); };
    const Tag *get(const int);
    void select(bool, const QTextCursor &c = QTextCursor());
    bool isSelected(const Tag *) const;
signals:
    void changed() const;
};

class TagBank: public QObject
{
    friend UnitTest::TestTag;
	Q_OBJECT
public:
	explicit TagBank(TextDocument *parent);
    TextDocument *document() const;
    const QList<const Tag *> tags() const { return _tags; };
    void addTag(Tag *);
    bool addTag(const QTextCursor & c, const int level, const QString & text);
    void addTag(const Tag::Type type,
                const int level,
                const int index,
                const int length,
                const QRegularExpressionMatch & match);
    unsigned int removeTags(int offset, int len);
    TagSuite *suiteTag()      const { return _suiteTag;      };
    TagSuite *suiteBookmark() const { return _suiteBookmark; };
    TagSuite *suiteOutline()  const { return _suiteOutline;  };
    TagSuite *suiteCONTENT()  const { return _suiteCONTENT;  };

signals:
    void changed() const;

protected:
    QList<const Tag *> _tags;
    TagSuite *_suiteTag;
    TagSuite *_suiteBookmark;
    TagSuite *_suiteOutline;
    TagSuite *_suiteCONTENT;
};

} // namespace Document
} // namespace Tw

Q_DECLARE_METATYPE(Tw::Document::Tag *) // for QVariant usage
Q_DECLARE_METATYPE(const void *) // for QVariant usage

#endif // ifndef TW_DOCUMENT_TAG_H
