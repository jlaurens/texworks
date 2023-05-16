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

/** \brief Collection of paths */
namespace Path {
/** \brief Factory paths to the application image */
  extern const QString & applicationImage;
/** \brief Factory paths to the application image of size 128 */
  extern const QString & applicationImage128;
}

namespace Core {

#if defined(TwxCore_TEST)
namespace Test {
	class Main;
}
#endif

class Settings;

/** \brief Resources manager
 	* 
	* 
	*/
class AssetsLookup
{
public:
/** \brief Setup the manager
 	* 
	* \param settings is a `QSettings` instance.
	*/
	static void setup(const Settings & settings);

/** \brief The flat list of paths to a resources folder
 	* 
	* What is the meaning of synchronization?
	* \param subdir is one of "completion", "configuration",
	* "dictionaries", "scripts", "templates"...
	* \param synchronize tells whether synchonization should occur
	* \return the full path to the subdirectory
	*/
	static const QStringList getPathList(const QString& subdir, const bool updateOnDisk = true);

private:
  #include "Core/TwxAssetsLookupPrivate.h"
};

} // namespace Utils

} // namespace Tw

#endif // !defined(ResourcesLibrary)
