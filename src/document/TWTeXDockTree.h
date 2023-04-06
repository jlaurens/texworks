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

#ifndef Tw_Document_TeXDockTree_H
#define Tw_Document_TeXDockTree_H

#include <QDockWidget>
#include <QTreeWidget>

class QTreeWidgetItem;
class QComboBox;
class QTextEdit;
class QTextCursor;
class TeXDocumentWindow;

namespace Tw {
namespace Document {

class Tag;
class TagSuite;
class TagBank;

class TeXDockTreeWidget;

class TeXDockTreeAux;

/// \author JL
class TeXDockTree: public QDockWidget
{
    Q_OBJECT
    using Super = QDockWidget;
    using Self  = TeXDockTree;
    struct Extra;
    TagSuite *tagSuite_m;
protected:
    bool updated_m;
    void setTagSuite(TagSuite *);
public:
    TeXDockTree(const QString & title, TeXDocumentWindow *window);
    ~TeXDockTree() override = default;
    const TagSuite *tagSuite() { return tagSuite_m; };
    TeXDocumentWindow *window();
    QTextEdit *editor();
protected slots:
    virtual void update(bool force);
    void find(const QString & text);
    
public:
    virtual void initUI();
    void setupUpdate();
    
protected:
    virtual TeXDockTreeWidget *newTreeWidget();
    virtual void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const;
    virtual void updateVoid() = 0;
    QTreeWidgetItem *getItemAtIndex(const int tagIndex);
    void selectItemsForCursor(const QTextCursor &cursor, bool dontFollowItemSelection);
    Extra *extra_m;
};

class TeXDockTreeWidget: public QTreeWidget
{
    Q_OBJECT
    using Super = QTreeWidget;
public:
    friend void TeXDockTree::initUI();
    explicit TeXDockTreeWidget(QWidget * parent = nullptr);
    ~TeXDockTreeWidget() override = default;
    QSize sizeHint() const override;
};

class TeXDockTag: public TeXDockTree
{
    Q_OBJECT
    
    using Super = TeXDockTree;
    
public:
    TeXDockTag(TeXDocumentWindow *window);
    ~TeXDockTag() override = default;
    
protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

class TeXDockBookmark: public TeXDockTree
{
    Q_OBJECT
    
    using Super = TeXDockTree;
    
public:
    TeXDockBookmark(TeXDocumentWindow *window);
    ~TeXDockBookmark() override = default;
    
protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

class TeXDockOutline;

/**
 D&D manager.
 */
class TeXDockOutlineWidget: public TeXDockTreeWidget
{
    Q_OBJECT
    using Super = TeXDockTreeWidget;
    
public:
    explicit TeXDockOutlineWidget(TeXDockOutline * parent);
    ~TeXDockOutlineWidget() override = default;
    
protected:
    void dragEnterEvent(QDragEnterEvent *event) override;
    void dropEvent(QDropEvent *) override;
};

class TeXDockOutline: public TeXDockTree
{
    Q_OBJECT
    
    using Super = TeXDockTree;

public:
    struct TagX
    {
        const Tag * tag;
        bool isExpanded;
    };
    TeXDockOutline(TeXDocumentWindow *window);
    ~TeXDockOutline() override = default;
    bool performDrag(const QList<TagX> &, QTextCursor);

protected:
    void updateVoid() override;
    TeXDockTreeWidget *newTreeWidget() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

} // namespace Document
} // namespace Tw

#endif // Tw_Document_TeXDockTree_H
