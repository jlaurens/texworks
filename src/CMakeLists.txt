# Build TeXworks
# ==============

twx_assert_target ( TeXworks )

target_include_directories (
  TeXworks
  PRIVATE
  "${TWX_DIR}/src"
  "${TWX_PROJECT_BUILD_DIR}/src"
)

# Collect Source Files
# --------------------

# **NOTE:** _A `GLOB` operation is quick, but may not be appropriate. It may be
# better to maintain an explicit list of source files. Particularly, adding a
# new file to an explicit list will cause CMake to automatically reconfigure
# the next time `make` is invoked. When `GLOB` is used, the developer will have
# to remember to re-run `cmake` if a source file is added._
set ( TeXworks_SOURCES
  BibTeXFile.cpp
  CitationSelectDialog.cpp
  CompletingEdit.cpp
  FindDialog.cpp
  HardWrapDialog.cpp
  main.cpp
  PDFDocumentWindow.cpp
  PrefsDialog.cpp
  ResourcesDialog.cpp
  ScriptManagerWidget.cpp
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
  scripting/ScriptObject.cpp
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
  utils/FullscreenManager.cpp
  utils/SystemCommand.cpp
  utils/TextCodecs.cpp
  utils/WindowManager.cpp
)
set ( TeXworks_HEADERS
  BibTeXFile.h
  CitationSelectDialog.h
  CompletingEdit.h
  DefaultPrefs.h
  FindDialog.h
  HardWrapDialog.h
  PDFDocumentWindow.h
  PrefsDialog.h
  ResourcesDialog.h
  ScriptManagerWidget.h
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
  scripting/ScriptObject.h
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
  utils/FullscreenManager.h
  utils/SystemCommand.h
  utils/TextCodecs.h
  utils/WindowManager.h
)

if (WIN32)
  list(APPEND TeXworks_SOURCES InterProcessCommunicatorWin.cpp)
elseif (APPLE)
  list(APPEND TeXworks_SOURCES InterProcessCommunicatorDummy.cpp)
else ()
  list(APPEND TeXworks_SOURCES InterProcessCommunicatorDBus.cpp)
endif ()

if ( WITH_QTSCRIPT )
  list(
    APPEND TeXworks_SOURCES
    scripting/JSScriptInterface.cpp
    scripting/JSScript.cpp
  )
  list(
    APPEND TeXworks_HEADERS
    scripting/JSScriptInterface.h
    scripting/JSScript.h
  )
  add_definitions(-DWITH_QTSCRIPT)
endif ( WITH_QTSCRIPT )

set ( TeXworks_UIS
  CitationSelectDialog.ui
  CompletingEdit.ui
  Find.ui
  HardWrapDialog.ui
  PDFDocumentWindow.ui
  PDFFind.ui
  PrefsDialog.ui
  Replace.ui
  ResourcesDialog.ui
  ScriptManagerWidget.ui
  SearchResults.ui
  TemplateDialog.ui
  TeXDocumentWindow.ui
  ToolConfig.ui
  ui/ListSelectDialog.ui
)

set ( TeXworks_RCS
  "${TWX_DIR}/res/resfiles.qrc"
  "${TWX_DIR}/res/resources.qrc"
)

IF ( WIN32 )
  if (NOT MSVC)
    set(CREATE_MANIFEST TRUE)
  endif (NOT MSVC)
  include ( TwxCfgLib )
  twx_cfg_write_begin ( ID "package-private" )
  twx_cfg_set ( PKG_APP_ICO   "${TWX_DIR}/res/images/TeXworks.ico" )
  twx_cfg_set ( PKG_DOC_ICO   "${TWX_DIR}/res/images/TeXworks-doc.ico" )
  twx_cfg_set ( EXE_MANIFEST  "${TWX_PROJECT_BUILD_DIR}/res/os_windows/TeXworks.exe.manifest" )
  twx_cfg_write_end ()
  include ( TwxCfgFileLib)
  twx_cfg_files (
    ID 			PACKAGE_WINDOWS
    FILES 	${TWX_NAME}.in.rc ${TWX_NAME}.in.exe.manifest
    IN_DIR 	"${TWX_DIR}/res/os_windows/"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}/res/os_windows/"
    EXPORT twx
  )
  list(
    APPEND TeXworks_SOURCES
    "${twx_PACKAGE_WINDOWS}"
  )
ENDIF ( WIN32 )

# These source files along with the `.moc` files generated from some headers
# form the TeXworks scripting API. We export them to variables in the
# `PARENT_SCOPE` (top level CMake file) so that they will be available to the
# build processes of the scripting language plugins.
set (
  TeXworks_SCRIPT_API
  "${TWX_DIR}/src/scripting/Script.cpp"
  "${TWX_DIR}/src/scripting/ScriptAPI.cpp"
  PARENT_SCOPE
)
set (
  TeXworks_SCRIPT_API_H
  "${TWX_DIR}/src/scripting/Script.h"
  "${TWX_DIR}/src/scripting/ScriptAPI.h"
  "${TWX_DIR}/src/TWSystemCmd.h"
  PARENT_SCOPE
)

# App Setup
# ---------

# On OS X, add core system frameworks to the library link list.
IF ( APPLE )
  LIST(APPEND TeXworks_LIBRARIES  "-framework Foundation")
ENDIF ()

# Compilation
# -----------

IF (NOT ${BUILD_SHARED_PLUGINS})
  IF (WITH_LUA AND LUA_FOUND)
    LIST(INSERT TeXworks_LIBRARIES 0 TWLuaPlugin ${LUA_LIBRARIES})
  ENDIF()
  IF (WITH_PYTHON AND PYTHONLIBS_FOUND)
    LIST(INSERT TeXworks_LIBRARIES 0 TWPythonPlugin ${PYTHON_LIBRARIES})
  ENDIF()
ENDIF()

# Build the executable
target_sources (
  TeXworks
  PRIVATE
    ${TeXworks_SOURCES}
    ${TeXworks_HEADERS}
    ${TeXworks_RCS}
)

target_compile_options(TeXworks PRIVATE ${WARNING_OPTIONS})


IF (UNIX)
  # Required (at least) on OpenBSD to make scripting plugins work
  SET_TARGET_PROPERTIES(TeXworks PROPERTIES LINK_FLAGS -rdynamic)
ENDIF ()

# Specify libraries to be linked to TeXworks.
target_link_libraries (
  TeXworks
  QtPDF::qtpdf
  ${TeXworks_LIBRARIES}
)

twx_module_add ( Core Typeset TARGETS TeXworks )

# Disallow automatic casts from char* to QString (enforcing the use of tr() or
# explicitly specifying the string encoding)
target_compile_definitions(TeXworks PRIVATE QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII QT_NO_CAST_FROM_BYTEARRAY)
if ( NOT MSVC )
	# Set QT_STRICT_ITERATORS everywhere except for MSVC (QTBUG-78112)
	target_compile_definitions(TeXworks PRIVATE QT_STRICT_ITERATORS)
endif ()

IF ( UNIX )
  set_target_properties(TeXworks PROPERTIES COMPILE_FLAGS -fPIC)
endif ()

