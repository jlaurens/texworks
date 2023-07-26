/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2018-2023  Jonathan Kew, Stefan Löffler, Jérôme Laurens

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

#include "TwxEngine.h"

#include "TwxConst.h"
#include "TwxLocate.h"
using Locate = Twx::Core::Locate;

#include <QDir>
#include <QJsonArray>
#include <QSettings>

namespace Twx {

namespace Key {
	const QString Engine 		= QStringLiteral("Engine");
	const QString name 			= QStringLiteral("name");
	const QString program		= QStringLiteral("program");
	const QString arguments	= QStringLiteral("arguments");
	const QString showPdf		= QStringLiteral("showPdf");
}

namespace Typeset {

const QString Engine::factoryEngineName = QStringLiteral("pdfLaTeX");

Engine::Engine(
	const QString & name,
	const QString & program,
	const QStringList & arguments,
	bool showPdf
): _name(name), _program(program), _arguments(arguments), _showPdf(showPdf)
{
}

Engine::Engine(const Engine & orig)
	: _name(orig._name), _program(orig._program), _arguments(orig._arguments), _showPdf(orig._showPdf)
{
}

Engine & Engine::operator=(const Engine & rhs)
{
	_name = rhs._name;
	_program = rhs._program;
	_arguments = rhs._arguments;
	_showPdf = rhs._showPdf;
	return *this;
}

const QString Engine::name() const
{
	return _name;
}

const QString Engine::program() const
{
	return _program;
}

const QStringList Engine::arguments() const
{
	return _arguments;
}

bool Engine::showPdf() const
{
	return _showPdf;
}

void Engine::setName(const QString& name)
{
	_name = name;
}

void Engine::setProgram(const QString& program)
{
	_program = program;
#if defined(Q_OS_WIN)
  if (!_program.endsWith(QStringLiteral(".exe"))) {
		_program.append(QStringLiteral(".exe"));
	}
#endif
}

void Engine::setArguments(const QStringList& arguments)
{
	_arguments = arguments;
}

void Engine::setShowPdf(bool showPdf)
{
	_showPdf = showPdf;
}

bool Engine::isValid() const
{
	return !name().isEmpty();
}

bool Engine::hasName(const QString& aName) const
{
	return name().compare(aName, Qt::CaseInsensitive) == 0;
}

bool Engine::isAvailable() const
{
	return !(Locate::absoluteProgramPath(program()).isEmpty());
}

QProcess * Engine::run(const QFileInfo & input, QObject * parent /* = nullptr*/) const
{
	QString exeFilePath = Locate::absoluteProgramPath(program());
	if (exeFilePath.isEmpty())
		return nullptr;

	QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
	QProcess* process = new QProcess(parent);

	QString workingDir = input.canonicalPath();
#if defined(Q_OS_WIN)
	// files in the root directory of the current drive have to be handled specially
	// because QFileInfo::canonicalPath() returns a path without trailing slash
	// (i.e., a bare drive letter)
	if (workingDir.length() == 2&& workingDir.endsWith(QChar::fromLatin1(':')))
		workingDir.append(QChar::fromLatin1('/'));
#endif
	process->setWorkingDirectory(workingDir);

#if !defined(Q_OS_DARWIN) // not supported on OS X yet :(
	// Add a (customized) TEXEDIT environment variable
	env.insert(
		QStringLiteral("TEXEDIT"),
		QStringLiteral("``%1'' --position=%d ``%s''").arg(QCoreApplication::applicationFilePath())
	);
	// MiKTeX apparently uses it's own variable
	env.insert(
		QStringLiteral("MIKTEX_EDITOR"),
		QStringLiteral("``%1'' --position=%l ``%f''").arg(QCoreApplication::applicationFilePath())
	);
#endif

#if defined(Q_OS_DARWIN)
	// On Mac OS X, append the path to the typesetting tool to the PATH
	// environment variable.
	// In recent versions of Mac OS X and Qt, GUI applications (like Tw) get
	// different values for PATH than console applications (because .bashrc etc.
	// don't get parsed). Typesetting tools still run correctly (as they are
	// invoked with a full path), but if they in turn try to run other tools
	// (like epstopdf) without full path, the process will fail.
	// Appending the path to the typesetting tool to PATH acts as a fallback and
	// implicitly assumes that the tool itself and all tools it relies on are in
	// the same (standard) location.
	QStringList envPaths{QFileInfo(exeFilePath).dir().absolutePath()};
	envPaths.append(Locate::listPATH(env));
	env.insert(Key::PATH, envPaths.join(QDir::listSeparator()));
#endif

	QStringList args = arguments();

	// for old MikTeX versions: delete $synctexoption if it causes an error
	static bool checkedForSynctex = false;
	static bool synctexSupported = true;
	if (!checkedForSynctex) {
#if defined(TwxTypeset_TEST)
		QString pdftex = Locate::absoluteProgramPath(QStringLiteral("pdftex_TwxTypeset.program"));
#else
		QString pdftex = Locate::absoluteProgramPath(QStringLiteral("pdftex"));
#endif
		if (!pdftex.isEmpty()) {
			int result = QProcess::execute(pdftex, QStringList() << QStringLiteral("-synctex=1") << QStringLiteral("-version"));
			synctexSupported = (result == 0);
		}
		checkedForSynctex = true;
	}
	if (!synctexSupported)
		args.removeAll(QStringLiteral("$synctexoption"));

	args.replaceInStrings(QStringLiteral("$synctexoption"), QStringLiteral("-synctex=1"));
	args.replaceInStrings(QStringLiteral("$fullname"), input.fileName());
	args.replaceInStrings(QStringLiteral("$basename"), input.completeBaseName());
	args.replaceInStrings(QStringLiteral("$suffix"), input.suffix());
	args.replaceInStrings(QStringLiteral("$directory"), input.absoluteDir().absolutePath());

	process->setEnvironment(env.toStringList());
	process->setProcessChannelMode(QProcess::MergedChannels);

	process->start(exeFilePath, args);

	return process;
}

Engine::Engine(const QSettings & settings)
{
	setName(settings.value(Key::name).toString());
	setProgram(settings.value(Key::program).toString());
  setArguments(settings.value(Key::arguments).toStringList());
	setShowPdf(settings.value(Key::showPdf).toBool());
}

void Engine::save(QSettings & settings) const
{
	settings.setValue(Key::name, name());
	settings.setValue(Key::program, program());
	settings.setValue(Key::arguments, arguments());
	settings.setValue(Key::showPdf, showPdf());
}

Engine::Engine(const QJsonObject & data)
{
	setName(data.value(Key::name).toString());
	setProgram(data.value(Key::program).toString());
	setShowPdf(data.value(Key::showPdf).toBool());
	_arguments.clear();
	for (auto const& value: data.value(Key::arguments).toArray()) {
		_arguments << value.toString();
	}
}

const QJsonObject Engine::toJsonObject() const
{
	QJsonArray arguments;
	for (const auto & argument: _arguments) {
		if (argument.length() > 0) {
			arguments.append(argument);
		}
	}
	return QJsonObject{
		{Key::name, _name},
		{Key::program, _program},
		{Key::arguments, arguments},
		{Key::showPdf, _showPdf},
	};
}

bool Engine::operator<(const Engine& r) const
{
		return std::tie(_name, _program, _arguments, _showPdf)
					< std::tie(r._name, r._program, r._arguments, r._showPdf);
}

bool Engine::operator==(const Engine& r) const
{
		return std::tie(_name, _program, _arguments, _showPdf)
					== std::tie(r._name, r._program, r._arguments, r._showPdf);
}

const Engine::List & Engine::factoryEngineList()
{
	static Engine::List list;
	if (list.empty()) {
		list
//		<< Engine("LaTeXmk", "latexmk" EXE, QStringList("-e") <<
//				  "$pdflatex=q/pdflatex -synctex=1 %O %S/" << "-pdf" << "$fullname", true)
		// << Engine(
		// 	QStringLiteral("LaTeXmk"),
		// 	QStringLiteral("latexmk"),
		// 	QStringList{
		// 		QStringLiteral("-e"),
		// 		QStringLiteral("$pdflatex=q/pdflatex -synctex=1 %O %S/"),
		// 		QStringLiteral("-pdf"),
		// 		QStringLiteral("$fullname")
		// 	},
		// 	true
		// )
		<< Engine(
			QStringLiteral("pdfTeX"),
			QStringLiteral("pdftex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("pdfLaTeX"),
			QStringLiteral("pdflatex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
#if !defined(TwxTypeset_TEST)
// For testing purposes, only keep 3 engines in the list.
		<< Engine(
			QStringLiteral("LuaTeX"),
			QStringLiteral("luatex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("LuaLaTeX"),
			QStringLiteral("lualatex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("XeTeX"),
			QStringLiteral("xetex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("XeLaTeX"),
			QStringLiteral("xelatex"),
			QStringList{
				QStringLiteral("$synctexoption"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("ConTeXt (LuaTeX)"),
			QStringLiteral("context"),
			QStringList{
				QStringLiteral("--synctex"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("ConTeXt (pdfTeX)"),
			QStringLiteral("texexec"),
			QStringList{
				QStringLiteral("--synctex"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("ConTeXt (XeTeX)"),
			QStringLiteral("texexec"),
			QStringList{
				QStringLiteral("--synctex"),
				QStringLiteral("--xtx"),
				QStringLiteral("$fullname")
			},
			true
		)
		<< Engine(
			QStringLiteral("BibTeX"),
			QStringLiteral("bibtex"),
			QStringList{
				QStringLiteral("$basename")
			},
			false
		)
		<< Engine(
			QStringLiteral("Biber"),
			QStringLiteral("biber"),
			QStringList{
				QStringLiteral("$basename")
			},
			false
		)
#endif // !defined(TwxTypeset_TEST)
		<< Engine(
			QStringLiteral("MakeIndex"),
			QStringLiteral("makeindex"),
			QStringList{
				QStringLiteral("$basename")
			},
			false
		);
	}
	return list;
}

} // namespace Typeset
} // namespace Twx
