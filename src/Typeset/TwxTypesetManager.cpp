/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2023  Stefan Löffler, Jérôme Laurens

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
#include "Typeset/TwxTypesetManager.h"

#include "Core/TwxPathManager.h"
using PathManager = Twx::Core::PathManager;

#include <QVariant>
#include <QMetaObject>

Q_DECLARE_METATYPE(QMetaObject::Connection)

namespace Twx {
namespace Typeset {

QMap<QString, QObject*> Manager::running_m;

Manager *Manager::emitter()
{
	static Manager m;
	return &m;
}

bool Manager::isFileBeingTypeset(const QString & rootFile)
{
	return getOwnerForRootFile(rootFile) != nullptr;
}

QObject *Manager::getOwnerForRootFile(const QString & rootFile)
{
	return running_m.value(rootFile, nullptr);
}

#if TwxTypeset_TEST
int Manager::test_count;
#endif

static const char *_key = "TwxTypesetManager.connection";

bool Manager::startTypesetting(const QString& rootFile, QObject *const owner)
{
	if (rootFile.isEmpty() || owner == nullptr || running_m.contains(rootFile)) {
		return false;
	}
	running_m.insert(rootFile, owner);
	// If the owner is already registered
	// We do not register it once again.
	QVariant v = owner->property(_key);
	if (!v.isValid()) {
		auto c = connect(owner, &QObject::destroyed, [=]() {
#if TwxTypeset_TEST
		++test_count;
#endif
			Manager::stopTypesetting(owner);
		});
		owner->setProperty(_key, QVariant::fromValue(c));
	}
	emit emitter()->typesettingStarted(rootFile);
	return true;
}

void Manager::stopTypesetting(QObject* const owner)
{
	for(const QString& rootFile: running_m.keys(owner)) {
		running_m.remove(rootFile);
		emit emitter()->typesettingStopped(rootFile);
	}
	QVariant v = owner->property(_key);
  if (v.isValid()) {
		auto c = v.value<QMetaObject::Connection>();
		QObject::disconnect(c);
	}
}

} // namespace Typeset
} // namespace Twx
