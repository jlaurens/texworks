/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2023  Jérôme Laurens

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
/** \file
 * \brief General purpose constants
 * 
 * 
*/
#ifndef TwxCore_Tools_H
#define TwxCore_Tools_H

#include <QString>

namespace Twx {
namespace Core {

/** \brief A md5 checksum wrapper
 * 
 * `==` and `!=` operators are implemented.
 */
struct Hash {
  QByteArray bytes;
  bool operator==(const Hash &);
  bool operator!=(const Hash &);
};

/** \brief A sha 256 wrapper
 * 
 * `==` and `!=` operators are implemented.
 */
struct Checksum {
  QByteArray bytes;
  bool operator==(const Checksum &);
  bool operator!=(const Checksum &);
};

/** \brief md5 checksum of a byte array
  * 
  * \param bytes is a possibly void QByteArray instance.
  * \return an hexadecimal representation of the md5 checksum of `bytes`.
  */
extern Hash md5Hash(const QByteArray & bytes);

/** \brief md5 checksum of a text
  * 
  * \param text is a possibly void QString instance.
  * \return an hexadecimal representation of the md5 checksum of `text`.
  */
extern Hash md5Hash(const QString & text);

/** \brief sha256 checksum of a byte array
  * 
  * \param bytes is a possibly void QByteArray instance.
  * \return an hexadecimal representation of the sha256 checksum of `bytes`.
  */
extern Hash md5Hash(const QByteArray & bytes);

/** \brief sha256 checksum of a text
  * 
  * \param text is a possibly void QString instance.
  * \return an hexadecimal representation of the sha256 checksum of `text`.
  */
extern Checksum sha256Checksum(const QString & text);

/** \brief md5 checksum of a file contents
  * 
	* The checksum of a file that do not exist is an empty `QByteArray`.
	*
  * \param path is a full path of an existing file, or not.
  * \return an hexadecimal representation of the `md5Hash()` of the contents at the given path if any,
  * an empty `QByteArray` otherwise.
  */
extern Hash hashForFilePath(const QString path);

/** \brief sha256 checksum of a file contents
  * 
	* The checksum of a file that do not exist is an empty `QByteArray`.
	*
  * \param path is a full path of an existing file, or not.
  * \return an hexadecimal representation of the `sha256Checksum()` of the contents at the given path if any,
  * an empty `QByteArray` otherwise.
  */
extern Checksum checksumForFilePath(const QString path);

} // namespace Core
} // namespace Twx

#endif // TwxCore_Tools_H
