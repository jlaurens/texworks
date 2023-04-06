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
#include "TWUtils.h"
#include "utils/ResourcesLibrary.h"

#include <QString>
#include <QDebug>
#include <QTreeWidgetItem>

namespace Tw {
namespace Document {

/// \file Tag model
/// \author JL

// types declared in the pattern-tags.txt file
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

//MARK: Tag static
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

Tag::Subtype Tag::subtypeForMatch(const QRegularExpressionMatch &match) {
    return subtypeForName(match.captured(__::kKeyType));
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

const QList<const Tag::Rule *> Tag::rules()
{
    static QList<const Rule *> rules;
    if (rules.empty()) {
        // read tag-recognition patterns
        QFile file(::Tw::Utils::ResourcesLibrary::getTagPatternsPath());
        if (file.open(QIODevice::ReadOnly)) {
            QRegularExpression whitespace(QStringLiteral("\\s+"));
            while (true) {
                QByteArray ba = file.readLine();
                if (ba.size() == 0)
                    break;
                if (ba[0] == '#' || ba[0] == '\n')
                    continue;
                QString line = QString::fromUtf8(ba.data(), ba.size());
                QStringList parts = line.split(whitespace, Qt::SkipEmptyParts);
                if (parts.size() != 3)
                    continue;
                bool ok{false};
                Type type = typeForName(parts[0]);
                if (type != Type::Any) {
                    int level = parts[1].toInt(&ok);
                    if (ok) {
                        auto pattern = QRegularExpression(parts[2]);
                        if (pattern.isValid()) {
                            const Rule *r = new Rule(type, level, pattern);
                            rules << r;
                        } else {
                            qWarning() << "Wrong tag pattern:" << parts[2];
                        }
                    }
                }
            }
        }
    }
    return rules;
}


//MARK: Tag
Tag::Tag(const Type    type,
         const Subtype subtype,
         const int     level,
         const QTextCursor &cursor,
         const QString     &text,
         const QString     &tooltip,
         TagBank           *bank):
type_m   (type),
subtype_m(subtype),
level_m  (level),
cursor_m (cursor),
text_m   (text),
tooltip_m(tooltip),
bank_m   (bank)
{
    Q_ASSERT(bank);
}

const TagBank *Tag::bank() const
{
    return bank_m;
}

TextDocument *Tag::document() const
{
    return bank_m->document();
}

int Tag::level() const
{
    return level_m;
}

const QString &Tag::text() const
{
    return text_m;
}

const QString &Tag::tooltip() const
{
    return tooltip_m;
}

const QTextCursor &Tag::cursor() const
{
    return cursor_m;
}

int  Tag::position()const
{
    return cursor_m.position();
}

bool Tag::isOfType(Type t) const
{
    return type_m == t;
}

bool Tag::isMagic() const
{
    return type_m == Type::Magic;
}

bool Tag::isBookmark() const
{
    return type_m == Type::Bookmark;
}

bool Tag::isOutline() const
{
    return type_m == Type::Outline;
}

bool Tag::isMARK() const
{
    return subtype_m == Subtype::MARK;
}

bool Tag::isTODO() const
{
    return subtype_m == Subtype::TODO;
}

bool Tag::isBORDER() const
{
    return subtype_m == Subtype::BORDER;
}

bool Tag::isBoundary() const
{
    return isMagic() || isBORDER();
}

bool Tag::operator==(Tag &rhs)
{
    return position() == rhs.position();
}

//MARK: Tag::Rule
Tag::Rule::Rule(Type type,
                int level,
                const QRegularExpression & pattern):
type_m(type),
level_m(level),
pattern_m(pattern)
{}

//MARK: TagBank
TagBank::TagBank(TextDocument *parent): Super(parent)
{
    // no destructor available, install a signal listener instead
    connect(this, &QObject::destroyed, this, [=]() {
        for (auto *suite: suites_m) {
            delete suite;
        }
        suites_m.clear();
        for (auto *tag: tags_m) {
            delete tag;
        }
        tags_m.clear();
    });
}

TagSuite *TagBank::makeSuite(Tag::Filter filter)
{
    suites_m << new TagSuite(this, filter);
    return suites_m.last();
}

TextDocument *TagBank::document() const
{
    return static_cast<TextDocument *>(parent());
}

const QList<const Tag *> TagBank::tags() const
{
    return tags_m;
};

void TagBank::willChange()
{
    for(auto *suite: suites_m) {
        suite->willChange();
    }
}

void TagBank::didChange()
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

//MARK: Tag::BankHelper
Tag::BankHelper::BankHelper(TextDocument *document): document_m(document)
{
    Q_ASSERT(document_m);
    document_m->tagBank()->willChange();
}

Tag::BankHelper::~BankHelper() {
    document_m->tagBank()->didChange();
}

void Tag::BankHelper::addTag(const Tag::Rule *rule,
                             const int position,
                             const QRegularExpressionMatch &match)
{
    Q_ASSERT(rule);
    auto subtype = subtypeForMatch(match);
    
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
    auto *bank = document_m->tagBank();
    auto *tag = new Tag(rule->type(),
                        subtype,
                        rule->level(),
                        cursor,
                        text,
                        tooltip,
                        bank
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
        tags.insert(i, tag);
        tag = nullptr;
        break;
    }
    if (tag) {
        tags.insert(0, tag);
    }
}

unsigned int Tag::BankHelper::removeTags(int offset, int len)
{
    unsigned int removed = 0;
    auto *bank = document_m->tagBank();
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

//MARK: TagSuite

TagSuite::TagSuite(TagBank *bank, Tag::Filter filter): Super(bank),
filter_m(filter)
{
    Q_ASSERT(bank);
}

const TagBank *TagSuite::bank() const
{
    return static_cast<TagBank *>(parent());
}

TextDocument *TagSuite::document() const
{
    return bank()->document();
}

QList<const Tag *> TagSuite::tags() const
{
    return tags_m;
}

bool TagSuite::isEmpty() const
{
    return tags_m.isEmpty();
}

const Tag *TagSuite::at(const int i) const
{
    return 0 <= i && i < tags_m.count() ? tags_m.at(i) : nullptr;
}

int TagSuite::indexOf(const Tag *tag) const
{
    return tags_m.indexOf(tag);
}

void TagSuite::emitChange()
{
    emit willChange();
    emit didChange();
}

void TagSuite::update()
{
    tags_m.clear();
    const auto tags = bank()->tags();
    qDebug() << tags.size();
    for (const Tag *tag: tags) {
        if (tag && filter_m(tag))
            tags_m << tag;
    }
}

} // namespace Document
} // namespace Tw
