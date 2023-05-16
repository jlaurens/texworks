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

/** \brief Private interface */

private:

/** \brief The setup path
 	* 
	* \return the full path to an assets folder defined at setup.
	*/
	static const QString & getSetupPath();

/** \brief Set the setup assets path
 	* 
	* \param path the full path to the assets
	*/
	static void setSetupPath(const QString & path);

	static const QString getPath();
	// the return value is sorted from new to old
	static const QString getLegacyPath();
	static bool shouldMigrateLegacy();
	static void migrateLegacy();
	static void update(const QDir & srcRootDir, const QDir & destRootDir, const QString& libPath);

#if defined(TwxCore_TEST)
	friend class Test::Main;
#endif
