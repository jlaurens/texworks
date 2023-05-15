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

/** \brief Private interface */
private:

  static const int version;

	FileRecordDB(const QDir & dir);
	virtual ~FileRecordDB() = default;

  QList<FileRecord> fileRecords_m;
  QDir              dir_m;

	bool save(const QString & path) const;
	static FileRecordDB load(const QString & path);
	bool save_legacy(const QString & path) const;
  static FileRecordDB load_legacy(const QString & path);

#if defined(TwxCore_TEST)
	static const QString saveComponent;
	QList<FileRecord> & getList();
	const QList<FileRecord> & getList() const;
  void removeStorage() const;

  friend class Test::Main;
	friend bool operator==(const FileRecordDB & frdb1, const FileRecordDB & frdb2);

#endif
