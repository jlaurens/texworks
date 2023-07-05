/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2023  Stefan Löffler, Jérôme Laurens

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
	* \brief Database of assets tracks
	*
	* Maintains a database of support file tracks.
	* This is used by the assets manager to save some snapshot of
	* the contents of a support directory and compare it to a
	* corresponding factory directory to synchronize them,
	* as far as it makes sense.
	*/

private:

  static const int version;

  QList<AssetsTrack> assetsTracks_m;
  QDir dir_m;

	bool save(const QString & path) const;
	static AssetsTrackDB load(const QString & path);
	bool save_legacy(const QString & path) const;
  static AssetsTrackDB load_legacy(const QString & path);

	static const QString saveComponent;
	static const QString saveComponentLegacy;
	QList<AssetsTrack> & getList();
	const QList<AssetsTrack> & getList() const;
	void removeStorage() const;

	friend bool operator==(const AssetsTrackDB & frdb1, const AssetsTrackDB & frdb2);
