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
class QComboBox;
class QTextCursor;
class TeXDocumentWindow;

namespace Tw {
namespace Document {
class Tag;
class TagSuite;
class TagBank;
}
}

class TeXDock: public QDockWidget
{
	Q_OBJECT

public:
	TeXDock(const QString & title, TeXDocumentWindow *window = nullptr);
	~TeXDock() override = default;

protected:
	virtual void update(bool force) = 0;

	TeXDocumentWindow *_window;

	bool _updated;

private slots:
	void onVisibilityChanged(bool visible);
};

class TeXDockTreeWidget: public QTreeWidget
{
    Q_OBJECT

    using Super = QTreeWidget;
    
public:
    explicit TeXDockTreeWidget(QWidget * parent = nullptr);
    ~TeXDockTreeWidget() override = default;

    QSize sizeHint() const override;

protected:
    void dropEvent(QDropEvent *) override;
};

/// \author JL
class TeXDockTree: public TeXDock
{
    Q_OBJECT

public:
    TeXDockTree(const QString & title, TeXDocumentWindow *window = nullptr);
    ~TeXDockTree() override = default;
    virtual Tw::Document::TagSuite *tagSuite() = 0;

public slots:
    void observeCursorPositionChanged(bool yorn);
    void onTagBankChanged();
    void onTagSuiteChanged();

protected slots:
    void itemGainedFocus();
    void update(bool force) override;
    void find(const QString & text);

private slots:
    void onCursorPositionChanged();

protected:
    virtual void initUI();
    virtual TeXDockTreeWidget *newTreeWidget(QWidget *parent);
    virtual void makeNewItem(QTreeWidgetItem *, QTreeWidget *, const Tw::Document::Tag *) const;
    int _lastScrollValue;
    bool _dontFollowItemSelection;
    virtual void updateVoid() = 0;
    QTreeWidgetItem *getItemAtIndex(const int tagIndex);
    void selectItemsForCursor(const QTextCursor &cursor, bool dontFollowItemSelection);
};

class TeXDockTag: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockTag(TeXDocumentWindow *window = nullptr);
    ~TeXDockTag() override = default;
    Tw::Document::TagSuite *tagSuite() override;

protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *, QTreeWidget *, const Tw::Document::Tag *) const override;
};

class TeXDockBookmark: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockBookmark(TeXDocumentWindow *window = nullptr);
    ~TeXDockBookmark() override = default;
    Tw::Document::TagSuite *tagSuite() override;

protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *, QTreeWidget *, const Tw::Document::Tag *) const override;
};

class TeXDockOutlineWidget: public TeXDockTreeWidget
{
    Q_OBJECT

    using Super = TeXDockTreeWidget;
    
public:
    explicit TeXDockOutlineWidget(QWidget * parent = nullptr);
    ~TeXDockOutlineWidget() override = default;

protected:
    void dropEvent(QDropEvent *) override;
};

class TeXDockOutline: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockOutline(TeXDocumentWindow *window = nullptr);
    ~TeXDockOutline() override = default;
    Tw::Document::TagSuite *tagSuite() override;

protected:
    void updateVoid() override;
    TeXDockTreeWidget *newTreeWidget(QWidget *parent) override;
    void makeNewItem(QTreeWidgetItem *, QTreeWidget *, const Tw::Document::Tag *) const override;
};

#endif // TW_TEXDOCKS_H
