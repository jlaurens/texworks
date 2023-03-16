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

class QListWidget;
class QTableWidget;
class QTreeWidgetItem;
class TeXDocumentWindow;
class QLineEdit;

namespace Tw {
namespace Document {
class TagArray;
}
}

class TeXDock: public QDockWidget
{
	Q_OBJECT

public:
	TeXDock(const QString & title, TeXDocumentWindow *documentWindow_p = nullptr);
	~TeXDock() override = default;

protected:
	virtual void update(bool force) = 0;

	TeXDocumentWindow *documentWindow_p;

	bool updated;

private slots:
	void onVisibilityChanged(bool visible);
};


class TagsDock: public TeXDock
{
    Q_OBJECT

public:
    TagsDock(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TagsDock() override = default;

public slots:
    virtual void listChanged();
    void observeCursorPositionChanged(bool yorn);

protected:
    void update(bool force) override;

private slots:
    void followTagSelection();
    void onCursorPositionChanged();

private:
    QTreeWidget *tree;
    int saveScrollValue;
    bool dontFollowTagSelection;
    bool lastSelectionIsOutline;
};

/// \author JL
class TeXDockTree: public TeXDock
{
    Q_OBJECT

public:
    TeXDockTree(const QString & title, TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockTree() override = default;
    virtual const Tw::Document::TagArray &getTagArray() = 0;

public slots:
    void observeCursorPositionChanged(bool yorn);
    void onTagVectorChanged();

protected slots:
    void itemGainedFocus();
    void update(bool force) override;

private slots:
    void onCursorPositionChanged();

protected:
    QTreeWidget *_treeWidget_p;
    void makeTreeWidget(QWidget* parent);
    virtual void initUI();
    int _lastScrollValue;
    bool _dontAnswerWhenItemGainedFocus;
    virtual void updateVoid() = 0;
};

class TeXDockBookmark: public TeXDockTree
{
    Q_OBJECT

public:
    TeXDockBookmark(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockBookmark() override = default;
    const Tw::Document::TagArray & getTagArray() override;

protected:
    void initUI() override;
    void updateVoid() override;

private:
    QLineEdit * __lineEdit_p;
};

class TeXDockOutline: public TeXDockTree
{
    Q_OBJECT

public:
    TeXDockOutline(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockOutline() override = default;
    const Tw::Document::TagArray &getTagArray() override;

protected:
    void updateVoid() override;
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
