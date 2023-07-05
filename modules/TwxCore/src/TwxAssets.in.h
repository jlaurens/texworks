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
 	* \brief Location of assets.
	*/
#ifndef TwxCore_Assets_H
#define TwxCore_Assets_H

#include <QString>
#include <QDir>

class QProcessEnvironment;

namespace Twx {
namespace Core {

class Settings;
@TWX_CFG_include_TwxNamespaceTestMain_private_h@

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
	static void setup(Settings & settings);

/** \brief Setup the manager
 	*
	* Retrieve the value of the environment variable
	* `Env::TWX_ASSETS_LIBRARY_PATH`
	* (or `Env::TW_LIBPATH` when the former is empty).
	* This is the return value of `Assets::setupLocation()`.
	*
	* If the location is a relative path, it is resolved
	* by `Locate::resolve()`.
	*
	* \param PE is a `QProcessEnvironment` instance.
	*/
	static void setup(const QProcessEnvironment & PE);

/** \brief The path to an assets folder
 	*
	* \param category is one of "completion", "configuration",
	* "scripts", "templates"...
	* \param updateLocal tells whether the local asserts folder should
	* update to mirror the factory assets.
	* \return the full path to the directory where the assets files are stored
	*/
	static const QString path(const QString& category, const bool updateLocal = true);

/** \brief The list of paths to dictionary folders
 	*
	* For windows and macOS, This is the `Assets::path("dictionaries",updateLocal)` output.

	* For raw unix OS, except in "-setup.ini" mode, the `TWX_DICTIONARY_PATH`
	* environment variable can contain a colon separated list of paths.
	* Notice that:
	*   * The build and test system allows to customize this list at build time
	*     using `-DTWX_DICTIONARY_PATH="..."` when invoking `cmake`.
	*   * The former `TW_DICPATH` is deprecated since version 0.7.0.
	* 	* By default, this list is `/usr/share/hunspell/` and
	*		`/usr/share/myspell/dicts/`.
	* \param updateLocal tells whether the local asserts folder should
	* update to mirror the factory assets.
	* \return a QStringList filled with the full paths to the dictionary folders
	*/
	static const QStringList dictionaryLocations(const bool updateLocal = true);

private:

  Assets()  = delete;
	~Assets() = delete;
	Assets(Assets &  other) = delete;
	Assets(Assets && other) = delete;
  void operator=(const Assets & ) = delete;
  void operator=(const Assets &&) = delete;

@TWX_CFG_include_TwxAssets_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};

} // namespace Core
} // namespace Twx

#endif // TwxCore_Assets_H
