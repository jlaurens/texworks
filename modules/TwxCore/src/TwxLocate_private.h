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

	static QStringList listPATHRaw_m;

/** \brief Helper for the other `absoluteProgramPath` methods
 	*	\param program same semantics
	* \param listPATH list of path to look for the `program`
	*/
	static QString absoluteProgramPath (
		const QString & program,
		const QStringList & listPATH
	);
/** \brief Append paths to the given list of paths */
	static void appendListPATH_TeXLive_Windows(QStringList & listPATH);
	static void appendListPATH_TeXLive_Other(QStringList & listPATH);
	static void appendListPATH_MiKTeX_Windows(
		QStringList & listPATH,
		const QProcessEnvironment & env
	);
	static void appendListPATH_MiKTeX_Other(QStringList & listPATH);
	static void appendListPATH_TeX(
		QStringList & listPATH,
		const QProcessEnvironment & env
	);
/** \brief Consolidate the given list PATH
 	*	
 	*	Remove directories that do not exit.
	*/
	static void consolidateListPATH(
		QStringList & listPATH,
		const QProcessEnvironment & env
	);

	static QString LOCALAPPDATA_Windows;
	static QString SystemDrive_Windows;
	static QStringList appendListPATH_TeXLive_Other_m;

#if defined(TwxCore_TEST)
#define TWX_CONST

  static QStringList messages_TwxCore_TEST;
	
  static const QFileInfo fileInfoMustExist_TwxCore_TEST;
  static const QFileInfo fileInfoNone_TwxCore_TEST;

#else
#define TWX_CONST const
#endif

	static QString rootTeXLive;
	static QString w32tex_bin;

	static TWX_CONST QString root4MiKTeX;
	static TWX_CONST QStringList listPATHFactory;
