/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2018-2020  Jonathan Kew, Stefan Löffler

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
#ifndef TwxTypeset_EngineManager_h
#define TwxTypeset_EngineManager_h

/** \file TwxEngineManager.h
 	* \brief Engines management.
 	* 
 	* The engine manager is responsible for storing and managing
 	* all the different engines needed for typesetting.
 	* Each engine is uniquely identified by its name, such that
 	* clients may store the engine name instead of the complete engine.
 	* 
 	* All the methods are static, except for the `emitter` that emits
 	* signals.
 	* 
 	*/

#include "TwxEngine.h"

#include <QFileInfo>
#include <QProcess>

namespace Twx {
namespace Key {
	extern const QString engineList;
	extern const QString defaultEngineName;
}
namespace Typeset {
@TWX_CFG_include_TwxNamespaceTestMain_private_h@
// specification of an "engine" used to process files
class EngineManager: public QObject
{
  Q_OBJECT
public:
/** \brief Signal emitter
	* 
	* Usage:
	* ```cpp
	* connect(
	*   EngineManager::emitter(),
	*   &EngineManager::engineListChanged,
	*   ...
	* );
	* ```
	*	\return a shared EngineManager instance which sole task is to emit signals.
	*/
static EngineManager * emitter();

/** \brief Get the current list of engines
 	*
	* \return a constant instance of `Engine::List`.
	*/
	static const Engine::List engineList();

/** \brief Set the current list of engines
 	*
	* \param engines possibly void list of engines.
	* \return false if the list contains duplicates, true otherwise
	*/
  static bool setEngineList(const Engine::List & engines);

/** \brief Save the current list of engines.
 	*
	*	The exact location depends on the system.
	* See `Assets`.
	*/
	static void saveEngineList();

/** \brief Set the current list of engines to a saved one.
 	*
	*  See `saveEngineList()`.
	*/
	static void restoreEngineList();

/** \brief Set the current list of engines to the factory defaults.
 	*
	*  See `Engine::factoryEngineList()`.
	*/
	static void resetEngineListToFactory();

/** \brief Get the engine of the list with the given name.
 	*
	* Case insensitive comparison.
	* \param name if such an engine exists, it has this name.
	* \return an `Engine` instance, which is not valid if
	*   no such engine exists.
	*/
	static const Engine & engineWithName(const QString & name);

/** \brief Get the default engine name.
 	*
	*  \return a non empty `QString`.
	*/
	static const QString & defaultEngineName();

/** \brief Set the default engine name.
 	*
	*  \param name is a non empty `QString`.
	*/
	static void setDefaultEngineName(const QString & name);

/** \brief Get the default engine.
 	*
	*  \return the engine with name `defaultEngineName()`.
	*/
	static const Engine & defaultEngine();

signals:
/** \brief Signal
 	*
	* 	See `emitter()`.
	*/
	void engineListChanged();

private:
  EngineManager() = default;
	~EngineManager() = default;
	EngineManager(EngineManager& other) = delete;
	EngineManager(EngineManager&& other) = delete;
  void operator=(const EngineManager&) = delete;
  void operator=(const EngineManager&&) = delete;
@TWX_CFG_include_TwxEngineManager_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};
} // namespace Typeset
} // namespace Twx

#endif // !defined(TwxTypeset_EngineManager_h)
