/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2018-2023  Jonathan Kew, Stefan Löffler, Jérôme Laurens

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

/** \brief Private interface */

private:

	PathManager() = delete;
	~PathManager() = delete;
	PathManager( const PathManager& ) = delete;
	PathManager(PathManager&&) = delete;
	PathManager& operator=(const PathManager&) = delete;
	PathManager& operator=(PathManager &&) = delete;

#if defined(TwxCore_TEST)
	friend class Test::Main;

  static QStringList messages_m;
	static QStringList factoryBinaryPathsTest;
	static QStringList &rawBinaryPaths();
#endif
