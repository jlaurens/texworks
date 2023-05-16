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
#ifndef TwxCore_PathManager_h
#define TwxCore_PathManager_h

/*! \file TwxPathManager.h
 	*  \brief Some kind of `PATH` manager.
 	*  
 	*  `TwxPathManager` is a static object which main method
 	*  is `programPath()` to retrieve the full path of a program.
 	* 
 	*  In addition, \ref `TwxPathFinder` instances also implement
 	*  `programPath()` but with a per instance approach.
 	*  
 	*  Whereas `TwxPathManager` will be used as general purpose path provider,
 	*  different documents may need there own customized `TwxPathFinder` instance
 	*  to suit their particular needs.
 	*/

#include <QString>
#include <QStringList>
#include <QDir>
#include <QProcessEnvironment>

namespace Twx {

namespace Key {
/** \brief Settings key for the list of binary paths */
	extern const QString binaryPaths;
/** \brief Settings key for the list of binary paths (Deprecated)
  * 
	* Use \ref `binaryPaths` instead.
	*/
	extern const QString defaultbinpaths;
}

namespace Core {

class Settings;

#if defined(TwxCore_TEST)
namespace Test {
	class Main;
}
#endif

/** \brief Path manager
  *
  * The main purpose of the path manager is `programPath()`.
  * This method gives the full path to an executable given its name,
  * if any.
  * 
  * To achieve this, the manager maintains lists of binary paths,
  * similar to the `PATH` environment variable contents.
  * - in the raw binary paths list, components are allowed to
  *   contain special placeholder like `${foo}` 
  *   (`$foo` is supported only to some extent).
  *   These will be replaced before usage with environment values
  *   or state values.
  *
  * The path lists can be managed from the settings dialogs.
  */
class PathManager
{
// Using a shortcut to QProcessEnvironment
// troubles Doxygen
public:
/** \brief Setup the manager
	* 
	* \param settings is a `Settings` instance.
	*/
	static void setup(const Settings & settings);

/** \brief The directory of the application
	* 
	* On mac OS, this is the directory of the bundle application,
	* not the application executable.
	*/
	static QDir getApplicationDir();

/** \brief Get the full path of a program
	*
	* Used by engines to resolve programs like `pdfTeX`, `BibTeX`...
	* Based on `getBinaryPaths()`.
	* 
	*  \param program a case sensitive program name. On windows extension
	*    can be omitted.
	*  \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment.
	*/
	// Engine::programPath
	static QString programPath(
		const QString & program,	
		const QProcessEnvironment & env =
		  QProcessEnvironment::systemEnvironment()
	);

/** \brief Get the binary paths used by `programPath()`
	*
	* Get the list of the directories where programs are looked for.
	* Take the raw binary paths and the `PATH` ones,
	* resolve the environment variables, remove duplicates.
	* 
	* Store this list in the settings under key \see `Key::binaryPaths`.
	* 
	* \param env is an optional `QProcessEnvironment` instance that
	*   defaults to the system environment.
	*/
	static const QStringList getBinaryPaths(
		const QProcessEnvironment & env
		  = QProcessEnvironment::systemEnvironment()
	);
/**
	* \brief set the list of raw binary paths
	*
	* \param paths is a list of paths, possibly including placeholders
	*   like `${foo}` on unix like systems, and `%foo%` on windows.
	* 
	* \see `getRawBinaryPaths()`
	*/
	static void setRawBinaryPaths(
		const QStringList & paths
	);
/** \brief get the list of raw binary paths
	*
	* This is a lazy getter.
	* If the settings store a list of raw binary paths
	* for key `Twx::Core::Key::binaryPaths`, it is used.
	* Otherwise, `resetRawBinaryPaths(env)` is used.
	* 
	* This list can be edited with the GUI by `PrefsDialog`,
	* or by hand under key "binaryPaths". The location and
	* storage format of the settings is system dependent.
	* See the `QSettings` documentation for
	* [Qt5](https://doc.qt.io/qt-5/qsettings.html#platform-specific-notes) or
	* [Qt6](https://doc.qt.io/qt-6/qsettings.html#platform-specific-notes).
	* 
	* \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment. 
	*/
	static const QStringList getRawBinaryPaths(
		const QProcessEnvironment & env =
			QProcessEnvironment::systemEnvironment()
	);

/**
	* \brief Reset the list of raw binary paths
	* 
	* The new list consists of, in order,
	* <ul>
	* <li> the directory of the current application (executable)
	* <li> standard path locations for TeX distributions:
	* 	<ul>
	* 	<li> on macOS `/Library/TeX/texbin` and `/usr/texbin` standard locations
	*   <li> TeXlive or MikTeX standard related paths
	* 	</ul>
	* <li> factory paths
	* <li> the contents of the `PATH` variable of `env`
	* </ul>
	*
	* \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment.
	* \see `getRawBinaryPaths()`
	*/
	static bool resetRawBinaryPaths(
		const QProcessEnvironment & env
			= QProcessEnvironment::systemEnvironment()
	);

#include "Core/TwxPathManagerPrivate.h"
};

} // namespace Core
} // namespace Twx

#endif // #ifndef TwxCore_PathManager_h
