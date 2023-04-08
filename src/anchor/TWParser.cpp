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
#include "anchor/TWParser.h"
#include "TWUtils.h"
#include "utils/ResourcesLibrary.h"

#include <QString>
#include <QDebug>
#include <QTreeWidgetItem>

namespace Tw {
namespace Anchor {

namespace Mode {
const type plain   = QStringLiteral("plain");
const type latex   = QStringLiteral("latex");
const type dtx     = QStringLiteral("dtx");
const type context = QStringLiteral("context");
}

namespace Category {
const type Magic     = QStringLiteral("Magic");
const type Bookmark  = QStringLiteral("Bookmark");
const type Outline   = QStringLiteral("Outline");
}

namespace Type {
const type MARK   = QStringLiteral("MARK");
const type TODO   = QStringLiteral("TODO");
const type BORDER = QStringLiteral("BORDER");
}

#if false
#pragma mark Rule
#endif

bool Rule::isMode(Mode::type mode) const
{
    return ! mode.length() || modes_m.contains(mode);
}

bool Rule::isCategory(Category::type category) const
{
    return category_m == category;
}

//const QList<const Rule *> Tag::rules()
//{
//    static QList<const Rule *> rules;
//    if (rules.empty()) {
//        // read tag-recognition patterns
//        QFile file(::Tw::Utils::ResourcesLibrary::getTagPatternsPath());
//        if (file.open(QIODevice::ReadOnly)) {
//            QRegularExpression whitespace(QStringLiteral("\\s+"));
//            while (true) {
//                QByteArray ba = file.readLine();
//                if (ba.size() == 0)
//                    break;
//                if (ba[0] == '#' || ba[0] == '\n')
//                    continue;
//                QString line = QString::fromUtf8(ba.data(), ba.size());
//                QStringList parts = line.split(whitespace, Qt::SkipEmptyParts);
//                if (parts.size() != 3)
//                    continue;
//                bool ok{false};
//                Type type = typeForName(parts[0]);
//                if (type != Type::Any) {
//                    int level = parts[1].toInt(&ok);
//                    if (ok) {
//                        auto pattern = QRegularExpression(parts[2]);
//                        if (pattern.isValid()) {
//                            const Rule *r = new Rule(type, level, pattern);
//                            rules << r;
//                        } else {
//                            qWarning() << "Wrong tag pattern:" << parts[2];
//                        }
//                    }
//                }
//            }
//        }
//    }
//    return rules;
//}


} // namespace Anchor
} // namespace Tw
