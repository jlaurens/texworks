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
#include "Core/TwxAssetsTrackDB.h"
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

const int AssetsTrackDB::version = 1;

#if defined(TwxCore_TEST)
const QString AssetsTrackDB::saveComponent = 
#else
static auto const saveComponent = 
#endif
QStringLiteral("TwxAssetsTrackDB.json");

// next are static keys local to this code unit
namespace Key {
	static const QString path     = QStringLiteral("path");
	static const QString version  = QStringLiteral("version");
	static const QString checksum = QStringLiteral("checksum");
	static const QString hash     = QStringLiteral("hash");
	static const QString AssetsTrackDB = QStringLiteral("TwxAssetsTrackDB");
}

AssetsTrackDB::AssetsTrackDB( const QDir & dir)
: dir_m(dir)
{}

/* The persistent storage is a text file
 * Each line starting with a `#` is a comment
 * Other lines: <version><space><hash><space><file path>
 */
AssetsTrackDB AssetsTrackDB::load(const QString & path)
{	
	QDir rootDir(QFileInfo(path).absoluteDir());
	QDir rootPath(rootDir.absolutePath());
	AssetsTrackDB frdb(rootDir);
  QFile f(path);
	if (f.open(QIODevice::ReadOnly)) {
		auto bytes = f.readAll();
		auto o = QJsonDocument::fromJson(bytes).object();
		if (o.value(Key::__type) == Key::AssetsTrackDB) {
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

AssetsTrackDB AssetsTrackDB::load_legacy(const QString & path)
{
	QDir rootDir(QFileInfo(path).absoluteDir());
	AssetsTrackDB frdb(rootDir);

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

bool AssetsTrackDB::save_legacy(const QString & path) const
{
	QFile f(path);
	if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
		return false;
	}
	QTextStream strm(&f);
	QDir rootDir(QFileInfo(path).absoluteDir());
	for ( const auto & track: assetsTracks_m ) {
		QString filePath = track.fileInfo.absoluteFilePath();
		strm << track.version      << " "
		     << track.hash.bytes << " "
				 << rootDir.relativeFilePath(filePath) << Qt::endl;
	}
	f.close();
	return true;
}

bool AssetsTrackDB::save(const QString & path) const
{
	QDir rootDir(QFileInfo(path).absoluteDir());

	QJsonArray ra;
	for (auto const & track: assetsTracks_m) {
		ra.append(QJsonObject{
			{Key::path, rootDir.relativeFilePath(track.fileInfo.absoluteFilePath())},
			{Key::version, track.version},
			{Key::checksum, QString(track.checksum.bytes)},
		});
	};
	QJsonDocument d(QJsonObject{
    {Key::__status, QStringLiteral("READ ONLY file for Twx")},
    {Key::__version, version},
    {Key::__type, Key::AssetsTrackDB},
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

AssetsTrackDB AssetsTrackDB::load(const QDir & dir)
{
	auto frdb = load(
		dir.absoluteFilePath(saveComponent)
	);
  if (frdb.assetsTracks_m.empty()) {
		frdb = load_legacy(
			dir.absoluteFilePath(QStringLiteral("TwFileVersion.db"))
		);
	}
	return frdb;
}

bool AssetsTrackDB::save() const
{
	return save (dir_m.absoluteFilePath(saveComponent));
}

void AssetsTrackDB::add(
	const QFileInfo & fileInfo,
	const QString   & version,
	const Checksum  & checksum,
	const Hash 			& hash
)
{
	// remove all existing entries for this file
	QMutableListIterator<AssetsTrack> it(assetsTracks_m);
	while (it.hasNext()) {
		const AssetsTrack & fileRecord = it.next();
		if (fileInfo.absoluteFilePath() == fileRecord.fileInfo.absoluteFilePath()) {
			it.remove();
		}
	}
	assetsTracks_m.append(AssetsTrack{
		fileInfo, version, checksum, hash
	});
}

bool AssetsTrackDB::knows(const QFileInfo & fileInfo) const
{
	for ( const auto & fileRecord: assetsTracks_m) {
		if (fileInfo.filePath() == fileRecord.fileInfo.filePath())
			return true;
	}
	return false;
}

const AssetsTrack & AssetsTrackDB::get(const QFileInfo & fileInfo) const
{
	for ( const auto & fileRecord: assetsTracks_m) {
		if (fileInfo.filePath() == fileRecord.fileInfo.filePath())
			return fileRecord;
	}
	static AssetsTrack fileRecord;
	return fileRecord;
}

void AssetsTrackDB::adjust(const QDir & factoryDir)
{
	// Now, remove all tracked files that are no longer in the factory
	// that are unmodified on disk and were
	// removed upstream
	QMutableListIterator<AssetsTrack> it(assetsTracks_m);
	while (it.hasNext()) {
		const auto & track = it.next();
		QString trackPath  = track.fileInfo.absoluteFilePath();

		// If the factory file still exists there is nothing to do here
		QString relativePath = dir_m.relativeFilePath(trackPath);
		if (factoryDir.exists(relativePath))
			continue;

		// If the factory file no longer exists but the track is up to
		// date, remove the track and its associate file
		if (track.fileInfo.exists()) {
			if ( (!track.hash.bytes.isEmpty()
						&& hashForFilePath(trackPath) == track.hash)
			  || (!track.checksum.bytes.isEmpty()
						&& checksumForFilePath(trackPath) == track.checksum)	)
			{
				QFile(trackPath).remove();
				it.remove();
			}
		}
	}
}

#if defined (TwxCore_TEST)
void AssetsTrackDB::removeStorage() const
{
  QFile::remove(
		dir_m.absolutePath() + QDir::separator() + saveComponent
	);
}
QList<AssetsTrack> & AssetsTrackDB::getList()
{
	return assetsTracks_m;
}
const QList<AssetsTrack> & AssetsTrackDB::getList() const
{
	return assetsTracks_m;
}
#endif

} // namespace Core
} // namespace Twx
