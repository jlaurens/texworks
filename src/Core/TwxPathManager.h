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
#ifndef Twx_Core_PathManager_h
#define Twx_Core_PathManager_h

#include <QString>
#include <QStringList>
#include <QProcessEnvironment>

namespace Twx {
namespace Core {

namespace Test {
	class Main;
}

extern const QString pathListSeparator;
extern const QStringList staticBinaryPaths;

class PathManager
{
	static QStringList rawBinaryPaths_m;
	static QStringList defaultBinaryPaths_m;
	
	using QProcEnv = QProcessEnvironment;

public:
	static void setRawBinaryPaths(
		const QStringList& paths
	);
	static void resetDefaultBinaryPaths();
  static bool resetRawBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);
  static const QStringList getRawBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);
	static const QStringList getBinaryPaths(
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);
	static QString programPath(
		const QString& program,	
		const QProcEnv& env = QProcEnv::systemEnvironment()
	);

private:
	PathManager() = delete;
	~PathManager() = delete;
	PathManager( const PathManager& ) = delete;
	PathManager(PathManager&&) = delete;
  PathManager& operator=(const PathManager&) = delete;
  PathManager& operator=(PathManager &&) = delete;

#include "Core/TwxPathManagerPrivate.h"

	friend class Test::Main;
};

} // namespace Core
} // namespace Twx

#endif // #ifndef Twx_Core_PathManager_h
