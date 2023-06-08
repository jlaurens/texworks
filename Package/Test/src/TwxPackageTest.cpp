/*
	This is part of TeXworks build and test system.
	Copyright (C) 2023 Jérôme Laurens

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

#include "TwxPackageTest.h"

#include <QString>
#include <QDir>
#include <QAction>
#include <QMenu>
#include <QMenuBar>
#include <QString>
#include <QUrl>
#include <QMessageBox>
#include <QSignalMapper>
#include <QDesktopServices>
#include <QTextStream>
#include <QDirIterator>

TwxPackageTest::TwxPackageTest(int &argc, char **argv)
	: QApplication(argc, argv)
{
	init();
}

TwxPackageTest::~TwxPackageTest()
{
}

void TwxPackageTest::init()
{
	
#if defined(Q_OS_DARWIN)
	setQuitOnLastWindowClosed(false);
	setAttribute(Qt::AA_DontShowIconsInMenus);

	menuBar = new QMenuBar;

	menuHelp = menuBar->addMenu(tr("Help"));

	homePageAction = new QAction(tr("Go to TeXworks home page"), this);
	menuHelp->addAction(homePageAction);
	connect(homePageAction, &QAction::triggered, this, &TwxPackageTest::goToHomePage);
	mailingListAction = new QAction(tr("Email to the mailing list"), this);
	menuHelp->addAction(mailingListAction);

	insertHelpMenuItems(menuHelp);

#endif
}

#if defined(Q_OS_DARWIN)
static int
insertItemIfPresent(QFileInfo& fi, QMenu* helpMenu, QAction* before, QSignalMapper* mapper, QString title)
{
	QFileInfo indexFile(fi.absoluteFilePath(), QStringLiteral("index.html"));
	if (!indexFile.exists()) {
		return 0;
	}
	QFileInfo titlefileInfo(fi.absoluteFilePath(), QStringLiteral("tw-help-title.txt"));
	if (titlefileInfo.exists() && titlefileInfo.isReadable()) {
		QFile titleFile(titlefileInfo.absoluteFilePath());
		titleFile.open(QIODevice::ReadOnly | QIODevice::Text);
		QTextStream titleStream(&titleFile);
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
		titleStream.setCodec("UTF-8");
#endif
		title = titleStream.readLine();
	}
	QAction* action = new QAction(title, helpMenu);
	mapper->setMapping(action, fi.canonicalFilePath());
	QObject::connect(action, &QAction::triggered, mapper, static_cast<void (QSignalMapper::*)()>(&QSignalMapper::map));
	helpMenu->insertAction(before, action);
	return 1;
}

void TwxPackageTest::insertHelpMenuItems(QMenu * helpMenu)
{
	QSignalMapper* mapper = new QSignalMapper(helpMenu);
	QObject::connect(mapper, &QSignalMapper::mappedString, this, &TwxPackageTest::openHelpFile);

	QAction* before = nullptr;
	int i{0}, firstSeparator = 0;
	QList<QAction*> actions = helpMenu->actions();
	for (i = 0; i < actions.count(); ++i) {
		if (actions[i]->isSeparator() && !firstSeparator)
			firstSeparator = i;
		if (actions[i]->menuRole() == QAction::AboutRole) {
			before = actions[i];
			break;
		}
	}
	while (--i > firstSeparator) {
		helpMenu->removeAction(actions[i]);
		delete actions[i];
	}

	QDir helpDir(QCoreApplication::applicationDirPath() + QStringLiteral("/../texworks-help"));
	QDirIterator it(helpDir);
	int inserted = 0;
	while (it.hasNext()) {
		(void)it.next();
		if (!it.fileInfo().isDir())
			continue;
		QString name(it.fileName());
		if (name == QStringLiteral(".") || name == QStringLiteral(".."))
			continue;
		QDir subDir(it.filePath());
		// try for localized content first
		QFileInfo fi(subDir, QStringLiteral("en"));
		if (fi.exists() && fi.isDir() && fi.isReadable()) {
			inserted += insertItemIfPresent(fi, helpMenu, before, mapper, name);
		}
	}
	if (inserted > 0) {
		QAction* sep = new QAction(helpMenu);
		sep->setSeparator(true);
		helpMenu->insertAction(before, sep);
	}
}
#endif

void TwxPackageTest::openUrl(const QUrl& url)
{
	if (!QDesktopServices::openUrl(url))
		QMessageBox::warning(nullptr, applicationName(),
							 tr("Unable to access \"%1\"; perhaps your browser or mail application is not properly configured?")
							 .arg(url.toString()));
}
void TwxPackageTest::goToHomePage()
{
	openUrl(QUrl(QString::fromLatin1("http://www.tug.org/texworks/")));
}

void TwxPackageTest::openHelpFile(const QString& helpDirName)
{
	QDir helpDir(helpDirName);
	if (helpDir.exists(QString::fromLatin1("index.html")))
		openUrl(QUrl::fromLocalFile(helpDir.absoluteFilePath(QString::fromLatin1("index.html"))));
	else
		QMessageBox::warning(nullptr, applicationName(), tr("Unable to find help file."));
}
