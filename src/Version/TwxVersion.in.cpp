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

#include "Version/TwxVersion.h"

#include <QString>

namespace Twx {
namespace Version {

const QString major = QStringLiteral("@TwxVersion_MAJOR@");
const QString minor = QStringLiteral("@TwxVersion_MINOR@");
const QString patch = QStringLiteral("@TwxVersion_PATCH@");
const QString tweak = QStringLiteral("@TwxVersion_TWEAK@");
const QString all   = QStringLiteral("@TwxVersion_ALL@"); // major.minor.patch
const QString full  = QStringLiteral("@TwxVersion_FULL@"); // major.minor.patch.tweak

} // namespace Version
} // namespace Twx
