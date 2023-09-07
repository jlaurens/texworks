/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Jérôme LAURENS

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
 	* \brief Utilities.
	*/
#ifndef TwxW3_H
#define TwxW3_H

#include <QObject>

class QUrl;

namespace Twx {
@/TWX/CFG/include_TwxNamespaceTestMain_private_h@
/** \brief Utility class
 	*
	* All methods are static
	*/
class W3: QObject
{
	Q_OBJECT

public:
/** \brief Signal emitter
	*
	* Usage:
	* ```cpp
	* connect(
	*   W3::emitter(),
	*   &W3::openUrlHome,
	*   ...
	* );
	* ```
	*	\return a shared W3 instance which sole task is to emit signals.
	*/
static W3 * emitter();
/** \brief Open an Url.
 	*
	* Open the given Url with the system application.
	*
	* \param url is a `QUrl` instance.
	*/
	static bool openUrl(const QUrl & url);

/** \brief Open the home page
 	*
	* Open the home page with the system application.
	*/
	static bool openUrlHome();

	/** \brief Constants */
	static const QString mail_address;

	/** \brief
		* Various url for onlline information.
		*
		*/
	struct URL {
		static const QUrl GPL;
		static const QUrl home;
		static const QUrl homeDev;
		static const QUrl issues;
	};

private:
  W3() = default;
	~W3() = default;
	W3(W3& other) = delete;
	W3(W3&& other) = delete;
  void operator=(const W3&) = delete;
  void operator=(const W3&&) = delete;

@/TWX/CFG/include_TwxW3_private_h@
@/TWX/CFG/include_TwxFriendTestMain_private_h@
};

} // namespace Twx

#endif // TwxW3_H
