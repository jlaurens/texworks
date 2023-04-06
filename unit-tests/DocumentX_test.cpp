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

#include "../modules/QtPDF/src/PDFBackend.h"
#include "TWSynchronizer.h"
#include "TeXHighlighter.h"
#include "document/Document.h"
#include "document/TWSpellChecker.h"
#include "document/TeXDocument.h"
#include "document/TextDocument.h"
#include "utils/ResourcesLibrary.h"

#include <QSignalSpy>
#include <limits>

#if WITH_POPPLERQT
#if POPPLER_HAS_RUNTIME_VERSION
#include <poppler-version.h>
#else
#include <poppler-config.h>
#endif
#endif

Q_DECLARE_METATYPE(QSharedPointer<TWSyncTeXSynchronizer>)
Q_DECLARE_METATYPE(TWSynchronizer::TeXSyncPoint)
Q_DECLARE_METATYPE(TWSynchronizer::PDFSyncPoint)
Q_DECLARE_METATYPE(TWSynchronizer::Resolution)

void NonblockingSyntaxHighlighter::setTextDocument(QTextDocument * doc) { Q_UNUSED(doc) }
void NonblockingSyntaxHighlighter::rehighlight() { }
void NonblockingSyntaxHighlighter::rehighlightBlock(const QTextBlock & block) { Q_UNUSED(block) }
void NonblockingSyntaxHighlighter::maybeRehighlightText(int position, int charsRemoved, int charsAdded) { Q_UNUSED(position) Q_UNUSED(charsRemoved) Q_UNUSED(charsAdded) }
void NonblockingSyntaxHighlighter::process() { }
void NonblockingSyntaxHighlighter::processWhenIdle() {}
TeXHighlighter::TeXHighlighter(Tw::Document::TeXDocument * parent) : NonblockingSyntaxHighlighter(parent) { }
void TeXHighlighter::highlightBlock(const QString &text) { Q_UNUSED(text) }

char * toString(const TWSyncTeXSynchronizer::TeXSyncPoint & p) {
	return QTest::toString(QStringLiteral("TeXSyncPoint(%0 @ %1, %2 - %3)").arg(p.filename).arg(p.line).arg(p.col).arg(p.col + p.len));
}

char * toString(const TWSyncTeXSynchronizer::PDFSyncPoint & p) {
	QString rectStr;
	QDebug(&rectStr) << qSetRealNumberPrecision(20) << p.rects;
	return QTest::toString(QStringLiteral("PDFSyncPoint(%0 @ %1, %2)").arg(p.filename).arg(p.page).arg(rectStr));
}

#if WITH_POPPLERQT

#if QT_VERSION < QT_VERSION_CHECK(5, 6, 0)
// QVersionNumber was introduced in 5.6.0; for compatibility with older versions
// this class provides a rudimentary implementation if necessary
class VersionNumber {
	QVector<int> m_segments;
public:
	VersionNumber() = default;
	VersionNumber(int maj, int min, int mic) { m_segments << maj << min << mic; }
	static VersionNumber fromString(const QString & string) {
		VersionNumber rv;
		Q_FOREACH(const QString & s, string.split(QChar('.'))) {
			bool ok;
			int i = s.toInt(&ok);
			if (!ok) return {};
			rv.m_segments.append(i);
		}
		return rv;
	}
	static int compare(const VersionNumber & v1, const VersionNumber & v2) {
		for (int i = 0; i < qMax(v1.m_segments.size(), v2.m_segments.size()); ++i) {
			int a = (i < v1.m_segments.size() ? v1.m_segments[i] : 0);
			int b = (i < v2.m_segments.size() ? v2.m_segments[i] : 0);
			if (a < b)
				return -1;
			else if (a > b)
				return 1;
		}
		return 0;
	}
	bool operator==(const VersionNumber & rhs) const { return compare(*this, rhs) == 0; }
	bool operator!=(const VersionNumber & rhs) const { return compare(*this, rhs) != 0; }
	bool operator<(const VersionNumber & rhs) const { return compare(*this, rhs) < 0; }
	bool operator<=(const VersionNumber & rhs) const { return compare(*this, rhs) <= 0; }
	bool operator>(const VersionNumber & rhs) const { return compare(*this, rhs) > 0; }
	bool operator>=(const VersionNumber & rhs) const { return compare(*this, rhs) >= 0; }
};
#else
using VersionNumber = QVersionNumber;
#endif

VersionNumber popplerBuildVersion() {
	return VersionNumber::fromString(POPPLER_VERSION);
}

VersionNumber popplerRuntimeVersion() {
#if POPPLER_HAS_RUNTIME_VERSION
	return {static_cast<int>(Poppler::Version::major()), static_cast<int>(Poppler::Version::minor()), static_cast<int>(Poppler::Version::micro())};
#else
	return popplerBuildVersion();
#endif
}
#endif // WITH_POPPLERQT

namespace Tw {
namespace Document {
namespace UnitTest {

void SpellCheckerTest::SpellChecker_getDictionaryList()
{
    auto * sc = Tw::Document::SpellChecker::instance();
    Q_ASSERT(sc != nullptr);
#if QT_VERSION < QT_VERSION_CHECK(5, 4, 0)
    QSignalSpy spy(sc, SIGNAL(dictionaryListChanged()));
#else
    QSignalSpy spy(sc, &SpellChecker::dictionaryListChanged);
#endif

    QVERIFY(spy.isValid());

    QCOMPARE(spy.count(), 0);

    auto dictList = sc->getDictionaryList();
    Q_ASSERT(dictList);
    
    qDebug() << "TESTING dictList content";

    auto i = dictList->begin();
    while (i != dictList->end()) {
        qDebug() << i.key() << ": " << i.value();
        ++i;
    }
    
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

void SpellCheckerTest::SpellChecker_getDictionary()
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

void SpellCheckerTest::SpellChecker_ignoreWord()
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
