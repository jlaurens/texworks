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
#ifndef TwxCore_Assets_H
#define TwxCore_Assets_H

#include <QString>
#include <QDir>

class QSettings;
class QProcessEnvironment;

namespace Twx {
namespace Core {

#if defined(TwxCore_TEST)
namespace Test {
	class Main;
}
#endif

/** \brief Assets manager and location lookup
 	* 
	* 
	*/
class Assets
{
public:
/** \brief Setup the manager
 	* 
	* \param settings is a `QSettings` instance.
	*/
	static void setup(const QSettings & settings);

/** \brief The setup path when in "-setup.ini" mode
 	* 
	* \return the full path to an assets folder defined at setup.
	*/
	static const QString & getSetupLocation();

/** \brief Set the assets location in "-setup.ini" mode
 	* 
	* \param path the full path to the assets
	*/
	static void setSetupLocation(const QString & path);

/** \brief The list of paths to dictionary folders
 	* 
	* \param synchronize tells whether synchonization should occur
	* \return a QStringList filled with the full paths to the dictionary folders
	*/
	static const QStringList dictionaryLocations(const bool synchronize = true);

/** \brief The flat list of paths to a resources folder
 	* 
	* What is the meaning of synchronization?
	* \param category is one of "completion", "configuration",
	* "scripts", "templates"...
	* \param synchronize tells whether synchonization should occur
	* \return the full path to the directory where the files are stored
	*/
	static const QString getPath(const QString& category, const bool synchronize = true);

private:
  #include "Core/TwxAssetsPrivate.h"
};

} // namespace Core
} // namespace Twx

#endif // TwxCore_Assets_H
