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
static const Tw::Document::Tag *getItemTag(const QTreeWidgetItem *item) {
    if (item) {
        QVariant v = item->data(0, __::kTagRole);
        if (v.isValid()) {
            return static_cast<const Tw::Document::Tag *>(v.value<const void *>());
        }
    }
    return nullptr;
}
static void setItemTag(QTreeWidgetItem *item, const Tw::Document::Tag *tag) {
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
TeXDock::TeXDock(const QString &title, TeXDocumentWindow * window)
	: QDockWidget(title, window), _window(window), _updated(false)
{
	connect(this, &TeXDock::visibilityChanged, this, &TeXDock::onVisibilityChanged);
}

void TeXDock::onVisibilityChanged(bool visible)
{
	update(visible);
}
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
TeXDockTree::TeXDockTree(const QString &title, TeXDocumentWindow * win)
    : TeXDock(title, win), _dontFollowItemSelection(false)
{
    setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea);
    connect(win->textDoc()->tagBank(), &Tw::Document::TagBank::changed, this, &TeXDockTree::onTagBankChanged);
    _lastScrollValue = 0;
    observeCursorPositionChanged(true);
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
    toolbarWidget->setObjectName(Tw::ObjectName::toolbar);
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
    auto *treeWidget = newTreeWidget(this);
    treeWidget->header()->hide();
    treeWidget->setHorizontalScrollMode(QAbstractItemView::ScrollPerPixel);
    treeWidget->setExpandsOnDoubleClick(false);
    topLayout->addWidget(treeWidget);
    setWidget(topWidget);
}

TeXDockTreeWidget *TeXDockTree::newTreeWidget(QWidget *parent)
{
    return new TeXDockTreeWidget(parent);
}

void TeXDockTree::onTagBankChanged()
{
}

void TeXDockTree::onTagSuiteChanged()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    _lastScrollValue = treeWidget->verticalScrollBar()->value();
    treeWidget->clear();
    update(true);
    
}

void TeXDockTree::observeCursorPositionChanged(bool yorn)
{
    if (yorn) {
        connect(_window->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    } else {
        disconnect(_window->editor(), &QTextEdit::cursorPositionChanged, this, &TeXDockTree::onCursorPositionChanged);
    }
}

void TeXDockTree::itemGainedFocus()
{
    if (_dontFollowItemSelection) return;
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    auto *suite = tagSuite();
    suite->select(false);
    for (const auto &item: treeWidget->selectedItems()) {
        auto *tag = __::getItemTag(item);
        if (tag) {
            auto c = tag->cursor();
            _window->ensureCursorVisible(c);
            suite->select(true, c);
        }
    }
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
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    QTextCursor c(cursor);
    c.movePosition(QTextCursor::StartOfBlock);
    int start = c.selectionStart();
    c.setPosition(cursor.selectionEnd());
    c.movePosition(QTextCursor::EndOfBlock);
    int end = c.selectionEnd();
    int tagIndex = 0;
    auto *suite = tagSuite();
    suite->select(false);
    for (const auto *tag: suite->tags()) {
        int i = tag->selectionStart();
        if (start <= i) {
            if (end <= i)
                break;
            auto *item = getItemAtIndex(tagIndex);
            if (item) {
                _dontFollowItemSelection = dontFollowItemSelection;
                item->setSelected(true);
                suite->select(true, tag->cursor());
                _dontFollowItemSelection = false;
                treeWidget->scrollToItem(item);
            }
        }
        ++tagIndex;
    }
}

void TeXDockTree::onCursorPositionChanged()
{
    if (_window) {
        auto *editor = _window->editor();
        if (editor) {
            selectItemsForCursor(editor->textCursor(), true);
        }
    }
}

void TeXDockTree::makeNewItem(QTreeWidgetItem *item,
                              QTreeWidget *treeWidget,
                              const Tw::Document::Tag *tag) const
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
    if ((! _window || ! isVisible() || _updated) && ! force) return;
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    disconnect(treeWidget, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
    disconnect(treeWidget, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    treeWidget->clear();
    auto *suite = tagSuite();
    if (suite->isEmpty()) {
        updateVoid();
    } else {
        QTreeWidgetItem *item = nullptr;
        int i = 0;
        const Tw::Document::Tag *tag;
        while((tag = suite->get(i))) {
            makeNewItem(item, treeWidget, tag);
            __::setItemTag(item, tag);
            __::setItemTagIndex(item, i);
            treeWidget->expandItem(item);
            item->setSelected(suite->isSelected(tag));
            ++i;
        }
        if (_lastScrollValue > 0) {
            treeWidget->verticalScrollBar()->setValue(_lastScrollValue);
            _lastScrollValue = 0;
        }
        connect(treeWidget, &QTreeWidget::itemSelectionChanged, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget, &QTreeWidget::itemActivated, this, &TeXDockBookmark::itemGainedFocus);
        connect(treeWidget, &QTreeWidget::itemClicked, this, &TeXDockBookmark::itemGainedFocus);
    }
    _updated = true;
}

void TeXDockTree::find(const QString &find)
{
    if (! _window) return;
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    if (! treeWidget) {
        return;
    }
    QList<const Tw::Document::Tag *> next;
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
            anchor = _window->editor()->textCursor().selectionEnd();
        }
    } else {
        anchor = _window->editor()->textCursor().selectionEnd();
    }
    if (find.startsWith(QStringLiteral(":"))) {
        QRegularExpression re(find.mid(1));
        if(re.isValid()) {
            auto *suite = tagSuite();
            for (const auto *tag: suite->tags()) {
                if(tag->selectionStart() >= anchor) {
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
    for (const auto *tag: tagSuite()->tags()) {
        if(tag->cursor().selectionStart() >= anchor) {
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
TeXDockTag::TeXDockTag(TeXDocumentWindow * win)
    : TeXDockTree(TeXDockTree::tr("Tags"), win)
{
    setObjectName(Tw::ObjectName::Tags);
    connect(tagSuite(), &Tw::Document::TagSuite::changed, this, &TeXDockTag::onTagSuiteChanged);
    initUI();
}

Tw::Document::TagSuite *TeXDockTag::tagSuite()
{
    Q_ASSERT(_window);
    return _window->textDoc()->tagBank()->suiteAll();
}

void TeXDockTag::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    if (! treeWidget) {
        return;
    }
    QTreeWidgetItem *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No bookmark"));
    item->setFlags(item->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockTag::initUI()
{
    Q_ASSERT(_window);
    Super::initUI();
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    treeWidget->setColumnCount(2);
    treeWidget->header()->setStretchLastSection(false);
    treeWidget->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget->header()->resizeSection(1, 24);
    auto *toolbarWidget = findChild<QWidget*>(Tw::ObjectName::toolbar);
    Q_ASSERT(toolbarWidget);
//TODO: Edit tags in place
    auto *layout = static_cast<QBoxLayout *>(toolbarWidget->layout());
    if (! layout) return;
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Tw::Icon::list_add());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(Tw::ObjectName::list_add);
        connect(button, &QPushButton::clicked, [=]() {
            auto cursor = _window->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            _window->editor()->setTextCursor(cursor);
            _window->editor()->setFocus();
        });
        layout->insertWidget(0, button);
    }
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Tw::Icon::list_remove());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(Tw::ObjectName::list_remove);
        button->setEnabled(false);
        connect(button, &QPushButton::clicked, [=]() {
            auto items = treeWidget->selectedItems();
            auto *suite = tagSuite();
            suite->select(false);
            for (auto *item: treeWidget->selectedItems()) {
                auto const *tag = __::getItemTag(item);
                if (tag) {
                    QTextCursor cursor = tag->cursor();
                    cursor.movePosition(QTextCursor::StartOfBlock);
                    cursor.movePosition(QTextCursor::NextBlock, QTextCursor::KeepAnchor);
                    cursor.insertText(QString());
                    suite->select(true, cursor);
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
void TeXDockTag::makeNewItem(QTreeWidgetItem *item,
                             QTreeWidget *treeWidget,
                             const Tw::Document::Tag *tag) const
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
        item->setIcon(1, Tw::Icon::Outline());
    } else if (tag->isTODO()) {
        item->setIcon(1, Tw::Icon::TODO());
    } else if (tag->isMARK()) {
        item->setIcon(1, Tw::Icon::MARK());
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
    setObjectName(Tw::ObjectName::Bookmarks);
    connect(tagSuite(), &Tw::Document::TagSuite::changed, this, &TeXDockBookmark::onTagSuiteChanged);
    initUI();
}

Tw::Document::TagSuite *TeXDockBookmark::tagSuite()
{
    Q_ASSERT(_window);
    return _window->textDoc()->tagBank()->suiteBookmark();
}

void TeXDockBookmark::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    if (! treeWidget) {
        return;
    }
    QTreeWidgetItem *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No bookmark"));
    item->setFlags(item->flags() &~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockBookmark::initUI()
{
    Q_ASSERT(_window);
    Super::initUI();
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    Q_ASSERT(treeWidget);
    treeWidget->setColumnCount(2);
    treeWidget->header()->setStretchLastSection(false);
    treeWidget->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    treeWidget->header()->setSectionResizeMode(1, QHeaderView::Fixed);
    treeWidget->header()->resizeSection(1, 24);
    auto *toolbarWidget = findChild<QWidget*>(Tw::ObjectName::toolbar);
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
        button->setIcon(Tw::Icon::list_add());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(Tw::ObjectName::list_add);
        connect(button, &QPushButton::clicked, [=]() {
            auto cursor = _window->editor()->textCursor();
            cursor.movePosition(QTextCursor::StartOfBlock);
            cursor.insertText(QStringLiteral("%:?\n"));
            cursor.movePosition(QTextCursor::PreviousBlock);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter);
            cursor.movePosition(QTextCursor::NextCharacter, QTextCursor::KeepAnchor);
            _window->editor()->setTextCursor(cursor);
            _window->editor()->setFocus();
        });
        layout->insertWidget(0, button);
    }
    {
        auto *button = new QPushButton(QString());
        button->setIcon(Tw::Icon::list_remove());
        button->setStyleSheet(QStringLiteral("QPushButton { border: none; }"));
        button->setObjectName(Tw::ObjectName::list_remove);
        button->setEnabled(false);
        connect(button, &QPushButton::clicked, [=]() {
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

void TeXDockBookmark::makeNewItem(QTreeWidgetItem *item,
                                  QTreeWidget *treeWidget,
                                  const Tw::Document::Tag *tag) const
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
        item->setIcon(1, Tw::Icon::TODO());
    } else if (tag->isMARK()) {
        item->setIcon(1, Tw::Icon::MARK());
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
    setObjectName(Tw::ObjectName::Outlines);
    connect(tagSuite(), &Tw::Document::TagSuite::changed, this, &TeXDockOutline::onTagSuiteChanged);
    initUI();
}

TeXDockTreeWidget *TeXDockOutline::newTreeWidget(QWidget *parent)
{
    auto *treeWidget = new TeXDockOutlineWidget(parent);
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

Tw::Document::TagSuite *TeXDockOutline::tagSuite()
{
    Q_ASSERT(_window);
    return _window->textDoc()->tagBank()->suiteOutline();
}

void TeXDockOutline::updateVoid()
{
    auto *treeWidget = findChild<TeXDockTreeWidget *>();
    if (! treeWidget) {
        return;
    }
    QTreeWidgetItem *item = new QTreeWidgetItem();
    item->setText(0, TeXDockTree::tr("No outline"));
    item->setFlags(item->flags() & ~(Qt::ItemIsEnabled | Qt::ItemIsSelectable));
    treeWidget->addTopLevelItem(item);
}

void TeXDockOutline::makeNewItem(QTreeWidgetItem *item,
                                 QTreeWidget *treeWidget,
                                 const Tw::Document::Tag *tag) const
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

///MARK: TeXDockOutlineWidget
TeXDockOutlineWidget::TeXDockOutlineWidget(QWidget *parent): Super(parent) {}

void TeXDockOutlineWidget::dragEnterEvent(QDragEnterEvent *event)
{
    for (const auto *item: selectedItems()) {
        const auto *tag = __::getItemTag(item);
        if (tag->isBoundary()) { // Logically unreachable due to TeXDockOutline::makeNewItem above
            event->ignore();
            Super::dragEnterEvent(event);
            return;
        }
    }
    Super::dragEnterEvent(event);
}

/// \note We assume contiguous selections only.
/// We assume that tag cursor position points to the start of a line,
/// which does not break a grapheme.
void TeXDockOutlineWidget::dropEvent(QDropEvent *event)
{
    QTextCursor fromCursor, toCursor;
    bool insertEOL = false;
    // we start by the drop location setting up toCursor
    auto index = indexAt(event->pos());
    if (! index.isValid()) {  // just in case
theBeach:
        event->setDropAction(Qt::IgnoreAction);
        Super::dropEvent(event);
        return;
    }
    QTreeWidgetItem *item = itemFromIndex(index);
    if (! item) {
        goto theBeach;
    }
    const auto *tag = __::getItemTag(item);
    Q_ASSERT(tag && tag->isOutline());
    if (! tag || ! tag->isOutline()) {
        goto theBeach; // Unlikely to happen in theory
    }
    // Ready to setup toCursor
    toCursor = tag->cursor();
    {
        QRect R = visualItemRect(item);
        if (event->pos().y() > R.center().y()) {
            if ((item = itemBelow(item))) {
                if (! (tag = __::getItemTag(item))) {
                    goto theBeach;
                }
                toCursor.setPosition(tag->selectionStart());
            } else {
                toCursor.movePosition(QTextCursor::End);
                toCursor.movePosition(QTextCursor::StartOfLine, QTextCursor::KeepAnchor);
                insertEOL = toCursor.position() < toCursor.anchor();
                toCursor.movePosition(QTextCursor::End);
            }
        } else {
            // ensure position == anchor
            toCursor.setPosition(tag->selectionStart());
        }
    }
    // Setting the fromCursor:
    tag = nullptr;
    const auto items = selectedItems();
    if (items.isEmpty()) {
        goto theBeach;
    }
    item = items.first();
    tag = __::getItemTag(item);
    Q_ASSERT(tag && tag->isOutline());
    if (! tag || ! tag->isOutline()) {
        goto theBeach; // Unlikely to happen in theory
    }
    int max_level = tag->level();
    auto *last = items.last();
    auto document = static_cast<Tw::Document::TextDocument *>(fromCursor.document());
    auto tags = document->tagBank()->suiteOutline()->tags();
    int i = tags.indexOf(tag);
    if (item == last) {
        // only one item
        if (Qt::AltModifier & event->keyboardModifiers()) {
            // only move the text material up to the next tag
            if (++i < tags.size()) {
                tag = tags.at(i);
                fromCursor.setPosition(tag->selectionStart(), QTextCursor::KeepAnchor);
            } else {
                fromCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
            }
        } else {
            // only move the text material up to the next boundary or upper outline
            while (++i < tags.size()) {
                tag = tags.at(i);
                fromCursor.setPosition(tag->selectionStart(), QTextCursor::KeepAnchor);
                if (tag->level() <= max_level || tag->isBoundary()) {
                    break;
                }
            }
            if (i == tags.size()) {
                // all forthcoming tags where included: select to the end
                fromCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
            }
        }
    } else {
        tag = __::getItemTag(last);
        Q_ASSERT(tag && tag->isOutline());
        if (! tag || ! tag->isOutline()) {
            goto theBeach; // Unlikely to happen in theory
        }
        i = tags.indexOf(tag);
        Q_ASSERT(i >= 0);
        if (i < 0) {
            goto theBeach; // Unlikely to happen in theory
        }
        if (++i < tags.size()) {
            tag = tags.at(i);
            fromCursor.setPosition(tag->selectionStart(), QTextCursor::KeepAnchor);
        } else {
            fromCursor.movePosition(QTextCursor::End, QTextCursor::KeepAnchor);
        }
    }
    // source cursor
    if (toCursor.position() < fromCursor.anchor() || toCursor > fromCursor) {
        toCursor.beginEditBlock();
        if (insertEOL) {
            toCursor.insertText(QString(QChar::LineFeed));
        }
        toCursor.insertText(fromCursor.selectedText());
        fromCursor.removeSelectedText();
        toCursor.endEditBlock();
        return;
    } else {
        event->ignore();
    }
    Super::dropEvent(event);
}
