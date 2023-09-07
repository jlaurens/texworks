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

// THIS FILE MUST BE IN UTF-8
// NB: documenting the source and the header at the same time
// gets doxygen into trouble

#include "TwxInfo.h"

#include <QLocale>
#include <QCoreApplication>

namespace Twx {

namespace Core {

const QString Info::name = QString::fromUtf8("@/TWX/CFG/NAME@");
const QString Info::domain = QStringLiteral("@/TWX/CFG/DOMAIN@");
const QString Info::authors = QString::fromUtf8("@/TWX/CFG/AUTHORS@");
const QString Info::copyrightYears = QString::fromUtf8("@/TWX/CFG/COPYRIGHT_YEARS@");
const QString Info::copyrightHolders = QString::fromUtf8("@/TWX/CFG/COPYRIGHT_HOLDERS@");
const QString Info::organizationDomain = QStringLiteral("@/TWX/CFG/ORGANIZATION_DOMAIN@");
const QString Info::organizationName   		= QString::fromUtf8("@/TWX/CFG/ORGANIZATION_NAME@");
const QString Info::organizationShortName = QString::fromUtf8("@/TWX/CFG/ORGANIZATION_SHORT_NAME@");
const QString Info::gitHash = QStringLiteral("@/TWX/CFG/GIT_HASH@");
const QDateTime Info::gitDate = QDateTime::fromString(
	QStringLiteral("@/TWX/CFG/GIT_DATE@"),
	Qt::ISODate
).toUTC();
const QString Info::gitBranch = QStringLiteral("@/TWX/CFG/GIT_BRANCH@");


const QString Info::buildId = QStringLiteral("@/TWX/CFG/BUILD_ID@");

int Info::versionMNP = @/TWX/CFG/VERSION_MAJOR@ << 16
	     	| @/TWX/CFG/VERSION_MINOR@ << 8
			 	| @/TWX/CFG/VERSION_PATCH@;

int Info::versionMNPT = @/TWX/CFG/VERSION_MAJOR@ << 24
	     	| @/TWX/CFG/VERSION_MINOR@ << 16
			 	| @/TWX/CFG/VERSION_PATCH@ << 8
				| @/TWX/CFG/VERSION_TWEAK@;

int Info::versionMajor = @/TWX/CFG/VERSION_MAJOR@;

int Info::versionMinor = @/TWX/CFG/VERSION_MINOR@;

int Info::versionBugfix = @/TWX/CFG/VERSION_PATCH@;

int Info::versionPatch = @/TWX/CFG/VERSION_PATCH@;

int Info::versionTweak = @/TWX/CFG/VERSION_TWEAK@;

const QString Info::version = QStringLiteral("@/TWX/CFG/VERSION@");

const QString Info::versionFull = @/TWX/CFG/GIT_OK@
	? QStringLiteral(
		"%1 (%2) [r.%3, %4]"
	).arg(
		Info::version,
		Info::buildId,
		Info::gitHash,
		QLocale::system().toString(
			gitDate.toLocalTime(),
			QLocale::ShortFormat
		)
	)
	: QStringLiteral("%1 (%2)").arg(
		Info::version,
		Info::buildId
	);

void Info::initApplication (QCoreApplication * application)
{
// #if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN) || defined (/TWX/TESTING)
// #else
//   Q_UNUSED(application);
// #endif
  if (application) {
		application->setOrganizationName(Info::organizationName);
		application->setOrganizationDomain(Info::organizationDomain);
		application->setApplicationName(Info::name);
	}
}

} // namespace Core

} // namespace Twx

