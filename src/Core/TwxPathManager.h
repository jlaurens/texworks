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
#ifndef TwxCore_PathManager_h
#define TwxCore_PathManager_h

/*! \file TwxPathManager.h
 *  \brief Some kind of `PATH` manager.
 *  
 *  Every method is a static method of `PathManager`.
 *  The main method is `programPath()` to give the full path of a program.
 *  For that we have various utilities and we maintain different `PATH` like
 *  variables.
 */

#include <QString>
#include <QStringList>
#include <QProcessEnvironment>

namespace Twx {
namespace Core {

namespace Test {
	class Main;
}

/*! \brief Path list separator
 *
 *  `;` on windows and `:` otherwise.
 */
extern const QString pathListSeparator;

class PathManager
{
	using QProcEnv = QProcessEnvironment;

public:
	/*! \brief Get the full path of a program
	 *
	 *  Used by engines to resolve programs like `pdfTeX`, `BibTeX`...
	 *  \param program a case sensitive program name
	 *  \param env is an optional `QProcessEnvironment` instance that
	 *    defaults to the system environment.
	 */
	static QString programPath(
		const QString& program,	
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);

	/*! \brief Get the binary paths
	 *
	 *  Get the list of the directories where programs are looked for.
	 *  \param env is an optional `QProcessEnvironment` instance that
	 *    defaults to the system environment.
	 */
	static const QStringList getBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);

	static void setRawBinaryPaths(
		const QStringList& paths
	);
	static void resetDefaultBinaryPathsToSettings();
  static bool resetRawBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);
  static const QStringList getRawBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);

private:

#include "Core/TwxPathManagerPrivate.h"

	friend class Test::Main;
};

} // namespace Core
} // namespace Twx

#endif // #ifndef TwxCore_PathManager_h
