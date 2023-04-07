/*
    This is part of TeXworks, an environment for working with TeX documents
    Copyright (C) 2023  Jérôme Laurens

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

namespace Path {

const QString setup_ini = QStringLiteral("texworks_setup.ini");

}
namespace String {

#if defined(Q_OS_WIN)
const QString pathListSeparator = QStringLiteral(";");
const QString exeExtension = QStringLiteral(".exe");
#else
const QString pathListSeparator = QStringLiteral(":");
const QString exeExtension = QStringLiteral("");
#endif

}

namespace TypeName {

}

namespace ObjectName {

const QString textEdit_m    = QStringLiteral("textEdit_m");

} // namespace ObjectName

} // namespace Tw
