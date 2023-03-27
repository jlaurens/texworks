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
#include "TWString.h"
#include "TWIcon.h"

#include <QHeaderView>
#include <QScrollBar>
#include <QTreeWidget>
#include <QComboBox>
#include <QPushButton>
#include <QDebug>

TeXDock::TeXDock(const QString &title, TeXDocumentWindow * documentWindow_p)
	: QDockWidget(title, documentWindow_p), documentWindow_p(documentWindow_p), updated(false)
{
	connect(this, &TeXDock::visibilityChanged, this, &TeXDock::onVisibilityChanged);
}

void TeXDock::onVisibilityChanged(bool visible)
{
	update(visible);
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

// Bookmarks

/// \author JL
TeXDockTree::TeXDockTree(const QString &title, TeXDocumentWindow * win)
    : TeXDock(title, win), _dontFollowItemSelection(false)
{
    setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    connect(win->textDoc(), &Tw::Document::TeXDocument::tagsChanged, this, &TeXDockTree::onTagArrayChanged);
    _lastScrollValue = 0;
    observeCursorPositionChanged(true);
}

/// \note must be called by subclassers.
void TeXDockTree::initUI()
{
    // top level
    QVBoxLayout *topLayout_p = new QVBoxLayout;
    topLayout_p->setSpacing(0);
    topLayout_p->setContentsMargins(0,0,0,0);
    QWidget * topWidget_p = new QWidget;
    topWidget_p->setLayout(topLayout_p);
    // the toolbar
    auto *toolbarWidget_p = new QWidget;
    toolbarWidget_p->setObjectName(Tw::Name::toolbar);
    auto *toolbarLayout_p = new QHBoxLayout;
    toolbarLayout_p->setSpacing(0);
    toolbarLayout_p->setContentsMargins(0,0,0,0);
    toolbarWidget_p->setLayout(toolbarLayout_p);
    auto *comboBox_p = new QComboBox;
    comboBox_p->setEditable(true);
    comboBox_p->setPlaceholderText(tr("Find"));
    comboBox_p->setInsertPolicy(QComboBox::InsertAtTop);
    connect(comboBox_p, &QComboBox::currentTextChanged, [=](const QString &text){
        find(text);
    });
    connect(comboBox_p, QOverload<int>::of(&QComboBox::activated), [=](int index){
        find(comboBox_p->itemText(index));
    });
    toolbarLayout_p->addWidget(comboBox_p, 2);
    topLayout_p->addWidget(toolbarWidget_p);
    // the tree
    auto *treeWidget_p = new TeXDockTreeWidget();
    treeWidget_p->header()->hide();
    treeWidget_p->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
    treeWidget_p->setExpandsOnDoubleClick(false);
    topLayout_p->addWidget(treeWidget_p);
    setWidget(topWidget_p);
}

void TeXDockTree::onTagArrayChanged()
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    _lastScrollValue = treeWidget_p->verticalScrollBar()->value();
    treeWidget_p->clear();
    auto *tag_p = getTagArray().getCurrent_p();
    if (tag_p) {
        auto *item_p = getItemForCursor(tag_p->cursor);
        selectItem(item_p, true);
    }
    update(true);
}

void TeXDockTree::observeCursorPositionChanged(bool yorn)
{
    if (yorn) {
        connect(documentWindow_p->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    } else {
        disconnect(documentWindow_p->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    }
}

void TeXDockTree::itemGainedFocus()
{
    if (_dontFollowItemSelection) return;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p)
        return;
    auto items = treeWidget_p->selectedItems();
    if (items.count() > 0) {
        auto item = items.first();
        QString dest = item->text(1);
        if (!dest.isEmpty()) {
            auto &tagList = getMutableTagArray();
            auto *tag_p = tagList.get_p(dest.toInt());
            if (tag_p) {
                documentWindow_p->ensureCursorVisible(tag_p->cursor);
                tagList.setCurrent(*tag_p);
            }
        }
    }
}

QTreeWidgetItem *TeXDockTree::getItemAtIndex(const int tagIndex)
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    QList<QTreeWidgetItem *> items = { treeWidget_p->invisibleRootItem() };
    while (!items.isEmpty()) {
        QTreeWidgetItem *item_p = items.takeFirst();
        int i = item_p->childCount();
        while (i--) {
            items.prepend(item_p->child(i));
        }
        QString dest = item_p->text(1);
        if (!dest.isEmpty() &&(dest.toInt() == tagIndex)) {
            return item_p;
        }
    }
    return nullptr;
}

QTreeWidgetItem *TeXDockTree::getItemForCursor(const QTextCursor &cursor)
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    const int charIndex = cursor.position();
    int tagIndex = 0;
    for (auto tag: getTagArray()) {
        auto c = tag.cursor;
        if (c.position() >= charIndex) {
            if (c.position() > charIndex) {
                --tagIndex;
            }
            return getItemAtIndex(tagIndex);
        }
        ++tagIndex;
    }
    return nullptr;
}

void TeXDockTree::selectItem(QTreeWidgetItem *item_p, bool dontFollowItemSelection)
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    if (item_p) {
        for (auto *p: treeWidget_p->selectedItems()) {
            p->setSelected(false);
        }
        _dontFollowItemSelection = dontFollowItemSelection;
        item_p->setSelected(true);
        _dontFollowItemSelection = false;
        treeWidget_p->scrollToItem(item_p);
    }
}

void TeXDockTree::selectItemForCursor(const QTextCursor &cursor, bool dontFollowItemSelection)
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    const int charIndex = cursor.position();
    int tagIndex = 0;
    for (auto tag: getTagArray()) {
        auto c = tag.cursor;
        if (c.position() >= charIndex) {
            if (c.position() > charIndex) {
                --tagIndex;
            }
            auto *item_p = getItemAtIndex(tagIndex);
            if (item_p) {
                selectItem(item_p, dontFollowItemSelection);
                return;
            }
        }
        ++tagIndex;
    }
}

void TeXDockTree::onCursorPositionChanged()
{
    if (documentWindow_p) {
        CompletingEdit* editor = documentWindow_p->editor();
        if (editor) {
            QTextCursor cursor = editor->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            selectItemForCursor(cursor, true);
        }
    }
}

void TeXDockTree::update(bool force)
{
    if ((!documentWindow_p || !isVisible() || updated) &&!force) return;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    disconnect(treeWidget_p, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget_p, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget_p, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    treeWidget_p->clear();
    auto &tagArray = getTagArray();
    if (tagArray.empty()) {
        updateVoid();
    } else {
        QTreeWidgetItem *item_p = nullptr;
        int index = 0;
        for (auto tag: tagArray) {
            const int level = QTreeWidgetItem::UserType + tag.level;
            while (item_p &&item_p->type() >= level)
                item_p = item_p->parent();
            if (item_p) {
                item_p = new QTreeWidgetItem( item_p, level);
            } else {
                item_p = new QTreeWidgetItem( treeWidget_p, level);
            }
            item_p->setText(0, tag.text);
            if (!tag.tooltip.isEmpty()) {
                item_p->setData(0, Qt::ToolTipRole, tag.tooltip);
            }
            item_p->setText(1, QString::number(index));
            item_p->setSelected(index == tagArray.getCurrentIndex());
            treeWidget_p->expandItem(item_p);
            ++index;
        }
        if (_lastScrollValue > 0) {
            treeWidget_p->verticalScrollBar()->setValue(_lastScrollValue);
            _lastScrollValue = 0;
        }
        connect(treeWidget_p, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget_p, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget_p, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    }
    updated = true;
}

void TeXDockTree::find(const QString &find)
{
    QList<Tw::Document::Tag> next;
    int anchor = 0;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p) {
        return;
    }
    QList<QTreeWidgetItem*> itemList = treeWidget_p->selectedItems();
    if (!itemList.isEmpty()) {
        QTreeWidgetItem *item_p = itemList.first();
        QString dest = item_p->text(1);
        if (dest.isEmpty()) {
            anchor = documentWindow_p->editor()->textCursor().selectionEnd();
        } else {
            auto *tag_p = getTagArray().get_p(dest.toInt());
            if (tag_p) {
                QTextCursor c(tag_p->cursor);
                c.movePosition(QTextCursor::EndOfBlock);
                anchor = c.position();
            } else {
                anchor = documentWindow_p->editor()->textCursor().selectionEnd();
            }
        }
    } else {
        anchor = documentWindow_p->editor()->textCursor().selectionEnd();
    }
    if (find.startsWith(QStringLiteral(":"))) {
        QRegularExpression re(find.mid(1));
        if(re.isValid()) {
            for (auto tag: getTagArray()) {
                if(tag.cursor.position() >= anchor) {
                    auto m = re.match(tag.text);
                    if (m.hasMatch()) {
                        selectItemForCursor(tag.cursor, false);
                        return;
                    }
                } else {
                    next.append(tag);
                }
            }
            for (auto tag: next) {
                auto m = re.match(tag.text);
                if (m.hasMatch()) {
                    selectItemForCursor(tag.cursor, false);
                    return;
                }
            }
            return;
        }
    }
    for (auto tag: getTagArray()) {
        if(tag.cursor.position() >= anchor) {
            if (tag.text.contains(find)) {
                selectItemForCursor(tag.cursor, false);
                return;
            }
        } else {
            next.append(tag);
        }
    }
    for (auto tag: next) {
        if (tag.text.contains(find)) {
            selectItemForCursor(tag.cursor, false);
            return;
        }
    }
}

//MARK: Tags

/// \author JL
TeXDockTag::TeXDockTag(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Tags"), win)
{
    setObjectName(Tw::Name::Tags);
    connect(&(getTagArray()), &Tw::Document::TagArray::changed, this, &TeXDockTag::onTagArrayChanged);
    initUI();
}

Tw::Document::TagArray &TeXDockTag::getMutableTagArray()
{
    return documentWindow_p->textDoc()->getMutableTagArray();
}

const Tw::Document::TagArray &TeXDockTag::getTagArray() const
{
    return documentWindow_p->textDoc()->getTagArray();
}

void TeXDockTag::updateVoid()
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p) {
        return;
    }
    QTreeWidgetItem *item_p = new QTreeWidgetItem();
    item_p->setText(0, TeXDockTree::tr("No bookmark"));
    item_p->setFlags(item_p->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget_p->addTopLevelItem(item_p);
}

void TeXDockTag::initUI()
{
    Super::initUI();
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(!treeWidget_p);
    auto *toolbarWidget_p = findChild<QWidget*>(Tw::Name::toolbar);
    Q_ASSERT(!toolbarWidget_p);
    //TODO: Edit tags in place
    /*
    connect(treeWidget_p, &QTreeWidget::itemDoubleClicked, [=](QTreeWidgetItem * item, int column)
            {
        if (column == 0) {
            treeWidget_p->editItem(item, column);
        }
    });
     */
    auto *layout_p = static_cast<QBoxLayout *>(toolbarWidget_p->layout());
    if (!layout_p) return;
    {
        auto *button_p = new QPushButton(QString());
        button_p->setIcon(Tw::Icon::list_add());
        button_p->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button_p->setObjectName(Tw::Name::list_add);
        connect(button_p, &QPushButton::clicked, [=]() {
            auto cursor = documentWindow_p->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            documentWindow_p->editor()->setTextCursor(cursor);
            documentWindow_p->editor()->setFocus();
        });
        layout_p->insertWidget(0, button_p);
    }
    {
        auto *button_p = new QPushButton(QString());
        button_p->setIcon(Tw::Icon::list_remove());
        button_p->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button_p->setObjectName(Tw::Name::list_remove);
        button_p->setEnabled(false);
        connect(button_p, &QPushButton::clicked, [=]() {
            auto items = treeWidget_p->selectedItems();
            Tw::Document::TagArray &tagList = getMutableTagArray();
            int currentTagIndex = -1;
            for (auto *item: treeWidget_p->selectedItems()) {
                auto dest = item->text(1);
                if (!dest.isEmpty()) {
                    const auto tagIndex = dest.toInt();
                    const auto *tag_p = tagList.get_p(tagIndex);
                    if (tag_p) {
                        QTextCursor cursor(tag_p->cursor);
                        cursor.movePosition(QTextCursor::StartOfBlock);
                        cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
                        cursor.insertText(QString());
                        if (currentTagIndex<0)
                            currentTagIndex = tagIndex;
                    }
                }
            }
            tagList.setCurrent(currentTagIndex);
        });
        auto f = [=] () {
            button_p->setEnabled(treeWidget_p->selectedItems().count() > 0);
        };
        connect(treeWidget_p, &QTreeWidget::itemSelectionChanged, f);
        connect(treeWidget_p, &QTreeWidget::itemActivated,        f);
        connect(treeWidget_p, &QTreeWidget::itemClicked,          f);
        layout_p->insertWidget(1, button_p);
    }
}

//MARK: Bookmarks

/// \author JL
TeXDockBookmark::TeXDockBookmark(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Bookmarks"), win)
{
    setObjectName(Tw::Name::Bookmarks);
    connect(&(getTagArray()), &Tw::Document::TagArray::changed, this, &TeXDockBookmark::onTagArrayChanged);
    initUI();
}

Tw::Document::TagArray &TeXDockBookmark::getMutableTagArray()
{
    return documentWindow_p->textDoc()->getMutableBookmarkArray();
}

const Tw::Document::TagArray &TeXDockBookmark::getTagArray() const
{
    return documentWindow_p->textDoc()->getBookmarkArray();
}

void TeXDockBookmark::updateVoid()
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p) {
        return;
    }
    QTreeWidgetItem *item_p = new QTreeWidgetItem();
    item_p->setText(0, TeXDockTree::tr("No bookmark"));
    item_p->setFlags(item_p->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget_p->addTopLevelItem(item_p);
}

void TeXDockBookmark::initUI()
{
    Super::initUI();
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(!treeWidget_p);
    auto *toolbarWidget_p = findChild<QWidget*>(Tw::Name::toolbar);
    Q_ASSERT(!toolbarWidget_p);
    //TODO: Edit tags in place
    /*
    connect(treeWidget_p, &QTreeWidget::itemDoubleClicked, [=](QTreeWidgetItem * item, int column)
            {
        if (column == 0) {
            treeWidget_p->editItem(item, column);
        }
    });
     */
    auto *layout_p = static_cast<QBoxLayout *>(toolbarWidget_p->layout());
    if (!layout_p) return;
    {
        auto *button_p = new QPushButton(QString());
        button_p->setIcon(Tw::Icon::list_add());
        button_p->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button_p->setObjectName(Tw::Name::list_add);
        connect(button_p, &QPushButton::clicked, [=]() {
            auto cursor = documentWindow_p->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            documentWindow_p->editor()->setTextCursor(cursor);
            documentWindow_p->editor()->setFocus();
        });
        layout_p->insertWidget(0, button_p);
    }
    {
        auto *button_p = new QPushButton(QString());
        button_p->setIcon(Tw::Icon::list_remove());
        button_p->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button_p->setObjectName(Tw::Name::list_remove);
        button_p->setEnabled(false);
        connect(button_p, &QPushButton::clicked, [=]() {
            auto items = treeWidget_p->selectedItems();
            Tw::Document::TagArray &tagList = getMutableTagArray();
            int currentTagIndex = -1;
            for (auto *item: treeWidget_p->selectedItems()) {
                auto dest = item->text(1);
                if (!dest.isEmpty()) {
                    const auto tagIndex = dest.toInt();
                    const auto *tag_p = tagList.get_p(tagIndex);
                    if (tag_p) {
                        QTextCursor cursor(tag_p->cursor);
                        cursor.movePosition(QTextCursor::StartOfBlock);
                        cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
                        cursor.insertText(QString());
                        if (currentTagIndex<0)
                            currentTagIndex = tagIndex;
                    }
                }
            }
            tagList.setCurrent(currentTagIndex);
        });
        auto f = [=] () {
            button_p->setEnabled(treeWidget_p->selectedItems().count() > 0);
        };
        connect(treeWidget_p, &QTreeWidget::itemSelectionChanged, f);
        connect(treeWidget_p, &QTreeWidget::itemActivated,        f);
        connect(treeWidget_p, &QTreeWidget::itemClicked,          f);
        layout_p->insertWidget(1, button_p);
    }
}

//MARK: Outlines

/// \author JL
TeXDockOutline::TeXDockOutline(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Outline"), win)
{
    setObjectName(Tw::Name::Outlines);
    connect(&(getTagArray()), &Tw::Document::TagArray::changed, this, &TeXDockOutline::onTagArrayChanged);
    initUI();
}

Tw::Document::TagArray &TeXDockOutline::getMutableTagArray()
{
    return documentWindow_p->textDoc()->getMutableOutlineArray();
}

const Tw::Document::TagArray &TeXDockOutline::getTagArray() const
{
    return documentWindow_p->textDoc()->getOutlineArray();
}

void TeXDockOutline::updateVoid()
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p) {
        return;
    }
    QTreeWidgetItem *item_p = new QTreeWidgetItem();
    item_p->setText(0, TeXDockTree::tr("No outline"));
    item_p->setFlags(item_p->flags() & ~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget_p->addTopLevelItem(item_p);
}

