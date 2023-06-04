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
#ifndef TwxTypeset_Engine_h
#define TwxTypeset_Engine_h

#include <QObject>
#include <QString>
#include <QSettings>
#include <QJsonObject>

/*! \file TwxEngine.h
 *  \brief Engine model.
 *  
 *  An engine collects the information to run the program
 *  that typesets or more generaly translates a file
 *  from one format to another. It is a frontend to `pdftex`,
 *  `luatex`, `bibtex`, `makeindex`...
 * 
 * 	The engine manager is responsible for storing and managing
 *  all the different engines needed for typesetting.
 */

class QProcess;
class QFileInfo;

namespace Twx {

namespace Key {
	extern const QString Engine;
	extern const QString name;
	extern const QString program;
	extern const QString arguments;
	extern const QString showPdf;
}

namespace Core {
	class Settings;
}

namespace Typeset {
@TWX_CFG_include_TwxNamespaceTestMain_private_h@

// specification of an "engine" used to process files
class Engine
{
public:
  typedef QList<Engine> List;

	/*! \brief The factory default engine name.
	 * 	\return This is `pdfLaTeX`
	 */
	static const QString factoryEngineName;

	/*! \brief List of engines
	 * 	\return Constant non void built in list
	 */
	static const List & factoryEngineList();
	
	/*! \brief Default constructor
	 */
	Engine() = default;

	/*! \brief Default constructor
	 * 	\param name should be unique within a list
	 * 	\param program for example `pdftex`; on windows `.exe` is added if necessary
	 *  \param arguments list of arguments passed to the program
	 *  \param showPdf whether to show the pdf window on successful runs
	 */
	explicit Engine(
		const QString & name,
		const QString & program,
		const QStringList & arguments,
		bool showPdf
	);
	/*! \brief Copy constructor
	 */
	Engine(const Engine& orig);

	/*! \brief Assignment operator
	 */
	Engine& operator=(const Engine& rhs);

	/*! \brief The name of the engine
	 */
	const QString name() const;

	/*! \brief The program of the engine
	 */
	const QString program() const;

	/*! \brief The arguments of the engine
	 */
	const QStringList arguments() const;

	/*! \brief Whether the pdf window should show on successful runs
	 */
	bool showPdf() const;

	/*! \brief Set the name of the engine
	 * 	\param newName within the same list, names should be unique
	 */
	void setName(const QString& newName);

	/*! \brief Set the name of the engine
	 * 	\param name within the same list, names should be unique
	 */
	void setProgram(const QString& program);

	/*! \brief Set the arguments of the engine
	 * 	\param arguments possibly void list of `QString`'s
	 */
	void setArguments(const QStringList& arguments);

	/*! \brief Set whether the pdf window should show on successful runs
	 * 	\param showPdf truthy or falsy
	 */
	void setShowPdf(bool showPdf);

	/*! \brief Whether the engine's name is empty.
	 */
	bool isValid() const;

	/*! \brief Whether the engine's name is the given one.
	 * 	\param name can be empty
	 */
	bool hasName(const QString& name) const;

	/*! \brief Whether the engine's program is available.
	 */
	bool isAvailable() const;

	/*! \brief Whether the engine's program is available.
	 * 	\param input the file on which the program operates
	 *  \param owner an optional owner
	 * 	\return a QProcess instance
	 */
	QProcess * run(const QFileInfo & input, QObject * owner = nullptr) const;

	/*! \brief equality operator.
	 */
  bool operator==(const Engine & rhs) const;

	/*! \brief ordering operator.
	 */
  bool operator<(const Engine & rhs) const;

	/*! \brief Constructor.
	 *  \param object a `QJsonObject` instance
	 */
	explicit Engine(const QJsonObject & object);

	/*! \brief Exporter.
	 *  \return a `QJsonObject` instance
	 */
	const QJsonObject toJsonObject() const;

	/*! \brief Constructor.
	 *  \param settings a `QSettings` instance
	 */
  explicit Engine(const QSettings & settings);

	/*! \brief Exports the receiver to the given settings.
	 *  \param settings a mutable `QSettings` instance
	 */
  void save(QSettings & settings) const;
@TWX_CFG_include_TwxEngine_private_h@
@TWX_CFG_include_TwxFriendTestMain_private_h@
};
} // namespace Typeset
} // namespace Twx

#endif // !defined(TwxTypeset_Engine_h)
