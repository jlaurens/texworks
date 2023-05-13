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

#ifndef TwxCore_AssetsTrackDB_H
#define TwxCore_AssetsTrackDB_H

#include "TwxTool.h"

#include <QList>
#include <QDir>
#include <QFileInfo>

namespace Twx {
namespace Core {

#if defined(TwxCore_TEST)
namespace Test {
	class Main;
}
#endif

/** \brief Support assets track data structure
  * 
	* md5 was used and then sha256.
	* At some point in time, the checksum corresponds to the fileInfo,
	* but in the meanwhile the user might have modified the file such
	* that the checksum is broken.
	* \note
	*   The underlying `QByteArray` instances are now hexadecimal representations.
	*/
struct AssetsTrack {
	QFileInfo fileInfo;
	QString   version;
	Checksum  checksum; // sha256
	Hash      hash; // md5 for old
};

/** \brief File support tracks database
  * 
	* Maintains a list of file support tracks.
	* Mainly used by the `AssetsLookup`.
	*	
	* The database is associated to an assets directory which
	* almost a mirror of the application factory assets directory.
	* This helps in keeping files consistent whilst the application
	* gets updated.
	*/
class AssetsTrackDB
{
public:
	
/** \brief support assets track database loaded from a directory
	* 
	* Parse the contents at the given location and create
	* a list of support assets tracks.
	* Will save its contents at the same place.
	*
	* The file format is private.
	* The file name is also private.
	*
	* \return a fresh support assets track database 
	*/
	static AssetsTrackDB load(const QDir & dir);

/** \brief Default constructor
	* 
	* \param dir is a `QDir` instance where the database
	* will be loaded or saved
	*/
	AssetsTrackDB(const QDir & dir);
	virtual ~AssetsTrackDB() = default;

/** \brief Save the database
	* 
	* Save the receiver to location it was loaded with.
	* The file format is private.
	* The file name is also private.
	* \return true on success, false on failure.
	*/
	bool save() const;

/** \brief Add a new support assets track
	* 
	* Add a new support assets track to the database,
	* after removing the already existing tracks with the same
	* `fileInfo`.
	* 
	* \param fileInfo is the file info of the track
	* \param version is the version of the track
	* \param checksum is the checksum of the track, it may not be related to the real checksum
	* \param hash is the optional hash of the track, it may not be related to the real hash
	*/
	void add(
		const QFileInfo & fileInfo,
		const QString   & version,
		const Checksum  & checksum,
		const Hash      & hash = Hash()
	);

/** \brief Whether the database contains some track
	* 
	* \param fileInfo is the file info of the request
	* \return true if the receiver contains a track with such a fileInfo,
	*   false otherwise;
	*/
	bool knows(const QFileInfo & fileInfo) const;

/** \brief Some database support assets track
	* 
	* The result is undefined if `knows(fileInfo)` did not return true.
	* \param fileInfo is the file info of the track
	* \return the known support assets track with the given `fileInfo`;
	*/
	const AssetsTrack & get(const QFileInfo & file) const;

/** \brief Adjust the associate directory 
	* 
	* Adjust the database associate directory
	* to a given factory directory.
	*
	* \param factoryDir is the factory reference directory
	*/
	void adjust(const QDir & factoryDir);

private:

  static const int version;

  QList<AssetsTrack> assetsTracks_m;
  QDir              dir_m;

	bool save(const QString & path) const;
	static AssetsTrackDB load(const QString & path);
	bool save_legacy(const QString & path) const;
  static AssetsTrackDB load_legacy(const QString & path);

#if defined(TwxCore_TEST)
	static const QString saveComponent;
	QList<AssetsTrack> & getList();
	const QList<AssetsTrack> & getList() const;
  void removeStorage() const;

  friend class Test::Main;
	friend bool operator==(const AssetsTrackDB & frdb1, const AssetsTrackDB & frdb2);
#endif

};

} // namespace Core
} // namespace Twx

#endif // TwxCore_AssetsTrackDB_H
