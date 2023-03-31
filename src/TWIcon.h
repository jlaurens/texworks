/*
    This is part of TeXworks, an environment for working with TeX documents
    Copyright (C) 2007_2022  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

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
struct Icon {
// categories
    static const QIcon preferences_system();
// actions
    static const QIcon document_new();
    static const QIcon document_open();
    static const QIcon document_save();

    static const QIcon go_down();
    static const QIcon go_first();
    static const QIcon go_jump();
    static const QIcon go_last();
    static const QIcon go_next();
    static const QIcon go_previous();
    static const QIcon go_up();

    static const QIcon list_add();
    static const QIcon list_remove();

    static const QIcon process_start();
    static const QIcon process_stop();

    static const QIcon edit_find();
    static const QIcon edit_find_replace();
    static const QIcon edit_cut();
    static const QIcon edit_copy();
    static const QIcon edit_paste();
    static const QIcon edit_undo();
    static const QIcon edit_redo();

    static const QIcon format_indent_less();
    static const QIcon format_indent_more();

    static const QIcon TODO();
    static const QIcon MARK();
    static const QIcon Outline();

};

}
#endif // TW_ICON_H
