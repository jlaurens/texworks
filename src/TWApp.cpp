/*
	This is part of TeXworks, an environment for working with TeX documents
	Copyright (C) 2007-2023  Jonathan Kew, Stefan Löffler, Charlie Sharpsteen

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

#include "TWApp.h"

#include "DefaultPrefs.h"
#include "PDFDocumentWindow.h"
#include "PrefsDialog.h"
#include "ResourcesDialog.h"
#include "TWUtils.h"
#include "TeXDocumentWindow.h"
#include "TemplateDialog.h"
#include "document/SpellChecker.h"
#include "scripting/ScriptAPI.h"
#include "utils/CommandlineParser.h"
#include "utils/SystemCommand.h"
#include "utils/TextCodecs.h"
#include "utils/WindowManager.h"

#include <TwxConst.h>
#include <TwxInfo.h>
#include <TwxSettings.h>
using Settings = Twx::Core::Settings;
#include <TwxLocate.h>
using Locate = Twx::Core::Locate;
#include <TwxSetup.h>
#include <TwxAssets.h>
#include <TwxW3.h>

#include <QAction>
#include <QDesktopServices>
#include <QEvent>
#include <QFileDialog>
#include <QKeyEvent>
#include <QKeySequence>
#include <QLibraryInfo>
#include <QLocale>
#include <QMenu>
#include <QMenuBar>
#include <QMessageBox>
#include <QSettings>
#include <QString>
#include <QStringList>
#include <QTextCodec>
#include <QTranslator>
#include <QUrl>

#if defined(Q_OS_WIN)
#include <windows.h>
#ifndef VER_SUITE_WH_SERVER /* not defined in my mingw system */
#define VER_SUITE_WH_SERVER 0x00008000
#endif
#endif

TWApp * TWApp::theAppInstance = nullptr;

const QEvent::Type TWDocumentOpenEvent::type = static_cast<QEvent::Type>(QEvent::registerEventType());

TWApp::TWApp(int &argc, char **argv)
	: QApplication(argc, argv)
{
	init();
	CommandLineData cld = processCommandLine();
	if (!cld.shouldContinue) {
		return;
	}
	if (!ensureSingleInstance(cld)) {
		return;
	}
	// If a document is opened during the startup of Tw, the QApplication
	// may not be properly initialized yet. Therefore, defer the opening to
	// the event loop.
	for (const auto & fileToOpen : cld.filesToOpen) {
		QCoreApplication::postEvent(this, new TWDocumentOpenEvent(fileToOpen.filename, fileToOpen.position));
	}

	QTimer::singleShot(1, this, &TWApp::launchAction);
}

TWApp::~TWApp()
{
	if (scriptManager) {
		scriptManager->saveDisabledList();
		delete scriptManager;
	}
}

void TWApp::init()
{
	Twx::Core::Info::initApplication(this);

	QIcon appIcon;
	QIcon::setThemeName(QStringLiteral("tango-texworks"));

#if defined(Q_OS_UNIX) && !defined(Q_OS_DARWIN)
	// The Compiz window manager doesn't seem to support icons larger than
	// 128x128, so we add a suitable one first
	appIcon.addFile(Twx::Path::applicationImage128);
#endif
	appIcon.addFile(Twx::Path::applicationImage);
	setWindowIcon(appIcon);

	Twx::Core::Setup::initialize();

	// </Check for portable mode>

	// Required for TWUtils::getLibraryPath()
	theAppInstance = this;

	Settings settings;

	QString locale = settings.value(QString::fromLatin1("locale"), QLocale::system().name()).toString();
	applyTranslation(locale);

	recentFilesLimit = settings.value(QString::fromLatin1("maxRecentFiles"), kDefaultMaxRecentFiles).toInt();

	QString codecName = settings.value(QString::fromLatin1("defaultEncoding"), QString::fromLatin1("UTF-8")).toString();
	defaultCodec = QTextCodec::codecForName(codecName.toLatin1());
	if (!defaultCodec)
		defaultCodec = QTextCodec::codecForName("UTF-8");

	QtPDF::Backend::Document::pageCache().setMaxCost(settings.value(QStringLiteral("pdfPageCacheSizeMiB"), kDefault_PDFPageCacheSizeMiB).toInt() * 1024 * 1024);

	TWUtils::readConfig();

	scriptManager = new TWScriptManager;

#if defined(Q_OS_DARWIN)
	setQuitOnLastWindowClosed(false);
	setAttribute(Qt::AA_DontShowIconsInMenus);

	menuBar = new QMenuBar;

	menuFile = menuBar->addMenu(tr("File"));

	actionNew = new QAction(tr("New"), this);
	actionNew->setIcon(QIcon::fromTheme(QStringLiteral("document-new")));
	menuFile->addAction(actionNew);
	connect(actionNew, &QAction::triggered, this, &TWApp::newFile);

	actionNew_from_Template = new QAction(tr("New from Template..."), this);
	menuFile->addAction(actionNew_from_Template);
	connect(actionNew_from_Template, &QAction::triggered, this, &TWApp::newFromTemplate);

	actionOpen = new QAction(tr("Open..."), this);
	actionOpen->setIcon(QIcon::fromTheme(QStringLiteral("document-open")));
	menuFile->addAction(actionOpen);
	connect(actionOpen, &QAction::triggered, [=]() { this->open(); });

	menuRecent = new QMenu(tr("Open Recent"));
	actionClear_Recent_Files = menuRecent->addAction(tr("Clear Recent Files"));
	actionClear_Recent_Files->setEnabled(false);
	connect(actionClear_Recent_Files, &QAction::triggered, this, &TWApp::clearRecentFiles);
	updateRecentFileActions();
	menuFile->addMenu(menuRecent);

	menuHelp = menuBar->addMenu(tr("Help"));

	homePageAction = new QAction(tr("Go to TeXworks home page"), this);
	menuHelp->addAction(homePageAction);
	connect(homePageAction, &QAction::triggered, this, &TWApp::openUrlHome);
	mailingListAction = new QAction(tr("Email to the mailing list"), this);
	menuHelp->addAction(mailingListAction);
	connect(mailingListAction, &QAction::triggered, this, &TWApp::writeToMailingList);
	QAction* sep = new QAction(this);
	sep->setSeparator(true);
	menuHelp->addAction(sep);

	TWUtils::insertHelpMenuItems(menuHelp);
	recreateSpecialMenuItems();

	connect(this, &TWApp::updatedTranslators, this, &TWApp::changeLanguage);
	changeLanguage();
#endif
}

TWApp::CommandLineData TWApp::processCommandLine()
{
	CommandLineData retVal;
	Tw::Utils::CommandlineParser clp;
	clp.registerSwitch(QString::fromLatin1("help"), tr("Display this message"), QString::fromLatin1("?"));
	clp.registerOption(QString::fromLatin1("position"), tr("Open the following file at the given position (line or page)"), QString::fromLatin1("p"));
	clp.registerSwitch(QString::fromLatin1("version"), tr("Display version information"), QString::fromLatin1("v"));

	if (clp.parse()) {
		int i{-1}, numArgs{0};
		while ((i = clp.getNextArgument()) >= 0) {
			++numArgs;
			int j = clp.getPrevOption(QString::fromLatin1("position"), i);
			int pos = -1;
			if (j >= 0) {
				pos = clp.at(j).value.toInt();
				clp.at(j).processed = true;
			}
			Tw::Utils::CommandlineParser::CommandlineItem & item = clp.at(i);
			item.processed = true;

			retVal.filesToOpen.push_back({item.value.toString(), pos});
		}
		if ((i = clp.getNextSwitch(QString::fromLatin1("version"))) >= 0) {
			if (numArgs == 0) {
				retVal.shouldContinue = false;
				exitLater(0);
			}
			clp.at(i).processed = true;
			QTextStream strm(stdout);
			using Info = Twx::Core::Info;
			strm << "TeXworks " << Info::version << "\n\n";
			strm << QStringLiteral("\
Copyright (C) %1  %2\n\
License GPLv2+: GNU GPL (version 2 or later) <http://gnu.org/licenses/gpl.html>\n\
This is free software: you are free to change and redistribute it.\n\
There is NO WARRANTY, to the extent permitted by law.\n\n").arg(Info::copyrightYears, Info::copyrightHolders);
			strm.flush();
		}
		if ((i = clp.getNextSwitch(QString::fromLatin1("help"))) >= 0) {
			if (numArgs == 0) {
				retVal.shouldContinue = false;
				exitLater(0);
			}
			clp.at(i).processed = true;
			QTextStream strm(stdout);
			clp.printUsage(strm);
		}
	}
	return retVal;
}

bool TWApp::ensureSingleInstance(const CommandLineData &cld)
{
	if (!m_IPC.isFirstInstance()) {
		m_IPC.sendBringToFront();
		for(const CommandLineData::fileToOpenStruct & fileToOpen : cld.filesToOpen) {
			QFileInfo fi(fileToOpen.filename);
			if (!fi.exists())
				continue;
			m_IPC.sendOpenFile(fi.absoluteFilePath(), fileToOpen.position);
		}
		exitLater(0);
		return false;
	}
	QObject::connect(&m_IPC, &Tw::InterProcessCommunicator::receivedBringToFront, this, &TWApp::bringToFront);
	QObject::connect(&m_IPC, &Tw::InterProcessCommunicator::receivedOpenFile, this, &TWApp::openFile);
	return true;
}

void TWApp::exitLater(int retCode)
{
#if QT_VERSION < QT_VERSION_CHECK(5, 4, 0)
	QTimer * t = new QTimer();
	t->setSingleShot(true);
	connect(t, &QTimer::timeout, [&]() { this->exit(retCode); });
	connect(t, &QTimer::timeout, t, &QTimer::deleteLater);
	t->start(0);
#else
	QTimer::singleShot(0, this, [&]() { this->exit(retCode); });
#endif
}

void TWApp::maybeQuit()
{
#if defined(Q_OS_DARWIN)
	setQuitOnLastWindowClosed(true);
#endif
	closeAllWindows();
#if defined(Q_OS_DARWIN)
	setQuitOnLastWindowClosed(false);
	// If maybeQuit() was called from the global menu (i.e., no windows were open),
	// closeAllWindows() has no effect; so we have to check for this condition
	// ourselves and quit Tw if necessary
	bool isAnyWindowStillOpen = false;
	for (QWidget * w : topLevelWidgets()) {
		if (w && w->isWindow() && w->isVisible()) {
			isAnyWindowStillOpen = true;
			break;
		}
	}
	if (!isAnyWindowStillOpen) {
		quit();
	}
#endif
}

#if defined(Q_OS_DARWIN)

void TWApp::recreateSpecialMenuItems()
{
	// This is an attempt to work around QTBUG-17941
	// On macOS, certain special menu items (Quit, Preferences, About) are moved from
	// the menus they are added to to the global system menu.
	// If several menu items with the same role are created (e.g., each window creates
	// a "Quit" item), only one (probably the last) such item is displayed in the
	// system menu.
	// When _any_ of those special actions is deleted (e.g. because their owning window is
	// destroyed) - regardless of whether it was the current/only item with a given role -
	// the corresponding system menu item vanishes.
	// As a workaround, this function can re-create the global menu items to forcefully re-add
	// the system menu items. This function has to be called _after any menu item with
	// a special role has been deleted_ (e.g. by using QTimer::singleShot(0, ...)) and will
	// override _all_ special menu items.

	delete actionQuit;
	actionQuit = menuFile->addAction(tr("Quit TeXworks"));
	actionQuit->setMenuRole(QAction::QuitRole);
	connect(actionQuit, &QAction::triggered, this, &TWApp::maybeQuit);

	delete actionPreferences;
	actionPreferences = menuFile->addAction(tr("Preferences..."));
	actionPreferences->setIcon(QIcon::fromTheme(QStringLiteral("preferences-system")));
	actionPreferences->setMenuRole(QAction::PreferencesRole);
	connect(actionPreferences, &QAction::triggered, this, &TWApp::preferences);

	delete aboutAction;
	aboutAction = menuHelp->addAction(tr("About %1...").arg(applicationName()));
	aboutAction->setMenuRole(QAction::AboutRole);
	connect(aboutAction, &QAction::triggered, this, &TWApp::about);
}

#endif // defined(Q_OS_DARWIN)

void TWApp::changeLanguage()
{
#if defined(Q_OS_DARWIN)
	menuFile->setTitle(tr("File"));
	actionNew->setText(tr("New"));
	actionNew->setShortcut(QKeySequence(tr("Ctrl+N")));
	actionNew_from_Template->setText(tr("New from Template..."));
	actionNew_from_Template->setShortcut(QKeySequence(tr("Ctrl+Shift+N")));
	actionOpen->setText(tr("Open..."));
	actionOpen->setShortcut(QKeySequence(tr("Ctrl+O")));
	actionQuit->setText(tr("Quit TeXworks"));
	actionQuit->setShortcut(QKeySequence(QKeySequence::Quit));

	menuRecent->setTitle(tr("Open Recent"));

	menuHelp->setTitle(tr("Help"));
	aboutAction->setText(tr("About %1...").arg(applicationName()));
	homePageAction->setText(tr("Go to TeXworks home page"));
	mailingListAction->setText(tr("Email to the mailing list"));
	TWUtils::insertHelpMenuItems(menuHelp);
#endif
}

void TWApp::about()
{
	QString aboutText = tr("<p>%1 is a simple environment for editing, typesetting, and previewing TeX documents.</p>").arg(applicationName());
	aboutText += QLatin1String("<small>");
	aboutText += QLatin1String("<p>&#xA9; 2007-2023  Jonathan Kew, Stefan L&#xF6;ffler, Charlie Sharpsteen");
	aboutText += tr("<br>Version %1").arg(Twx::Core::Info::version);
	aboutText += tr("<p>Distributed under the <a href=``http://www.gnu.org/licenses/gpl-2.0.html''>GNU General Public License</a>, version 2 or (at your option) any later version.");
	aboutText += tr("<p><a href=``http://www.qt.io/''>Qt application framework</a> v%1 by The Qt Company.").arg(QString::fromLatin1(qVersion()));
	aboutText += tr("<br><a href=``http://poppler.freedesktop.org/''>Poppler</a> PDF rendering library by Kristian H&#xF8;gsberg, Albert Astals Cid and others.");
	aboutText += tr("<br><a href=``http://hunspell.github.io/''>Hunspell</a> spell checker by L&#xE1;szl&#xF3; N&#xE9;meth.");
	aboutText += tr("<br>Concept and resources from <a href=``https://pages.uoregon.edu/koch/texshop/''>TeXShop</a> by Richard Koch.");
	aboutText += tr("<br><a href=``http://itexmac.sourceforge.net/SyncTeX.html''>SyncTeX</a> technology by J&#xE9;r&#xF4;me Laurens.");
	aboutText += tr("<br>Some icons used are from the <a href=``http://tango.freedesktop.org/''>Tango Desktop Project</a>.");
	QString trText = tr("<p>%1 translation kindly contributed by %2.").arg(tr("[language name]"), tr("[translator's name/email]"));
	if (!trText.contains(QString::fromLatin1("[language name]")))
		aboutText += trText;	// omit this if it hasn't been translated!
	aboutText += QLatin1String("</small>");
	QMessageBox::about(nullptr, tr("About %1").arg(applicationName()), aboutText);
}

void TWApp::openUrlHome()
{
	Twx::W3::openUrlHome();
}

#if defined(Q_OS_WIN)
/* based on MSDN sample code from http://msdn.microsoft.com/en-us/library/ms724429(VS.85).aspx */
typedef void (WINAPI *PGNSI)(LPSYSTEM_INFO);

QString TWApp::GetWindowsVersionString()
{
	OSVERSIONINFOEXA osvi;
	SYSTEM_INFO si;
	PGNSI pGNSI;
	BOOL bOsVersionInfoEx;
	QString result = QLatin1String("(unknown version)");

	memset(&si, 0, sizeof(SYSTEM_INFO));
	memset(&osvi, 0, sizeof(OSVERSIONINFOEXA));

	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEXA);
	if ( !(bOsVersionInfoEx = GetVersionExA (reinterpret_cast<OSVERSIONINFOA *>(&osvi))) )
		return result;

	// Call GetNativeSystemInfo if supported or GetSystemInfo otherwise.
	pGNSI = reinterpret_cast<PGNSI>(GetProcAddress(GetModuleHandle(TEXT("kernel32.dll")), "GetNativeSystemInfo"));
	if (pGNSI)
		pGNSI(&si);
	else
		GetSystemInfo(&si);

	// See https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-osversioninfoexa
	// and https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
	if ( VER_PLATFORM_WIN32_NT == osvi.dwPlatformId && osvi.dwMajorVersion > 4 ) {
		if ( osvi.dwMajorVersion == 10 ) {
			if ( osvi.dwMinorVersion == 0 ) {
				if ( osvi.wProductType == VER_NT_WORKSTATION ) {
					if (osvi.dwBuildNumber >= 22000)
						result = QLatin1String("11");
					else
						result = QLatin1String("10");
				}
				else {
					if (osvi.dwBuildNumber >= 20348)
						result = QLatin1String("Server 2022");
					else if (osvi.dwBuildNumber >= 17763)
						result = QLatin1String("Server 2019");
					else
						result = QLatin1String("Server 2016");
				}
			}
		}
		else if ( osvi.dwMajorVersion == 6 ) {
			if ( osvi.dwMinorVersion == 0 ) {
				if ( osvi.wProductType == VER_NT_WORKSTATION )
					result = QLatin1String("Vista");
				else
					result = QLatin1String("Server 2008");
			}
			else if ( osvi.dwMinorVersion == 1 ) {
				if( osvi.wProductType == VER_NT_WORKSTATION )
					result = QLatin1String("7");
				else
					result = QLatin1String("Server 2008 R2");
			}
			else if ( osvi.dwMinorVersion == 2 ) {
				if( osvi.wProductType == VER_NT_WORKSTATION )
					result = QLatin1String("8");
				else
					result = QLatin1String("Server 2012");
			}
			else if ( osvi.dwMinorVersion == 3 ) {
				if( osvi.wProductType == VER_NT_WORKSTATION )
					result = QLatin1String("8.1");
				else
					result = QLatin1String("Server 2012 R2");
			}
		}
		else if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2 ) {
			if ( GetSystemMetrics(SM_SERVERR2) )
				result = QLatin1String("Server 2003 R2");
			else if ( osvi.wSuiteMask & VER_SUITE_STORAGE_SERVER )
				result = QLatin1String("Storage Server 2003");
			else if ( osvi.wSuiteMask & VER_SUITE_WH_SERVER )
				result = QLatin1String("Home Server");
			else if ( osvi.wProductType == VER_NT_WORKSTATION &&
					si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_AMD64)
				result = QLatin1String("XP Professional x64 Edition");
			else
				result = QLatin1String("Server 2003");
		}
		else if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1 ) {
			result = QLatin1String("XP ");
			if ( osvi.wSuiteMask & VER_SUITE_PERSONAL )
				result += QLatin1String("Home Edition");
			else
				result += QLatin1String("Professional");
		}
		else if ( osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0 ) {
			result = QLatin1String("2000 ");

			if ( osvi.wProductType == VER_NT_WORKSTATION ) {
				result += QLatin1String("Professional");
			}
			else {
				if ( osvi.wSuiteMask & VER_SUITE_DATACENTER )
					result += QLatin1String("Datacenter Server");
				else if ( osvi.wSuiteMask & VER_SUITE_ENTERPRISE )
					result += QLatin1String("Advanced Server");
				else
					result += QLatin1String("Server");
			}
		}

		if ( strlen(osvi.szCSDVersion) > 0 ) {
			result += QChar::fromLatin1(' ');
			result += QLatin1String(osvi.szCSDVersion);
		}

		if ( osvi.dwMajorVersion >= 6 ) {
			if ( si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_AMD64 )
				result += QLatin1String(", 64-bit");
			else if (si.wProcessorArchitecture==PROCESSOR_ARCHITECTURE_INTEL )
				result += QLatin1String(", 32-bit");
		}
	}

	return result;
}

unsigned int TWApp::GetWindowsVersion()
{
	OSVERSIONINFOEXA osvi;

	memset(&osvi, 0, sizeof(OSVERSIONINFOEXA));

	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEXA);
	if (!GetVersionExA (reinterpret_cast<OSVERSIONINFOA *>(&osvi)))
		return 0;

	return (osvi.dwMajorVersion << 24) | (osvi.dwMinorVersion << 16) | (osvi.wServicePackMajor << 8) | (osvi.wServicePackMinor << 0);
}
#endif

void TWApp::writeToMailingList()
{
	// The strings here are deliberately NOT localizable!
	QString address(QLatin1String("texworks@tug.org"));
	QString body(QLatin1String("Thank you for taking the time to write an email to the TeXworks mailing list. Please read the instructions below carefully as following them will greatly facilitate the communication.\n\nInstructions:\n-) Please write your message in English (it's in your own best interest; otherwise, many people will not be able to understand it and therefore will not answer).\n\n-) Please type something meaningful in the subject line.\n\n-) If you are having a problem, please describe it step-by-step in detail.\n\n-) After reading, please delete these instructions (up to the ``configuration info'' below which we may need to find the source of problems).\n\n\n\n----- configuration info -----\n"));

	body += QStringLiteral("TeXworks version : %1\n").arg(Twx::Core::Info::versionFull);
#if defined(Q_OS_DARWIN)
	body += QLatin1String("Install location : ") + Twx::Core::Locate::applicationDir().absolutePath() + QChar::fromLatin1('\n');
#else
	body += QLatin1String("Install location : ") + applicationFilePath() + QChar::fromLatin1('\n');
#endif
	body += QLatin1String("Library path     : ") + Twx::Core::Assets::path(QString()) + QChar::fromLatin1('\n');

	QString pdftex = Locate::absoluteProgramPath(QStringLiteral("pdftex"));
	if (pdftex.isEmpty())
		pdftex = QLatin1String("not found");
	else {
		QFileInfo info(pdftex);
		pdftex = info.canonicalFilePath();
	}

	body += QLatin1String("pdfTeX location  : ") + pdftex + QChar::fromLatin1('\n');

	body += QLatin1String("Operating system : ");
#if defined(Q_OS_WIN)
	body += QLatin1String("Windows ") + GetWindowsVersionString() + QChar::fromLatin1('\n');
#else
#if defined(Q_OS_DARWIN)
	QStringList unameArgs{QStringLiteral("-v")};
#else
	QStringList unameArgs{QStringLiteral("-a")};
#endif
	QString unameResult(QLatin1String("unknown"));
	Tw::Utils::SystemCommand unameCmd(this, true);
	unameCmd.setProcessChannelMode(QProcess::MergedChannels);
	unameCmd.start(QStringLiteral("uname"), unameArgs);
	if (unameCmd.waitForStarted(1000) && unameCmd.waitForFinished(1000))
		unameResult = unameCmd.getResult().trimmed();
#if defined(Q_OS_DARWIN)
	body += Twx::Core::Info::macOSVersionString();
	body += QLatin1String(" (") + unameResult + QLatin1String(")\n");
#else
	body += unameResult + QChar::fromLatin1('\n');
#endif
#endif

	body += QLatin1String("Qt version       : " QT_VERSION_STR " (build) / ");
	body += QLatin1String(qVersion());
	body += QLatin1String(" (runtime)\n");
	body += QLatin1String("------------------------------\n");

#if defined(Q_OS_WIN)
	body.replace(QChar::fromLatin1('\n'), QLatin1String("\r\n"));
#endif

	Twx::W3::openUrl(QUrl(QString::fromLatin1("mailto:%1?subject=&body=%2").arg(address, QString::fromLatin1(QUrl::toPercentEncoding(body).constData()))));
}

void TWApp::launchAction()
{
	scriptManager->runHooks(QString::fromLatin1("TeXworksLaunched"));

	if (!TeXDocumentWindow::documentList().empty() || !PDFDocumentWindow::documentList().empty())
		return;

	Settings settings;
	int launchOption = settings.value(QString::fromLatin1("launchOption"), 1).toInt();
	switch (launchOption) {
		case 1: // Blank document
			newFile();
			break;
		case 2: // New from Template
			newFromTemplate();
			break;
		case 3: // Open File
			open();
			break;
	}
#if !defined(Q_OS_DARWIN)
	// on Mac OS, it's OK to end up with no document (we still have the app menu bar)
	// but on W32 and X11 we need a window otherwise the user can't interact at all
	if (TeXDocumentWindow::documentList().empty() && PDFDocumentWindow::documentList().empty()) {
		newFile();
		if (TeXDocumentWindow::documentList().empty()) {
			// something went wrong, give up!
			(void)QMessageBox::critical(nullptr, tr("Unable to create window"),
					tr("Something is badly wrong; %1 was unable to create a document window. "
					   "The application will now quit.").arg(applicationName()),
					QMessageBox::Close, QMessageBox::Close);
			quit();
		}
	}
#endif
}

QObject * TWApp::newFile() const
{
	TeXDocumentWindow *doc = new TeXDocumentWindow;
	doc->show();
	doc->editor()->updateLineNumberAreaWidth(0);
	doc->runHooks(QString::fromLatin1("NewFile"));
	return doc;
}

QObject * TWApp::newFromTemplate() const
{
	QString templateName = TemplateDialog::doTemplateDialog();
	if (!templateName.isEmpty()) {
		TeXDocumentWindow *doc = new TeXDocumentWindow(templateName, true);
		if (doc) {
			doc->makeUntitled();
			doc->selectWindow();
			doc->editor()->updateLineNumberAreaWidth(0);
			doc->runHooks(QString::fromLatin1("NewFromTemplate"));
			return doc;
		}
	}
	return nullptr;
}

void TWApp::openRecentFile()
{
	QAction *action = qobject_cast<QAction *>(sender());
	if (action)
		openFile(action->data().toString());
}

QStringList TWApp::getOpenFileNames(QString selectedFilter)
{
	QFileDialog::Options options;
#if defined(Q_OS_WIN)
	if(TWApp::GetWindowsVersion() < 0x06000000) options |= QFileDialog::DontUseNativeDialog;
#endif
	Settings settings;
	QString lastOpenDir = settings.value(QString::fromLatin1("openDialogDir")).toString();
	QStringList filters = *TWUtils::filterList();
	if (!selectedFilter.isNull() && !filters.contains(selectedFilter))
		filters.prepend(selectedFilter);
	return QFileDialog::getOpenFileNames(nullptr, QString(tr("Open File")), lastOpenDir,
	                                     filters.join(QLatin1String(";;")), &selectedFilter, options);
}

QString TWApp::getOpenFileName(QString selectedFilter)
{
	QFileDialog::Options options;
#if defined(Q_OS_WIN)
	if(TWApp::GetWindowsVersion() < 0x06000000) options |= QFileDialog::DontUseNativeDialog;
#endif
	Settings settings;
	QString lastOpenDir = settings.value(QString::fromLatin1("openDialogDir")).toString();
	QStringList filters = *TWUtils::filterList();
	if (!selectedFilter.isNull() && !filters.contains(selectedFilter))
		filters.prepend(selectedFilter);
	return QFileDialog::getOpenFileName(nullptr, QString(tr("Open File")), lastOpenDir,
	                                    filters.join(QLatin1String(";;")), &selectedFilter, options);
}

void TWApp::open(const QString & defaultFilter /* = {} */)
{
	Settings settings;
	QStringList files = getOpenFileNames(defaultFilter);
	foreach (QString fileName, files) {
		if (!fileName.isEmpty()) {
			QFileInfo info(fileName);
			settings.setValue(QString::fromLatin1("openDialogDir"), info.canonicalPath());
			openFile(fileName);
		}
	}
}

QObject* TWApp::openFile(const QString &fileName, int pos /* = 0 */)
{
	if (Tw::Document::isPDFfile(fileName)) {
		PDFDocumentWindow *doc = PDFDocumentWindow::findDocument(fileName);
		if (!doc)
			doc = new PDFDocumentWindow(fileName);
		if (doc) {
			if (pos > 0)
				doc->widget()->goToPage(pos - 1);
			doc->selectWindow();
			return doc;
		}
		return nullptr;
	}
	return TeXDocumentWindow::openDocument(fileName, true, true, pos, 0, 0);
}

void TWApp::preferences()
{
	PrefsDialog::doPrefsDialog(activeWindow());
}

void TWApp::emitHighlightLineOptionChanged()
{
	emit highlightLineOptionChanged();
}

int TWApp::maxRecentFiles() const
{
	return recentFilesLimit;
}

void TWApp::setMaxRecentFiles(int value)
{
	if (value < 1)
		value = 1;
	else if (value > 100)
		value = 100;

	if (value != recentFilesLimit) {
		recentFilesLimit = value;

		Settings settings;
		settings.setValue(QString::fromLatin1("maxRecentFiles"), value);

		updateRecentFileActions();
	}
}

void TWApp::updateRecentFileActions()
{
#if defined(Q_OS_DARWIN)
	TWUtils::updateRecentFileActions(this, recentFileActions, menuRecent, actionClear_Recent_Files);
#endif
	emit recentFileActionsChanged();
}

void TWApp::updateWindowMenus()
{
	Tw::Utils::WindowManager::updateWindowList(TeXDocumentWindow::documentList(), PDFDocumentWindow::documentList());
	emit windowListChanged();
}

void TWApp::stackWindows()
{
	arrangeWindows(Tw::Utils::WindowManager::stackWindowsInRect);
}

void TWApp::tileWindows()
{
	arrangeWindows(Tw::Utils::WindowManager::tileWindowsInRect);
}

void TWApp::arrangeWindows(WindowArrangementFunction func)
{
	foreach(QScreen * screen, QGuiApplication::screens()) {
		QWidgetList windows;
		// All windows we iterate over here are top-level windows, so
		// windowHandle() should return a valid pointer
		foreach (TeXDocumentWindow* texDoc, TeXDocumentWindow::documentList()) {
			if (texDoc->windowHandle()->screen() == screen)
				windows << texDoc;
		}
		foreach (PDFDocumentWindow* pdfDoc, PDFDocumentWindow::documentList()) {
			if (pdfDoc->windowHandle()->screen() == screen)
				windows << pdfDoc;
		}
		if (!windows.empty())
			(*func)(windows, screen->availableGeometry());
	}
}

bool TWApp::event(QEvent *event)
{
	if (event->type() == TWDocumentOpenEvent::type) {
		TWDocumentOpenEvent * e = dynamic_cast<TWDocumentOpenEvent*>(event);
		openFile(e->filename, e->pos);
		return true;
	}
	switch (event->type()) {
		case QEvent::FileOpen:
			openFile(dynamic_cast<QFileOpenEvent *>(event)->file());
			return true;
		default:
			return QApplication::event(event);
	}
}

QTextCodec *TWApp::getDefaultCodec()
{
	return defaultCodec;
}

void TWApp::setDefaultCodec(QTextCodec *codec)
{
	if (!codec)
		return;

	if (codec != defaultCodec) {
		defaultCodec = codec;
		Settings settings;
		settings.setValue(QString::fromLatin1("defaultEncoding"), codec->name());
	}
}

void TWApp::activatedWindow(QWidget* theWindow)
{
	emit hideFloatersExcept(theWindow);
}

// static
QStringList TWApp::getTranslationList()
{
	QStringList translationList;
	QVector<QDir> dirs({QDir(QStringLiteral(":/resfiles/translations")), QDir(Twx::Core::Assets::path(Twx::Key::translations))});

	for (QDir transDir : dirs) {
		for (QFileInfo qmFileInfo : transDir.entryInfoList(QStringList(QStringLiteral("%1_*.qm").arg(applicationName())),
					QDir::Files | QDir::Readable, QDir::Name | QDir::IgnoreCase)) {
			QString locName = qmFileInfo.completeBaseName();
			locName.remove(QStringLiteral("%1_").arg(applicationName()));
			if (!translationList.contains(locName, Qt::CaseInsensitive))
				translationList << locName;
		}
	}

	// English is always available, and it has to be the first item
	translationList.removeAll(QString::fromLatin1("en"));
	translationList.prepend(QString::fromLatin1("en"));

	return translationList;
}

void TWApp::applyTranslation(const QString& locale)
{
	foreach (QTranslator* t, translators) {
		removeTranslator(t);
		delete t;
	}
	translators.clear();

	if (!locale.isEmpty()) {
		// According to the Qt docs, translators are searched in reverse order
		// (the last installed one is tried first). Here, we use the following
		// search order (1. is tried first):
		// 1. The user's files in <resources>/translations
		// 2. The system-wide translation
		// 3. The bundled translation
		// Note that the bundled translations are not copied to <resources>, so
		// this search order is not messed up.
		QStringList names, directories;
		names << QString::fromLatin1("qt_") + locale \
					<< QString::fromLatin1("QtPDF_") + locale \
					<< applicationName() + QString::fromLatin1("_") + locale;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
		directories << QString::fromLatin1(":/resfiles/translations") \
					<< QLibraryInfo::location(QLibraryInfo::TranslationsPath) \
					<< Twx::Core::Assets::path(Twx::Key::translations);
#else
		directories << QStringLiteral(":/resfiles/translations") \
					<< QLibraryInfo::path(QLibraryInfo::TranslationsPath) \
					<< Twx::Core::Assets::path(Twx::Key::translations);
#endif

		foreach (QString name, names) {
			foreach (QString dir, directories) {
				QTranslator * t = new QTranslator(this);
				if (t->load(name, dir)) {
					installTranslator(t);
					translators.append(t);
				}
				else
					delete t;
			}
		}
	}

	emit updatedTranslators();
}

void TWApp::addToRecentFiles(const QMap<QString,QVariant>& fileProperties)
{
	Settings settings;

	QString fileName = fileProperties.value(QString::fromLatin1("path")).toString();
	if (fileName.isEmpty())
		return;

	QList<QVariant> fileList = settings.value(QString::fromLatin1("recentFiles")).toList();
	QList<QVariant>::iterator i = fileList.begin();
	while (i != fileList.end()) {
		QMap<QString,QVariant> h = i->toMap();
		if (h.value(QString::fromLatin1("path")).toString() == fileName)
			i = fileList.erase(i);
		else
			++i;
	}

	fileList.prepend(fileProperties);

	while (fileList.size() > maxRecentFiles())
		fileList.removeLast();

	settings.setValue(QString::fromLatin1("recentFiles"), QVariant::fromValue(fileList));

	updateRecentFileActions();
}

void TWApp::clearRecentFiles()
{
	Settings settings;
	QList<QVariant> fileList;
	settings.setValue(QString::fromLatin1("recentFiles"), QVariant::fromValue(fileList));
	updateRecentFileActions();
}

QMap<QString,QVariant> TWApp::getFileProperties(const QString& path)
{
	Settings settings;
	QList<QVariant> fileList = settings.value(QString::fromLatin1("recentFiles")).toList();
	QList<QVariant>::iterator i = fileList.begin();
	while (i != fileList.end()) {
		QMap<QString,QVariant> h = i->toMap();
		if (h.value(QString::fromLatin1("path")).toString() == path)
			return h;
		++i;
	}
	return QMap<QString,QVariant>();
}

void TWApp::openHelpFile(const QString& helpDirName)
{
	QDir helpDir(helpDirName);
	if (helpDir.exists(QString::fromLatin1("index.html")))
		Twx::W3::openUrl(QUrl::fromLocalFile(helpDir.absoluteFilePath(QString::fromLatin1("index.html"))));
	else
		QMessageBox::warning(nullptr, applicationName(), tr("Unable to find help file."));
}

void TWApp::updateScriptsList()
{
	scriptManager->reloadScripts();

	emit scriptListChanged();
}

void TWApp::showScriptsFolder()
{
	QDesktopServices::openUrl(QUrl::fromLocalFile(Twx::Core::Assets::path(Twx::Key::scripts)));
}

void TWApp::bringToFront()
{
	foreach (QWidget* widget, topLevelWidgets()) {
		QMainWindow* window = qobject_cast<QMainWindow*>(widget);
		if (window) {
			window->raise();
			window->activateWindow();
		}
	}
}

QList<QVariant> TWApp::getOpenWindows() const
{
	QList<QVariant> result;

	foreach (QWidget *widget, QApplication::topLevelWidgets()) {
		if (qobject_cast<TWScriptableWindow*>(widget))
			result << QVariant::fromValue(qobject_cast<QObject*>(widget));
	}
	return result;
}

void TWApp::setGlobal(const QString& key, const QVariant& val)
{
	QVariant v = val;

	if (key.isEmpty())
		return;

	// For objects on the heap make sure we are notified when their lifetimes
	// end so that we can remove them from our hash accordingly
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
	switch (static_cast<QMetaType::Type>(val.type())) {
#else
	switch (val.metaType().id()) {
#endif
		case QMetaType::QObjectStar:
			connect(v.value<QObject*>(), &QObject::destroyed, this, &TWApp::globalDestroyed);
			break;
		default: break;
	}
	m_globals[key] = v;
}

void TWApp::globalDestroyed(QObject * obj)
{
	QHash<QString, QVariant>::iterator i = m_globals.begin();

	while (i != m_globals.end()) {
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
		switch (static_cast<QMetaType::Type>(i.value().type())) {
#else
		switch (i.value().metaType().id()) {
#endif
			case QMetaType::QObjectStar:
				if (i.value().value<QObject*>() == obj)
					i = m_globals.erase(i);
				else
					++i;
				break;
			default:
				++i;
				break;
		}
	}
}

/*Q_INVOKABLE static*/
int TWApp::getVersion()
{
	return Twx::Core::Info::versionMNP;
}

//Q_INVOKABLE
QMap<QString, QVariant> TWApp::openFileFromScript(const QString& fileName, QObject * scriptApiObj, const int pos /* = -1 */, const bool askUser /* = false */)
{
	Settings settings;
	QMap<QString, QVariant> retVal;
	QObject * doc = nullptr;
	QFileInfo fi(fileName);
	Tw::Scripting::ScriptAPI * scriptApi = qobject_cast<Tw::Scripting::ScriptAPI*>(scriptApiObj);

	retVal[QString::fromLatin1("status")] = Tw::Scripting::ScriptAPI::SystemAccess_PermissionDenied;

	// for absolute paths and full reading permissions, we don't have to care
	// about peculiarities of the script; in that case, this even succeeds
	// if no valid scriptApi is passed; otherwise, we need to investigate further
	if (fi.isRelative() || !settings.value(QString::fromLatin1("allowScriptFileReading"), kDefault_AllowScriptFileReading).toBool()) {
		if (!scriptApi)
			return retVal;
		Tw::Scripting::ScriptObject * scriptObj = qobject_cast<Tw::Scripting::ScriptObject*>(scriptApi->GetScript());
		if (!scriptObj)
			return retVal; // this should never happen

		// relative paths are taken to be relative to the folder containing the
		// executing script's file
		QDir scriptDir(QFileInfo(scriptObj->getFilename()).dir());
		QString path = scriptDir.absoluteFilePath(fileName);

		if (!scriptApi->mayReadFile(path, scriptApi->GetTarget())) {
			// Possibly ask user to override the permissions
			if (!askUser)
				return retVal;
			if (QMessageBox::warning(qobject_cast<QWidget*>(scriptApi->GetTarget()),
				tr("Permission request"),
				tr("The script ``%1'' is trying to open the file ``%2'' without sufficient permissions. Do you want to open the file?")\
					.arg(scriptObj->getTitle(), path),
				QMessageBox::Yes | QMessageBox::No, QMessageBox::No
			) != QMessageBox::Yes)
				return retVal;
		}
	}
	doc = openFile(fileName, pos);
	retVal[QString::fromLatin1("result")] = QVariant::fromValue(doc);
	retVal[QString::fromLatin1("status")] = (doc ? Tw::Scripting::ScriptAPI::SystemAccess_OK : Tw::Scripting::ScriptAPI::SystemAccess_Failed);
	return retVal;
}

void TWApp::doResourcesDialog() const
{
	ResourcesDialog::doResourcesDialog(nullptr);
}

void TWApp::reloadSpellchecker()
{
	// save the current language and deactivate the spell checker for all open
	// TeXDocument windows
	QHash<TeXDocumentWindow*, QString> oldLangs;
	foreach (QWidget *widget, QApplication::topLevelWidgets()) {
		TeXDocumentWindow * texDoc = qobject_cast<TeXDocumentWindow*>(widget);
		if (texDoc) {
			oldLangs[texDoc] = texDoc->spellcheckLanguage();
			texDoc->setSpellcheckLanguage(QString());
		}
	}

	// reset dictionaries (getDictionaryList(true) automatically updates all
	// spell checker menus)
	Tw::Document::SpellChecker::clearDictionaries();
	Tw::Document::SpellChecker::getDictionaryList(true);

	// reenable spell checker
	for (QHash<TeXDocumentWindow*, QString>::iterator it = oldLangs.begin(); it != oldLangs.end(); ++it) {
		it.key()->setSpellcheckLanguage(it.value());
	}
}

