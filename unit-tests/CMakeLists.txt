#[=======[
This is `<...>/unit-tests/CMakeLists.txt`

When used as primary `CMakeLists.txt` it defines
a series of tests for TeXworks.

Usage:
```
cd <...>/unit-tests/
mkdir build
cd build
cmake ..
cmake --build .
ctest .
```

It is also included by the main `CMakeLists.txt`.

#]=======]

# File to build unit-tests

if (DEFINED TWX_IS_BASED)

include_directories (
	"${TWX_DIR_src}"
	${${PROJECT_NAME}_INCLUDE_DIRS}
)

else ()

cmake_minimum_required(VERSION 3.1)

# Always start with the base
include (
  "${CMAKE_CURRENT_LIST_DIR}/../CMake/Include/Base.cmake"
  NO_POLICY_SCOPE
)
# ANCHOR: Project
# Set project name.
project(TwxAllTests)
# Include the base once again to finish setup
include (Base)

# Declare Project Options
# -----------------------

# These are options that users can set at configure-time to determine how the
# application is built and what functionalities it will have. Here we declare
# these options by setting default values.

SET(TW_BUILD_ID "personal" CACHE STRING "A distribution-specific identifier for TeXworks")

# Build with shared libs by default
OPTION(BUILD_SHARED_LIBS "Build with shared libs?" ON)
MARK_AS_ADVANCED(BUILD_SHARED_LIBS)

# Build shared plugins by default
OPTION(BUILD_SHARED_PLUGINS "Build shared plugins?" ${BUILD_SHARED_LIBS})
MARK_AS_ADVANCED(BUILD_SHARED_PLUGINS)

OPTION(PREFER_BUNDLED_SyncTeX "Use SyncTeX bundled with TeXworks even if a shared library is found?" OFF)
MARK_AS_ADVANCED(PREFER_BUNDLED_SyncTeX)

# OPTION(WITH_TESTS "build unit tests" ON)
# IF (WITH_TESTS)
#   ENABLE_TESTING(TRUE)
# ENDIF (WITH_TESTS)

OPTION(WITH_COVERAGE "build with lcov coverage support" OFF)
IF (WITH_COVERAGE)
  IF (NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" AND WITH_TESTS))
    MESSAGE(WARNING "Coverage support is intended to be used with Debug builds and testing enabled")
  ENDIF ()
  INCLUDE(CodeCoverage)
  set(COVERAGE_COMPILER_FLAGS "${COVERAGE_COMPILER_FLAGS} -fno-inline")
  APPEND_COVERAGE_COMPILER_FLAGS()
  IF (UNIX)
    SET(COVERAGE_LCOV_EXCLUDES '/usr/*')
  ENDIF (UNIX)
  SETUP_TARGET_FOR_COVERAGE_LCOV(NAME coverage EXECUTABLE "${CMAKE_CTEST_COMMAND}")
ENDIF (WITH_COVERAGE)

SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} CACHE PATH "Path to place libraries in")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} CACHE PATH "Path to place programs in")
MARK_AS_ADVANCED(CMAKE_LIBRARY_OUTPUT_DIRECTORY CMAKE_RUNTIME_OUTPUT_DIRECTORY)

# On UNIX, CMake installs to `/usr/local` by default. However, Mac users
# will probably find `/Applications` a more convenient default.
IF( APPLE AND CMAKE_INSTALL_PREFIX MATCHES "/usr/local" )
  SET( CMAKE_INSTALL_PREFIX "/Applications" )
ENDIF()

# Do an optimized release build by default
IF ( NOT CMAKE_BUILD_TYPE )
  SET(CMAKE_BUILD_TYPE "Release")
ENDIF ()

# Options controlling the creation of scripting language plugins.
OPTION(WITH_LUA "Build TeXworks Lua plugin?" ON)
OPTION(WITH_PYTHON "Build TeXworks Python plugin?" OFF)

# On OS X we default to linking against the Python libraries provided by Apple
# even if other Pythons are available. This helps when building
# re-distributable `.app` packages. By disabling this option, a Mac user can
# link against whatever Python they wish for a personal build.
IF ( APPLE )
  OPTION(USE_SYSTEM_PYTHON "Link against Python Framework distributed with OS X?" ON)
ENDIF ()

IF (UNIX AND NOT APPLE)
  SET(TeXworks_HELP_DIR share/doc/texworks-help CACHE PATH "Path where TeXworks looks for help files")
  SET(TeXworks_DIC_DIR /usr/share/hunspell:/usr/share/myspell/dicts CACHE PATH "Path where TeXworks looks for spellchecking dictionaries")
  SET(TeXworks_DOCS_DIR share/doc/texworks CACHE PATH "Path in which documentation files are installed")
  SET(TeXworks_ICON_DIR share/icons/hicolor CACHE PATH "Path in which icons are installed")
  SET(TeXworks_MAN_DIR share/man/man1 CACHE PATH "Path in which manpages are installed")
  SET(TeXworks_DESKTOP_DIR share/applications CACHE PATH "Path in which .desktop files are installed")
  SET(TeXworks_APPDATA_DIR share/metainfo CACHE PATH "Path in which .appdata.xml files are installed")
  MARK_AS_ADVANCED(TeXworks_HELP_DIR)
  MARK_AS_ADVANCED(TeXworks_DIC_DIR)
  MARK_AS_ADVANCED(TeXworks_DOCS_DIR)
  MARK_AS_ADVANCED(TeXworks_ICON_DIR)
  MARK_AS_ADVANCED(TeXworks_MAN_DIR)
  MARK_AS_ADVANCED(TeXworks_DESKTOP_DIR)
  MARK_AS_ADVANCED(TeXworks_APPDATA_DIR)
  IF (EXISTS ${TeXworks_SOURCE_DIR}/manual/)
    INSTALL(DIRECTORY ${TeXworks_SOURCE_DIR}/manual/ DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_HELP_DIR}/ OPTIONAL)
  ENDIF()
ENDIF()

# Dependency Configuration
# ========================

# ANCHOR: Qt

include(WithQt)
include(WithQtPlugins)

twx_append_QT(
  REQUIRED Widgets Gui UiTools Concurrent Xml Qml
)
find_package(${QtMAJOR} REQUIRED COMPONENTS LinguistTools)

if (UNIX AND NOT APPLE)
  twx_append_QT(REQUIRED DBus)
endif ()

if (QT_VERSION_MAJOR EQUAL 6)
	# Check for Qt6
  twx_append_QT(REQUIRED Core5Compat)
  twx_setup_QT_PLUGINS()

else ()
	# Check for Qt5
  twx_append_QT(OPTIONAL Script ScriptTools)
	if (${QtMAJOR}Script_FOUND AND ${QtMAJOR}ScriptTools_FOUND)
		set(WITH_QTSCRIPT ON)
	endif()

	if (WIN32 AND NOT BUILD_SHARED_LIBS)
    twx_append_QT(REQUIRED WindowsPlatformSupport)
	endif ()
  # Next instruction needs explanations
	set(WITH_QTSCRIPT ON)
endif ()

if (WITH_TESTS)
  twx_append_QT(OPTIONAL Test)
  if (NOT ${QtMAJOR}Test_FOUND)
    set(WITH_TESTS OFF)
  endif ()
endif ()

FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(Hunspell REQUIRED)
FIND_PACKAGE(SyncTeX REQUIRED)

# Aggregate library names and include directories into variables for easy
# access.

SET(${PROJECT_NAME}_LIBRARIES
  SyncTeX::synctex
  Hunspell::hunspell
  ${QT_LIBRARIES}
  ZLIB::ZLIB
  ${TEXWORKS_ADDITIONAL_LIBS}
)


# Configure Optional Dependencies
# -------------------------------

IF ( WITH_LUA )
  FIND_PACKAGE(Lua)
ENDIF()

IF ( WITH_PYTHON )
  IF ( USE_SYSTEM_PYTHON )
    SET(PYTHON_LIBRARIES "-F/System/Library/Frameworks -framework Python" CACHE PATH "Python library.")
    SET(PYTHON_INCLUDE_DIR "/System/Library/Framework/Python.framework/Headers" CACHE PATH "Python framework.")
    MARK_AS_ADVANCED(PYTHON_LIBRARIES)
    MARK_AS_ADVANCED(PYTHON_INCLUDE_DIR)
    SET(PYTHONLIBS_FOUND TRUE)
  ELSE ()
    # **NOTE**
    # In order to find the correct version of 'PythonLibs', it seems that we need to run 'FIND_PACKAGE(PythonInterp)' firstly.
    # In order to find the correct version of 'PythonInterp', we need to set 'PYTHONHOME' environment variable
    FIND_PACKAGE(PythonInterp)
    FIND_PACKAGE(PythonLibs)
  ENDIF ()
ENDIF()

IF ( LUA_FOUND AND WITH_LUA AND NOT ${BUILD_SHARED_PLUGINS})
  ADD_DEFINITIONS(-DQT_STATICPLUGIN -DSTATIC_LUA_SCRIPTING_PLUGIN)
ENDIF ()

IF ( PYTHONLIBS_FOUND AND WITH_PYTHON AND NOT ${BUILD_SHARED_PLUGINS})
  ADD_DEFINITIONS(-DQT_STATICPLUGIN -DSTATIC_PYTHON_SCRIPTING_PLUGIN)
ENDIF ()


# Update Header Templates
# -----------------------

include(GenerateDefaultBinPaths)
GenerateDefaultBinPaths()

# Building
# ========

# ANCHOR: WARNING
include (InitWARNING)

# Build modules
add_subdirectory (
	"${TWX_DIR_modules}"
	"${CMAKE_CURRENT_BINARY_DIR}/modules"
)

# # Build Plugins
# # -------------

# # On OS X, the plugins should live inside the application bundle.
# IF ( APPLE )
#   SET(TeXworks_PLUGIN_DIR ${PROJECT_NAME}.app/Contents/PlugIns)
#   # Plugins are build as shared libraries that contain undefined symbols.
#   # Pass `-undefined dynamic_lookup` so that the Apple linker does not
#   # freak out about this.
#   SET(CMAKE_MODULE_LINKER_FLAGS
#     "${CMAKE_MODULE_LINKER_FLAGS} -undefined dynamic_lookup")
# ELSEIF (WIN32)
#   # Put plugins alongside the main app in the root installation folder on Windows
#   SET(TeXworks_PLUGIN_DIR . CACHE PATH "Path where TeXworks looks for plugins")
#   MARK_AS_ADVANCED(TeXworks_PLUGIN_DIR)
# ELSE ()
#   # Set the plugin installation path. This is a good default for UNIX-like
#   # systems, but is not appropriate for Windows.
#   SET(TeXworks_PLUGIN_DIR lib/texworks CACHE PATH "Path where TeXworks looks for plugins")
#   MARK_AS_ADVANCED(TeXworks_PLUGIN_DIR)
# ENDIF ()

# Build main TeXworks application
# -------------------------------
# add_subdirectory (src)

# Build Plugins
# -------------

# # Build scripting language plugins if the required libraries are available.
# IF ( LUA_FOUND AND WITH_LUA )
#   ADD_SUBDIRECTORY(${TeXworks_SOURCE_DIR}/plugins-src/TWLuaPlugin)
# ENDIF ()

# IF ( PYTHONLIBS_FOUND AND WITH_PYTHON )
#   ADD_SUBDIRECTORY(${TeXworks_SOURCE_DIR}/plugins-src/TWPythonPlugin)
# ENDIF ()

# # Tests
# # -----
# if (WITH_TESTS)
#   add_subdirectory(unit-tests)
# endif ()

enable_testing(TRUE)

set (TWX_ALL_TESTS_MAIN ON)
endif ()

# BiBTeXFile
add_executable (
	test_BibTeXFile
	BibTeXFile_test.cpp
	BibTeXFile_test.h
	"${TWX_DIR_src}/BibTeXFile.cpp"
	"${TWX_DIR_src}/BibTeXFile.h"
)
target_compile_options (
	test_BibTeXFile
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_BibTeXFile
	${QT_LIBRARIES}
	${ZLIB_LIBRARIES}
	${TEXWORKS_ADDITIONAL_LIBS}
)
add_test(
	NAME test_BibTeXFile
	COMMAND test_BibTeXFile
	WORKING_DIRECTORY "${TWX_DIR_testcases}"
)

# Scripting
add_executable(test_Scripting
	Scripting_test.cpp
	Scripting_test.h
	MockScriptingAPI.h
	"${TWX_DIR_src}/scripting/Script.cpp"
	"${TWX_DIR_src}/scripting/ECMAScriptInterface.cpp"
	"${TWX_DIR_src}/scripting/ECMAScript.cpp"
	"${TWX_DIR_src}/Settings.cpp"
)
if (WITH_QTSCRIPT)
	target_sources (
		test_Scripting
		PRIVATE "${TWX_DIR_src}/scripting/JSScriptInterface.cpp"
		PRIVATE "${TWX_DIR_src}/scripting/JSScript.cpp"
	)
	target_compile_definitions (
		test_Scripting
		PRIVATE WITH_QTSCRIPT
	)
endif (WITH_QTSCRIPT)
target_compile_options (
	test_Scripting
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_Scripting
	${QT_LIBRARIES}
	${ZLIB_LIBRARIES}
	${TEXWORKS_ADDITIONAL_LIBS}
)
add_test(
	NAME test_Scripting
	COMMAND test_Scripting
	WORKING_DIRECTORY "${TWX_DIR_testcases}"
)

IF ( LUA_FOUND AND WITH_LUA )
	add_executable(test_LuaScripting
		LuaScripting_test.cpp
		LuaScripting_test.h
		MockScriptingAPI.h
		"${TWX_DIR_src}/scripting/Script.cpp"
		"${TWX_DIR_src}/Settings.cpp"
	)
	target_compile_options(test_LuaScripting PRIVATE ${WARNING_OPTIONS})
	IF (NOT ${BUILD_SHARED_PLUGINS})
		target_link_libraries(test_LuaScripting TWLuaPlugin)
	ENDIF()

	target_link_libraries(test_LuaScripting ${QT_LIBRARIES} ${ZLIB_LIBRARIES} ${TEXWORKS_ADDITIONAL_LIBS})
	add_test(NAME test_LuaScripting COMMAND test_LuaScripting WORKING_DIRECTORY "${TWX_DIR_testcases}")
ENDIF ()

add_executable(
	byte_echo_test
	byte_echo_test.cpp
)
target_compile_options (
	byte_echo_test
	PRIVATE ${WARNING_OPTIONS}
)

# UI
add_executable(test_UI
	UI_test.cpp
	UI_test.h
	"${TWX_DIR_src}/ui/ClickableLabel.cpp"
	"${TWX_DIR_src}/ui/ClosableTabWidget.cpp"
	"${TWX_DIR_src}/ui/ColorButton.cpp"
	"${TWX_DIR_src}/ui/ConsoleWidget.cpp"
	"${TWX_DIR_src}/ui/LineNumberWidget.cpp"
	"${TWX_DIR_src}/ui/ScreenCalibrationWidget.cpp"
)
target_compile_options (
	test_UI
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_UI
	${QT_LIBRARIES}
	${ZLIB_LIBRARIES}
	${TEXWORKS_ADDITIONAL_LIBS}
)
add_test (
	NAME test_UI
	COMMAND test_UI
	WORKING_DIRECTORY "${TWX_DIR_testcases}"
)

# Utils
add_executable(test_Utils
	Utils_test.cpp
	Utils_test.h
	"${TWX_DIR_src}/utils/CommandlineParser.cpp"
	"${TWX_DIR_src}/utils/FileVersionDatabase.cpp"
	"${TWX_DIR_src}/utils/FullscreenManager.cpp"
	"${TWX_DIR_src}/utils/ResourcesLibrary.cpp"
	"${TWX_DIR_src}/utils/SystemCommand.cpp"
	"${TWX_DIR_src}/utils/TextCodecs.cpp"
	"${TWX_DIR_src}/utils/TypesetManager.cpp"
	"${TWX_DIR_src}/utils/VersionInfo.cpp"
)

target_compile_options (
	test_Utils
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_Utils
	${QT_LIBRARIES}
	${ZLIB_LIBRARIES}
	${TEXWORKS_ADDITIONAL_LIBS}
)
add_dependencies(
	test_Utils
	GitRev_target
)
add_test(
	NAME test_Utils
	COMMAND test_Utils
	WORKING_DIRECTORY "${TWX_DIR_testcases}"
)

if (APPLE)
	target_sources(test_Utils PRIVATE "${TWX_DIR_src}/utils/OSVersionInfo_mac.mm")
	target_link_libraries(test_Utils "-framework Foundation")
endif (APPLE)

# Document
add_executable(test_Document
	Document_test.cpp
	Document_test.h
	"${TWX_DIR_src}/document/Document.cpp"
	"${TWX_DIR_src}/document/SpellChecker.cpp"
	"${TWX_DIR_src}/document/TeXDocument.cpp"
	"${TWX_DIR_src}/document/TeXDocument.h"
	"${TWX_DIR_src}/document/TextDocument.cpp"
	"${TWX_DIR_src}/TWSynchronizer.cpp"
	"${TWX_DIR_src}/TWSynchronizer.h"
	"${TWX_DIR_src}/TeXHighlighter.h"
)
target_compile_options(
	test_Document
	PRIVATE ${WARNING_OPTIONS}
)
if (WITH_POPPLERQT)
	target_compile_definitions(test_Document PRIVATE WITH_POPPLERQT)
	if (POPPLER_HAS_RUNTIME_VERSION)
		target_compile_definitions(test_Document PRIVATE POPPLER_HAS_RUNTIME_VERSION)
	endif (POPPLER_HAS_RUNTIME_VERSION)
endif (WITH_POPPLERQT)
target_link_libraries(
	test_Document
	QtPDF::qtpdf
	SyncTeX::synctex
	Hunspell::hunspell
	${QT_LIBRARIES}
	${ZLIB_LIBRARIES}
	${TEXWORKS_ADDITIONAL_LIBS}
)
add_test (
	NAME test_Document
	COMMAND test_Document
	WORKING_DIRECTORY "${TWX_DIR_testcases}"
)

include (
	"${TWX_DIR_src}/Test/CMakeLists.txt"
)

if (TWX_ALL_TESTS_MAIN)

message("")

# Summary
# =======

# This section displays a nice configuration summary for the user.

twx_config_begin(
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)
twx_config_begin(BOLD_MAGENTA "Version info")
twx_config_log("${PROJECT_NAME}" "${TeXworks_VERSION} (${TWX_GIT_HASH}, ${TWX_GIT_DATE}, ${TWX_GIT_BRANCH})")
twx_config_log("Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH})
twx_config_end()

twx_config_log("Compiler optimization" ${CMAKE_BUILD_TYPE})
twx_config_log("")

twx_config_begin(BOLD_BLUE "Libraries" VERBOSE)
twx_config_log_kv ("Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES)
twx_config_end  ()

twx_config_begin(BOLD_BLUE "Build settings" VERBOSE)
twx_config_log_kv ("Compile definitions" VAR COMPILE_DEFINITIONS)
twx_config_log_kv ("Compile options" VAR COMPILE_OPTIONS)
twx_config_end  ()

twx_config_end  (NO_EOL)

endif ()
