/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023 Jérôme Laurens

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
Static methods are gathered to parse text for tags.
 */
#ifndef TW_Anchor_Parser_H
#define TW_Anchor_Parser_H

#include <QRegularExpression>
#include <QFileInfo>

namespace Tw {
namespace Anchor {

namespace UnitTest {

class ParserTest;// These classes may exist uniquely while testing, friend of everyone.
class SyntaxTest;
class RuleTest;

}

namespace Mode {
using type = QString;
extern const type plain;
extern const type latex;
extern const type dtx;
extern const type context;
}

namespace Category {
using type = QString;
extern const type Magic;
extern const type Bookmark;
extern const type Outline;
}

namespace Type {
using type = QString;
extern const type MARK;
extern const type TODO;
extern const type BORDER;
}


using ID       = QString;
using Name     = QString;
using Level    = int;
using Path     = QString;

class Parser;
class Syntax;
class Rule;

class Parser: public QObject
{
    Q_OBJECT
    
    using Super    = QObject;
    
    const Syntax *syntax_m;
    
public:
    static Syntax *newSyntax(const Path &);
    Parser(Syntax *, QObject * = nullptr);

    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
}; // class Parser

class Syntax: public QObject
{
    Q_OBJECT
    using Super = QObject;
    using Self  = Syntax;
    
    QList<Category::type> categories_m;
    QList<Mode::type>     modes_m;
    QList<Rule *>         rules_m;
    Syntax(Parser *, const QString &);
public:
    Rule * makeRule(Mode::type, QString);

    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
};

class Rule: public QObject
{
    Q_OBJECT
    using Super = QObject;

    QList<Mode::type> modes_m;
    Category::type category_m;
    Level level_m;
    bool  relative_m;
    QRegularExpression pattern_m;
    Rule(Syntax *, Mode::type, ID, int, const QRegularExpression &);
public:
    friend Rule * Syntax::makeRule(Mode::type, QString);
    QList<Mode::type> modes()           const { return modes_m; };
    Category::type category()           const { return category_m; };
    Level level()                       const { return level_m; };
    bool relative()                     const { return relative_m; }
    const QRegularExpression &pattern() const { return pattern_m; };

    bool isMode(Mode::type mode) const;
    bool isCategory(Category::type category) const;

    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
};


} // namespace Anchor
} // namespace Tw

#endif // ifndef TW_Anchor_Parser_H
