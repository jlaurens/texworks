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

/*! \brief Collection of shared static strings.
 *
 *  Literal strings are used only once in definitions.
 *  The compiler guards again typos.
 *
 */

#ifndef TW_STRING_H
#define TW_STRING_H

#include <QString>

namespace Tw {

/*!
 \brief Path related
 */
namespace Path {

extern const QString setup_ini;

}

/*! \brief For general purpose strings.
 */
namespace String {

extern const QString pathListSeparator;
extern const QString exeExtension;

}

/*! \brief QWidget object names.
 */
namespace ObjectName {

}

/*! \brief Type display names.
 */
namespace TypeName {

};

/*! \brief Keys in maps and similar usage.
 */
namespace Key {


}

}
#endif // TW_STRING_H
