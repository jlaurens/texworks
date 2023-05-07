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
#ifndef Twx_Core_Info_h
#define Twx_Core_Info_h

#include <QDateTime>
#include <QString>

namespace Twx {

namespace Core {

namespace Test {
  class Main;
}

class Info
{
public:
	static const QString name();

	static const QString copyrightYears();
	static const QString copyrightHolders();
	static const QString authors();

	static const QString gitCommitHash();
	static const QDateTime gitCommitDate();
	static const QString gitCommitBranch();

	static const QString versionString();
	static const QString buildIdString();

	static const QString fullVersionString();

	// return the version of Tw (0xMMNNPP)
	static int getVersion();

	static int getVersionMajor();
	static int getVersionMinor();
	static int getVersionBugfix();
  static int getVersionPatch();
  static int getVersionTweak();

  friend class Test::Main;
};

} // namespace Core

} // namespace Twx

#endif // Twx_Core_Info_h
