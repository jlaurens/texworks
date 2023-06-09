/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2023  Stefan Löffler, Jérôme LAURENS

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
/** \file
 	* \brief Utilities.
	*/
#ifndef TwxUtil_H
#define TwxUtil_H

#include <QObject>

class QUrl;

namespace Twx {
@TWX_CFG_include_TwxNamespaceTestMain_private_h@
/** \brief Utility class
 	* 
	* All methods are static
	*/
class Util: QObject
{
	Q_OBJECT

public:
/** \brief Open an Url.
 	* 
	* Open the given Url with the system application.
	*
	* \param url is a `QUrl` instance.
	*/
	static bool openUrl(const QUrl & url);

/** \brief Open the home page
 	* 
	* Open the home page with the system application.
	*/
	static bool openUrlHome()

@TWX_CFG_include_TwxUtil_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};

} // namespace Twx

#endif // TwxUtil_H
