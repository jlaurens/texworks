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

#include "document/TWTeXDockTree.h"
#include "document/TWTag.h"
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

namespace Tw {
namespace Document {

/// \note all static material is gathered here
namespace __ {

static int kMinLevel = std::numeric_limits<int>::min();

enum Role {
    kSuiteRole = Qt::UserRole,
    kTagRole,
    kTagIndexRole,
    kLevelRole,
    kBookmarkLevelRole,
    kOutlineLevelRole,
};
static const Tag *getItemTag(const QTreeWidgetItem *item) {
    if (item) {
        QVariant v = item->data(0, __::kTagRole);
        if (v.isValid()) {
            return static_cast<const Tag *>(v.value<const void *>());
        }
    }
    return nullptr; // this happens for void Tag suites.
}
static void setItemTag(QTreeWidgetItem *item, const Tag *tag) {
    if (item) {
        QVariant v = QVariant::fromValue(static_cast<const void*>(tag));
        item->setData(0, __::kTagRole, v);
    }
}
static int getItemTagIndex(const QTreeWidgetItem * item) {
    if (item) {
        QVariant v = item->data(0, __::kTagIndexRole);
        if (v.isValid()) {
            return v.toInt();
        }
    }
    return -1;
}
static void setItemTagIndex(QTreeWidgetItem * item, int tagIndex) {
    if (item) {
        item->setData(0, __::kTagIndexRole, tagIndex);
    }
}
static int getItemLevel(const QTreeWidgetItem * item) {
    if (item) {
        QVariant v = item->data(0, __::kLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemLevel(QTreeWidgetItem * item, const int level) {
    if (item) {
        item->setData(0, __::kLevelRole, level);
        return true;
    }
    return false;
}
static int getItemBookmarkLevel(const QTreeWidgetItem * item) {
    if (item) {
        QVariant v = item->data(0, __::kBookmarkLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemBookmarkLevel(QTreeWidgetItem * item, const int level) {
    if (item) {
        item->setData(0, __::kBookmarkLevelRole, level);
        return true;
    }
    return false;
}
static int getItemOutlineLevel(const QTreeWidgetItem * item) {
    if (item) {
        QVariant v = item->data(0, __::kOutlineLevelRole);
        return v.isValid() ? v.toInt() : __::kMinLevel; // safer with explicit isValid
    }
    return __::kMinLevel;
}
static bool setItemOutlineLevel(QTreeWidgetItem * item, const int level) {
    if (item) {
        item->setData(0, __::kOutlineLevelRole, level);
        return true;
    }
    return false;
}
} // namespace __

//MARK: TeXDockTreeWidget

TeXDockTreeWidget::TeXDockTreeWidget(QWidget *parent)
: QTreeWidget(parent)
{
    setIndentation(10);
}

QSize TeXDockTreeWidget::sizeHint() const
{
    return QSize(180, 300);
}

//MARK: TeXDockTree

/// \author JL
TeXDockTree::TeXDockTree(const QString &title, TeXDocumentWindow * window)
    : Super(title, window)
{
    connect(this,
            &TeXDockTree::visibilityChanged,
            this,
            [=](bool visible) {
        update(visible);
    });
    setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    connect(editor(), &QTextEdit::cursorPositionChanged, this, [=]() {
        selectItemsForCursor(editor()->textCursor(), true);
    });
}

TeXDocumentWindow *TeXDockTree::window()
{
    return static_cast<TeXDocumentWindow *>(parent());
}

QTextEdit *TeXDockTree::editor()
{
    return window()->editor();
}

//MARK: TeXDockTree::Extra[::State]
// People don't need to know what is in there.
struct TeXDockTree::Extra
{
    int lastScrollValue_m = 0;
    struct State
    {
        bool isSelected;
        bool isExpanded;
    };
    using States = QHash<int, State>;
    States states_m;
};

void TeXDockTree::setTagSuite(TagSuite * tagSuite)
{
    if (tagSuite_m) {
        disconnect(tagSuite_m, &TagSuite::willChange, this, nullptr);
        disconnect(tagSuite_m, &TagSuite::didChange,  this, nullptr);
    }
    tagSuite_m = tagSuite;
    if (!tagSuite_m) {
        return;
    }
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    qDebug() << "TeXDockTree::setTagSuite" << treeWidget;
    connect(tagSuite_m, &TagSuite::willChange, this, [=]() {
        qDebug() << "&TagSuite::willChange";
        qDebug() << treeWidget;
        treeWidget->blockSignals(true);
        if (!extra_m) {
            extra_m = new Extra();
            connect(this, &Self::destroyed, this, [=]() { delete extra_m; });
        }
        extra_m->lastScrollValue_m = treeWidget->verticalScrollBar()->value();
        if (tagSuite_m->isEmpty()) {
            treeWidget->clear();
            updateVoid();
        } else {
            // We save the state
            QList<QTreeWidgetItem *> items = { treeWidget->invisibleRootItem() };
            while (! items.isEmpty()) {
                const auto *item = items.takeFirst();
                int i = item->childCount();
                while (i--) {
                    items.prepend(item->child(i));
                }
                const auto *tag = __::getItemTag(item);
                Extra::State state{item->isSelected(), item->childCount() == 0 || item->isExpanded()};
                extra_m->states_m.insert(tag->position(), state);
            }
        }
    });
    connect(tagSuite_m, &TagSuite::didChange, this, [=]() {
        qDebug() << "&TagSuite::didChange";
        qDebug() << treeWidget;
        treeWidget->clear();
        if (tagSuite_m->isEmpty()) {
            updateVoid();
            treeWidget->blockSignals(false);
            return;
        }
        QTreeWidgetItem *item = nullptr;
        int i = 0;
        Extra::State defaultState{false, true};
        const Tag *tag = nullptr;
        while((tag = tagSuite_m->at(i))) {
            makeNewItem(item, treeWidget, tag);
            __::setItemTag(item, tag);
            __::setItemTagIndex(item, i);
            auto state = extra_m->states_m.value(tag->position(), defaultState);
            item->setSelected(state.isSelected);
            if (state.isExpanded) {
                treeWidget->expandItem(item);
            } else {
                treeWidget->collapseItem(item);
            }
            ++i;
        }
        if (extra_m->lastScrollValue_m > 0) {
            treeWidget->verticalScrollBar()->setValue(extra_m->lastScrollValue_m);
        }
        treeWidget->blockSignals(false);
    });
}
/// \note must be called by subclassers.
void TeXDockTree::initUI()
{
    // top level
    QVBoxLayout *topLayout = new QVBoxLayout;
    topLayout->setSpacing(0);
    topLayout->setContentsMargins(0,0,0,0);
    QWidget * topWidget = new QWidget;
    topWidget->setLayout(topLayout);
    // the toolbar
    auto *toolbarWidget = new QWidget;
    toolbarWidget->setObjectName(ObjectName::toolbar);
    auto *toolbarLayout = new QHBoxLayout;
    toolbarLayout->setSpacing(0);
    toolbarLayout->setContentsMargins(0,0,0,0);
    toolbarWidget->setLayout(toolbarLayout);
    auto *comboBox = new QComboBox;
    comboBox->setEditable(true);
    comboBox->setPlaceholderText(tr("Find"));
    comboBox->setInsertPolicy(QComboBox::InsertAtTop);
    connect(comboBox, &QComboBox::currentTextChanged, [=](const QString &text){
        find(text);
    });
    connect(comboBox, QOverload<int>::of(&QComboBox::activated), [=](int index){
        find(comboBox->itemText(index));
    });
    toolbarLayout->addWidget(comboBox, 2);
    topLayout->addWidget(toolbarWidget);
    // the tree
    auto *treeWidget = newTreeWidget();
    treeWidget->header()->hide();
    treeWidget->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
    treeWidget->setExpandsOnDoubleClick(false);
    topLayout->addWidget(treeWidget);
    setWidget(topWidget);
}

TeXDockTreeWidget *TeXDockTree::newTreeWidget()
{
    return new TeXDockTreeWidget(this);
}

QTreeWidgetItem *TeXDockTree::getItemAtIndex(const int tagIndex)
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    QList<QTreeWidgetItem *> items = { treeWidget->invisibleRootItem() };
    while (! items.isEmpty()) {
        QTreeWidgetItem *item = items.takeFirst();
        int i = item->childCount();
        while (i--) {
            items.prepend(item->child(i));
        }
        if (__::getItemTagIndex(item) == tagIndex) {
            return item;
        }
    }
    return nullptr;
}

void TeXDockTree::selectItemsForCursor(const QTextCursor &cursor, bool dontFollowItemSelection)
{
    if (tagSuite_m.empty()) {
        return;
    }
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    treeWidget->blockSignals(dontFollowItemSelection);
    QTextCursor c(cursor);
    c.movePosition(QTextCursor::StartOfBlock);
    int start = c.position();
    c.setPosition(cursor.selectionEnd());
    c.movePosition(QTextCursor::EndOfBlock);
    int end = c.position();
    QList<QTreeWidgetItem *> selectedItems;
    QList<QTreeWidgetItem *> items = { treeWidget->invisibleRootItem() };
    while (! items.isEmpty()) {
        QTreeWidgetItem *item = items.takeFirst();
        int i = item->childCount();
        while (i--) {
            items.prepend(item->child(i));
        }
        const auto *tag = __::getItemTag(item);
        Q_ASSERT(tag);
        i = tag->position();
        if (start <= i) {
            if (end <= i)
                break;
            item->setSelected(true);
            selectedItems<<item;
        }
    }
    // scroll to the item which is closest to the visible rect.
    if (! selectedItems.isEmpty()) {
        auto top = 0;
        auto bottom = treeWidget->viewport()->rect().bottom();
        auto distance = std::numeric_limits<int>::max();
        const QTreeWidgetItem *minItem = nullptr;
        for (const auto *item: selectedItems) {
            auto r = treeWidget->visualItemRect(item);
            int d = std::min(top - r.bottom(), r.top() - bottom);
            if (d < distance) {
                minItem = item;
                distance = d;
            }
        }
        if (minItem) {
            treeWidget->scrollToItem(minItem);
        }
    }
    treeWidget->blockSignals(false);
}

void TeXDockTree::makeNewItem(QTreeWidgetItem *&item,
                              QTreeWidget *treeWidget,
                              const Tag *tag) const
{
    if (! tag) return;
    const int level = tag->level();
    while (item && __::getItemLevel(item) >= level)
        item = item->parent();
    if (item) {
        item = new QTreeWidgetItem(item, QTreeWidgetItem::UserType);
    } else {
        item = new QTreeWidgetItem(treeWidget, QTreeWidgetItem::UserType);
    }
    __::setItemLevel(item, level);
    item->setText(0, tag->text());
    auto tip = tag->tooltip();
    if (! tip.isEmpty()) {
        item->setToolTip(0, tip);
    }
}

void TeXDockTree::update(bool force)
{
    if ((! isVisible() || updated_m) && ! force) return;
    emit tagSuite_m->willChange();
    emit tagSuite_m->didChange();
    updated_m = true;
}

void TeXDockTree::find(const QString &find)
{
    if (tagSuitep.empty()) {
        return;
    }
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    QList<const Tag *> next;
    int anchor = 0;
    auto items = treeWidget->selectedItems();
    if (! items.isEmpty()) {
        QTreeWidgetItem *item = items.first();
        auto *tag = __::getItemTag(item);
        if (tag) {
            QTextCursor c = tag->cursor();
            c.movePosition(QTextCursor::EndOfBlock);
            anchor = c.selectionEnd();
        } else {
            anchor = editor()->textCursor().selectionEnd();
        }
    } else {
        anchor = editor()->textCursor().selectionEnd();
    }
    if (find.startsWith(QStringLiteral(":"))) {
        QRegularExpression re(find.mid(1));
        if(re.isValid()) {
            for (const auto *tag: tagSuite_m->tags()) {
                if(tag->position() >= anchor) {
                    auto m = re.match(tag->text());
                    if (m.hasMatch()) {
                        selectItemsForCursor(tag->cursor(), false);
                        return;
                    }
                } else {
                    next << tag;
                }
            }
            for (const auto *tag: next) {
                auto m = re.match(tag->text());
                if (m.hasMatch()) {
                    selectItemsForCursor(tag->cursor(), false);
                    return;
                }
            }
            return;
        }
    }
    for (const auto *tag: tagSuite_m->tags()) {
        if(tag->position() >= anchor) {
            if (tag->text().contains(find)) {
                selectItemsForCursor(tag->cursor(), false);
                return;
            }
        } else {
            next << tag;
        }
    }
    for (const auto *tag: next) {
        if (tag->text().contains(find)) {
            selectItemsForCursor(tag->cursor(), false);
            return;
        }
    }
}

//MARK: Tags

/// \author JL
TeXDockTag::TeXDockTag(TeXDocumentWindow *window)
: TeXDockTree(TeXDockTree::tr("Tags"), window)
{
    Q_ASSERT(window);
    setObjectName(ObjectName::Tags);
    initUI();
    setTagSuite(window->textDoc()->tagBank()->makeSuite([](const Tag *tag) {
        Q_UNUSED(tag);
        return true;
    }));
}

void TeXDockTag::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    auto *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No bookmark"));
    // This item MUST NOT be selectable
    item->setFlags(item->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockTag::initUI()
{
    Super::initUI();
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    treeWidget->setColumnCount(2);
    treeWidget->header()->setStretchLastSection(false);
    treeWidget->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget->header()->resizeSection(1, 24);
    auto *toolbarWidget = findChild<QWidget*>(ObjectName::toolbar);
    Q_ASSERT(toolbarWidget);
    //TODO: Edit tags in place
    auto *layout = static_cast<QBoxLayout *>(toolbarWidget->layout());
    if (! layout) return;
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Icon::list_add());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(ObjectName::list_add);
        connect(button, &QPushButton::clicked, [=]() {
            auto cursor = editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            editor()->setTextCursor(cursor);
            editor()->setFocus();
        });
        layout->insertWidget(0, button);
    }
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Icon::list_remove());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(ObjectName::list_remove);
        button->setEnabled(false);
        connect(button, &QPushButton::clicked, [=]() {
            if (tagSuite_m.empty()) {
                return;
            }
            auto items = treeWidget->selectedItems();
            for (auto *item: treeWidget->selectedItems()) {
                auto const *tag = __::getItemTag(item);
                if (tag) {
                    QTextCursor cursor = tag->cursor();
                    cursor.movePosition(QTextCursor::StartOfBlock);
                    cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
                    cursor.insertText(QString());
                }
            }
        });
        auto f = [=] () {
            button->setEnabled(treeWidget->selectedItems().count() > 0);
        };
        connect(treeWidget, &QTreeWidget::itemSelectionChanged, f);
        connect(treeWidget, &QTreeWidget::itemActivated,        f);
        connect(treeWidget, &QTreeWidget::itemClicked,          f);
        layout->insertWidget(1, button);
    }
}

/// \author JL
/// \note Outline and bookmark items are interlaced.
/// Each item has both an outline level and a bookmark level.
/// The bookmark level of an outline item is always kMinLevel.
/// The outline level of a boorkmark item is its parent's one or kMinLevel whan at top.
void TeXDockTag::makeNewItem(QTreeWidgetItem *&item,
                             QTreeWidget *treeWidget,
                             const Tag *tag) const
{
    Q_ASSERT(tag);
    int outlineLevel = tag->level();
    Q_ASSERT(outlineLevel > __::kMinLevel);
    int bookmarkLevel = __::kMinLevel;
    if (tag->isOutline()) {
        while (__::getItemOutlineLevel(item) >= outlineLevel || __::getItemBookmarkLevel(item) > bookmarkLevel) {
            item = item->parent();
        }
    } else {
        bookmarkLevel = outlineLevel;
        while (__::getItemBookmarkLevel(item) >= bookmarkLevel) {
            item = item->parent();
        }
        outlineLevel = __::getItemOutlineLevel(item);
    }
    if (item) {
        bool bigStep = __::getItemOutlineLevel(item) + 1 < outlineLevel;
        item = new QTreeWidgetItem(item, QTreeWidgetItem::UserType);
        //TODO: Next does not work on OSX Ventura.
        if (bigStep) {
            QFont font(item->font(1));
            font.setBold(true);
            QBrush b(Qt::red);
            item->setForeground(0, b);
            item->setFont(0, font);
        }
    } else {
        item = new QTreeWidgetItem(treeWidget, QTreeWidgetItem::UserType);
    }
    __::setItemOutlineLevel(item, outlineLevel);
    __::setItemBookmarkLevel(item, bookmarkLevel);
    item->setText(0, tag->text());
    if (tag->isOutline()) {
        item->setIcon(1, Icon::Outline());
    } else if (tag->isTODO()) {
        item->setIcon(1, Icon::TODO());
    } else if (tag->isMARK()) {
        item->setIcon(1, Icon::MARK());
    }
    auto tip = tag->tooltip();
    if (! tip.isEmpty()) {
        item->setToolTip(0, tip);
        item->setToolTip(1, tip);
    }
}

//MARK: Bookmarks

/// \author JL
TeXDockBookmark::TeXDockBookmark(TeXDocumentWindow * window)
: TeXDockTree(TeXDockTree::tr("Bookmarks"), window)
{
    setObjectName(ObjectName::Bookmarks);
    initUI();
    setTagSuite(window->textDoc()->tagBank()->makeSuite([](const Tag *tag) {
        return tag && ! tag->isOutline();
    }));
}

void TeXDockBookmark::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    QTreeWidgetItem *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No bookmark"));
    item->setFlags(item->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockBookmark::initUI()
{
    Super::initUI();
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    treeWidget->setColumnCount(2);
    treeWidget->header()->setStretchLastSection(false);
    treeWidget->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget->header()->resizeSection(1, 24);
    auto *toolbarWidget = findChild<QWidget*>(ObjectName::toolbar);
    Q_ASSERT(toolbarWidget);
    //TODO: Edit tags in place
    /*
     connect(treeWidget, &QTreeWidget::itemDoubleClicked, [=](QTreeWidgetItem * item, int column)
     {
     if (column == 0) {
     treeWidget->editItem(item, column);
     }
     });
     */
    auto *layout = static_cast<QBoxLayout *>(toolbarWidget->layout());
    if (! layout) return;
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Icon::list_add());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(ObjectName::list_add);
        connect(button, &QPushButton::clicked, [=]() {
            auto cursor = editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            editor()->setTextCursor(cursor);
            editor()->setFocus();
        });
        layout->insertWidget(0, button);
    }
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Icon::list_remove());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(ObjectName::list_remove);
        button->setEnabled(false);
        connect(button, &QPushButton::clicked, [=]() {
            if (tagSuite_m.empty()) {
                return;
            }
            auto items = treeWidget->selectedItems();
            for (auto *item: treeWidget->selectedItems()) {
                auto const *tag = __::getItemTag(item);
                if (tag) {
                    QTextCursor cursor = tag->cursor();
                    cursor.insertText(QString());
                }
            }
        });
        auto f = [=] () {
            button->setEnabled(treeWidget->selectedItems().count() > 0);
        };
        connect(treeWidget, &QTreeWidget::itemSelectionChanged, f);
        connect(treeWidget, &QTreeWidget::itemActivated,        f);
        connect(treeWidget, &QTreeWidget::itemClicked,          f);
        layout->insertWidget(1, button);
    }
}

void TeXDockBookmark::makeNewItem(QTreeWidgetItem *&item,
                                  QTreeWidget *treeWidget,
                                  const Tag *tag) const
{
    Q_ASSERT(tag);
    const int level = tag->level();
    while (item && __::getItemLevel(item) >= level)
        item = item->parent();
    if (item) {
        item = new QTreeWidgetItem(item, QTreeWidgetItem::UserType);
    } else {
        item = new QTreeWidgetItem(treeWidget, QTreeWidgetItem::UserType);
    }
    __::setItemLevel(item, level);
    __::setItemBookmarkLevel(item, level);
    __::setItemOutlineLevel(item, __::kMinLevel);
    item->setText(0, tag->text());
    auto tip = tag->tooltip();
    if (! tip.isEmpty()) {
        item->setToolTip(0, tip);
        item->setToolTip(1, tip);
    }
    if (tag->isTODO()) {
        item->setIcon(1, Icon::TODO());
    } else if (tag->isMARK()) {
        item->setIcon(1, Icon::MARK());
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
                       const QWidget *widget = nullptr) const;
};

TeXDockTreeWidgetStyle::TeXDockTreeWidgetStyle(QStyle *style)
:QProxyStyle(style)
{}
//TODO: draw a thicker indicator
void TeXDockTreeWidgetStyle::drawPrimitive(QStyle::PrimitiveElement element,
                                           const QStyleOption *option,
                                           QPainter *painter,
                                           const QWidget *widget) const
{
    if (element == QStyle::PE_IndicatorItemViewItemDrop
        && ! option->rect.isNull()) {
        if (option->rect.height() == 0) {
            QStyleOption theOption(*option);
            theOption.rect.setLeft(0);
            if (widget) theOption.rect.setRight(widget->width());
            QProxyStyle::drawPrimitive(element, &theOption, painter, widget);
        }
        return;
    }
    Super::drawPrimitive(element, option, painter, widget);
}


//MARK: TeXDockOutline
/// \author JL
TeXDockOutline::TeXDockOutline(TeXDocumentWindow * window)
: TeXDockTree(TeXDockTree::tr("Outline"), window)
{
    setObjectName(ObjectName::Outlines);
    initUI();
    setTagSuite(window->textDoc()->tagBank()->makeSuite([](const Tag *tag) {
        return tag && (tag->isOutline() || tag->isBoundary());
    }));
}

TeXDockTreeWidget *TeXDockOutline::newTreeWidget()
{
    auto *treeWidget = new TeXDockOutlineWidget(this);
    Q_ASSERT(treeWidget);
    treeWidget->setDragEnabled(true);
    treeWidget->viewport()->setAcceptDrops(true);
    treeWidget->setDropIndicatorShown(true);
    treeWidget->setDragDropMode(QAbstractItemView::InternalMove);
    treeWidget->setSelectionMode(QAbstractItemView::ContiguousSelection);
    QStyle *oldStyle = treeWidget->style();
    QObject *oldOwner = oldStyle ? oldStyle->parent() : nullptr;
    QStyle *newStyle = new TeXDockTreeWidgetStyle(oldStyle);
    // oldStyle is now owned by newStyle
    newStyle->setParent(oldOwner ? oldOwner : this);
    // newStyle has an owner now
    treeWidget->setStyle(newStyle);
    return treeWidget;
}

void TeXDockOutline::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    QTreeWidgetItem *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No outline"));
    item->setFlags(item->flags() & ~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockOutline::makeNewItem(QTreeWidgetItem *&item,
                                 QTreeWidget *treeWidget,
                                 const Tag *tag) const
{
    Q_ASSERT(tag);
    Super::makeNewItem(item, treeWidget, tag);
    __::setItemBookmarkLevel(item, __::kMinLevel);
    __::setItemOutlineLevel(item, __::getItemLevel(item));
    if (tag->isBoundary()) {
        item->setFlags(Qt::ItemIsSelectable|
                       Qt::ItemIsEnabled);
    } else {
        item->setFlags(Qt::ItemIsSelectable|
                       Qt::ItemIsEnabled|
                       Qt::ItemIsDragEnabled);
        if (item->parent()) {
            item->parent()->setFlags(Qt::ItemIsSelectable|
                                     Qt::ItemIsEnabled|
                                     Qt::ItemIsDragEnabled|
                                     Qt::ItemIsDropEnabled);
        }
    }
}

bool TeXDockOutline::performDrag(const QList<TagX> &tagXs, QTextCursor toCursor)
{
    // first we build a list of cursors corresponding to the multiple text ranges to drag
    bool fromEOL = false;
    QTextCursor cursor;
    QList<QTextCursor> fromCursors;
    int position = 0;
    for (const auto &tagX: tagXs) {
        const auto *tag = tagX.tag;
        int i = tagSuite()->indexOf(tag);
        if (i<0)
            return false;
        cursor = tag->cursor();
        if (cursor.position() < position) {
            cursor.setPosition(position);
        }
        if (tagX.isExpanded) {
            // select up to the next tag when possible
            if ((tag = tagSuite()->at(++i))) {
                cursor.setPosition(tag->position(), QTextCursor::KeepAnchor);
                cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
            } else {
select_tail:
                cursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
                // Does it end with an EOL marker?
                QTextCursor c(cursor);
                c.movePosition(QTextCursor::End);
                int end = c.position();
                c.movePosition(QTextCursor::StartOfBlock);
                fromEOL = (cursor.position() < end);
            }
        } else {
            // select up to a boundary, the the next tag with a lower level or to the end
            int max_level = tag->level();
            while (true) {
                if ((tag = tagSuite()->at(++i))) {
                    if (tag->isBoundary() || tag->level() <= max_level) {
                        cursor.setPosition(tag->position(), QTextCursor::KeepAnchor);
                        cursor.movePosition(QTextCursor::PreviousCharacter, QTextCursor::KeepAnchor);
                        break;
                    }
                } else {
                    goto select_tail;
                }

            }
        }
        if (position < cursor.position()) {
            if (cursor.position() <= toCursor.position() || cursor.anchor() <= toCursor.position()) {
                fromCursors << cursor;
                position = cursor.position();
                // We ensure that the cursor position is always moved to the right of its anchor
            } else {
                // We do not allow to drop inside a selection
                return false;
            }
        }
    }
    // clean cursors
    if (fromCursors.empty()) {
        return false;
    }
    toCursor.beginEditBlock();
    toCursor.movePosition(QTextCursor::StartOfBlock, QTextCursor::KeepAnchor);
    if (toCursor.position() < toCursor.anchor()) {
        // I was at the end
        toCursor.insertText(QString(QChar::LineFeed));
        toCursor.movePosition(QTextCursor::End);
    }
    for (auto fromCursor: fromCursors) {
        toCursor.insertText(fromCursor.selectedText());
        fromCursor.removeSelectedText();
    }
    if (fromEOL) {
        toCursor.insertText(QString(QChar::LineFeed));
    }
    toCursor.endEditBlock();
    return true;
}

///MARK: TeXDockOutlineWidget
TeXDockOutlineWidget::TeXDockOutlineWidget(TeXDockOutline *parent)
    : Super(parent) {}

void TeXDockOutlineWidget::dragEnterEvent(QDragEnterEvent *event)
{
    // If one of the selected items is a boundary, we abort the drag
    if (tagSuite_m.empty()) {
        event->ignore();
    } else {
        for (const auto *item: selectedItems()) {
            const auto *tag = __::getItemTag(item);
            if (tag->isBoundary()) {
                event->ignore();
                break;
            }
        }
    }
    Super::dragEnterEvent(event);
}

void TeXDockOutlineWidget::dropEvent(QDropEvent *event)
{
    if (tagSuite_m.empty()) {
    theBeach:
        event->ignore();
        Super::dropEvent(event);
        return;
    }
    // We share the logic with the parent for better testing
    QTextCursor fromCursor, toCursor;
    // we start by the drop location setting up toCursor
    auto index = indexAt(event->pos());
    if (! index.isValid()) {  // just in case
        goto theBeach;
    }
    QTreeWidgetItem *item = itemFromIndex(index);
    if (! item) {
        goto theBeach;
    }
    const auto *tag = __::getItemTag(item);
    Q_ASSERT(tag);
    if (! tag || ! tag->isOutline()) {
        goto theBeach; // Only for boundary tags
    }
    // Ready to setup toCursor
    toCursor = tag->cursor();
    QRect R = visualItemRect(item);
    if (event->pos().y() > R.center().y()) {
        if ((item = itemBelow(item))) {
            if (! (tag = __::getItemTag(item))) {
                goto theBeach; // Logically unreachable
            }
            toCursor.setPosition(tag->position());
        } else {
            toCursor.movePosition(QTextCursor::End);
        }
    } else {
        // ensure position == anchor
        toCursor.setPosition(tag->position());
    }
    // Setting the fromCursor:
    tag = nullptr;
    QList<TeXDockOutline::TagX> tagXs;
    for (const auto *item: selectedItems()) {
        tag = __::getItemTag(item);
        auto tagX = TeXDockOutline::TagX{tag, item->isExpanded()};
        tagXs << tagX;
    }
    if (tagXs.isEmpty()) {
        goto theBeach;
    }
    auto * treeOutline = static_cast<TeXDockOutline *>(parent());
    if (! treeOutline->performDrag(tagXs, toCursor)) {
        goto theBeach;
    }
    Super::dropEvent(event);
}

} // namespace Document
} // namespace Tw
