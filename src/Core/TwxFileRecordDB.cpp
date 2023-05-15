/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2023  Stefan Löffler, Jérôme LAURENS

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
#include "Core/TwxFileRecordDB.h"
#include "Core/TwxConst.h"
#include "Core/TwxTool.h"

#include <QDir>
#include <QTextStream>
#include <QSettings>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QSaveFile>
#include <QDebug>

namespace Twx {
namespace Core {

const int FileRecordDB::version = 1;

#if defined(TwxCore_TEST)
const QString FileRecordDB::saveComponent = 
#else
static auto const saveComponent = 
#endif
QStringLiteral("TwxFileRecordDB.json");

namespace Key {
	static const QString path     = QStringLiteral("path");
	static const QString version  = QStringLiteral("version");
	static const QString checksum = QStringLiteral("checksum");
	static const QString hash     = QStringLiteral("hash");
	static const QString FileRecordDB = QStringLiteral("TwxFileRecordDB");
}

FileRecordDB::FileRecordDB( const QDir & dir)
: dir_m(dir)
{}

/* The persistent storage is a text file
 * Each line starting with a `#` is a comment
 * Other lines: <version><space><hash><space><file path>
 */
FileRecordDB FileRecordDB::load(const QString & path)
{	
	QDir rootDir(QFileInfo(path).absoluteDir());
	QDir rootPath(rootDir.absolutePath());
	FileRecordDB frdb(rootDir);
  QFile f(path);
	if (f.open(QIODevice::ReadOnly)) {
		auto bytes = f.readAll();
		auto o = QJsonDocument::fromJson(bytes).object();
		if (o.value(Key::__type) == Key::FileRecordDB) {
			auto ra = o.value(Key::__data).toArray();
      for (auto v: ra) {
				auto o = v.toObject();
				frdb.add(
					QFileInfo(rootPath, o.value(Key::path).toString()),
					o.value(Key::version).toString(),
					Checksum{o.value(Key::checksum).toString().toLatin1()}
				);
			}
		}
		f.close();
	}
	return frdb;
}

FileRecordDB FileRecordDB::load_legacy(const QString & path)
{
	QDir rootDir(QFileInfo(path).absoluteDir());
	FileRecordDB frdb(rootDir);

	QFile f(path);
	if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
		return frdb;
	}
	QTextStream strm(&f);

	while (!strm.atEnd()) {
		QString line = strm.readLine().trimmed();
		// ignore comments
		if (line.startsWith(QChar::fromLatin1('#')))
			continue;
		auto version = line.section(QChar::fromLatin1(' '), 0, 0);
		auto hash = Hash{line.section(QChar::fromLatin1(' '), 1, 1).toLatin1()};
		auto fileInfo = QFileInfo(line.section(QChar::fromLatin1(' '), 2).trimmed());
		fileInfo = QFileInfo(rootDir.absoluteFilePath(fileInfo.filePath()));
		frdb.add(fileInfo, version, Checksum(), hash);
	}
	f.close();

	return frdb;
}

bool FileRecordDB::save_legacy(const QString & path) const
{
	QFile f(path);
	if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
		return false;
	}
	QTextStream strm(&f);
	QDir rootDir(QFileInfo(path).absoluteDir());
	for ( const auto & record: fileRecords_m ) {
		QString filePath = record.fileInfo.absoluteFilePath();
		strm << record.version      << " "
		     << record.hash.bytes << " "
				 << rootDir.relativeFilePath(filePath) << Qt::endl;
	}
	f.close();
	return true;
}

bool FileRecordDB::save(const QString & path) const
{
	QDir rootDir(QFileInfo(path).absoluteDir());

	QJsonArray ra;
	for (auto const & record: fileRecords_m) {
		ra.append(QJsonObject{
			{Key::path, rootDir.relativeFilePath(record.fileInfo.absoluteFilePath())},
			{Key::version, record.version},
			{Key::checksum, QString(record.checksum.bytes)},
		});
	};
	QJsonDocument d(QJsonObject{
    {Key::__status, QStringLiteral("READ ONLY file for Twx")},
    {Key::__version, version},
    {Key::__type, Key::FileRecordDB},
    {Key::__data, ra},
	});
	QSaveFile f(path);
	if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
		f.write(d.toJson(QJsonDocument::Indented));
		f.commit();
		return true;
	}
	return false;
}

FileRecordDB FileRecordDB::load(const QDir & dir)
{
	auto frdb = load(
		dir.absoluteFilePath(saveComponent)
	);
  if (frdb.fileRecords_m.empty()) {
		frdb = load_legacy(
			dir.absoluteFilePath(QStringLiteral("TwFileVersion.db"))
		);
	}
	return frdb;
}

bool FileRecordDB::save() const
{
	return save (dir_m.absoluteFilePath(saveComponent));
}

void FileRecordDB::add(
	const QFileInfo & fileInfo,
	const QString   & version,
	const Checksum  & checksum,
	const Hash 			& hash
)
{
	// remove all existing entries for this file
	QMutableListIterator<FileRecord> it(fileRecords_m);
	while (it.hasNext()) {
		const FileRecord & fileRecord = it.next();
		if (fileInfo.absoluteFilePath() == fileRecord.fileInfo.absoluteFilePath()) {
			it.remove();
		}
	}
	fileRecords_m.append(FileRecord{
		fileInfo, version, checksum, hash
	});
}

bool FileRecordDB::knows(const QFileInfo & fileInfo) const
{
	for ( const auto & fileRecord: fileRecords_m) {
		if (fileInfo.filePath() == fileRecord.fileInfo.filePath())
			return true;
	}
	return false;
}

const FileRecord & FileRecordDB::get(const QFileInfo & fileInfo) const
{
	for ( const auto & fileRecord: fileRecords_m) {
		if (fileInfo.filePath() == fileRecord.fileInfo.filePath())
			return fileRecord;
	}
	static FileRecord fileRecord;
	return fileRecord;
}

#if defined (TwxCore_TEST)
void FileRecordDB::removeStorage() const
{
  QFile::remove(
		dir_m.absolutePath() + QDir::separator() + saveComponent
	);
}
QList<FileRecord> & FileRecordDB::getList()
{
	return fileRecords_m;
}
const QList<FileRecord> & FileRecordDB::getList() const
{
	return fileRecords_m;
}
#endif

} // namespace Core
} // namespace Twx
