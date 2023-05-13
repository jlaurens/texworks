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
  * \brief Setup support
  * 
  * If there is a `texworks-setup.ini` near the application,
	* is is parsed and the state is modified accordingly.
	* The static method `initialize` takes care of that.
	* It must be called very early in the initialization process.
  */
#ifndef TwxCore_Setup_H
#define TwxCore_Setup_H

#include <QString>

namespace Twx {
namespace Core {

/** \brief Setup manager
 	* 
 	* Manage the `texworks-setup.ini` that is read very early.
	* This initialization file does not depend on the operating system.
	*/
class Setup
{
public:
/** \brief Initialize the state with `texworks-setup.ini`
 	* 
 	*  
	*/
	static void initialize();
};

} // namespace Core
} // namespace Twx

#endif // TwxCore_Setup_H
