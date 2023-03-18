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

TeXDock::TeXDock(const QString & title, TeXDocumentWindow * doc)
	: QDockWidget(title, doc), document(doc), filled(false)
{
	connect(this, &TeXDock::visibilityChanged, this, &TeXDock::myVisibilityChanged);
}

void TeXDock::myVisibilityChanged(bool visible)
{
	if (visible && document && !filled) {
		fillInfo();
		filled = true;
	}
}

//////////////// TAGS ////////////////

TagsDock::TagsDock(TeXDocumentWindow * doc)
	: TeXDock(tr("Tags"), doc)
{
	setObjectName(QString::fromLatin1("tags"));
	setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
	tree = new TeXDockTreeWidget(this);
	tree->header()->hide();
	tree->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
	setWidget(tree);
	connect(doc->textDoc(), &Tw::Document::TeXDocument::tagsChanged, this, &TagsDock::listChanged);
	saveScrollValue = 0;
}

void TagsDock::fillInfo()
{
	disconnect(tree, &QTreeWidget::itemSelectionChanged, this, &TagsDock::followTagSelection);
	disconnect(tree, &QTreeWidget::itemActivated, this, &TagsDock::followTagSelection);
	disconnect(tree, &QTreeWidget::itemClicked, this, &TagsDock::followTagSelection);
	tree->clear();
	const QList<Tw::Document::TextDocument::Tag> & tags = document->textDoc()->getTags();
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
}

void TagsDock::listChanged()
{
	saveScrollValue = tree->verticalScrollBar()->value();
	tree->clear();
	filled = false;
	if (document && isVisible())
		fillInfo();
}

void TagsDock::followTagSelection()
{
	QList<QTreeWidgetItem*> items = tree->selectedItems();
	if (items.count() > 0) {
		QTreeWidgetItem* item = items.first();
		QString dest = item->text(1);
		if (!dest.isEmpty())
			document->goToTag(dest.toInt());
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
