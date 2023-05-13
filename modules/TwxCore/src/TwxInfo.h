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
/** \file
 	* 
 	* \brief Various information
 	* 
 	* Aims to replace `src/TWVersion.h` as well as `GitArchiveInfo.txt`.
	*/
#ifndef Twx_Core_Info_h
#define Twx_Core_Info_h

#include <QDateTime>
#include <QString>
#include <QCoreApplication>

namespace Twx {

namespace Core {

#if defined(TwxCore_TEST)
/**
 	* \brief Chord of the Twx testing architecture
 	* 
 	* Quite all these data come from the `TeXworks.ini``
 	* or equivalent. This file is undocumented by itself,
 	* see \ref `TwxCfgFileLib.cmake` for more details.
 	*/
namespace Test {
	class Main;
}
#endif

/**
 	* \brief Collects various information
 	* 
 	* Only getters.
 	*/
class Info
{
public:
/** \brief The name of the program
	* 
	* Appears at different places (dialog and files).
	*/
	static const QString name;
  
/** \brief The name of the organization
	* 
	* Appears at different places (dialog and files).
	*/
	static const QString organizationName;
  
/** \brief The domain of the organization
	* 
	* Appears at different places (dialog and files).
	*/
	static const QString organizationDomain;
  
/** \brief The list of authors
	* 
	* See \ref copyrightHolders.
	*/
	static const QString authors;

/** \brief The copyright years
	* 
	* As a range like "2008-2023".
	*/
	static const QString copyrightYears;

/** \brief The list of authors
	* 
	* Appears in various places.
	* See \ref authors.
	*/
	static const QString copyrightHolders;
	
/** \brief The M in M.m.P.T */
	static int versionMajor;

/** \brief The m in M.m.P.T */
	static int versionMinor;

/** \brief The P in M.m.P.T */
  static int versionPatch;

/** \brief Deprecated
	* 
	* Synonym of `versionPatch`
	*/
	static int versionBugfix;

/** \brief The T in M.m.P.T
	* 
	* Not yet used.
	*/
  static int versionTweak;

/** \brief A 0xMMNNPP version */
	static int versionMNP;

/** \brief A 0xMMNNPPTT version */
	static int versionMNPT;

/** \brief The  M.m.P version */
	static const QString version;

/** \brief The  M.m.P.T version
	* 
	* If there is no T, this is equivalent to `version`
	*/
	static const QString versionFull;

/** \brief The build identifier (CMake TW_BUIL_ID) */
	static const QString buildId;
	
/** \brief The latest git commit hash at build time */
	static const QString gitHash;

/** \brief The latest git commit date at build time */
	static const QDateTime gitDate;

/** \brief The git branch at build time
	* 
	* This is not always `main`.
	*/
	static const QString gitBranch;

/** \brief Initialize the applications
	* 
	* Set the application name, organization name and domain.
	* \note
	* On windows and macOS these are also set while testing because
	* the manifest and the plist are not available.
	* \param application
	*/
	static void initApplication(QCoreApplication * application);
  
#if defined(TwxCore_TEST)
  friend class Test::Main;
#endif

};

} // namespace Core
} // namespace Twx

#endif // Twx_Core_Info_h
