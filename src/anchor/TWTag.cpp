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

#include "document/TextDocument.h"
#include "anchor/TWTag.h"
#include "anchor/TWParser.h"
#include "TWUtils.h"
#include "utils/ResourcesLibrary.h"

#include <QString>
#include <QDebug>
#include <QTreeWidgetItem>

namespace Tw {
namespace Document {
namespace Anchor {

/// \file Tag model
/// \author JL

// name of a capture group, should be defined more globally because file "tag-patterns.txt" relies on it.
namespace __ {
static const QString kKeyContent = QStringLiteral("content");
static const QString kKeyType    = QStringLiteral("type");
}

const QString kNameBank  = QStringLiteral("Tw.Document.Anchor.Bank");

//MARK: Tag
Tag::Tag(      Bank *bank,
         const Rule *rule,
         const Type::type  type,
         const Level level,
         const QTextCursor &cursor,
         const Text        &text,
         const Tooltip     &tooltip)
    : Super(bank)
    , rule_m   (rule)
    , type_m   (type)
    , level_m  (level)
    , cursor_m (cursor)
    , text_m   (text)
    , tooltip_m(tooltip)
{}

const Bank *Tag::bank() const
{
    return reinterpret_cast<Bank *>(parent());
}

int Tag::level() const
{
    return level_m;
}

const Text &Tag::text() const
{
    return text_m;
}

const Tooltip &Tag::tooltip() const
{
    return tooltip_m;
}

const QTextCursor &Tag::cursor() const
{
    return cursor_m;
}

int Tag::position() const
{
    return cursor_m.position();
}

bool Tag::isMode(Mode::type mode) const
{
    return rule_m->isMode(mode);
}

bool Tag::isCategory(Category::type category) const
{
    return rule_m->isCategory(category);
}

bool Tag::isCategoryMagic() const
{
    return isCategory(Category::Magic);
}

bool Tag::isCategoryBookmark() const
{
    return isCategory(Category::Bookmark);
}

bool Tag::isCategoryOutline() const
{
    return isCategory(Category::Outline);
}

bool Tag::isType(Type::type type) const
{
    return type_m == type;
}

bool Tag::isTypeMARK() const
{
    return type_m == Type::MARK;
}

bool Tag::isTypeTODO() const
{
    return type_m == Type::TODO;
}

bool Tag::isTypeBORDER() const
{
    return type_m == Type::BORDER;
}

bool Tag::isBoundary() const
{
    return isCategoryMagic() || isTypeBORDER();
}

bool Tag::operator==(Tag &rhs)
{
    return position() == rhs.position();
}

//MARK: Static
void setBank(QObject *parent, Bank *bank)
{
    auto * already = getBank(parent);
    if (already == bank) {
        return;
    }
    if (already) {
        already->setParent(nullptr);
    }
    if (bank) {
        bank->setObjectName(kNameBank);
        bank->setParent(parent);
    }
}

Bank *getBank(QObject *parent)
{
    return parent ? parent->findChild<Bank *>(kNameBank, Qt::FindDirectChildrenOnly)
                  : nullptr;
}

//MARK: Bank
Bank::Bank(QObject *parent)
    : QObject(parent)
{}

Suite *Bank::makeSuite(Filter filter)
{
    suites_m << new Suite(this, filter);
    return suites_m.last();
}

const QList<const Tag *> Bank::tags() const
{
    return tags_m;
};

void Bank::willChange()
{
    for(auto *suite: suites_m) {
        suite->willChange();
    }
}

void Bank::didChange()
{
    // model changes
    for(auto *suite: suites_m) {
        suite->update();
    }
    // UI changes are postponed
    for(auto *suite: suites_m) {
        emit suite->didChange();
    }
}

//MARK: Banker
Banker::Banker(QTextDocument *document): document_m(document)
{
    Bank *bank = getBank(document);
    if (bank) {
        bank->willChange();
    }
}

Banker::~Banker() {
    Bank *bank = getBank(document_m);
    if (bank) {
        bank->didChange();
    }
}

bool Banker::addTag(const Rule *rule,
                    const int position,
                    const QRegularExpressionMatch &match)
{
    auto *bank = getBank(document_m);
    if (! bank || ! rule) {
        return false;
    }
    auto type = match.captured(__::kKeyType);
    
    auto cursor = QTextCursor(document_m);
    cursor.setPosition(position);
    cursor.movePosition(QTextCursor::StartOfBlock);

    QString s = match.captured(__::kKeyContent);
    if (s.isEmpty()) {
        s = match.captured(1);
    }
    QString text, tooltip;
    if (s.isEmpty()) {
        text = match.captured(0);
        tooltip = QString();
    } else {
        text = s;
        tooltip = match.captured(0);
    }
    auto *tag = new Tag(bank,
                        rule,
                        type,
                        rule->level(),
                        cursor,
                        text,
                        tooltip
                        );
    auto tags = bank->tags_m;
    int i = tags.size();
    while(i--) {
        const Tag *t = tags.at(i);
        if (t->position() > position) {
            continue;
        }
        if (t->position() == position) {
            delete tags.takeAt(i);
        }
        //TODO: support relative levels
        tags.insert(i, tag);
        tag = nullptr;
        break;
    }
    if (tag) {
        tags.insert(0, tag);
    }
    return true;
}

unsigned int Banker::removeTags(int offset, int len)
{
    unsigned int removed = 0;
    auto *bank = getBank(document_m);
    if (! bank) {
        return removed;
    }
    auto tags = bank->tags_m;
    auto start = tags.begin();
    while(start != tags.end() && (*start)->position() < offset) {
        ++start;
    }
    auto end = start;
    offset += len;
    while(end != tags.end() && (*end)->position() < offset) {
        delete *end;
        ++removed;
        ++end;
    }
    if (removed > 0) {
        tags.erase(start, end);
    }
    return removed;
}

//MARK: Suite

Suite::Suite(Bank *bank, Filter filter)
    : Super(bank)
    , filter_m(filter)
{
    Q_ASSERT(bank);
}

const Bank *Suite::bank() const
{
    return reinterpret_cast<Bank *>(parent());
}


QList<const Tag *> Suite::tags() const
{
    return tags_m;
}

bool Suite::isEmpty() const
{
    return tags_m.isEmpty();
}

const Tag *Suite::at(const int i) const
{
    return 0 <= i && i < tags_m.count() ? tags_m.at(i) : nullptr;
}

int Suite::indexOf(const Tag *tag) const
{
    return tags_m.indexOf(tag);
}

void Suite::emitChange()
{
    emit willChange();
    emit didChange();
}

void Suite::update()
{
    tags_m.clear();
    const auto tags = bank()->tags();
    qDebug() << tags.size();
    for (const Tag *tag: tags) {
        if (tag && filter_m(tag))
            tags_m << tag;
    }
}

} // namespace Anchor
} // namespace Document
} // namespace Tw
