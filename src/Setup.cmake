#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens & co

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

#[=======[
Usage:
```
include ( TwxSrcSetup)
```
Output:
* `TwxSrc_SOURCES`
* `TwxSrc_HEADERS`

When not absolute, the paths are relative to 
`TWX_DIR_src`.

#]=======]

if ( NOT TWX_IS_BASED )
  message ( FATAL ERROR "Missing Base" )
endif ()

include (TwxVersionSetup)
include (TwxGitSetup)
include (TwxCoreSetup)
include (TwxTypesetSetup)

set (
  TwxSrc_SOURCES
  BibTeXFile.cpp
  CitationSelectDialog.cpp
  CompletingEdit.cpp
  Engine.cpp
  FindDialog.cpp
  HardWrapDialog.cpp
  main.cpp
  PDFDocumentWindow.cpp
  PrefsDialog.cpp
  ResourcesDialog.cpp
  ScriptManagerWidget.cpp
  Settings.cpp
  TemplateDialog.cpp
  TeXDocks.cpp
  TeXDocumentWindow.cpp
  TeXHighlighter.cpp
  TWApp.cpp
  TWScriptableWindow.cpp
  TWScriptManager.cpp
  TWSynchronizer.cpp
  TWUtils.cpp
  document/Document.cpp
  document/SpellChecker.cpp
  document/TextDocument.cpp
  document/TeXDocument.cpp
  scripting/ECMAScriptInterface.cpp
  scripting/ECMAScript.cpp
  scripting/ScriptAPI.cpp
  scripting/Script.cpp
  ui/ClickableLabel.cpp
  ui/ClosableTabWidget.cpp
  ui/ColorButton.cpp
  ui/ConsoleWidget.cpp
  ui/LineNumberWidget.cpp
  ui/ListSelectDialog.cpp
  ui/RemoveAuxFilesDialog.cpp
  ui/ScreenCalibrationWidget.cpp
  utils/CmdKeyFilter.cpp
  utils/CommandlineParser.cpp
  utils/FileVersionDatabase.cpp
  utils/FullscreenManager.cpp
  utils/ResourcesLibrary.cpp
  utils/SystemCommand.cpp
  utils/TextCodecs.cpp
  utils/TypesetManager.cpp
  utils/VersionInfo.cpp
  utils/WindowManager.cpp
  ${TwxVersion_SOURCES}
  ${TwxGit_SOURCES}
  ${TwxTypeset_SOURCES}
  ${TwxCore_SOURCES}
)

set (
  TwxSrc_HEADERS
  BibTeXFile.h
  CitationSelectDialog.h
  CompletingEdit.h
  DefaultPrefs.h
  Engine.h
  FindDialog.h
  GitRev.h
  HardWrapDialog.h
  PDFDocumentWindow.h
  PrefsDialog.h
  ResourcesDialog.h
  ScriptManagerWidget.h
  Settings.h
  TemplateDialog.h
  TeXDocks.h
  TeXDocumentWindow.h
  TeXHighlighter.h
  TWApp.h
  TWScriptableWindow.h
  TWScriptManager.h
  TWSynchronizer.h
  TWUtils.h
  InterProcessCommunicator.h
  document/Document.h
  document/SpellChecker.h
  document/TextDocument.h
  document/TeXDocument.h
  scripting/ScriptAPIInterface.h
  scripting/ScriptLanguageInterface.h
  scripting/ScriptAPI.h
  scripting/Script.h
  ui/ClickableLabel.h
  ui/ClosableTabWidget.h
  ui/ColorButton.h
  ui/ConsoleWidget.h
  ui/LineNumberWidget.h
  ui/ListSelectDialog.h
  ui/RemoveAuxFilesDialog.h
  ui/ScreenCalibrationWidget.h
  utils/CmdKeyFilter.cpp
  utils/CommandlineParser.h
  utils/FileVersionDatabase.h
  utils/FullscreenManager.h
  utils/ResourcesLibrary.h
  utils/SystemCommand.h
  utils/TextCodecs.h
  utils/TypesetManager.h
  utils/VersionInfo.h
  utils/WindowManager.h
  ${TwxVersion_HEADERS}
  ${TwxGit_HEADERS}
  ${TwxTypeset_HEADERS}
  ${TwxCore_HEADERS}
)
