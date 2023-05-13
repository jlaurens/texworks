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

const QString Info::name = QString::fromUtf8("@TWX_CFG_NAME@");
const QString Info::authors = QString::fromUtf8("@TWX_CFG_AUTHORS@");
const QString Info::copyrightYears = QString::fromUtf8("@TWX_CFG_COPYRIGHT_YEARS@");
const QString Info::copyrightHolders = QString::fromUtf8("@TWX_CFG_COPYRIGHT_HOLDERS@");
const QString Info::organizationDomain = QStringLiteral("@TWX_CFG_ORGANIZATION_DOMAIN@");
const QString Info::organizationName   = QStringLiteral("@TWX_CFG_ORGANIZATION_NAME@");
const QString Info::gitHash = QStringLiteral("@TWX_CFG_GIT_HASH@");
const QDateTime Info::gitDate = QDateTime::fromString(
	QStringLiteral("@TWX_CFG_GIT_DATE@"),
	Qt::ISODate
).toUTC();
const QString Info::gitBranch = QStringLiteral("@TWX_CFG_GIT_BRANCH@");


const QString Info::buildId = QStringLiteral("@TWX_CFG_BUILD_ID@");

int Info::versionMNP = @TWX_CFG_VERSION_MAJOR@ << 16
	     	| @TWX_CFG_VERSION_MINOR@ << 8
			 	| @TWX_CFG_VERSION_PATCH@;

int Info::versionMNPT = @TWX_CFG_VERSION_MAJOR@ << 24
	     	| @TWX_CFG_VERSION_MINOR@ << 16
			 	| @TWX_CFG_VERSION_PATCH@ << 8
				| @TWX_CFG_VERSION_TWEAK@;

int Info::versionMajor = @TWX_CFG_VERSION_MAJOR@;

int Info::versionMinor = @TWX_CFG_VERSION_MINOR@;

int Info::versionBugfix = @TWX_CFG_VERSION_PATCH@;

int Info::versionPatch = @TWX_CFG_VERSION_PATCH@;

int Info::versionTweak = @TWX_CFG_VERSION_TWEAK@;

const QString Info::version = QStringLiteral("@TWX_CFG_PROJECT_VERSION@");

const QString Info::versionFull = @TWX_CFG_GIT_OK@
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
// #if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN) || defined (TWX_TEST)
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

