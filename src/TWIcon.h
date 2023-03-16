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

#ifndef TW_ICON_H
#define TW_ICON_H

#include <QIcon>

namespace Tw {

/*! \brief Only known icons .
 */
namespace Icon {

const QIcon edit_find();
const QIcon edit_paste();
const QIcon edit_redo();
const QIcon edit_undo();
const QIcon format_indent_less();
const QIcon format_indent_more();
const QIcon go_down();
const QIcon go_first();
const QIcon go_jump();
const QIcon go_last();
const QIcon go_next();
const QIcon go_previous();
const QIcon go_up();
const QIcon list_add();
const QIcon list_remove();
const QIcon process_start();
const QIcon process_stop();

}

}
#endif // TW_ICON_H
