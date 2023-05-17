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
/** \file
 * \brief General purpose constants
 * 
 * 
*/
#ifndef TwxCore_Const_H
#define TwxCore_Const_H

#include <QString>

/** \brief Alternate to `TW`
 	* 
 	* \note New technologies belong here.
 	* Old technologies should migrate to this new namespace
 	* once properly refactored and documented.
	*/
namespace Twx {

/** \brief Core technologies */
namespace Core {
}

/** \brief Path related constants */
namespace Path {
	extern const QString dot;
  extern const QString applicationImage;
  extern const QString applicationImage128;
}

/** \brief Constants */
namespace Const {
}

/** \brief
 	* Strings that are used as keys in various places,
 	* for example in the settings.
 	* 
 	* \note Using keys instead of `QStringLiteral` and friends
 	* let the compiler check for typing errors.
	*/
namespace Key {

	extern const QString __data;
	extern const QString __status;
	extern const QString __type;
	extern const QString __version;

	extern const QString PATH;

/** \brief Settings key for the list of binary paths */
	extern const QString binaryPaths;

/** \brief Settings key for the list of binary paths (Deprecated)
  * 
	* Use \ref `binaryPaths` instead.
	*/
	extern const QString defaultbinpaths;

/** \brief Assets category
  * 
	* Where dictionaries are stored. System dependent.
	*/
	extern const QString dictionaries;

/** \brief Settings key
  * 
	*  In "-setup.ini" mode.
	*/
	extern const QString libpath;

/** \brief Assets category */
	extern const QString translations;

} // namespace Key

} // namespace Twx


#endif // TwxCore_Const_H
