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
#include "TwxConst.h"

#define TWX_DECLARE_EPONYM(WHAT)\
const QString WHAT = QStringLiteral(#WHAT)
#define TWX_DECLARE_SETTINGS_EPONYM(WHAT)\
const QString WHAT = QStringLiteral("Twx_" #WHAT)

namespace Twx {

namespace Key {

TWX_DECLARE_EPONYM(__data);
TWX_DECLARE_EPONYM(__status);
TWX_DECLARE_EPONYM(__type);
TWX_DECLARE_EPONYM(__version);

// Assets keys and categories
TWX_DECLARE_EPONYM(translations);
TWX_DECLARE_EPONYM(configuration);
TWX_DECLARE_EPONYM(templates);
TWX_DECLARE_EPONYM(completion);
TWX_DECLARE_EPONYM(dictionaries);
TWX_DECLARE_EPONYM(scripts);

// Settings keys
TWX_DECLARE_EPONYM(binaryPaths);
TWX_DECLARE_SETTINGS_EPONYM(PATH);

TWX_DECLARE_EPONYM(inipath);
TWX_DECLARE_SETTINGS_EPONYM(settings_ini);

TWX_DECLARE_EPONYM(libpath);
TWX_DECLARE_SETTINGS_EPONYM(assets_library_location);

} // namespace Key

namespace Env {

// Environment variables
TWX_DECLARE_EPONYM(SystemDrive);
TWX_DECLARE_EPONYM(LOCALAPPDATA);
TWX_DECLARE_EPONYM(PATH);
TWX_DECLARE_EPONYM(TWX_DICTIONARY_PATH);
TWX_DECLARE_EPONYM(TW_DICPATH);
TWX_DECLARE_EPONYM(TWX_SETUP_INI_PATH);
TWX_DECLARE_EPONYM(TWX_SETTINGS_INI_PATH);
TWX_DECLARE_EPONYM(TW_INIPATH);
TWX_DECLARE_EPONYM(TWX_ASSETS_LIBRARY_PATH);
TWX_DECLARE_EPONYM(TW_LIBPATH);

#if defined(Q_OS_WIN)
	TWX_DECLARE_EPONYM(LOCALAPPDATA);
	TWX_DECLARE_EPONYM(TW_LIBPATHSystemDrive);
#endif

} // namespace Env

namespace Path {
	const QString dot = QStringLiteral(".");
	TWX_DECLARE_EPONYM(bin);
  const QString applicationImage    = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE_128@");
  const QString applicationImage128 = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE@");

	const QString setup_ini           = QStringLiteral("@TWX_CFG_NAME_LOWER@-setup.ini");
} // namespace Path

namespace PropertyKey {
// the `_twx` suffix limits name collision

const char * listPATH = "listPATH_twx";

} // namespace PropertyKey

} // namespace Twx

#undef TWX_DECLARE_EPONYM