/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2022-2023  Stefan Löffler, Jérôme Laurens

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
#ifndef TwxHelp_Manager_H
#define TwxHelp_Manager_H

#include <QObject>
#include <QString>

namespace Twx {

namespace Const {
	extern const QString & index_html;
}
namespace Help {

@TWX_CFG_include_TwxNamespaceTestMain_private_h@
/** \file TwxHelpManager.h
 	*	\brief Help manager.
 	*
 	*/

class Manager: public QObject
{
	Q_OBJECT
public:
  static bool open(const QString & helpDirName);

@TWX_CFG_include_TwxHelpManager_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};

} // namespace Help
} // namespace Twx

#endif // TwxHelp_Manager_H
