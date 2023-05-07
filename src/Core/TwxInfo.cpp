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

static const QString copyrightYears_ = QString::fromUtf8("1234-5678");
static const QString copyrightHolders_ = QString::fromUtf8("æê®†\"Úºîœπ‡Ò∂\"ƒﬁÌÏÈ");
static const QString authors_ = QString::fromUtf8("Ò∂ƒﬁ");
static const QString name_ = QString::fromUtf8("TwxCoreTest");
static const QString hash_ = QStringLiteral("ed726a59*");
static const QDateTime date_ = QDateTime::fromString(
	QStringLiteral("2023-04-28T13:23:07+02:00"),
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
	return QStringLiteral("1.7.8");
}

QString Info::buildIdString()
{
	return QStringLiteral("personal");
}

QString Info::fullVersionString()
{
	static const QString ans = ON
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
	return (1 << 16) | (7 << 8) | 8;
}

// static
int Info::getVersionMajor()
{
	return 1;
}

// static
int Info::getVersionMinor()
{
	return 7;
}

// static
int Info::getVersionBugfix()
{
	return 8;
}

// static
int Info::getVersionPatch()
{
	return 8;
}

// static
int Info::getVersionTweak()
{
	return 9;
}

} // namespace Core

} // namespace Twx

