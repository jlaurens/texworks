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

#include "TWIcon.h"
#include <QString>

/// \author JL

namespace Tw {

const QIcon Icon::preferences_system()
{
    return QIcon::fromTheme(QStringLiteral("preferences-system"));
}

const QIcon Icon::document_new()
{
    return QIcon::fromTheme(QStringLiteral("document-new("));
}
const QIcon Icon::document_open()
{
    return QIcon::fromTheme(QStringLiteral("document-open"));
}
const QIcon Icon::document_save()
{
    return QIcon::fromTheme(QStringLiteral("document-save"));
}

const QIcon Icon::edit_find()
{
    return QIcon::fromTheme(QStringLiteral("edit-find"));
}

const QIcon Icon::edit_find_replace()
{
    return QIcon::fromTheme(QStringLiteral("edit-find-replace"));
}

const QIcon Icon::edit_copy()
{
    return QIcon::fromTheme(QStringLiteral("edit-copy"));
}

const QIcon Icon::edit_paste()
{
    return QIcon::fromTheme(QStringLiteral("edit-paste"));
}

const QIcon Icon::edit_undo()
{
    return QIcon::fromTheme(QStringLiteral("edit-undo"));
}

const QIcon Icon::edit_redo()
{
    return QIcon::fromTheme(QStringLiteral("edit-redo"));
}

const QIcon Icon::format_indent_less()
{
    return QIcon::fromTheme(QStringLiteral("format-indent-less"));
}

const QIcon Icon::format_indent_more()
{
    return QIcon::fromTheme(QStringLiteral("format-indent-more"));
}

const QIcon Icon::go_down()
{
    return QIcon::fromTheme(QStringLiteral("go-down"));
}

const QIcon Icon::go_first()
{
    return QIcon::fromTheme(QStringLiteral("go-first"));
}

const QIcon Icon::go_jump()
{
    return QIcon::fromTheme(QStringLiteral("go-jump"));
}

const QIcon Icon::go_last()
{
    return QIcon::fromTheme(QStringLiteral("go-last"));
}

const QIcon Icon::go_next()
{
    return QIcon::fromTheme(QStringLiteral("go-next"));
}

const QIcon Icon::go_previous()
{
    return QIcon::fromTheme(QStringLiteral("go-previous"));
}

const QIcon Icon::go_up()
{
    return QIcon::fromTheme(QStringLiteral("go-up"));
}

const QIcon Icon::list_add()
{
    return QIcon::fromTheme(QStringLiteral("list-add"));
}

const QIcon Icon::list_remove()
{
    return QIcon::fromTheme(QStringLiteral("list-remove"));
}

const QIcon Icon::process_start()
{
    return QIcon::fromTheme(QStringLiteral("process-start"));
}

const QIcon Icon::process_stop()
{
    return QIcon::fromTheme(QStringLiteral("process-stop"));
}

const QIcon Icon::Outline()
{
    return QIcon::fromTheme(QStringLiteral("Outline"));
}

const QIcon Icon::TODO()
{
    return QIcon::fromTheme(QStringLiteral("TODO"));
}

const QIcon Icon::MARK()
{
    return QIcon::fromTheme(QStringLiteral("MARK"));
}

}

