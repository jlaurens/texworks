/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2020-2023  Stefan Löffler, Jérôme LAURENS

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

#include "Core/TwxAssetsLookup.h"
#include "Core/TwxAssetsTrackDB.h"
#include "Core/TwxInfo.h"
#include "Core/TwxSettings.h"
#include "Core/TwxPathManager.h"

#include <QDebug>
#include <QDirIterator>
#include <QStandardPaths>
#include <QCoreApplication>

namespace Twx {

namespace Path {
  const QString & applicationImage           = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE_128@");
  extern const QString & applicationImage128 = QStringLiteral("@TWX_CFG_APPLICATION_IMAGE@");
}

namespace Core {

namespace Key {
	const QString libpath = QStringLiteral("libpath");
}

#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
// compile-time default paths - customize by defining in the .pro file
#	ifndef TW_DICPATH
#		define TW_DICPATH "/usr/share/hunspell" PATH_LIST_SEP "/usr/share/myspell/dicts"
#	endif
#endif

void AssetsLookup::setup(const Settings & settings)
{
	if (settings.contains(Key::libpath)) {
		auto dir = PathManager::getApplicationDir();
		if (dir.cd(settings.value(Key::libpath).toString())) {
			setSetupPath(dir.absolutePath());
		}
	}
}

// static
/** \brief 
  * 
	*/
const QString AssetsLookup::getPath()
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 4, 0)
	return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#else
	return QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif
}

const QString AssetsLookup::getLegacyPath()
{
#if defined(Q_OS_DARWIN)
	return QStringLiteral("%1/Library/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#elif defined(Q_OS_UNIX) // && !defined(Q_OS_DARWIN)
	return QStringLiteral("%1/.%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#else // defined(Q_OS_WIN)
	return QStringLiteral("%1/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#endif
}

// static
bool AssetsLookup::shouldMigrateLegacy()
{
	// We don't migrate old (system) libraries in -setup.ini mode
	if (!getSetupPath().isEmpty()) {
		return false;
	}
	// We don't migrate if the destination exists already
	if (QDir(getPath()).exists()) {
		return false;
	}
	if (QDir(getLegacyPath()).exists()) {
		return true;
	}
	return false;
}

// static
void AssetsLookup::migrateLegacy()
{
	const QDir dst(getPath());
	const QString & srcPath = getLegacyPath();
	QDir src(srcPath);
	if (src.exists()) {
		qDebug() << "Migrating resources library from" << src.absolutePath() << "to" << dst.absolutePath();
		dst.mkpath(QStringLiteral("."));
		QDirIterator it(src, QDirIterator::Subdirectories);
		while (it.hasNext()) {
			it.next();
			const QFileInfo & srcFileInfo(it.fileInfo());
			const QString relativePath(src.relativeFilePath(srcFileInfo.absoluteFilePath()));

			if (srcFileInfo.isSymLink()) {
				QFile::link(srcFileInfo.symLinkTarget(), dst.filePath(relativePath));
			}
			else if (srcFileInfo.isDir()) {
				dst.mkpath(relativePath);
			}
			else {
				QFile f(srcFileInfo.absoluteFilePath());
				f.copy(dst.filePath(relativePath));
			}
		}
	}
}

// static
const QStringList AssetsLookup::getPathList(const QString & subdir, const bool updateOnDisk)
{
	QString libRootPath, libPath;

	libRootPath = getSetupPath();
	if (libRootPath.isEmpty()) {
#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
		if (subdir == QLatin1String("dictionaries")) {
			libPath = QString::fromLatin1(TW_DICPATH);
			QString dicPath = QString::fromLocal8Bit(getenv("TW_DICPATH"));
			if (!dicPath.isEmpty())
				libPath = dicPath;
			return libPath; // don't try to create/update the system dicts directory
		}
#endif
		libRootPath = getPath();
		if (shouldMigrateLegacy()) {
			migrateLegacy();
		}
	}
	libPath = QDir(libRootPath).absolutePath() + QStringLiteral("/") + subdir;

	if(updateOnDisk)
		update(QDir(QString::fromLatin1(":/resfiles")), libRootPath, subdir);
	return libPath.split(QDir::listSeparator());
}

// static
void AssetsLookup::update(
	const QDir& factoryDir,
	const QDir& assetsDir,
	const QString& subdirPath)
{
	if (subdirPath == QStringLiteral("translations"))
		// don't copy the factory translations
		return;
	QDir factorySubdir(factoryDir);
	if (!factorySubdir.cd(subdirPath))
	  // Nothing to copy
		return;
	QDir assetsSubdir(assetsDir);
	if (!assetsSubdir.mkpath(subdirPath))
	  // No destination to copy
		return;
	assetsSubdir.cd(subdirPath);

	auto frdb = AssetsTrackDB::load(assetsDir);

	QDirIterator iter(factorySubdir, QDirIterator::Subdirectories);
	while (iter.hasNext()) {
		(void)iter.next();
		// Skip directories (they get created on-the-fly if required for copying files)
		if (iter.fileInfo().isDir())
			continue;

		QString factoryPath = iter.fileInfo().filePath();
		QString relativePath = factoryDir.relativeFilePath(factoryPath);
		QFileInfo assetsFileInfo(assetsDir.filePath(relativePath));

		// Check if the file is in the database
		if (frdb.knows(assetsFileInfo)) {
			// If the file no longer exists on the disk, the user has deleted it
			// Hence we won't recreate it, but we keep the database track to
			// remember that this file was deleted by the user
			if (!assetsFileInfo.exists())
				continue;

			auto track = frdb.get(assetsFileInfo);

			auto factoryChecksum = checksumForFilePath(factoryPath);
			auto assetsChecksum  = checksumForFilePath(assetsFileInfo.filePath());
			// If the file was modified, don't do anything, either
			if (factoryChecksum != track.checksum) {
				// The only exception is if the file on the disk matches the
				// new file we would have installed. In this case, we reassume
				// ownership of it. (This is the case if the user deleted the
				// file, but later wants to resurrect it by downloading the
				// latest version from the internet)
				if (assetsChecksum != factoryChecksum)
					continue;
				frdb.add(assetsFileInfo, Info::gitHash(), assetsChecksum);
			}
			else {
				// The file matches the track in the database; update it
				// (copying is only necessary if the contents has changed)
				if (srcHash == destHash)
					frdb.add(assetsFileInfo, Info::gitHash(), Checksum{}, srcHash);
				else {
					// we have to remove the file first as QFile::copy doesn't
					// overwrite existing files
					QFile::remove(assetsFileInfo.filePath());
					if(QFile::copy(factoryPath, assetsFileInfo.filePath()))
						frdb.add(assetsFileInfo, Info::gitHash(), Checksum{}, srcHash);
				}
			}
		} else {
			auto srcHash = hashForFilePath(factoryPath);
			// If the file is not in the database, we add it - unless a file
			// with the name already exists
			if (!QFileInfo(assetsFileInfo).exists()) {
				// We have to make sure the directory exists - otherwise copying
				// might fail
				assetsDir.mkpath(QFileInfo(assetsFileInfo).path());
				QFile(factoryPath).copy(assetsFileInfo.filePath());
				frdb.add(assetsFileInfo, Info::gitHash(), Checksum{}, srcHash);
			}
			else {
				// If a file with that name already exists, we don't replace it
				// If it happens to be identical with the version we would install
				// we do take ownership, however, and register it in the
				// database so that future updates are applied
				auto destHash = hashForFilePath(assetsFileInfo.filePath());
				if (srcHash == destHash)
					frdb.add(assetsFileInfo, Info::gitHash(), Checksum{}, destHash);
			}
		}
	}
  frdb.clean(factoryDir);
	frdb.save();
}

namespace P {
	static QString setupPath;
}

static const QString & AssetsLookup::getSetupPath()
{
	return P::setupPath;
}
static void AssetsLookup::setSetupPath(const QString & path)
{
	P::setupPath = path;
}

} // namespace Core
} // namespace Twx
