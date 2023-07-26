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

#include "TwxW3.h"

#include <QUrl>
#include <QDesktopServices>
#include <QMessageBox>
#include <QCoreApplication>

namespace Twx {

#if defined(TwxW3_TEST)
W3::ModeOpenUrl W3::modeOpenUrl = W3::ModeOpenUrl::Normal;
#endif

const QUrl W3::URL::home 		= QUrl(QStringLiteral("@TWX_CFG_URL_HOME@"));
const QUrl W3::URL::homeDev	= QUrl(QStringLiteral("@TWX_CFG_URL_HOME_DEV@"));
const QUrl W3::URL::issues  = QUrl(QStringLiteral("@TWX_CFG_URL_ISSUES@"));
const QUrl W3::URL::GPL 		= QUrl(QStringLiteral("@TWX_CFG_URL_GPL@"));
const QString W3::mail_address = QStringLiteral("@TWX_CFG_MAIL_ADDRESS@");

W3 * W3::emitter ()
{
	static W3 m;
	return &m;
}

bool W3::openUrl(const QUrl & url)
{
#if !defined(TwxW3_TEST_NO_openUrl)
	#if defined(TwxW3_TEST)
	if (modeOpenUrl == ModeOpenUrl::ReturnTrue) return true;
	if (modeOpenUrl == ModeOpenUrl::ReturnFalse) return false;
	#endif
	if (!QDesktopServices::openUrl(url)) {
		#if defined(TwxW3_TEST)
		if (modeOpenUrl == ModeOpenUrl::NoGUI) return false;
		#endif
		QMessageBox::warning(
			nullptr,
			QCoreApplication::applicationName(),
			warningText(url)
		);
		return false;
	}
#endif	
	return true;
}

QString W3::warningText(const QUrl & url)
{
	return tr("Unable to access ``%1''; perhaps your browser or mail application is not properly configured?")
							.arg(url.toString());
}

bool W3::openUrlHome()
{
	return openUrl(URL::home);
}

} // namespace Twx
