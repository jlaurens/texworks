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

#include "TeXDocks.h"

#include "TeXDocumentWindow.h"

#include <QHeaderView>
#include <QScrollBar>
#include <QTreeWidget>
#include <QDebug>

TeXDock::TeXDock(const QString & title, TeXDocumentWindow * documentWindow)
	: QDockWidget(title, documentWindow), documentWindow(documentWindow), updated(false)
{
	connect(this, &TeXDock::visibilityChanged, this, &TeXDock::onVisibilityChanged);
}

void TeXDock::onVisibilityChanged(bool visible)
{
	update(visible);
}

//////////////// TAGS ////////////////

TagsDock::TagsDock(TeXDocumentWindow * doc)
	: TeXDock(tr("Tags"), doc), dontFollowTagSelection(false)
{
	setObjectName(QStringLiteral("tags"));
	setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
	tree = new TeXDockTreeWidget(this);
	tree->header()->hide();
	tree->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
	setWidget(tree);
	connect(doc->textDoc(), &Tw::Document::TeXDocument::tagsChanged, this, &TagsDock::listChanged);
	saveScrollValue = 0;
    activateTagFollowCursorPosition(true);
}

void TagsDock::update(bool force)
{
    if ((!documentWindow || !isVisible() || updated) && !force) return;
	disconnect(tree, &QTreeWidget::itemSelectionChanged, this, &TagsDock::followTagSelection);
	disconnect(tree, &QTreeWidget::itemActivated, this, &TagsDock::followTagSelection);
	disconnect(tree, &QTreeWidget::itemClicked, this, &TagsDock::followTagSelection);
	tree->clear();
	const QList<Tw::Document::TextDocument::Tag> & tags = documentWindow->getTags();
	if (!tags.empty()) {
		QTreeWidgetItem *olItem = nullptr, *bmItem = nullptr;
		QTreeWidgetItem *bookmarks = new QTreeWidgetItem(tree);
		bookmarks->setText(0, tr("Bookmarks"));
		bookmarks->setFlags(Qt::ItemIsEnabled);
		bookmarks->setForeground(0, Qt::blue);
		tree->expandItem(bookmarks);
		QTreeWidgetItem *outline = new QTreeWidgetItem(tree, bookmarks);
		outline->setText(0, tr("Outline"));
		outline->setFlags(Qt::ItemIsEnabled);
		outline->setForeground(0, Qt::blue);
		tree->expandItem(outline);
		for (int index = 0; index < tags.size(); ++index) {
			const Tw::Document::TextDocument::Tag & bm = tags[index];
            auto new_item = [this, index, bm] (QTreeWidgetItem *root,
                                               QTreeWidgetItem *item,
                                               const int level) {
                while (item && item->type() >= level)
                    item = item->parent();
                if (!item)
                    item = new QTreeWidgetItem(root, level);
                else
                    item = new QTreeWidgetItem(item, level);
                item->setText(0, bm.text);
                item->setText(1, QString::number(index));
                tree->expandItem(item);
                return item;
            };
			if (bm.level < 1) {
                bmItem = new_item(bookmarks, bmItem, QTreeWidgetItem::UserType + 1 - bm.level);
			}
			else  {
                olItem = new_item(outline, olItem, QTreeWidgetItem::UserType + bm.level);
			}
		}
		if (bookmarks->childCount() == 0)
			bookmarks->setHidden(true);
		if (outline->childCount() == 0)
			outline->setHidden(true);
		if (saveScrollValue > 0) {
			tree->verticalScrollBar()->setValue(saveScrollValue);
			saveScrollValue = 0;
		}
		connect(tree, &QTreeWidget::itemSelectionChanged, this, &TagsDock::followTagSelection);
		connect(tree, &QTreeWidget::itemActivated, this, &TagsDock::followTagSelection);
		connect(tree, &QTreeWidget::itemClicked, this, &TagsDock::followTagSelection);
	} else {
		QTreeWidgetItem *item = new QTreeWidgetItem();
		item->setText(0, tr("No tags"));
		item->setFlags(item->flags() & ~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
		tree->addTopLevelItem(item);
	}
    updated = true;
}

void TagsDock::listChanged()
{
	saveScrollValue = tree->verticalScrollBar()->value();
	tree->clear();
    update(true);
}

void TagsDock::activateTagFollowCursorPosition(bool yorn)
{
    if (yorn) {
        connect(documentWindow->editor(), &QTextEdit::cursorPositionChanged, this, &TagsDock::onCursorPositionChanged);
    } else {
        disconnect(documentWindow->editor(), &QTextEdit::cursorPositionChanged, this, &TagsDock::onCursorPositionChanged);
    }
}

void TagsDock::followTagSelection()
{
    if (dontFollowTagSelection) return;
    QList<QTreeWidgetItem*> items = tree->selectedItems();
    if (items.count() > 0) {
        QTreeWidgetItem* item = items.first();
        QString dest = item->text(1);
        if (!dest.isEmpty())
            documentWindow->ensureVisibleTagAtIndex(dest.toInt());
    }
}

/// \author JL
void TagsDock::onCursorPositionChanged()
{
    if (documentWindow) {
        CompletingEdit* editor = documentWindow->editor();
        if (editor) {
            QTextCursor cursor = editor->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            const int charIndex = cursor.position();
            int tagIndex = 0;
            auto tags = documentWindow->getTags();
            for (auto tag: tags) {
                QTextCursor c = tag.cursor;
                if (tag.cursor.position() >= charIndex) {
                    QList<QTreeWidgetItem *> items = { tree->invisibleRootItem() };
                    while (!items.isEmpty()) {
                        QTreeWidgetItem *item = items.takeFirst();
                        int i = item->childCount();
                        while (i--) {
                            items.prepend(item->child(i));
                        }
                        QString dest = item->text(1);
                        if (!dest.isEmpty() && tagIndex == dest.toInt()) {
                            for (auto item: tree->selectedItems()) {
                                item->setSelected(false);
                            }
                            dontFollowTagSelection = true;
                            item->setSelected(true);
                            dontFollowTagSelection = false;
                            tree->expandItem(item);
                            tree->scrollToItem(item);
                            return;
                        }
                    }
                    return;
                }
                ++tagIndex;
            }
        }
    }
}

TeXDockTreeWidget::TeXDockTreeWidget(QWidget* parent)
	: QTreeWidget(parent)
{
	setIndentation(10);
}

QSize TeXDockTreeWidget::sizeHint() const
{
	return QSize(180, 300);
}
