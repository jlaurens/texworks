/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2020-2023  Stefan Löffler, Jérôme LAURENS

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

#include "TwxUtil.h"

#include <QUrl>
#include <QDesktopServices>
#include <QMessageBox>
#include <QCoreApplication>

namespace Twx {

bool Util::gui_mode = false;

bool Util::openUrl(const QUrl & url)
{
#if !defined(TwxUtil_TEST_NO_OpenUrl)
	if (!QDesktopServices::openUrl(url)) {
		if (gui_mode) {
			QMessageBox::warning(nullptr, QCoreApplication::applicationName(),
								tr("Unable to access \"%1\"; perhaps your browser or mail application is not properly configured?")
								.arg(url.toString()));
		}
		return false;
	}
#endif	
	return true;
}

} // namespace Twx
