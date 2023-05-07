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

#include "Core/TwxInfo.h"

#include <QLocale>

namespace Twx {

namespace Core {

static const QString copyrightYears_ = QString::fromUtf8("@TWX_INFO_COPYRIGHT_YEARS@");
static const QString copyrightHolders_ = QString::fromUtf8("@TWX_INFO_COPYRIGHT_HOLDERS@");
static const QString authors_ = QString::fromUtf8("@TWX_INFO_AUTHORS@");
static const QString name_ = QString::fromUtf8("@TWX_INFO_NAME@");
static const QString hash_ = QStringLiteral("@TWX_INFO_GIT_HASH@");
static const QDateTime date_ = QDateTime::fromString(
	QStringLiteral("@TWX_INFO_GIT_DATE@"),
	Qt::ISODate
).toUTC();

// static
const QString Info::copyrightYears()
{
	return copyrightYears_;
}
// static
const QString Info::copyrightHolders()
{
	return copyrightHolders_;
}

// static
const QString Info::gitCommitHash()
{
	return hash_;
}

// static
const QString Info::name()
{
	return name_;
}

static
const QDateTime Info::gitCommitDate()
{
	return date_;
}

// static
QString Info::versionString()
{
	return QStringLiteral("@TWX_INFO_PROJECT_VERSION@");
}

QString Info::buildIdString()
{
	return QStringLiteral("@TWX_INFO_BUILD_ID@");
}

QString Info::fullVersionString()
{
	static const QString ans = @TWX_INFO_GIT_OK@
	? QStringLiteral(
		"%1 (%2) [r.%3, %4]"
	).arg(
		versionString(),
		buildIdString(),
		hash_,
		QLocale::system().toString(
			date_.toLocalTime(),
			QLocale::ShortFormat
		)
	)
	: QStringLiteral("%1 (%2)").arg(
		versionString(),
		buildIdString()
	);
	return ans;
}

// static
int Info::getVersion()
{
	return (@TWX_INFO_VERSION_MAJOR@ << 16) | (@TWX_INFO_VERSION_MINOR@ << 8) | @TWX_INFO_VERSION_PATCH@;
}

// static
int Info::getVersionMajor()
{
	return @TWX_INFO_VERSION_MAJOR@;
}

// static
int Info::getVersionMinor()
{
	return @TWX_INFO_VERSION_MINOR@;
}

// static
int Info::getVersionBugfix()
{
	return @TWX_INFO_VERSION_PATCH@;
}

// static
int Info::getVersionPatch()
{
	return @TWX_INFO_VERSION_PATCH@;
}

// static
int Info::getVersionTweak()
{
	return @TWX_INFO_VERSION_TWEAK@;
}

} // namespace Core

} // namespace Twx

