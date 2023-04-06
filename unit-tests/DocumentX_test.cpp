/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2020-2022  Stefan Löffler

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

#include "DocumentX_test.h"

#include "document/TWSpellChecker.h"
#include "utils/ResourcesLibrary.h"

#include <QSignalSpy>
#include <limits>

namespace Tw {
namespace Utils {

// Referenced in Tw::Document::SpellChecker
const QStringList ResourcesLibrary::getLibraryPaths(const QString & subdir, const bool updateOnDisk) { Q_UNUSED(subdir) Q_UNUSED(updateOnDisk) return QStringList(QDir::currentPath()); }

} //namespace Utils

namespace Document {
namespace UnitTest {

void SpellCheckerTest::test_getDictionaryList()
{
    auto * sc = Tw::Document::SpellChecker::instance();
    Q_ASSERT(sc != nullptr);
#if QT_VERSION < QT_VERSION_CHECK(5, 4, 0)
    QSignalSpy spy(sc, SIGNAL(dictionaryListChanged()));
#else
    QSignalSpy spy(sc, &Tw::Document::SpellChecker::dictionaryListChanged);
#endif

    QVERIFY(spy.isValid());

    QCOMPARE(spy.count(), 0);

    auto dictList = sc->getDictionaryList();
    Q_ASSERT(dictList);

    QCOMPARE(spy.count(), 1);
    QVERIFY(dictList->contains(QDir::current().absoluteFilePath(QStringLiteral("dictionary.dic")), QStringLiteral("dictionary")));

    // Calling getDictionaryList() again (without forcing a reload) should give
    // the same data again
    QCOMPARE(sc->getDictionaryList(), dictList);
    QCOMPARE(spy.count(), 1);

    // Calling getDictionaryList() with forceReload should emit the
    // dictionaryListChanged signal again
    sc->getDictionaryList(true);
    QCOMPARE(spy.count(), 2);
}

void SpellCheckerTest::test_getDictionary()
{
    QString lang{QStringLiteral("dictionary")};
    QString correctWord{QStringLiteral("World")};
    QString wrongWord{QStringLiteral("Wrld")};

    auto * sc = Tw::Document::SpellChecker::instance();
    Q_ASSERT(sc != nullptr);

    QVERIFY(sc->getDictionary(QString()) == nullptr);
    QVERIFY(sc->getDictionary(QStringLiteral("does-not-exist")) == nullptr);

    auto * d = sc->getDictionary(lang);
    QVERIFY(d != nullptr);
    QCOMPARE(sc->getDictionary(lang), d);

    QCOMPARE(d->getLanguage(), lang);
    QCOMPARE(d->isWordCorrect(correctWord), true);
    QCOMPARE(d->isWordCorrect(wrongWord), false);

    QCOMPARE(d->suggestionsForWord(wrongWord), QList<QString>{correctWord});
}

void SpellCheckerTest::test_ignoreWord()
{
    QString lang{QStringLiteral("dictionary")};
    QString wrongWord{QStringLiteral("Wrld")};

    auto * sc = Tw::Document::SpellChecker::instance();
    Q_ASSERT(sc != nullptr);
    {
        auto * d = sc->getDictionary(lang);
        Q_ASSERT(d != nullptr);
        
        QCOMPARE(d->isWordCorrect(wrongWord), false);
        d->ignoreWord(wrongWord);
        QCOMPARE(d->isWordCorrect(wrongWord), true);
    }
    {
        // Check that ignoring is not persistent
        sc->clearDictionaries();

        auto * d = sc->getDictionary(lang);
        Q_ASSERT(d != nullptr);

        QCOMPARE(d->isWordCorrect(wrongWord), false);
    }
}

} // namespace UnitTest
} // namespace Document
} // namespace Tw

#if defined(STATIC_QT5) && defined(Q_OS_WIN)
  Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin)
#endif

QTEST_MAIN(Tw::Document::UnitTest::SpellCheckerTest)
