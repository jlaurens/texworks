/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2023  Stefan Löffler, Jérôme Laurens

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
#include "TwxHelpManager.h"

namespace Twx {
namespace Help {

void Manager::open(const QString & helpDirName)
{
	QDir helpDir(helpDirName);
	if (helpDir.exists(QString::fromLatin1("index.html")))
		openUrl(QUrl::fromLocalFile(helpDir.absoluteFilePath(QString::fromLatin1("index.html"))));
	else
		QMessageBox::warning(nullptr, applicationName(), tr("Unable to find help file."));
}

} // namespace Help
} // namespace Twx
