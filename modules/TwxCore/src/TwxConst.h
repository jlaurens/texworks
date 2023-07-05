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
#include <QUrl>

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
	extern const QString bin;
  extern const QString applicationImage;
  extern const QString applicationImage128;
  extern const QString setup_ini;
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

/** \brief Settings key for the flat list of binary paths */
	extern const QString PATH;

/** \brief Settings key for the list of binary paths (Deprecated)
  *
	* Use \ref `Key::PATH` instead.
	*/
	extern const QString binaryPaths;

/** \brief Assets category
  *
	* Where dictionaries are stored. System dependent.
	*/
	extern const QString dictionaries;

/** \brief `...-setup.ini` settings key */
	extern const QString assets_library_location;

/** \brief `...-setup.ini` settings key
  *
	*  Deprecated, see \ref Twx::Key::assets_library_location.
	*/
	extern const QString libpath;

/** \brief `...-setup.ini` settings key
  *
	*  Deprecated, see \ref Twx::Key::settings_ini.
	*/
	extern const QString inipath;

/** \brief `...-setup.ini` settings key
  *
	* This makes sense mainly on raw unix (no macOS).
	*	The value is the path of a `.ini` file where the application
	*	is expected to read and write its settings.
	* The setup file and the settings are assumed to be different.
	*
	* When not absolute, this settings location is relative to
	* * the directory of the `...-setup.ini` file itself
	* * the current directory
	* * the home directory
	* * the directory of the application
	* \warning
	* To developers: changing the current directory may have bad consequences.
	*/
	extern const QString settings_ini;

/** \brief Assets category */
	extern const QString translations;

/** \brief Assets category */
	extern const QString configuration;

/** \brief Assets category */
	extern const QString completion;

/** \brief Assets category */
	extern const QString templates;

/** \brief Assets category */
	extern const QString scripts;

} // namespace Key

/** \brief
 	* Strings that are used as environment variable names in various places.
	*
 	* The identifier is also the environment variable name.
	* The contents of the variable overrides the built in state.
	*/
namespace Env {
/** \brief The standard PATH environment variable.
 	*
 	* Used by `Core::Locate` to find the full path to programs.
 	*/
	extern const QString PATH;

/** \brief Locations of spell checking dictionaries.
 	*
 	* On raw unix, the eponym environment variable overrides
	* the locations of the spell checking dictionaries.
	*
	* This locations are unused on macOS and windows.
	* See `Core::Assets::dictionaryLocations()`.
 	*/
	extern const QString TWX_DICTIONARY_PATH;
	
/** \brief Locations of spell checking dictionaries.
 	*
 	* Deprecated in favor of `Env::TWX_DICTIONARY_PATH`.
 	*/
	extern const QString TW_DICPATH;
	
/** \brief Location of a setup ini file
 	*
 	* On raw unix, the eponym environment variable determines
	* the locations of a "...-setup.ini" file.
	*
	* Makes sense mainly on raw unix (not on macOS)
	*/
	extern const QString TWX_SETUP_INI_PATH;
	
/** \brief Location of the settings ini file
 	*
 	* On raw unix, the eponym environment variable overrides
	* the location of the settings ini file.
	*
	* Makes sense mainly on raw unix (not on macOS)
	*/
	extern const QString TWX_SETTINGS_INI_PATH;
	
/** \brief Environment variable
 	*
 	* Not recommended, use `Env::TWX_SETTINGS_INI_PATH` instead
	*/
	extern const QString TW_INIPATH;

/** \brief Environment variable
 	*
 	* On raw unix, the eponym environment variable overrides
	* the location of the local assets library.
	*
	* Makes sense mainly on raw unix (not on macOS)
	*/
	extern const QString TWX_ASSETS_LIBRARY_PATH;
	
/** \brief Environment variable
 	*
 	* Not recommended, use `TWX_ASSETS_LIBRARY_PATH` instead
	*/
	extern const QString TW_LIBPATH;

/** \brief Windows environment variable
 	*
 	* Used by Core::Locate
	*/
	extern const QString LOCALAPPDATA;

/** \brief Windows environment variable
 	*
 	* Used by Core::Locate
	*/
	extern const QString SystemDrive;

} // namespace Env
namespace PropertyKey {
	
/** \brief PATH as a list od strings
 	*
 	* Used by Core::Locate
	*/
	extern const char * listPATH;

} // namespace PropertyKey
} // namespace Twx

#endif // TwxCore_Const_H
