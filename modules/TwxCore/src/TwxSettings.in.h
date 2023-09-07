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
/**
  * \brief Slightly customized `QSettings`
  */
#ifndef TwxCore_Settings_H
#define TwxCore_Settings_H

#include <QSettings>

class QDir;
class QProcessEnvironment;

//TODO: document this class, what is the purpose???
namespace Twx {
namespace Core {
@/TWX/CFG/include_TwxNamespaceTestMain_private_h@

class Settings: public QSettings
{
	Q_OBJECT
public:

/** \brief Setup the manager
	*
	* When in "-setup.ini" mode.
	* \param path is a absolute path to a potential settings file.
	* \param mustExist defaults to false. In mustExist mode, when a full path
	*   is provided we do not fall back to deprecated keys.
	*/
	static void setup(const QString & settings_ini_path, bool mustExist=false);

/** \brief Setup the manager
	*
	* When in "-setup.ini" mode.
	* \param PE is a QProcessEnvironment instance.
	*/
	static void setup(const QProcessEnvironment & PE);

/** \brief Whether the receiver can provide a `listPATH`.
	*
	* Convenient method for `Locate`.
	*/
	bool hasListPATH();

/** \brief Get the stored `listPATH`.
	*
	* Convenient method for `Locate`.
	*/
	QStringList listPATH();

/** \brief Store the `listPATH`.
	*
	* Convenient method for `Locate`.
	* \param listPATH is a list of strings.
	*/
	void setListPATH(QStringList listPATH);

/** \brief Whether the receiver can provide the assets library path.
	*
	* Convenient method for `Assets`.
	*/
	bool hasAssetsLibraryLocation();

/** \brief Get the stored assets library path.
	*
	* Convenient method for `Assets`.
	*/
	QString assetsLibraryLocation();

	Settings() = default;
	Settings(const QString &fileName, QSettings::Format format, QObject *parent = nullptr);

private:

/** \brief Get the assets library path.
	*
	* Convenient method for `Assets`.
	* \param path is the actual location
	*/
	void setAssetsLibraryLocation(const QString & path);

@/TWX/CFG/include_TwxFriendTestMain_private_h@

};


} // namespace Core
} // namespace Twx

#endif // TwxCore_Settings_H
