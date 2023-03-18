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
#include "Settings.h"

namespace Tw {

namespace Key {

const QString Editor::highlightCurrentLine =  QStringLiteral("highlightCurrentLine");
const QString Editor::cursorWidth          =  QStringLiteral("cursorWidth");
const QString Editor::lineTimerInterval    =  QStringLiteral("Edit/lineTimerInterval");

} // namespace Key

} // namespace Tw

/// \author JL
Tw::Settings::Settings()
{
    registerEditorDefaults();
}

QMap<QString, QVariant> __defaults;

/// \author JL
void Tw::Settings::registerEditorDefaults()
{
    setValueDefault(Key::Editor::lineTimerInterval, 3000);
}
/// \author JL
void Tw::Settings::restoreEditorDefaults()
{
    Settings settings;
    settings.remove(Key::Editor::lineTimerInterval);
}

/// \author JL
void Tw::Settings::setValueDefault(QString key, QVariant value)
{
    __defaults.insert(key, value);
}

/// \author JL
int Tw::Settings::getInt(const QString & key)
{
    auto ans = value(key);
    if (ans.isNull()) {
        ans = __defaults.value(key);
        Q_ASSERT(!ans.isNull());
    }
    return ans.toInt();
}
/// \author JL
int Tw::Settings::getInt(const QString & key, int defaultValue)
{
    auto ans = value(key);
    return ans.isNull() ? defaultValue : ans.toInt();
}

/// \author JL
Tw::SettingsObserver *Tw::SettingsObserver::instance() {
    static Tw::SettingsObserver * ans = nullptr;
    if (!ans) {
        ans = new Tw::SettingsObserver();
    }
    return ans;
}

/// \author JL
Tw::RWSettings::~RWSettings()
{
    emit Tw::SettingsObserver::instance()->settingsChanged();
}
