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

#include "Core/TwxAssets.h"
#include "Core/TwxAssetsTrackDB.h"
#include "Core/TwxConst.h"
#include "Core/TwxInfo.h"
#include "Core/TwxSettings.h"
#include "Core/TwxPathManager.h"

#include <QDebug>
#include <QDirIterator>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QSettings>

namespace Twx {

namespace Core {

#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
// compile-time default paths - customize by defining in the .pro file
#	ifndef TW_DICPATH
#		define TW_DICPATH "/usr/share/hunspell" PATH_LIST_SEP "/usr/share/myspell/dicts"
#	endif
#endif

void Assets::setup(const QSettings & settings)
{
	if (settings.contains(Key::libpath)) {
		auto dir = PathManager::getApplicationDir();
		if (dir.cd(settings.value(Key::libpath).toString())) {
			setSetupLocation(dir.absolutePath());
		}
	}
}

TWX_CONST_NO_TEST QString Assets::standardLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
TWX_CONST_NO_TEST QString Assets::legacyLocation =
#if defined(Q_OS_DARWIN)
	QStringLiteral("%1/Library/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#elif defined(Q_OS_UNIX) // && !defined(Q_OS_DARWIN)
	QStringLiteral("%1/.%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#else // defined(Q_OS_WIN)
	QStringLiteral("%1/%2/").arg(QDir::homePath(), QCoreApplication::applicationName());
#endif

// static
void Assets::possiblyMigrateLegacy()
{
	// We don't migrate old (system) libraries in -setup.ini mode
	if (!getSetupLocation().isEmpty()) {
		return;
	}
	// We don't migrate if the destination exists already
	const QDir standardDir(standardLocation);
	if (standardDir.exists()) {
		return;
	}
	QDir legacyDir(legacyLocation);
	if (!legacyDir.exists()) {
		return;
	}
	qDebug() << "Migrating assets from" << legacyDir.absolutePath() << "to" << standardDir.absolutePath();
	standardDir.mkpath(Path::dot);
	QDirIterator it(legacyDir, QDirIterator::Subdirectories);
	while (it.hasNext()) {
		(void)it.next();
		const QFileInfo & legacyFileInfo(it.fileInfo());
		const QString relativePath(legacyDir.relativeFilePath(legacyFileInfo.absoluteFilePath()));

		if (legacyFileInfo.isSymLink()) {
			QFile::link(legacyFileInfo.symLinkTarget(), standardDir.filePath(relativePath));
		} else if (legacyFileInfo.isDir()) {
			standardDir.mkpath(relativePath);
		} else {
			QFile f(legacyFileInfo.absoluteFilePath());
			f.copy(standardDir.filePath(relativePath));
		}
	}
}

// static
const QStringList Assets::dictionaryLocations(
	const bool updateLocal
)
{
#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
	if (getSetupLocation().isEmpty()) {
		// The "-setup.ini" mode takes precedence over the process environment
		const auto answer = rawUnixDictionaryLocations(QProcessEnvironment::systemEnvironment());
		if (!answer.empty())
		  return answer;
	}
#endif
	return QStringList{ getPath(
		Key::dictionaries,
		updateLocal
	) };
}

// This is specific to raw unix ( not apple )
// However, testing is not always performed on raw unix
// and we do not want to change the process environment variables
// on the fly to control exactly the overall state.
// With next method we can simulate raw unix behaviour
const QStringList Assets::rawUnixDictionaryLocations(
	const QProcessEnvironment & PE
)
{
	// The "-setup.ini" mode takes precedence over the process environment
#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN) || defined(TwxAssets_TEST)
	QString dicPath = PE.value(QStringLiteral("TW_DICPATH"));
	if (!dicPath.isEmpty())
		return dicPath.split(QDir::listSeparator());
# if defined(TW_DICPATH)
	dicPath = QStringLiteral("TW_DICPATH");
	if (!dicPath.isEmpty())
		return dicPath.split(QDir::listSeparator());
	// don't try to create/update the system dicts directory, JL: meaning?
# endif
	return QStringList{
		QStringLiteral("/usr/share/hunspell"),
		QStringLiteral("/usr/share/myspell/dicts"),
	};
#else
	return QStringList();
#endif
}

// TODO: Change this awfull `resfiles` into `assetsDir` or `assets`
// depending on the context
TWX_CONST_NO_TEST QDir Assets::factoryDir = QDir(QStringLiteral(":/resfiles"));

// static
const QString Assets::getPath(
	const QString & category,
	const bool updateLocal
)
{
	QString location = getSetupLocation();
	if (location.isEmpty()) {
		location = standardLocation;
		possiblyMigrateLegacy();
	}
	if(updateLocal) {
		update(location, category);
	}
	return QDir(location).absoluteFilePath(category);
}

namespace K {
	static const QString translations = QStringLiteral("translations");
}
// static
int Assets::update(
	const QDir& assetsDir,
	const QString& category)
{
	if (category == K::translations) {
		// don't copy the factory translations
		return 1;
	}
	QDir factorySubdir(factoryDir);
	if (!factorySubdir.cd(category))
	  // Nothing to copy
		return 2;
	QDir assetsSubdir(assetsDir);
	if (!assetsSubdir.mkpath(category))
	  // No destination to copy
		return 3;
	assetsSubdir.cd(category);

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
				frdb.add(assetsFileInfo, Info::gitHash, assetsChecksum);
			}
			else {
				// The file matches the track in the database; update it
				// (copying is only necessary if the contents has changed)
				if (factoryChecksum == assetsChecksum)
					frdb.add(assetsFileInfo, Info::gitHash, assetsChecksum);
				else {
					// we have to remove the file first as QFile::copy doesn't
					// overwrite existing files
					QFile::remove(assetsFileInfo.filePath());
					if(QFile::copy(factoryPath, assetsFileInfo.filePath()))
						frdb.add(assetsFileInfo, Info::gitHash, factoryChecksum);
				}
			}
		} else {
			auto factoryChecksum = checksumForFilePath(factoryPath);
			// If the file is not in the database, we add it - unless a file
			// with the name already exists
			if (!QFileInfo(assetsFileInfo).exists()) {
				// We have to make sure the directory exists - otherwise copying
				// might fail
				assetsDir.mkpath(assetsFileInfo.path());
				QFile(factoryPath).copy(assetsFileInfo.absoluteFilePath());
				frdb.add(assetsFileInfo, Info::gitHash, factoryChecksum);
			}
			else {
				// If a file with that name already exists, we don't replace it
				// If it happens to be identical with the version we would install
				// we do take ownership, however, and register it in the
				// database so that future updates are applied
				auto assetsChecksum = checksumForFilePath(assetsFileInfo.filePath());
				if (factoryChecksum == assetsChecksum)
					frdb.add(assetsFileInfo, Info::gitHash, assetsChecksum);
			}
		}
	}
  frdb.adjust(factoryDir);
	frdb.save();
	return 0;
}

namespace P {
	static QString setupPath;
}

const QString & Assets::getSetupLocation()
{
	return P::setupPath;
}
void Assets::setSetupLocation(const QString & path)
{
	P::setupPath = path;
}

} // namespace Core
} // namespace Twx
