/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2023  Stefan Löffler, Jérôme LAURENS

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

private:

	static void possiblyMigrateLegacy();
	static int update(const QDir & assetsDir, const QString& category);
	const QStringList rawUnixDictionaryLocations(
		const QProcessEnvironment & PE
	);

	static QDir factoryDir_m;
	static QString setupLocation_m;
	static QString standardLocation_m;
	static QString legacyLocation_m;

// lazy initializers
	static const QDir factoryDir();
	static const QString setupLocation();
	static const QString standardLocation();
	static const QString legacyLocation();
