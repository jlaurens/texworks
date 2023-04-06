/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019-2020  Stefan Löffler

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

#include "document/TWSpellChecker.h"

#include "TWUtils.h" // for TWUtils::getLibraryPath
#include "utils/ResourcesLibrary.h"

#include <hunspell.h>

#include <QDebug>

namespace Tw {
namespace Document {

namespace __ {
static QMultiHash<QString, QString> * dictionaryList = nullptr;
static QHash<const QString, SpellChecker::Dictionary*> * dictionaries = nullptr;
}

SpellChecker * SpellChecker::instance_m = new SpellChecker();

// static
SpellChecker::DictionaryList * SpellChecker::getDictionaryList(const bool forceReload /* = false */)
{
	if (__::dictionaryList) {
		if (!forceReload)
			return __::dictionaryList;
        delete __::dictionaryList;
	}
    __::dictionaryList = new DictionaryList();
	const QStringList dirs = Tw::Utils::ResourcesLibrary::getLibraryPaths(QStringLiteral("dictionaries"));
	foreach (QDir dicDir, dirs) {
		foreach (QFileInfo dicFileInfo, dicDir.entryInfoList(QStringList(QStringLiteral("*.dic")),
					QDir::Files | QDir::Readable, QDir::Name | QDir::IgnoreCase)) {
			QFileInfo affFileInfo(dicFileInfo.dir(), dicFileInfo.completeBaseName() + QStringLiteral(".aff"));
            if (affFileInfo.isReadable()) {
                __::dictionaryList->insert(dicFileInfo.canonicalFilePath(), dicFileInfo.completeBaseName());
            }
		}
	}

	emit instance()->dictionaryListChanged();
	return __::dictionaryList;
}

// static
SpellChecker::Dictionary * SpellChecker::getDictionary(const QString& language)
{
	if (language.isEmpty())
		return nullptr;

	if (!__::dictionaries)
        __::dictionaries = new QHash<const QString, Dictionary*>;

	if (__::dictionaries->contains(language))
		return __::dictionaries->value(language);

	const QStringList dirs = Tw::Utils::ResourcesLibrary::getLibraryPaths(QStringLiteral("dictionaries"));
	foreach (QDir dicDir, dirs) {
		QFileInfo affFile(dicDir, language + QStringLiteral(".aff"));
		QFileInfo dicFile(dicDir, language + QStringLiteral(".dic"));
		if (affFile.isReadable() && dicFile.isReadable()) {
			Hunhandle * h = Hunspell_create(affFile.canonicalFilePath().toLocal8Bit().data(),
								dicFile.canonicalFilePath().toLocal8Bit().data());
            __::dictionaries->insert(language, new Dictionary(language, h));
			return __::dictionaries->value(language);
		}
	}
	return nullptr;
}

// static
void SpellChecker::clearDictionaries()
{
	if (!__::dictionaries)
		return;

	foreach(Dictionary * d, *__::dictionaries)
		delete d;

	delete __::dictionaries;
    __::dictionaries = nullptr;
}
//MARK: SpellChecker::Dictionary
SpellChecker::Dictionary::Dictionary(const QString & language, Hunhandle * hunhandle)
	: language_m(language)
	, hunhandle_m(hunhandle)
	, codec_m(nullptr)
{
	if (hunhandle_m)
		codec_m = QTextCodec::codecForName(Hunspell_get_dic_encoding(hunhandle_m));
	if (!codec_m)
		codec_m = QTextCodec::codecForLocale(); // almost certainly wrong, if we couldn't find the actual name!
}

SpellChecker::Dictionary::~Dictionary()
{
	if (hunhandle_m)
		Hunspell_destroy(hunhandle_m);
}

bool SpellChecker::Dictionary::isWordCorrect(const QString & word) const
{
	return (Hunspell_spell(hunhandle_m, codec_m->fromUnicode(word).data()) != 0);
}

QList<QString> SpellChecker::Dictionary::suggestionsForWord(const QString & word) const
{
	QList<QString> suggestions;
	char ** suggestionList{nullptr};

	int numSuggestions = Hunspell_suggest(hunhandle_m, &suggestionList, codec_m->fromUnicode(word).data());
	suggestions.reserve(numSuggestions);
	for (int iSuggestion = 0; iSuggestion < numSuggestions; ++iSuggestion)
		suggestions.append(codec_m->toUnicode(suggestionList[iSuggestion]));

	Hunspell_free_list(hunhandle_m, &suggestionList, numSuggestions);

	return suggestions;
}

void SpellChecker::Dictionary::ignoreWord(const QString & word)
{
	// note that this is not persistent after quitting TW
	Hunspell_add(hunhandle_m, codec_m->fromUnicode(word).data());
}

} // namespace Document
} // namespace Tw
