/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2023  Stefan Löffler, Jérôme Laurens

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
#include "document/anchor/TWParser.h"
#include "TWUtils.h"
#include "utils/ResourcesLibrary.h"

#include <QString>
#include <QDebug>
#include <QTreeWidgetItem>

namespace Tw {
namespace Document {
namespace Anchor {

auto Parser::categories_m = QList<Category>();
auto Parser::modes_m      = QList<Mode>();

} // namespace Anchor
} // namespace Document
} // namespace Tw
