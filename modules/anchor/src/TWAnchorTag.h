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
 These tags are collected and displayed in docks, see `TWDockTree.h`.
 
## Implementation details.
 Any `Tag` instance contains informations about one particular tag: its text, tooltip, type, subtype, level
 and finally a text cursor indicating the start of the line where the tag belongs in some `TextDocument` instance. All these informations are known at creation time
 and are never modified afterwards. Actually, `Tag` instances are created when the `TeXHighlighter`parses the document but this may change in the future.
 `Tags` are owned and created by a `Bank` instance. There are various tree widgets that display
 a subset of all tags these maintained in one of three `Suite`'s: one for the outline tags, one for the tag marks and one for all of them. The very same `Tag` instance may be hold by different objects.
 The `QTreeWidget` instances will recreate their inner `QTreeWidgetItem` instances based on
 the available tags. The list is updated each time tags are removed or created while editing the text.
 In order to keep the corresponding items expanded or selected, we store supplemental information
 based on the cursor.
 */
#ifndef TWAnchor_Tag_H
#define TWAnchor_Tag_H

#include "TWAnchorParser.h"

#include <QVariant>
#include <QTextCursor>
#include <QTextDocument>
#include <QRegularExpression>
#include <QRegularExpressionMatch>

class QTextEdit;
class QTreeWidgetItem;

namespace TWAnchor {

namespace UnitTest {
class TagTest; // This class may exist uniquely while testing, friend of everyone.
}

using Text    = QString;
using Tooltip = QString;

class Tag;
class Bank;
class Banker;
class Suite;

extern const QString kNameBank;

extern void setBank(QObject *, Bank *); /*!< Set the bank of any object */
extern Bank *getBank(QObject *); /*!< Get the bank of any object, if any. */

/**
 The `Banker` makes the changes to the `Bank` but let the `Bank` emit its `changed`
 signal only once all expected modifications are performed.
 Scoped instances are created on the stack.
 */
class Banker
{
    QTextDocument *document_m;
public:
    Banker(QTextDocument *document);
    ~Banker();
    bool addTag(const Rule *rule,
                const int position,
                const QRegularExpressionMatch &match);/*!< The only public way to create a new Tag. */
    unsigned int removeTags(int offset, int len);

    friend class UnitTest::TagTest;
};

using Filter = std::function<bool(const Tag *)>; // to pick up only some tags

class Tag: public QObject
{
    using Super   = QObject;
private:
    const Rule *rule_m;
    Type::type  type_m;
    Level       level_m;
    QTextCursor cursor_m;
    Text        text_m;
    Tooltip     tooltip_m;
    /**
     Private constructor only available to `Bank::makeTag` method.
     */
    Tag(      Bank *,
        const Rule *,
        const Type::type,
        const Level,
        const QTextCursor &,
        const Text        &,
        const Tooltip     &);
public:
    QTextDocument *document() const;
    const Bank *bank() const;
    const Rule *rule() const;
    const Mode::type mode();
    const Category::type category();
    const Type::type type();
          Level level() const;
    const QTextCursor &cursor() const;
    const Text &text() const;
    const Tooltip &tooltip() const;
    Level  position() const;
    bool isMode(Mode::type) const;
    bool isCategory(Category::type) const;
    bool isType(Type::type) const;
    bool isCategoryMagic() const;
    bool isCategoryBookmark() const;
    bool isCategoryOutline() const;
    bool isTypeMARK() const;
    bool isTypeTODO() const;
    bool isTypeBORDER() const;
    bool isBoundary() const;
    bool operator==(Tag &rhs);

    friend bool Banker::addTag(const Rule *,
                               const int,
                               const QRegularExpressionMatch &);

    friend class UnitTest::TagTest;
}; // class Tag

class Bank: public QObject
{
    Q_OBJECT
    using Super = QObject;
    QList<const Tag *> tags_m;
    QList<Suite *> suites_m;
public:
    explicit Bank(QObject *parent); /*!< The parent may not be null. */
    const QList<const Tag *> tags() const;
    void willChange(); /*!< Forwards the message to all the owned suites. */
    void didChange(); /*!< Forwards the message to all the owned suites. */
signals:
    void changed() const;
public:
    friend class Banker; /*!< Management of Tag's is delegated to a `Tagger` instance. */
    Suite *makeSuite(Filter); /*!< Create a new suite owned by the receiver. */

    friend class UnitTest::TagTest;
}; // class Bank

/**
 `Suite` instances are owned by `Bank` instances and created only by them.
 */
class Suite: public QObject
{
    Q_OBJECT
    using Super = QObject;
    QList<const Tag *> tags_m; /*!< List of chosen tags. */
    Filter filter_m;
    Suite(Bank *, Filter);
public:
    friend Suite *Bank::makeSuite(Filter);
    const Bank *bank() const; /*!< The owner is a Tag bank. */
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
}; // class Suite

} // namespace TWAnchor

Q_DECLARE_METATYPE(const TWAnchor::Tag *) // for QVariant usage

#endif // #ifndef TWAnchor_Tag_H
