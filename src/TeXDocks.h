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
class TagArray;
struct Tag;
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
    TeXDockTree(const QString & title, TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockTree() override = default;
    virtual Tw::Document::TagArray &getMutableTagArray() = 0;
    virtual const Tw::Document::TagArray &getTagArray() const = 0;

public slots:
    void observeCursorPositionChanged(bool yorn);
    void onTagArrayChanged();

protected slots:
    void itemGainedFocus();
    void update(bool force) override;
    void find(const QString & text);

private slots:
    void onCursorPositionChanged();

protected:
    virtual void initUI();
    virtual void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tw::Document::Tag *);
    int _lastScrollValue;
    bool _dontFollowItemSelection;
    virtual void updateVoid() = 0;
    void hilightTagAt(const QTextCursor & cursor);
    QTreeWidgetItem *getItemAtIndex(const int tagIndex);
    const Tw::Document::Tag *getTagForItem_p(const QTreeWidgetItem *item_p);
    QTreeWidgetItem *getItemForCursor(const QTextCursor &cursor);
    void selectItem(QTreeWidgetItem *item_p, bool dontFollowItemSelection);
    void selectItemForCursor(const QTextCursor &cursor, bool dontFollowItemSelection);
};

class TeXDockTag: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockTag(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockTag() override = default;
    Tw::Document::TagArray & getMutableTagArray() override;
    const Tw::Document::TagArray & getTagArray() const override;

protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tw::Document::Tag *) override;
};

class TeXDockBookmark: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockBookmark(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockBookmark() override = default;
    Tw::Document::TagArray & getMutableTagArray() override;
    const Tw::Document::TagArray & getTagArray() const override;

protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tw::Document::Tag *) override;
};

class TeXDockOutline: public TeXDockTree
{
    Q_OBJECT

    using Super = TeXDockTree;
    
public:
    TeXDockOutline(TeXDocumentWindow *documentWindow_p = nullptr);
    ~TeXDockOutline() override = default;
    Tw::Document::TagArray &getMutableTagArray() override;
    const Tw::Document::TagArray &getTagArray() const override;

protected:
    void updateVoid() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tw::Document::Tag *) override;
};

#endif // TW_TEXDOCKS_H
