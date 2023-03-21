/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2020  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

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

#ifndef TW_TEXDOCKS_H
#define TW_TEXDOCKS_H

#include <QDockWidget>
#include <QListWidget>
#include <QScrollArea>
#include <QTreeWidget>

class TeXDocumentWindow;
class QListWidget;
class QTableWidget;
class QTreeWidgetItem;

class TeXDock: public QDockWidget
{
	Q_OBJECT

public:
	TeXDock(const QString & title, TeXDocumentWindow * doc = nullptr);
	~TeXDock() override = default;

protected:
	virtual void update(bool force) = 0;

	TeXDocumentWindow *documentWindow;

	bool updated;

private slots:
	void onVisibilityChanged(bool visible);
};


class TagsDock: public TeXDock
{
	Q_OBJECT

public:
	TagsDock(TeXDocumentWindow *documentWindow = nullptr);
	~TagsDock() override = default;

public slots:
	virtual void listChanged();
    void activateTagFollowCursorPosition(bool yorn);

protected:
	void update(bool force) override;

private slots:
	void followTagSelection();
    void onCursorPositionChanged();

private:
	QTreeWidget *tree;
    int saveScrollValue;
    bool dontFollowTagSelection;
};

class TeXDockTreeWidget: public QTreeWidget
{
	Q_OBJECT

public:
	explicit TeXDockTreeWidget(QWidget * parent);
	~TeXDockTreeWidget() override = default;

	QSize sizeHint() const override;
};

#endif // TW_TEXDOCKS_H
