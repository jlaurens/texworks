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
#ifndef TwxCore_Locate_h
#define TwxCore_Locate_h

/*! \file TwxLocate.h
 	*  \brief Some kind of `PATH` manager.
 	*  
 	*  `TwxLocate` is a static object which main method
 	*  is `absoluteProgramPath()` to retrieve the full path of a program.
 	* 
 	*  In addition, \ref `TwxPathFinder` instances also implement
 	*  `absoluteProgramPath()` but with a per instance approach.
 	*  
 	*  Whereas `TwxLocate` will be used as general purpose path provider,
 	*  different documents may need there own customized `TwxPathFinder` instance
 	*  to suit their particular needs.
 	*/

#include <QString>
#include <QStringList>
#include <QDir>
#include <QProcessEnvironment>

namespace Twx {

namespace Core {

class Settings;
@TWX_CFG_include_TwxNamespaceTestMain_private_h@
/** \brief Location manager
  *
  * The main purpose of the location manager is `absoluteProgramPath()`.
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
class Locate
{
// Using a shortcut to QProcessEnvironment
// troubles Doxygen
public:

/** \brief Setup the manager
	* 
	* \param settings is a `Settings` instance.
	*/
	static void setup(Settings & settings);

/** \brief The directory of the application
	* 
	* On mac OS, this is the directory of the bundle application,
	* not the application executable.
	* \return absolute path as a `QDir` object
	*/
	static QDir applicationDir();

/** \brief Get the full path of a program
	*
	* Used by engines to resolve programs like `pdfTeX`, `BibTeX`...
	* Based on `listPATH()`.
	* 
	* \param program a case sensitive program name. On windows extension
	*  	can be omitted.
	* \param controller is a QObject instance.
	* \param env is an optional `QProcessEnvironment` instance that
	*  	defaults to the system environment.
	*/
	// Engine::absoluteProgramPath
	static QString absoluteProgramPath(
		const QString & program,
		const QObject & controller,
		const QProcessEnvironment & env =
		  QProcessEnvironment::systemEnvironment()
	);

/** \brief Get the full path of a program
	*
	* Used by engines to resolve programs like `pdfTeX`, `BibTeX`...
	* Based on `listPATH()`.
	* 
	*  \param program a case sensitive program name. On windows extension
	*    can be omitted.
	*  \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment.
	*/
	// Engine::absoluteProgramPath
	static QString absoluteProgramPath(
		const QString & program,	
		const QProcessEnvironment & env =
		  QProcessEnvironment::systemEnvironment()
	);

/** \brief Get the binary paths used by `absoluteProgramPath()`
	*
	* Get the list of the directories where programs are looked for.
	* Take the controller's property named `PropertyKey::listPATH` as string list.
	* Take the raw binary paths and the environment's `PATH` ones,
	* resolve the environment variables, remove duplicates.
	*
	* @note the controller might be a TeX project for which the
	* TeX programs calls an external tool that is not shared or
	* or not located in one of the standard locations. 
	* 
	* \param controller is a QObject instance.
	* \param env is an optional `QProcessEnvironment` instance that
	*   defaults to the system environment.
	*/
	static const QStringList listPATH(
		const QObject & controller,
		const QProcessEnvironment & env
		  = QProcessEnvironment::systemEnvironment()
	);

/** \brief Get the binary paths used by `absoluteProgramPath()`
	*
	* Get the list of the directories where programs are looked for.
	* Take the raw binary paths and the environment's `PATH` ones,
	* resolve the environment variables, remove duplicates.
	* 
	* \param env is an optional `QProcessEnvironment` instance that
	*   defaults to the system environment.
	*/
	static const QStringList listPATH(
		const QProcessEnvironment & env
		  = QProcessEnvironment::systemEnvironment()
	);

/** \brief Set the `PATH` of a process environment
	*
	* Set the `PATH` variable of the given process environment to
	* the items of `listPATH` joined by the native path list separator.
	*
	* The extra directory is prepended to the list of path.
	* In practice, this is the folder of the current document being typeset.
	* 
	* \param env is an `QProcessEnvironment` to amend.
	* \param env is an extra directory that should appear in the list.
	*/
	static void setPATH(QProcessEnvironment & env, const QDir & extraDir);

/**
	* \brief set the list of raw binary paths
	*
	* \param paths is a list of paths, possibly including placeholders
	*   like `${foo}` on unix like systems, and `%foo%` on windows.
	* 
	* \see `listPATHRaw()`
	*/
	static void setListPATH(
		const QStringList & paths
	);
/** \brief get the list of raw binary paths
	*
	* This is a lazy getter.
	* If the settings store a list of raw binary paths
	* for key `Twx::Core::Key::PATH`, it is used.
	* Otherwise, `resetListPATHRaw(env)` is used.
	* 
	* This list can be edited with the GUI by `PrefsDialog`,
	* or by hand under key "PATH". The location and
	* storage format of the settings is system dependent.
	* See the `QSettings` documentation for
	* [Qt5](https://doc.qt.io/qt-5/qsettings.html#platform-specific-notes) or
	* [Qt6](https://doc.qt.io/qt-6/qsettings.html#platform-specific-notes).
	* 
	* \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment. 
	*/
	static const QStringList listPATHRaw(
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
	*   <li> TeXlive or MiKTeX standard related paths
	* 	</ul>
	* <li> factory paths
	* <li> the contents of the `PATH` variable of `env`
	* </ul>
	*
	* \param env is an optional `QProcessEnvironment` instance that
	*    defaults to the system environment.
	* \see `listPATHRaw()`
	*/
	static bool resetListPATHRaw(
		const QProcessEnvironment & env
			= QProcessEnvironment::systemEnvironment()
	);

/** \brief Type of `Locate::resolve` result */
	struct Resolved {
		bool success;
		QFileInfo fileInfo;
	};
/**
	* \brief Resolve a location
	*
	* Find an absolute path to an existing location.
	*
	* * If the location is absolute:
	*   - if it points to an existing object in the file system,
	*     it is returned as `QFileInfo` after a true value for success;
	*   - if it does not points to an existing object, and `mustExist` is true,
	*     it is also returned as `QFileInfo` but after a false value for failure.
	* * If the location is relative, it is resolved with respect to
	*   - the custom directory
	*   - the current directory
	*   - the home directory
	*   - the directory of the application
  * 
	* \note
	* * The type of the file system object is not considered,
	*   whether a file or a directory does not come into play.
	* * The `mustExist` formal argument is used to manage a dilemma:
	* 	if a full path is given, should we expect it to point to an
	* 	existing object or not?
	*
	* \param location is a relative or an absolute path.
	* \param customDir ignored when the location is absolute.
	* \return a boolean indicating that an existing path is found,
	*   and a file info in case of success.
	*   The file info is unspecified in case of failure.
	*/
	static const Resolved resolve(
		const QString & path,
		const QDir & customDir,
		bool mustExist
	);

private:

	Locate() = delete;
	~Locate() = delete;
	Locate( const Locate& ) = delete;
	Locate(Locate&&) = delete;
	Locate& operator=(const Locate&) = delete;
	Locate& operator=(Locate &&) = delete;
@TWX_CFG_include_TwxLocate_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};

} // namespace Core
} // namespace Twx

#endif // #ifndef TwxCore_Locate_h
