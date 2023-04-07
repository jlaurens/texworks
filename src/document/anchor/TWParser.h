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
#ifndef Tw_Document_Anchor_Parser_H
#define Tw_Document_Anchor_Parser_H

#include <QObject>

namespace Tw {
namespace Document {
namespace Anchor {

namespace UnitTest {

class ParserTest;// These classes may exist uniquely while testing, friend of everyone.
class SyntaxTest;
class RuleTest;

}

class Parser;
class Syntax;
class Rule;

using Mode     = QString;
using Category = QString;
using Name     = QString;

class Parser: public QObject
{
    Q_OBJECT
    using Super    = QObject;
    

    static QList<Category> categories_m;
    static QList<Mode>     modes_m;
        
    class Rule;

public:

    void reload();

    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
}; // class Parser

class Syntax: public QObject
{
    Q_OBJECT
    using Super = QObject;
    using Self  = Syntax;
    
    QList<Category> categories_m;
    QList<Mode>     modes_m;
    
    Syntax(Parser *, const QString &);
public:
    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
};

class Rule: public QObject
{
    Q_OBJECT
    using Super = QObject;

    Rule(Parser *);
public:
    friend class UnitTest::RuleTest;
    friend class UnitTest::SyntaxTest;
    friend class UnitTest::ParserTest;
};

} // namespace Anchor
} // namespace Document
} // namespace Tw

#endif // ifndef Tw_Document_Anchor_Parser_H
