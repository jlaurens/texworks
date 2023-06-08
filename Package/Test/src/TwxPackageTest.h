/*
	This is part of TeXworks build and test system.
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

#ifndef TwxPackageTest_H
#define TwxPackageTest_H

#include <QAction>
#include <QApplication>

#if defined Q_OS_DARWIN
#include <QMenu>
#include <QMenuBar>
#endif

#include <QString>
#include <QEvent>
#include <QUrl>

class TwxPackageTest: public QApplication
{
	Q_OBJECT

public:
  static TwxPackageTest * emitter();

	TwxPackageTest(int &argc, char **argv);
	~TwxPackageTest() override;

#if defined(Q_OS_DARWIN)
	void recreateSpecialMenuItems();
private:
	// on the Mac only, we have a top-level app menu bar, including its own copy of the recent files menu
	QMenuBar * menuBar{nullptr};

	QMenu * menuHelp{nullptr};
	QAction * homePageAction{nullptr};
	QAction * mailingListAction{nullptr};
  void insertHelpMenuItems(QMenu * helpMenu);

#endif

public slots:

	void goToHomePage();
	void openHelpFile(const QString& helpDirName);
	void openUrl(const QUrl& url);

private:
	void init();

};

#endif	// TwxPackageTest_H

