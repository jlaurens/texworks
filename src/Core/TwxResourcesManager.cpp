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

#include "Core/TwxResourcesLibrary.h"
#include "Core/TwxFileRecordDB.h"
#include "Core/TwxInfo.h"

#include <QDebug>
#include <QDirIterator>
#include <QStandardPaths>

namespace Twx {
namespace Core {

QString ResourcesManager::m_portableLibPath;

#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
// compile-time default paths - customize by defining in the .pro file
#	ifndef TW_DICPATH
#		define TW_DICPATH "/usr/share/hunspell" PATH_LIST_SEP "/usr/share/myspell/dicts"
#	endif
#endif

// static
const QString ResourcesManager::getLibraryRootPath()
{
#if QT_VERSION >= QT_VERSION_CHECK(5, 4, 0)
	return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
#else
	return QStandardPaths::writableLocation(QStandardPaths::DataLocation);
#endif
}

// the return value is sorted from new to old
const QStringList ResourcesManager::getLegacyLibraryRootPaths()
{
	QStringList retVal;
#if defined(Q_OS_DARWIN)
	retVal << QStringLiteral("%1/Library/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#elif defined(Q_OS_UNIX) // && !defined(Q_OS_DARWIN)
	retVal << QStringLiteral("%1/.%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#else // defined(Q_OS_WIN)
	retVal << QStringLiteral("%1/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#endif
	return retVal;
}

// static
bool ResourcesManager::shouldMigrateLegacyLibrary()
{
	// We don't migrate old (system) libraries in portable mode
	if (!getPortableLibPath().isEmpty()) {
		return false;
	}
	const QString dst = getLibraryRootPath();
	// We don't migrate if the destination exists already
	if (QDir(dst).exists()) {
		return false;
	}
	for (const QString & src : getLegacyLibraryRootPaths()) {
		if (QDir(src).exists()) {
			return true;
		}
	}
	return false;
}

// static
void ResourcesManager::migrateLegacyLibrary()
{
	const QDir dst(getLibraryRootPath());

	for (const QString & srcPath : getLegacyLibraryRootPaths()) {
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
}

// static
const QString ResourcesManager::getPath(const QString& subdir, const bool updateOnDisk /* = true */)
{
	QString libRootPath, libPath;

	libRootPath = getPortableLibPath();
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
		libRootPath = getLibraryRootPath();
		if (shouldMigrateLegacyLibrary()) {
			migrateLegacyLibrary();
		}
	}
	libPath = QDir(libRootPath).absolutePath() + QStringLiteral("/") + subdir;

	if(updateOnDisk)
		updateLibraryResources(QDir(QString::fromLatin1(":/resfiles")), libRootPath, subdir);
	return libPath;
}

// static
const QStringList ResourcesManager::getLibraryPaths(const QString & subdir, const bool updateOnDisk)
{
	return getLibraryPath(subdir, updateOnDisk).split(QStringLiteral(PATH_LIST_SEP));
}

// static
void ResourcesManager::updateLibraryResources(const QDir& srcRootDir, const QDir& destRootDir, const QString& subdir)
{
	QDir srcDir(srcRootDir);
	QDir destDir(destRootDir.absolutePath() + QDir::separator() + subdir);
// sanity check
	if (!srcDir.cd(subdir))
		return;
	// don't copy the built-in translations
	if (subdir == QStringLiteral("translations"))
		return;

	// make sure the library folder exists - even if the user deleted it;
	// otherwise other parts of the program might fail
	if (!destDir.exists())
		QDir::root().mkpath(destDir.absolutePath());

	auto frdb = FileRecordDB::load(destRootDir);

	QDirIterator iter(srcDir, QDirIterator::Subdirectories);
	while (iter.hasNext()) {
		(void)iter.next();
		// Skip directories (they get created on-the-fly if required for copying files)
		if (iter.fileInfo().isDir())
			continue;

		QString srcPath = iter.fileInfo().filePath();
		QString path = srcRootDir.relativeFilePath(srcPath);
		QFileInfo destFileInfo(destRootDir.filePath(path));

		// Check if the file is in the database
		if (frdb.knows(destFileInfo)) {
			// If the file no longer exists on the disk, the user has deleted it
			// Hence we won't recreate it, but we keep the database record to
			// remember that this file was deleted by the user
			if (!destFileInfo.exists())
				continue;

			auto record = frdb.get(destFileInfo);

			auto srcHash  = Twx::Core::hashForFilePath(srcPath);
			auto destHash = Twx::Core::hashForFilePath(destFileInfo.filePath());
			// If the file was modified, don't do anything, either
			if (destHash != record.hash) {
				// The only exception is if the file on the disk matches the
				// new file we would have installed. In this case, we reassume
				// ownership of it. (This is the case if the user deleted the
				// file, but later wants to resurrect it by downloading the
				// latest version from the internet)
				if (destHash != srcHash)
					continue;
				frdb.add(destFileInfo, Info::gitHash(), QByteArray(), srcHash);
			}
			else {
				// The file matches the record in the database; update it
				// (copying is only necessary if the contents has changed)
				if (srcHash == destHash)
					frdb.add(destFileInfo, Info::gitHash(), QByteArray(), srcHash);
				else {
					// we have to remove the file first as QFile::copy doesn't
					// overwrite existing files
					QFile::remove(destFileInfo.filePath());
					if(QFile::copy(srcPath, destFileInfo.filePath()))
						frdb.add(destFileInfo, Info::gitHash(), QByteArray(), srcHash);
				}
			}
		} else {
			QByteArray srcHash = Twx::Core::hashForFilePath(srcPath);
			// If the file is not in the database, we add it - unless a file
			// with the name already exists
			if (!QFileInfo(destFileInfo).exists()) {
				// We have to make sure the directory exists - otherwise copying
				// might fail
				destRootDir.mkpath(QFileInfo(destFileInfo).path());
				QFile(srcPath).copy(destFileInfo.filePath());
				frdb.addFileRecord(destFileInfo, Info::gitHash(), QByteArray(), srcHash);
			}
			else {
				// If a file with that name already exists, we don't replace it
				// If it happens to be identical with the version we would install
				// we do take ownership, however, and register it in the
				// database so that future updates are applied
				QByteArray destHash = Twx::Core::hashForFilePath(destFileInfo.filePath());
				if (srcHash == destHash)
					frdb.add(destFileInfo, Info::gitHash(), QByteArray(), destHash);
			}
		}
	}
	
  frdb.clean();
	frdb.save(destRootDir);
}

static QString m_portableLibPath;

static const QString & ResourcesManager::getPortableLibPath()
{
	return m_portableLibPath;
}
static void ResourcesManager::setPortableLibPath(const QString & path)
{
	m_portableLibPath = path;
}

} // namespace Core
} // namespace Twx
