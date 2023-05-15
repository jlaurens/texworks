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
	* \brief Database of file records
	* 
	* Maintains a database of file records with persistent storage.
	* This is used by the resources manager to save a snapshot of
	* the contents of a directory.
	*/

#ifndef TwxCore_FileRecordDB_H
#define TwxCore_FileRecordDB_H

#include "Core/TwxTool.h"

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

/** \brief File record data structure
  * 
	* md5 was use and then sha256.
	* \note
	*   The underlying `QByteArray` instances are now hexadecimal representations.
	*/
struct FileRecord {
	QFileInfo fileInfo;
	QString   version;
	Checksum  checksum; // sha256
	Hash      hash; // md5 for old
};

/** \brief File records database
  * 
	* Maintains a list of file records.
	* Mainly used by `ResourcesLibrary`.
	*/
class FileRecordDB
{
public:
	
/** \brief File record database loaded from a dirctory
	* 
	* Parse the contents at the given location and create
	* a list of file records.
	* Will save its contents at the same place.
	*
	* The file format is private.
	* The file name is also private.
	*
	* \return a fresh file record database 
	*/
	static FileRecordDB load(const QDir & dir);

/** \brief Save the database
	* 
	* Save the receiver to location it was loaded with.
	* The file format is private.
	* The file name is also private.
	* \return true on success, false on failure.
	*/
	bool save() const;

/** \brief Add a new file record
	* 
	* Add a new file record to the database,
	* after removing the already existing records with the same
	* `fileInfo`.
	* 
	* \param fileInfo is the file info of the record
	* \param version is the version of the record
	* \param checksum is the checksum of the record, it may not be related to the real checksum
	* \param hash is the optional hash of the record, it may not be related to the real hash
	*/
	void add(
		const QFileInfo & fileInfo,
		const QString   & version,
		const Checksum  & checksum,
		const Hash      & hash = Hash()
	);

/** \brief Whether the database contains some record
	* 
	* Save the receiver to the given path.
	* The file format is private.
	* \param fileInfo is the file info of the request
	* \return true if the receiver contains a record with such a fileInfo,
	*   false otherwise;
	*/
	bool knows(const QFileInfo & fileInfo) const;

/** \brief Some database record
	* 
	* The result is undefined if `knows(fileInfo)` did not return true.
	* \param fileInfo is the file info of the record
	* \return the known file record with the given `fileInfo`;
	*/
	const FileRecord & get(const QFileInfo & file) const;

private:
	#include "Core/TwxFileRecordDBPrivate.h"
};

} // namespace Core
} // namespace Twx

#endif // TwxCore_FileRecordDB_H
