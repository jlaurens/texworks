/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2022-2023  Stefan Löffler, Jérôme Laurens

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
#ifndef Twx_Typeset_Manager_H
#define Twx_Typeset_Manager_H

#include <QMap>
#include <QObject>
#include <QString>

namespace Twx {
namespace Typeset {

namespace Test {
	class Main;
}

// Class that keeps track of all running typesetting processes and who started/
// owns them.
// This helps avoid running multiple processes on the same input file (which
// would wreak havoc in the auxiliary and output files) and provides information
// in which object (window) information about a currently running typesetting
// process for a given input (root) file can be found
// Static methods, only one emitter.
class Manager: public QObject
{
	Q_OBJECT
  static QMap<QString, QObject*> running_m;
	static QMap<QObject *, QMetaObject::Connection> connections_m;
public:
  static Manager *emitter();
	// In practice, the returned object should be a TeXDocumentWindow; to avoid
	// interdependencies of headers (and to enable other types as owners in the
	// future) we use a generic QObject* here instead
	static QObject *getOwnerForRootFile(const QString& rootFile);
	static bool isFileBeingTypeset(const QString& rootFile);

	// Returns true if it is safe to start typesetting, false if typesetting
	// should not be started (e.g. because another owner is already typesetting
	// the specified root file)
	// The root file should always be a canonical file path
	static bool startTypesetting(const QString& rootFile, QObject *const owner);
	static void stopTypesetting(QObject *const owner);

private:
  Manager() = default;
	~Manager() = default;
	Manager(Manager& other) = delete;
	Manager(Manager&& other) = delete;
  void operator=(const Manager&) = delete;
  void operator=(const Manager&&) = delete;

signals:
	void typesettingStarted(const QString rootFile);
	void typesettingStopped(const QString rootFile);

private:
#include "Typeset/TwxTypesetManagerPrivate.h"

  friend class Test::Main;
};

} // namespace Typeset
} // namespace Twx

#endif // Twx_Typeset_Manager_H
