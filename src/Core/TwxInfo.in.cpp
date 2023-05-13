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

static const QString name_ = QString::fromUtf8("@TWX_CFG_NAME@");
static const QString authors_ = QString::fromUtf8("@TWX_CFG_AUTHORS@");
static const QString copyrightYears_ = QString::fromUtf8("@TWX_CFG_COPYRIGHT_YEARS@");
static const QString copyrightHolders_ = QString::fromUtf8("@TWX_CFG_COPYRIGHT_HOLDERS@");
static const QString hash_ = QStringLiteral("@TWX_CFG_GIT_HASH@");
static const QDateTime date_ = QDateTime::fromString(
	QStringLiteral("@TWX_CFG_GIT_DATE@"),
	Qt::ISODate
).toUTC();
static const QString branch_ = QStringLiteral("@TWX_CFG_GIT_BRANCH@");

// static
const QString Info::name()
{
	return name_;
}

// static
const QString Info::authors()
{
	return authors_;
}

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
int Info::versionMNP()
{
	return  @TWX_CFG_VERSION_MAJOR@ << 16
	     	| @TWX_CFG_VERSION_MINOR@ << 8
			 	| @TWX_CFG_VERSION_PATCH@;
}

// static
int Info::versionMNPT()
{
	return  @TWX_CFG_VERSION_MAJOR@ << 24
	     	| @TWX_CFG_VERSION_MINOR@ << 16
			 	| @TWX_CFG_VERSION_PATCH@ << 8
				| @TWX_CFG_VERSION_TWEAK@;
}

// static
int Info::versionMajor()
{
	return @TWX_CFG_VERSION_MAJOR@;
}

// static
int Info::versionMinor()
{
	return @TWX_CFG_VERSION_MINOR@;
}

// static
int Info::versionBugfix()
{
	return @TWX_CFG_VERSION_PATCH@;
}

// static
int Info::versionPatch()
{
	return @TWX_CFG_VERSION_PATCH@;
}

// static
int Info::versionTweak()
{
	return @TWX_CFG_VERSION_TWEAK@;
}

// static
const QString Info::version()
{
	return QStringLiteral("@TWX_CFG_PROJECT_VERSION@");
}

const QString Info::versionFull()
{
	static const QString ans = @TWX_CFG_GIT_OK@
	? QStringLiteral(
		"%1 (%2) [r.%3, %4]"
	).arg(
		version(),
		buildId(),
		hash_,
		QLocale::system().toString(
			date_.toLocalTime(),
			QLocale::ShortFormat
		)
	)
	: QStringLiteral("%1 (%2)").arg(
		version(),
		buildId()
	);
	return ans;
}

const QString Info::buildId()
{
	return QStringLiteral("@TWX_CFG_BUILD_ID@");
}

// static
const QString Info::gitHash()
{
	return hash_;
}

// static
const QDateTime Info::gitDate()
{
	return date_;
}

// static
const QString Info::gitBranch()
{
	return branch_;
}

} // namespace Core

} // namespace Twx

