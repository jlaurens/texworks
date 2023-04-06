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

/**
## Presentation
 Tags are text extracts that fulfill some conditions.
 We have magic comments at lines starting with `% TeX:` or `LaTeX` sectionning commands.
 These tags are collected and displayed in docks, see `TWTeXDockTree.h`.
 
## Implementation details.
 Any `Tag` instance contains informations about one particular tag: its text, tooltip, type, subtype, level
 and finally a text cursor indicating the start of the line where the tag belongs in some `TextDocument` instance. All these informations are known at creation time
 and are never modified afterwards. Actually, `Tag` instances are created when the `TeXHighlighter`parses the document but this may change in the future.
 `Tags` are owned and created by a `TagBank` instance. There are various tree widgets that display
 a subset of all tags these maintained in one of three `TagSuite`'s: one for the outline tags, one for the tag marks and one for all of them. The very same `Tag` instance may be hold by different objects.
 The `QTreeWidget` instances will recreate their inner `QTreeWidgetItem` instances based on
 the available tags. The list is updated each time tags are removed or created while editing the text.
 In order to keep the corresponding items expanded or selected, we store supplemental information
 based on the cursor.
 */
#ifndef TW_DOCUMENT_TAG_H
#define TW_DOCUMENT_TAG_H

#include "document/Document.h"

#include <QVariant>
#include <QTextCursor>
#include <QTextDocument>
#include <QRegularExpression>
#include <QRegularExpressionMatch>

class QTextEdit;
class QTreeWidgetItem;

namespace Tw {
namespace Document {
namespace UnitTest {
class TagTest; // This class may exist uniquely while testing, friend of everyone.
}
class TextDocument;

class Tag;
class TagBank;
class TagSuite;

class Tag
{
public:
    enum class Type {Any, Magic, Bookmark, Outline};
    struct TypeName {
        static const QString Any;
        static const QString Magic;
        static const QString Bookmark;
        static const QString Outline;
    };
    static Type typeForName(const QString &name);
    static const QString nameForType(Type type);
    enum class Subtype {Any, MARK, TODO, BORDER};
    struct SubtypeName {
        static const QString Any;
        static const QString MARK;
        static const QString TODO;
        static const QString BORDER;
    };
    static Subtype subtypeForName(const QString &name);
    static Subtype subtypeForMatch(const QRegularExpressionMatch &match);
    static const QString nameForSubtype(Subtype type);
    
    class Rule
    {
        Type type_m;
        int level_m;
        QRegularExpression pattern_m;
    public:
        Rule(Type, int, const QRegularExpression &);
        Type type() const { return type_m; };
        int level() const { return level_m; };
        const QRegularExpression &pattern() const { return pattern_m; };
    };
    
    class BankHelper;
    
    using Filter = std::function<bool(const Tag *)>; // to pick up only some tags
    
    struct State
    {
        bool isSelected;
        bool isCollapsed;
    };
    
    static const QList<const Rule *> rules();
    
private:
    Type    type_m;
    Subtype subtype_m;
    int          level_m;
    QTextCursor  cursor_m;
    QString      text_m;
    QString      tooltip_m;
    TagBank     *bank_m;
    /**
     Private constructorc only available to `TagBank::makeTag` method.
     */
    Tag(const Type,
        const Subtype,
        const int,
        const QTextCursor&,
        const QString& text,
        const QString& tooltip,
        TagBank *bank);
public:
    TextDocument *document() const;
    const TagBank *bank() const;
    int level() const;
    const QString &text() const;
    const QString &tooltip() const;
    const QTextCursor &cursor() const;
    int  position() const;
    bool isOfType(Type t) const;
    bool isMagic() const;
    bool isBookmark() const;
    bool isOutline() const;
    bool isMARK() const;
    bool isTODO() const;
    bool isBORDER() const;
    bool isBoundary() const;
    bool operator==(Tag &rhs);
public:
    /**
     The `BankHelper` makes the changes to the `TagBank` but let the `TagBank` emit its `changed`
     signal only once all expected modifications are performed.
     Scoped instance are created on the stack.
     */
    class BankHelper
    {
        TextDocument *document_m;
    public:
        BankHelper(TextDocument *document);
        ~BankHelper();
        void addTag(const Rule *rule,
                    const int position,
                    const QRegularExpressionMatch &match);/*!< The only public way to create a new Tag. */
        unsigned int removeTags(int offset, int len);

        friend class UnitTest::TagTest;
    };
    
public:
    friend void BankHelper::addTag(const Rule *,
                                   const int,
                                   const QRegularExpressionMatch &);
    
    
    friend class UnitTest::TagTest;
}; // class Tag

class TagBank: public QObject
{
    Q_OBJECT
    using Super = QObject;
    QList<const Tag *> tags_m;
    QList<TagSuite *>  suites_m;
public:
    explicit TagBank(TextDocument *parent); /*!< The parent may not be null. */
    TextDocument *document() const; /*!< The owner is the parent. */
    const QList<const Tag *> tags() const;
    void willChange(); /*!< Forwards the message to all the owned suites. */
    void didChange(); /*!< Forwards the message to all the owned suites. */
signals:
    void changed() const;
public:
    friend class Tag::BankHelper; /*!< Management of Tag's is delegated to a `Tagger` instance. */
    TagSuite *makeSuite(Tag::Filter); /*!< Create a new suite owned by the receiver. */

    friend class UnitTest::TagTest;
}; // class TagBank

/**
 `TagSuite` instances are owned by `TagBank`instances and created only by them.
 */
class TagSuite: public QObject
{
    Q_OBJECT
    using Super = QObject;
    QList<const Tag *> tags_m; /*!< List of chosen tags. */
    Tag::Filter        filter_m;
    TagBank           *bank_m;
    TagSuite(TagBank *, Tag::Filter);
public:
    friend TagSuite *TagBank::makeSuite(Tag::Filter);
    const TagBank *bank() const; /*!< The owner is a Tag bank. */
    TextDocument *document() const; /*!< Shortcut to the owner of the owning Tag bank. */
    bool isEmpty() const;
    QList<const Tag *> tags() const; /*!< Copy of the internal list. */
    const Tag *at(const int) const;
    int indexOf(const Tag *tag) const;
    void update();
    void emitChange();
signals:
    void willChange();
    void didChange();
    
    friend class UnitTest::TagTest;
}; // class TagSuite

} // namespace Document
} // namespace Tw

Q_DECLARE_METATYPE(Tw::Document::Tag *) // for QVariant usage
Q_DECLARE_METATYPE(const void *) // for QVariant usage

#endif // ifndef TW_DOCUMENT_TAG_H
