/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2018-2023  Jonathan Kew, Stefan Löffler, Jérôme Laurens

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

#include "TwxEngineManager.h"

#include "TwxConst.h"
#include "TwxAssets.h"
#include "TwxSettings.h"
using Settings = Twx::Core::Settings;
#include "TwxLocate.h"
using Locate = Twx::Core::Locate;

#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSaveFile>
#include <QDebug>

namespace Twx {

namespace Key {
	auto const engineList = QStringLiteral("engineList");
	auto const defaultEngineName = QStringLiteral("defaultEngine");
}

namespace Typeset {

auto const EngineManager::saveComponent = QStringLiteral("engines.json");

namespace P {
	static QString defaultEngineName;
  static Engine::List engineList;
}

EngineManager * EngineManager::emitter ()
{
	static EngineManager m;
	return &m;
}

// lazy builder
const Engine::List EngineManager::engineList()
{
	if (P::engineList.empty()) {
		// check for old engine list in Preferences
		// This is deprecated since version 0.7.0 at least
		Settings settings;
  	auto const keyEngines = QStringLiteral("engines");
		int count = settings.beginReadArray(keyEngines);
		if (count > 0) {
			for (int i = 0; i < count; ++i) {
				settings.setArrayIndex(i);
				P::engineList << Engine(settings);
				settings.remove(QString());
			}
			saveEngineList();
		}
		settings.endArray();
		settings.remove(keyEngines);

		if (P::engineList.empty()) {
		  restoreEngineList();
		}
		if (P::engineList.empty()) {
			resetEngineListToFactory();
		}
	}
	return P::engineList;
}

const QString EngineManager::saveLocation(const QString & component)
{
#if defined(TwxTypeset_TEST)
  return QDir::current().filePath(component);
#else
  return QDir(Core::Assets::path(QStringLiteral("configuration"))).filePath(component);
#endif
}

void EngineManager::saveEngineList()
{
	QFile toolsFile(saveLocation(QStringLiteral("engines.ini")));
	QSettings settings(toolsFile.fileName(), QSettings::IniFormat);
	settings.clear();
	int n = 0;
	for (auto const & engine: P::engineList) {
		settings.beginGroup(QStringLiteral("%1").arg(++n, 3, 10, QChar::fromLatin1('0')));
		engine.save(settings);
		settings.endGroup();
	}
	QJsonArray ra;
	for (auto const & engine: P::engineList) {
		ra.append(engine.toJsonObject());
	};
	QJsonDocument d(QJsonObject{
    {Key::__type, Key::engineList},
    {Key::__data, ra},
	});
	QFile enginesFile(saveLocation(saveComponent));
  QSaveFile file(enginesFile.fileName());
	if (file.open(QIODevice::WriteOnly)) {
		file.write(d.toJson(QJsonDocument::Indented));
		file.commit();
	}
}

Engine::List EngineManager::savedEngineList()
{
	Engine::List list;
  QFile file(saveLocation(saveComponent));
	if (file.open(QIODevice::ReadOnly)) {
		auto bytes = file.readAll();
		auto o = QJsonDocument::fromJson(bytes).object();
		if (o.value(Key::__type) == Key::engineList) {
			auto ra = o.value(Key::__data).toArray();
      for (auto v: ra) {
				list << Engine(v.toObject());
			}
		}
		file.close();
	}
	if (!list.empty()) {
		return list;
	}
	// Next is supported for reading only
	QFile toolsFile(saveLocation(QStringLiteral("tools.ini")));
	if (toolsFile.exists()) {
		QSettings settings(toolsFile.fileName(), QSettings::IniFormat);
		for (const QString& name: settings.childGroups()) {
			settings.beginGroup(name);
			list << Engine(settings);
			settings.endGroup();
		}
	}
	return list;
}

void EngineManager::restoreEngineList()
{
	setEngineList(savedEngineList());
}

void EngineManager::resetEngineListToFactory()
{
	setEngineList(Engine::factoryEngineList());
}

/*! \details
 *  If the old list and the replacement are the same,
 *  nothing is performed.
 *  This does not change the default engine name.
 *  Emits `engineListChanged` on change.
 */
bool EngineManager::setEngineList(const Engine::List & engines)
{
	bool ans = true;
	if (engines == P::engineList) {
		return ans;
	}
	QHash<QString,bool> already;
	P::engineList.clear();
  for (auto const &engine: engines) {
		auto const name = engine.name().toLower();
		if (already[name]) {
			ans = false;
		} else {
			already[name] = true;
			P::engineList << engine;
		}
	}
	saveEngineList();
	emit emitter()->engineListChanged();
	return ans;
}

const QString EngineManager::settingsEngineName()
{
	Settings settings;
	return settings.value(
		Key::defaultEngineName,
		Engine::factoryEngineName
	).toString();
}

/*! \details
 *  If there is no engine with name `defaultEngineName()`,
 *  try with some `factoryEngineName`. If it still fails,
 *  take the name of the first engine in the list, if any.
 */
const Engine & EngineManager::defaultEngine()
{
	const auto name = defaultEngineName();
	auto & engine = engineWithName(name);
	if (engine.isValid()) {
		return engine;
	}
	const auto settingsName = settingsEngineName();
	if (name != settingsName) {
		auto & engine = engineWithName(settingsName);
		if (engine.isValid()) {
			setDefaultEngineName(settingsName);
			return engine;
		}
	}
	if (name != Engine::factoryEngineName && settingsName != Engine::factoryEngineName) {
		auto & engine = engineWithName(Engine::factoryEngineName);
		if (engine.isValid()) {
			setDefaultEngineName(Engine::factoryEngineName);
			return engine;
		}
	}
	if (!P::engineList.empty()) {
		auto & engine = P::engineList[0];
		setDefaultEngineName(engine.name());
		return engine;
	}
	return engine;
}

const QString & EngineManager::defaultEngineName()
{
	return P::defaultEngineName;
}

void EngineManager::setDefaultEngineName(const QString & name)
{
	Settings settings;
	settings.setValue(Key::defaultEngineName, name);
	P::defaultEngineName = name;
}

const Engine & EngineManager::engineWithName(const QString & name)
{
	for (const auto & engine: engineList()) {
		if (engine.hasName(name))
			return engine;
	}
	static auto e = Engine();
	return e;
}

#if defined(TwxTypeset_TEST)

QString & EngineManager::defaultEngineNameRef()
{
	return P::defaultEngineName;
}
Engine::List & EngineManager::rawEngineList()
{
	return P::engineList;
}

#endif // defined(TwxTypeset_TEST)

} // namespace Typeset
} // namespace Twx
