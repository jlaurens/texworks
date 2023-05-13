/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Stefan Löffler, Jérôme Laurens

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

#include "TwxTool.h"

#include <QByteArray>
#include <QString>
#include <QCryptographicHash>
#include <QFile>

namespace Twx {
namespace Core {

bool Hash::operator==(const Hash & rhs)
{
	return bytes == rhs.bytes;
}

bool Hash::operator!=(const Hash & rhs)
{
	return bytes != rhs.bytes;
}

bool Checksum::operator==(const Checksum & rhs)
{
	return bytes == rhs.bytes;
}

bool Checksum::operator!=(const Checksum & rhs)
{
	return bytes != rhs.bytes;
}

/*static*/
Hash md5Hash (const QByteArray & bytes)
{
  return Hash{
		QCryptographicHash::hash(
			bytes,
			QCryptographicHash::Md5
		).toHex()
	};
};
Hash md5Hash (const QString & text)
{
  return md5Hash(text.toUtf8());
};
Checksum sha256Checksum (const QByteArray & bytes)
{
  return Checksum{
		QCryptographicHash::hash(
			bytes,
			QCryptographicHash::Sha256
		).toHex()
	};
};
Checksum sha256Checksum (const QString & text)
{
  return sha256Checksum(text.toUtf8());
};

/*static*/
Hash hashForFilePath(const QString path)
{
	QFile f(path);
	if (f.open(QIODevice::ReadOnly)) {
		auto contents = f.readAll();
		f.close();
		return md5Hash(contents);
	}
	return Hash();
}

Checksum checksumForFilePath(const QString path)
{
	QFile f(path);
	if (f.open(QIODevice::ReadOnly)) {
		auto contents = f.readAll();
		f.close();
		return sha256Checksum(contents);
	}
	return Checksum();
}

} // namespace Core
} // namespace Twx
