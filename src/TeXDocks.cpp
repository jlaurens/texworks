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
#include <QProxyStyle>

/// \note all static material is gathered here
namespace __ {

static int kMinLevel = std::numeric_limits<int>::min();

enum Role {
    kTagRole = Qt::UserRole,
    kTagIndexRole,
    kLevelRole,
    kBookmarkLevelRole,
    kOutlineLevelRole,
};
static const Tw::Document::Tag *getItemTag_p(const QTreeWidgetItem *item_p) {
    if (item_p) {
        QVariant v = item_p->data(0, __::kTagRole);
        if (v.isValid()) {
            return static_cast<const Tw::Document::Tag *>(v.value<const void *>());
        }
    }
    return nullptr;
}
static void setItemTag(QTreeWidgetItem *item_p, const Tw::Document::Tag *tag_p) {
    if (item_p) {
        QVariant v = QVariant::fromValue(static_cast<const void*>(tag_p));
        item_p->setData(0, __::kTagRole, v);
    }
}
static int getItemTagIndex(const QTreeWidgetItem * item_p) {
    if (item_p) {
        QVariant v = item_p->data(0, __::kTagIndexRole);
        if (v.isValid()) {
            return v.toInt();
        }
    }
    return -1;
}
static void setItemTagIndex(QTreeWidgetItem * item_p, int tagIndex) {
    if (item_p) {
        item_p->setData(0, __::kTagIndexRole, tagIndex);
    }
}
static int getItemLevel(const QTreeWidgetItem * item_p) {
    if (item_p) {
        QVariant v = item_p->data(0, __::kLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemLevel(QTreeWidgetItem * item_p, const int level) {
    if (item_p) {
        item_p->setData(0, __::kLevelRole, level);
        return true;
    }
    return false;
}
static int getItemBookmarkLevel(const QTreeWidgetItem * item_p) {
    if (item_p) {
        QVariant v = item_p->data(0, __::kBookmarkLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemBookmarkLevel(QTreeWidgetItem * item_p, const int level) {
    if (item_p) {
        item_p->setData(0, __::kBookmarkLevelRole, level);
        return true;
    }
    return false;
}
static int getItemOutlineLevel(const QTreeWidgetItem * item_p) {
    if (item_p) {
        QVariant v = item_p->data(0, __::kOutlineLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemOutlineLevel(QTreeWidgetItem * item_p, const int level) {
    if (item_p) {
        item_p->setData(0, __::kOutlineLevelRole, level);
        return true;
    }
    return false;
}
} // namespace __
TeXDock::TeXDock(const QString &title, TeXDocumentWindow * window_p)
	: QDockWidget(title, window_p), _window_p(window_p), _updated(false)
{
	connect(this, &TeXDock::visibilityChanged, this, &TeXDock::onVisibilityChanged);
}

void TeXDock::onVisibilityChanged(bool visible)
{
	update(visible);
}
 //MARK: TeXDockTreeWidget

TeXDockTreeWidget::TeXDockTreeWidget(QWidget *parent_p)
	: QTreeWidget(parent_p)
{
	setIndentation(10);
}

QSize TeXDockTreeWidget::sizeHint() const
{
	return QSize(180, 300);
}

//MARK: TeXDockTree

/// \author JL
TeXDockTree::TeXDockTree(const QString &title, TeXDocumentWindow * win)
    : TeXDock(title, win), _dontFollowItemSelection(false)
{
    setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    connect(win->textDoc(), &Tw::Document::TeXDocument::tagsChanged, this, &TeXDockTree::onListTagPChanged);
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
    toolbarWidget_p->setObjectName(Tw::ObjectName::toolbar);
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
    auto *treeWidget_p = newTreeWidget(this);
    treeWidget_p->header()->hide();
    treeWidget_p->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
    treeWidget_p->setExpandsOnDoubleClick(false);
    topLayout_p->addWidget(treeWidget_p);
    setWidget(topWidget_p);
}

TeXDockTreeWidget *TeXDockTree::newTreeWidget(QWidget *parent_p)
{
    return new TeXDockTreeWidget(parent_p);
}

void TeXDockTree::onListTagPChanged()
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    _lastScrollValue = treeWidget_p->verticalScrollBar()->value();
    treeWidget_p->clear();
    update(true);
    
}

void TeXDockTree::observeCursorPositionChanged(bool yorn)
{
    if (yorn) {
        connect(window_p->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    } else {
        disconnect(window_p->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    }
}

void TeXDockTree::itemGainedFocus()
{
    if (_dontFollowItemSelection) return;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    auto &array = getArrayTagP();
    array.select(false);
    for (const auto &item: treeWidget_p->selectedItems()) {
        auto *tag_p = __::getItemTag_p(item_p);
        if (tag_p) {
            auto c = tag_p->cursor();
            _window_p->ensureCursorVisible(c);
            array.select(c);
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
        if (__::getItemTagIndex(item_p) == tagIndex) {
            return item_p;
        }
    }
    return nullptr;
}

void TeXDockTree::selectItemsForCursor(const QTextCursor &cursor, bool dontFollowItemSelection)
{
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    QTextCursor c(cursor);
    c.movePosition(QTextCursor::StartOfBlock);
    int start = c.selectionStart();
    c.setPosition(cursor.selectionEnd());
    c.movePosition(QTextCursor::EndOfBlock);
    int end = c.selectionEnd();
    int tagIndex = 0;
    auto &array = getArrayTagP();
    array.select(false);
    for (const auto *tag_p: getArrayTagP()) {
        int i = tag_p->selectionStart();
        if (start <= i ) {
            if (end <= i)
                break;
            auto *item_p = getItemAtIndex(tagIndex);
            if (item_p) {
                _dontFollowItemSelection = dontFollowItemSelection;
                item_p->setSelected(true);
                array.select(true, tag_p);
                _dontFollowItemSelection = false;
                treeWidget_p->scrollToItem(item_p);
            }
        }
        ++tagIndex;
    }
}

void TeXDockTree::onCursorPositionChanged()
{
    if (window_p) {
        auto *editor_p = _window_p->editor();
        if (editor_p) {
            selectItemsForCursor(editor_p->textCursor(), true);
        }
    }
}

void TeXDockTree::makeNewItem(QTreeWidgetItem * &item_p,
                              QTreeWidget *treeWidget_p,
                              const Tw::Document::Tag *tag_p) const
{
    if (!tag_p) return;
    const int level = tag_p->level();
    while (item_p && __::getItemLevel(item_p) >= level)
        item_p = item_p->parent();
    if (item_p) {
        item_p = new QTreeWidgetItem(item_p, QTreeWidgetItem::UserType);
    } else {
        item_p = new QTreeWidgetItem(treeWidget_p, QTreeWidgetItem::UserType);
    }
    __::setItemLevel(item_p, level);
    item_p->setText(0, tag_p->text());
    auto tip = tag_p->tooltip();
    if (!tip.isEmpty()) {
        item_p->setToolTip(0, tip);
    }
}

void TeXDockTree::update(bool force)
{
    if ((!_window_p || !isVisible() || _updated) &&!force) return;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    disconnect(treeWidget_p, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget_p, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget_p, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    treeWidget_p->clear();
    auto &listTagP = getArrayTagP();
    if (listTagP.isEmpty()) {
        updateVoid();
    } else {
        QTreeWidgetItem *item_p = nullptr;
        int i = 0;
        const Tw::Document::Tag *tag_p;
        while((tag_p = listTagP.get_p(i))) {
            makeNewItem(item_p, treeWidget_p, tag_p);
            __::setItemTag(item_p, tag_p);
            __::setItemTagIndex(item_p, i);
            treeWidget_p->expandItem(item_p);
            treeWidget_p->setSelected(listTagP.isSelected(tag_p));
            ++i;
        }
        if (_lastScrollValue > 0) {
            treeWidget_p->verticalScrollBar()->setValue(_lastScrollValue);
            _lastScrollValue = 0;
        }
        connect(treeWidget_p, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget_p, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget_p, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    }
    _updated = true;
}

void TeXDockTree::find(const QString &find)
{
    if (!_window_p) return;
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    if (!treeWidget_p) {
        return;
    }
    QList<Tw::Document::Tag> next;
    int anchor = 0;
    auto &iistItem = treeWidget_p->selectedItems();
    if (!iistItem.isEmpty()) {
        QTreeWidgetItem *item_p = iistItem.first();
        auto *tag_p = __::getItemTag_p(item_p);
        if (tag_p) {
            QTextCursor c = tag_p->cursor();
            c.movePosition(QTextCursor::EndOfBlock);
            anchor = c.selectionEnd();
        } else {
            anchor = _window_p->editor()->textCursor().selectionEnd();
        }
    } else {
        anchor = _window_p->editor()->textCursor().selectionEnd();
    }
    if (find.startsWith(QStringLiteral(":"))) {
        QRegularExpression re(find.mid(1));
        if(re.isValid()) {
            auto &arrayTagP = getArrayTagP();

            for (auto tag: getArrayTagP()) {
                if(tag.selectionStart() >= anchor) {
                    auto m = re.match(tag.text());
                    if (m.hasMatch()) {
                        selectItemsForCursor(tag.cursor(), false);
                        return;
                    }
                } else {
                    next.append(tag);
                }
            }
            for (auto tag: next) {
                auto m = re.match(tag.text());
                if (m.hasMatch()) {
                    selectItemsForCursor(tag.cursor(), false);
                    return;
                }
            }
            return;
        }
    }
    for (auto tag: getArrayTagP()) {
        if(tag.cursor.position() >= anchor) {
            if (tag.text.contains(find)) {
                selectItemsForCursor(tag.cursor(), false);
                return;
            }
        } else {
            next.append(tag);
        }
    }
    for (auto tag: next) {
        if (tag.text().contains(find)) {
            selectItemsForCursor(tag.cursor(), false);
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
    connect(&(getArrayTagP()), &Tw::Document::ArrayTagP::changed, this, &TeXDockTag::onListTagPChanged);
    initUI();
}

const Tw::Document::ArrayTagP &TeXDockTag::getArrayTagP() const
{
    Q_ASSERT(_window_p);
    return _window_p->textDoc()->getArrayTagP();
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
    Q_ASSERT(_window_p);
    Super::initUI();
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    treeWidget_p->setColumnCount(2);
    treeWidget_p->header()->setStretchLastSection(false);
    treeWidget_p->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget_p->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget_p->header()->resizeSection(1, 24);
    auto *toolbarWidget_p = findChild<QWidget*>(Tw::ObjectName::toolbar);
    Q_ASSERT(!toolbarWidget_p);
//TODO: Edit tags in place
    auto *layout_p = static_cast<QBoxLayout *>(toolbarWidget_p->layout());
    if (!layout_p) return;
    {
        auto *button_p = new QPushButton(QString());
        button_p->setIcon(Tw::Icon::list_add());
        button_p->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button_p->setObjectName(Tw::Name::list_add);
        connect(button_p, &QPushButton::clicked, [=]() {
            auto cursor = _window_p->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            _window_p->editor()->setTextCursor(cursor);
            _window_p->editor()->setFocus();
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
            Tw::Document::ArrayTagP &arrayTagP = getArrayTagP();
            int currentTagIndex = -1;
            for (auto *item_p: treeWidget_p->selectedItems()) {
                auto const *tag_p = __::getItemTag_p(item_p);
                if (tag_p) {
                    QTextCursor cursor = tag_p->cursor();
                    cursor.movePosition(QTextCursor::StartOfBlock);
                    cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
                    cursor.insertText(QString());
                    if (currentTagIndex < 0) {
                        currentTagIndex = __::getItemTagIndex(item_p);
                    }
                }
            }
            arrayTagP.setCurrent(currentTagIndex);
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

/// \author JL
/// \note Outline and bookmark items are interlaced.
/// Each item has both an outline level and a bookmark level.
/// The bookmark level of an outline item is always kMinLevel.
/// The outline level of a boorkmark item is its parent's one or kMinLevel whan at top.
void TeXDockTag::makeNewItem(QTreeWidgetItem * &item_p,
                             QTreeWidget *treeWidget_p,
                             const Tw::Document::Tag *tag_p) const
{
    Q_ASSERT(tag_p);
    int outlineLevel = tag_p->level();
    Q_ASSERT(outlineLevel > __::kMinLevel);
    int bookmarkLevel = __::kMinLevel;
    if (tag_p->isOutline()) {
        while (__::getItemOutlineLevel(item_p) >= outlineLevel || __::getItemBookmarkLevel(item_p) > bookmarkLevel) {
            item_p = item_p->parent();
        }
    } else {
        bookmarkLevel = outlineLevel;
        while (__::getItemBookmarkLevel(item_p) >= bookmarkLevel) {
            item_p = item_p->parent();
        }
        outlineLevel = __::getItemOutlineLevel(item_p);
    }
    if (item_p) {
        bool bigStep = __::getItemOutlineLevel(item_p) + 1 < outlineLevel;
        item_p = new QTreeWidgetItem(item_p, QTreeWidgetItem::UserType);
//TODO: Next does not work on OSX Ventura.
        if (bigStep) {
            QFont font(item_p->font(1));
            font.setBold(true);
            QBrush b(Qt::red);
            item_p->setForeground(0, b);
            item_p->setFont(0, font);
        }
    } else {
        item_p = new QTreeWidgetItem(treeWidget_p, QTreeWidgetItem::UserType);
    }
    __::setItemOutlineLevel(item_p, outlineLevel);
    __::setItemBookmarkLevel(item_p, bookmarkLevel);
    item_p->setText(0, tag_p->text());
    if (tag_p->isOutline()) {
        item_p->setIcon(1, Tw::Icon::Outline());
    } else if (tag_p->isTODO()) {
        item_p->setIcon(1, Tw::Icon::TODO());
    } else if (tag_p->isMARK()) {
        item_p->setIcon(1, Tw::Icon::MARK());
    }
    auto tip = tag_p->tooltip();
    if (!tip.isEmpty()) {
        item_p->setToolTip(0, tip);
        item_p->setToolTip(1, tip);
    }
}

//MARK: Bookmarks

/// \author JL
TeXDockBookmark::TeXDockBookmark(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Bookmarks"), win)
{
    setObjectName(Tw::Name::Bookmarks);
    connect(&(getArrayTagP()), &Tw::Document::ArrayTagP::changed, this, &TeXDockBookmark::onListTagPChanged);
    initUI();
}

Tw::Document::ArrayTagP &TeXDockBookmark::getArrayTagP() const
{
    Q_ASSERT(_window_p);
    return _window_p->textDoc()->getArrayBookmarkP();
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
    Q_ASSERT(_window_p);
    Super::initUI();
    auto *treeWidget_p = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget_p);
    treeWidget_p->setColumnCount(2);
    treeWidget_p->header()->setStretchLastSection(false);
    treeWidget_p->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget_p->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget_p->header()->resizeSection(1, 24);
    auto *toolbarWidget_p = findChild<QWidget*>(Tw::ObjectName::toolbar);
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
            auto cursor = _window_p->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            _window_p->editor()->setTextCursor(cursor);
            _window_p->editor()->setFocus();
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
            Tw::Document::ArrayTagP &arrayTagP = getArrayTagP();
            for (auto *item_p: treeWidget_p->selectedItems()) {
                auto const *tag_p = __::getItemTag_p(item_p);
                if (tag_p) {
                    QTextCursor cursor = tag_p->cursor();
                    cursor.insertText(QString());
                }
            }
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

void TeXDockBookmark::makeNewItem(QTreeWidgetItem * &item_p,
                                  QTreeWidget *treeWidget_p,
                                  const Tw::Document::Tag *tag_p) const
{
    Q_ASSERT(tag_p);
    const int level = tag_p->level();
    while (item_p && __::getItemLevel(item_p) >= level)
        item_p = item_p->parent();
    if (item_p) {
        item_p = new QTreeWidgetItem(item_p, QTreeWidgetItem::UserType);
    } else {
        item_p = new QTreeWidgetItem(treeWidget_p, QTreeWidgetItem::UserType);
    }
    __::setItemLevel(item_p, level);
    __::setItemBookmarkLevel(item_p, level);
    __::setItemOutlineLevel(item_p, __::kMinLevel);
    item_p->setText(0, tag_p->text());
    auto tip = tag_p->tooltip();
    if (!tip.isEmpty()) {
        item_p->setToolTip(0, tip);
        item_p->setToolTip(1, tip);
    }
    if (tag_p->isTODO()) {
        item_p->setIcon(1, Tw::Icon::TODO());
    } else if (tag_p->isMARK()) {
        item_p->setIcon(1, Tw::Icon::MARK());
    }
}
//MARK: TeXDockTreeWidgetStyle
//// See https://stackoverflow.com/questions/7596584/qtreeview-draw-drop-indicator
class TeXDockTreeWidgetStyle: public QProxyStyle
{
    using Super = QProxyStyle;
    
public:
    TeXDockTreeWidgetStyle(QStyle *style = nullptr);

    void drawPrimitive(PrimitiveElement element,
                       const QStyleOption *option,
                       QPainter *painter,
                       const QWidget *widget = nullptr ) const;
};

TeXDockTreeWidgetStyle::TeXDockTreeWidgetStyle(QStyle *style)
     :QProxyStyle(style)
{}
//TODO: draw a thicker indicator
void TeXDockTreeWidgetStyle::drawPrimitive(QStyle::PrimitiveElement element,
                                           const QStyleOption *option_p,
                                           QPainter *painter_p,
                                           const QWidget *widget_p) const
{
    if (element == QStyle::PE_IndicatorItemViewItemDrop
            && !option_p->rect.isNull()) {
        if (option_p->rect.height() == 0) {
            QStyleOption option(*option_p);
            option.rect.setLeft(0);
            if (widget_p) option.rect.setRight(widget_p->width());
            QProxyStyle::drawPrimitive(element, &option, painter_p, widget_p);
        }
        return;
    }
    Super::drawPrimitive(element, option_p, painter_p, widget_p);
}


//MARK: TeXDockOutline
/// \author JL
TeXDockOutline::TeXDockOutline(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Outline"), win)
{
    setObjectName(Tw::Name::Outlines);
    connect(&(getArrayTagP()), &Tw::Document::ArrayTagP::changed, this, &TeXDockOutline::onListTagPChanged);
    initUI();
}

TeXDockTreeWidget *TeXDockOutline::newTreeWidget(QWidget *parent_p)
{
    auto *treeWidget_p = new TeXDockOutlineWidget(parent_p);
    treeWidget_p->setDragEnabled(true);
    treeWidget_p->viewport()->setAcceptDrops(true);
    treeWidget_p->setDropIndicatorShown(true);
    treeWidget_p->setDragDropMode(QAbstractItemView::InternalMove);
    treeWidget_p->setSelectionMode(QAbstractItemView::ContiguousSelection);
    QStyle *oldStyle = treeWidget_p->style();
    QObject *oldOwner = oldStyle ? oldStyle->parent() : nullptr;
    QStyle *newStyle = new TeXDockTreeWidgetStyle(oldStyle);
    // oldStyle is now owned by newStyle
    newStyle->setParent(oldOwner ? oldOwner : this);
    // newStyle has an owner now
    treeWidget_p->setStyle(newStyle);
    return treeWidget_p;
}

Tw::Document::ArrayTagP &TeXDockOutline::getArrayTagP() const
{
    Q_ASSERT(_window_p);
    return _window_p->textDoc()->getArrayOutlineP();
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

void TeXDockOutline::makeNewItem(QTreeWidgetItem * &item_p,
                                 QTreeWidget *treeWidget_p,
                                 const Tw::Document::Tag *tag_p) const
{
    Q_ASSERT(tag_p);
    Super::makeNewItem(item_p, treeWidget_p, tag_p);
    item_p->setFlags(Qt::ItemIsSelectable|Qt::ItemIsEnabled|Qt::ItemIsDragEnabled);
    __::setItemBookmarkLevel(item_p, __::kMinLevel);
    __::setItemOutlineLevel(item_p, __::getItemLevel(item_p));
    if (item_p->parent()) {
        item_p->parent()->setFlags(Qt::ItemIsSelectable|Qt::ItemIsEnabled|Qt::ItemIsDragEnabled|Qt::ItemIsDropEnabled);
    }
}
//MARK: TeXDockOutlineWidget
// \note We assume contiguous selections only.
// We assume that tag cursor position points to the start of a line,
// which does not break a grapheme.
void TeXDockOutlineWidget::dropEvent(QDropEvent *event_p)
{
    QTextCursor fromCursor, toCursor;
    bool insertEOL = false;
    // we start by the drop location setting up toCursor
    auto index = indexAt(event_p->pos());
    if (!index.isValid()) {  // just in case
theBeach:
        event_p->setDropAction(Qt::IgnoreAction);
        Super::dropEvent(event_p);
        return;
    }
    QTreeWidgetItem *item_p = itemFromIndex(index);
    if (!item_p) {
        goto theBeach;
    }
    const auto *tag_p = __::getItemTag_p(item_p);
    if (!tag_p || !tag_p->isOutline()) {
        goto theBeach;
    }
    // Ready to setup toCursor
    toCursor = tag_p->cursor();
    {
        QRect R = visualItemRect(item_p);
        if (event_p->pos().y() > R.center().y()) {
            if ((item_p = itemBelow(item_p))) {
                if (!(tag_p = __::getItemTag_p(item_p))) {
                    goto theBeach;
                }
                toCursor.setPosition(tag_p->selectionStart());
            } else {
                toCursor.movePosition(QTextCursor::End);
                toCursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
                insertEOL = toCursor.position() < toCursor.anchor();
                toCursor.movePosition(QTextCursor::End);
            }
        } else {
            // ensure position == anchor
            toCursor.setPosition(tag_p->selectionStart());
        }
    }
    // Setting the fromCursor:
    tag_p = nullptr;
    
    QList<QTreeWidgetItem *> list = selectedItems();
    if (list.isEmpty()) {
        goto theBeach;
    }
    item_p = list.takeFirst();
    tag_p = __::getItemTag_p(item_p);
    if (!tag_p || !tag_p->isOutline()) {
        goto theBeach;
    }
    fromCursor = tag_p->cursor();
    fromCursor.setPosition(fromCursor.position());
    if (list.isEmpty()) {
        
    } else {
        auto *last_p = list.last();
        tag_p = __::getItemTag_p(last_p);
        if (!tag_p || !tag_p->isOutline()) {
            goto theBeach;
        }
        fromCursor.setPosition(tag_p->selectionStart(), QTextCursor::KeepAnchor);
        QList<QTreeWidgetItem *> list{ invisibleRootItem() };
        while (!list.isEmpty()) {
            item_p = list.takeFirst();
            int i = item_p->childCount();
            while (i--) {
                list.prepend(item_p->child(i));
            }
            if (item_p == last_p) {
                break;
            }
        }
        while (!list.isEmpty()) {
            item_p = list.takeFirst();
        }

        
        auto document_p = static_cast<Tw::Document::TextDocument *>(fromCursor.document());
        auto const &array = document_p->getArrayOutlineP();
        auto it = array.begin();
        

    }

    
    for (const auto index: selectedIndexes()) {
        if (!index.isValid()) {
            goto theBeach;
        }
        auto *fromItem_p = itemFromIndex(index);
        if (!fromItem_p) {
            goto theBeach;
        }
        tag_p = __::getItemTag_p(fromItem_p);
        if (!tag_p || !tag_p->isOutline()) {
            goto theBeach;
        }
        if (fromCursor.isNull()) {
            fromCursor = tag_p->cursor();
            fromCursor.setPosition(fromCursor.position());
        } else {
            fromCursor.setPosition(tag_p->selectionStart(), QTextCursor::KeepAnchor);
        }
    }
    if (!tag_p) {
        goto theBeach;
    }
    
    
    
    
    
    // source cursor
    auto document_p = static_cast<Tw::Document::TextDocument *>(fromCursor.document());
    auto const &oulineArray = document_p->getArrayOutlineP();
    fromCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
    int tagIndex = __::getItemTagIndex(fromItem_p);
    const Tw::Document::Tag *tag_p = nullptr;
    while ((tag_p = oulineArray.get_p(++tagIndex))) {
        if (tag_p->isType(sourceTag_p->type()) && tag_p->level() <= sourceTag_p->level()) {
            fromCursor.setPosition(tag_p->selectionStart(), QTextCursor::KeepAnchor);
            break;
        }
    }
    QTextCursor toCursor(fromCursor);
    toCursor.beginEditBlock();
    
    if (toCursor.position() < fromCursor.anchor() || toCursor > fromCursor ) {
        toCursor.insertText(fromCursor.selectedText());
        fromCursor.removeSelectedText();
        toCursor.endEditBlock();
        Super::dropEvent(event_p);
        return;
    } else {
        toCursor.endEditBlock();
        goto theBeach;
    }
}

