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

#include "TWString.h"

/// \author JL

namespace Tw {

namespace String {

#if defined(Q_OS_WIN)
const QString pathListSeparator = QStringLiteral(";");
const QString exeExtension = QStringLiteral(".exe");
#else
const QString pathListSeparator = QStringLiteral(":");
const QString exeExtension = QStringLiteral("");
#endif

}

const QString TypeName::Bookmark = QStringLiteral("Bookmark");
const QString TypeName::Outline  = QStringLiteral("Outline");
const QString TypeName::Unknown  = QStringLiteral("Unknown");

const QString ObjectName::treeWidget  = QStringLiteral("Tw.treeWidget");
const QString ObjectName::toolbar     = QStringLiteral("Tw.toolbar");
const QString ObjectName::list_add    = QStringLiteral("Tw.list_add");
const QString ObjectName::list_remove = QStringLiteral("Tw.list_remove");
const QString ObjectName::Tags        = QStringLiteral("Tw.Tags");
const QString ObjectName::Bookmarks   = QStringLiteral("Tw.Bookmarks");
const QString ObjectName::Outlines    = QStringLiteral("Tw.Outlines");

}
