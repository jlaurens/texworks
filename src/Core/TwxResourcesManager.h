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
#ifndef ResourcesLibrary_H
#define ResourcesLibrary_H

#include <QString>
#include <QDir>

namespace Twx {
namespace Core {

#if defined(TwxCore_TEST)
namespace Test {
	class Main;
}
#endif

/** \brief Resources manager
 	* 
	* 
	*/
class ResourcesManager
{
public:
/** \brief The path to a resources folder
 	* 
	* \param subdir is one of "completion", "configuration",
	* "dictionaries", "scripts", "templates"...
	* \param synchronize tells whether synchonization should occur
	* \return the full path to the subdirectory
	*/
	static const QString getPath(const QString& subdir, const bool synchronize = true);

	// same as getLibraryPath(), but splits the return value by the path list separator
	static const QStringList getPaths(const QString& subdir, const bool updateOnDisk = true);

	static const QString & getPortableLibPath();
	static void setPortableLibPath(const QString & path);

private:
  #include "Core/TwxResourcesLibraryPrivate.h"
};

} // namespace Utils

} // namespace Tw

#endif // !defined(ResourcesLibrary)
