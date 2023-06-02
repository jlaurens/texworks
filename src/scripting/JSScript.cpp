/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2019  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

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

#include "scripting/JSScript.h"

#include <TwxSettings.h>
using Settings = Twx::Core::Settings;

#include <QScriptEngine>
#include <QScriptEngineDebugger>
#include <QScriptValue>
#include <QTextStream>

namespace Tw {
namespace Scripting {

static
QVariant convertValue(const QScriptValue& value)
{
	if (value.isArray()) {
		QVariantList lst;
		quint32 len = value.property(QString::fromLatin1("length")).toUInt32();
		for (quint32 i = 0; i < len; ++i) {
			QScriptValue p = value.property(i);
			lst.append(convertValue(p));
		}
		return lst;
	}
	return value.toVariant();
}

bool JSScript::execute(ScriptAPIInterface * tw) const
{
	QFile scriptFile(m_Filename);
	if (!scriptFile.open(QIODevice::ReadOnly)) {
		// handle error
		return false;
	}
	QTextStream stream(&scriptFile);
	stream.setCodec(m_Codec);
	QString contents = stream.readAll();
	scriptFile.close();

	QScriptEngine engine;
	QScriptValue twObject = engine.newQObject(tw->self());
	engine.globalObject().setProperty(QString::fromLatin1("TW"), twObject);

	QScriptValue val;

	Settings settings;
	if (settings.value(QString::fromLatin1("scriptDebugger"), false).toBool()) {
		QScriptEngineDebugger debugger;
		debugger.attachTo(&engine);
		val = engine.evaluate(contents, m_Filename);
	}
	else {
		val = engine.evaluate(contents, m_Filename);
	}

	if (engine.hasUncaughtException()) {
		tw->SetResult(engine.uncaughtException().toString());
		return false;
	}
	if (!val.isUndefined())
		tw->SetResult(convertValue(val));
	return true;
}

} // namespace Scripting
} // namespace Tw
