/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2008-2023  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen, Jérôme Laurens

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

#ifndef Tw_Document_Anchor_DockTree_H
#define Tw_Document_Anchor_DockTree_H

#include <QDockWidget>
#include <QTreeWidget>

class QTreeWidgetItem;
class QComboBox;
class QTextEdit;
class QTextCursor;
class TeXDocumentWindow;

namespace Tw {
namespace Document {
namespace Anchor {

class Tag;
class TagSuite;
class TagBank;

class DockTreeWidget;

class DockTreeAux;

/// \author JL
class DockTree: public QDockWidget
{
    Q_OBJECT
    using Super = QDockWidget;
    using Self  = DockTree;
    struct Extra;
    TagSuite *tagSuite_m;
protected:
    bool updated_m;
    void setTagSuite(TagSuite *);
public:
    DockTree(const QString & title, TeXDocumentWindow *window);
    ~DockTree() override = default;
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
    virtual DockTreeWidget *newTreeWidget();
    virtual void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const;
    virtual void updateVoid() = 0;
    QTreeWidgetItem *getItemAtIndex(const int tagIndex);
    void selectItemsForCursor(const QTextCursor &cursor, bool dontFollowItemSelection);
    Extra *extra_m;
};

class DockTreeWidget: public QTreeWidget
{
    Q_OBJECT
    using Super = QTreeWidget;
public:
    friend void DockTree::initUI();
    explicit DockTreeWidget(QWidget * parent = nullptr);
    ~DockTreeWidget() override = default;
    QSize sizeHint() const override;
};

class DockTag: public DockTree
{
    Q_OBJECT
    
    using Super = DockTree;
    
public:
    DockTag(TeXDocumentWindow *window);
    ~DockTag() override = default;
    
protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

class DockBookmark: public DockTree
{
    Q_OBJECT
    
    using Super = DockTree;
    
public:
    DockBookmark(TeXDocumentWindow *window);
    ~DockBookmark() override = default;
    
protected:
    void updateVoid() override;
    void initUI() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

class DockOutline;

/**
 D&D manager.
 */
class DockOutlineWidget: public DockTreeWidget
{
    Q_OBJECT
    using Super = DockTreeWidget;
    
public:
    explicit DockOutlineWidget(DockOutline * parent);
    ~DockOutlineWidget() override = default;
    
protected:
    void dragEnterEvent(QDragEnterEvent *event) override;
    void dropEvent(QDropEvent *) override;
};

class DockOutline: public DockTree
{
    Q_OBJECT
    
    using Super = DockTree;

public:
    struct TagX
    {
        const Tag * tag;
        bool isExpanded;
    };
    DockOutline(TeXDocumentWindow *window);
    ~DockOutline() override = default;
    bool performDrag(const QList<TagX> &, QTextCursor);

protected:
    void updateVoid() override;
    DockTreeWidget *newTreeWidget() override;
    void makeNewItem(QTreeWidgetItem *&, QTreeWidget *, const Tag *) const override;
};

} // namespace Anchor
} // namespace Document
} // namespace Tw

#endif // Tw_Document_Anchor_DockTree_H
