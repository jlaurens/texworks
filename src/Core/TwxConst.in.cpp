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
#include "Core/TwxConst.h"

#define TWX_DECLARE_EPONYM(WHAT)\
const QString WHAT = QStringLiteral(#WHAT)

namespace Twx {

namespace Key {

TWX_DECLARE_EPONYM(__data);
TWX_DECLARE_EPONYM(__status);
TWX_DECLARE_EPONYM(__type);
TWX_DECLARE_EPONYM(__version);

// Assets keys and categories
TWX_DECLARE_EPONYM(translations);
TWX_DECLARE_EPONYM(dictionaries);
TWX_DECLARE_EPONYM(libpath);

// Settings keys
TWX_DECLARE_EPONYM(binaryPaths);
TWX_DECLARE_EPONYM(defaultbinpaths);
TWX_DECLARE_EPONYM(settings_ini);
TWX_DECLARE_EPONYM(inipath);

}
namespace Env {

// Environment variables
TWX_DECLARE_EPONYM(PATH);
TWX_DECLARE_EPONYM(TWX_DICTIONARY_PATH);
TWX_DECLARE_EPONYM(TW_DICPATH);
TWX_DECLARE_EPONYM(TWX_SETUP_INI_PATH);
TWX_DECLARE_EPONYM(TWX_SETTINGS_INI_PATH);
TWX_DECLARE_EPONYM(TW_INIPATH);
TWX_DECLARE_EPONYM(TWX_ASSETS_LIBRARY_PATH);
TWX_DECLARE_EPONYM(TW_LIBPATH);

} // namespace Env

namespace Path {
	const QString dot = QStringLiteral(".");
  const QString applicationImage    = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE_128@");
  const QString applicationImage128 = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE@");

	const QString setup_ini           = QStringLiteral("@TWX_CFG_NAME_LOWER@-setup.ini");
}

} // namespace Twx

#undef TWX_DECLARE_EPONYM