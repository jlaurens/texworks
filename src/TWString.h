/*
    This is part of TeXworks, an environment for working with TeX documents
    Copyright (C) 2007-2022  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

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

/*! \brief Collection of static strings.
 *
 *  Literal strings are used only once in definitions to avoid typos.
 *
 */

#ifndef TW_STRING_H
#define TW_STRING_H

#include <QString>

namespace Tw {

/*! \brief For general purpose strings.
 */
namespace String {

}

/*! \brief QWidget object names.
 */
namespace ObjectName {

extern const QString toolbar;
extern const QString list_add;
extern const QString list_remove;
extern const QString Tags;
extern const QString Bookmarks;
extern const QString Outlines;

}

/*! \brief Type display names.
 */
struct TypeName {

    static const QString Bookmark;
    static const QString Outline;
    static const QString Unknown;

};

/*! \brief Keys in maps and similar usage.
 */
namespace Key {


}

}
#endif // TW_STRING_H
