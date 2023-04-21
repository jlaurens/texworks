#[=====================================[

## Back to version `CMakeLists.txt` version `0.7.0`

The build system has been improved to help people develop and test
new features without building the whole TeXworks package.

This file will not follow github usual commit mechanism.
During a period of transition, it will be possible to revert
to the original design with
```
cmake -CTWX_CMakeLists_OLD=ON ...
```
This will cause `CMakeLists.txt` version `0.7.0` to be loaded. 
#]=====================================]

# CMake 3.1 significantly improves support for imported targets, Qt5, c++11, etc.
# This must be first
cmake_minimum_required(VERSION 3.1)

if (TWX_CMakeLists_OLD)
  PROJECT (TeXworks)
  include (
    "${CMAKE_CURENT_LIST_DIR}/CMakeLists-OLD.txt"
    NO_POLICY_SCOPE
  )
  return ()
endif ()

# Always start with the base
include (
  "${CMAKE_CURRENT_LIST_DIR}/CMake/Include/Base.cmake"
  NO_POLICY_SCOPE
)
# ANCHOR: Project
# Set project name.
project(TeXworks)
# Include the base once again to finish setup
include (Base)
include (TwxGetVERSION)
include (TwxGitRev)

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

OPTION(PREFER_BUNDLED_SYNCTEX "Use SyncTeX bundled with TeXworks even if a shared library is found?" OFF)
MARK_AS_ADVANCED(PREFER_BUNDLED_SYNCTEX)

OPTION(WITH_TESTS "build unit tests" ON)
IF (WITH_TESTS)
  ENABLE_TESTING(TRUE)
ENDIF (WITH_TESTS)

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
  REQUIRED Core Widgets Gui UiTools Concurrent Xml Qml
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

twx_setup_QT_VERSION()


FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(Hunspell REQUIRED)
FIND_PACKAGE(Synctex QUIET)

# Aggregate library names and include directories into variables for easy
# access.

SET(TeXworks_LIBS
  SyncTeX::synctex
  Hunspell::hunspell
  ${QT_LIBRARIES}
  ZLIB::ZLIB
  ${TEXWORKS_ADDITIONAL_LIBS}
)


# Configure Optional Dependencies
# -------------------------------

IF ( WITH_LUA )
  find_package(TwxLua)
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
add_subdirectory (modules)

# Build Plugins
# -------------

# On OS X, the plugins should live inside the application bundle.
IF ( APPLE )
  SET(TeXworks_PLUGIN_DIR ${PROJECT_NAME}.app/Contents/PlugIns)
  # Plugins are build as shared libraries that contain undefined symbols.
  # Pass `-undefined dynamic_lookup` so that the Apple linker does not
  # freak out about this.
  SET(CMAKE_MODULE_LINKER_FLAGS
    "${CMAKE_MODULE_LINKER_FLAGS} -undefined dynamic_lookup")
ELSEIF (WIN32)
  # Put plugins alongside the main app in the root installation folder on Windows
  SET(TeXworks_PLUGIN_DIR . CACHE PATH "Path where TeXworks looks for plugins")
  MARK_AS_ADVANCED(TeXworks_PLUGIN_DIR)
ELSE ()
  # Set the plugin installation path. This is a good default for UNIX-like
  # systems, but is not appropriate for Windows.
  SET(TeXworks_PLUGIN_DIR lib/texworks CACHE PATH "Path where TeXworks looks for plugins")
  MARK_AS_ADVANCED(TeXworks_PLUGIN_DIR)
ENDIF ()

# Build main TeXworks application
# -------------------------------
add_subdirectory (src)

# Build Plugins
# -------------

# Build scripting language plugins if the required libraries are available.
IF ( LUA_FOUND AND WITH_LUA )
  ADD_SUBDIRECTORY(${TeXworks_SOURCE_DIR}/plugins-src/TWLuaPlugin)
ENDIF ()

IF ( PYTHONLIBS_FOUND AND WITH_PYTHON )
  ADD_SUBDIRECTORY(${TeXworks_SOURCE_DIR}/plugins-src/TWPythonPlugin)
ENDIF ()

# Tests
# -----
if (WITH_TESTS)
  add_subdirectory(unit-tests)
endif ()


# Packaging
# =========

# This section is responsible for executing all tasks that run when a user
# invokes `cpack` or `make package` after executing their platform's equivalent
# of of `make`. The packaging tasks are responsible for two things:
#
#  * Applying transformations to the compiled binaries such that they can be
#    distributed to another machine.
#
#  * Gathering all binaries and libraries and packaging them into an archive
#    suitable for distribution such as a Windows installer or Mac disk image
#    file.

# Gather all libraries related to Qt plugins used by TeXworks so that they can
# be bundled into packages. (Required on APPLE for a consistent macOS look&feel)
foreach (_target ${Qt5Gui_PLUGINS} ${Qt5Widgets_PLUGINS})
	get_target_property(_path ${_target} LOCATION_Release)
	list(APPEND QT_PLUGINS ${_path})
endforeach()

# The file `CMake/packaging/CMakeLists.txt` controls the execution of tasks
# specific to preparing binaries for packaging on a given platform. This script
# is invoked via `ADD_SUBDIRECTORY` so that it executes after TeXworks and its
# components are built and installed. You cannot fixup an application bundle
# before it has been created...
ADD_SUBDIRECTORY(${PROJECT_SOURCE_DIR}/CMake/packaging)

# Set CPack variables.
SET(CPACK_PACKAGE_VERSION_MAJOR ${TeXworks_VER_MAJOR})
SET(CPACK_PACKAGE_VERSION_MINOR ${TeXworks_VER_MINOR})
SET(CPACK_PACKAGE_VERSION_PATCH ${TeXworks_VER_PATCH})
SET(CPACK_PACKAGE_VERSION ${TeXworks_VERSION})

SET(CPACK_PACKAGE_NAME ${PROJECT_NAME})

# Configure Drag N' Drop installer.
IF ( APPLE )
  SET(MAC_PACK_BITS "${CMAKE_SOURCE_DIR}/CMake/packaging/mac")
  SET(CPACK_GENERATOR DragNDrop)
  SET( CPACK_DMG_BACKGROUND_IMAGE "${MAC_PACK_BITS}/texworks_dmg_background.png" )
  # Configure an AppleScript for applying a nice window layout to Drag N' Drop disk
  # image.
  set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${MAC_PACK_BITS}/DMGSetup.scpt")
ENDIF ()

INCLUDE(CPack)


# ANCHOR: Summary
# Summary
# =======

# This section displays a nice configuration summary for the user.

twx_config_begin(BOLD_GREEN "TeXworks has been configured (CMake ${CMAKE_VERSION}, ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}):\n")
twx_config_begin(BOLD_MAGENTA "Version info")
twx_config_log("${PROJECT_NAME}" "${TeXworks_VERSION} (${TeXworks_GIT_HASH}, ${TeXworks_GIT_DATE}, ${TeXworks_GIT_BRANCH})")
# Hunspell does not have a reliable way to determine its version
twx_config_log_kv("Hunspell" FLAG HUNSPELL_FOUND)
IF ( WITH_LUA )
  twx_config_log("Lua" "${LUA_VERSION_STRING}")
ENDIF()
if (WITH_PYTHON)
  twx_config_log("Python" "${PYTHON_VERSION_STRING}")
endif()
twx_config_log("Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH})
twx_config_log("SyncTeX" "${SYNCTEX_VERSION_STRING}")
twx_config_log("zlib" "${ZLIB_VERSION_STRING}")
twx_config_end()

twx_config_begin(BOLD_MAGENTA "Scripting")
twx_config_log_kv("ECMA scripting" FLAG "ON")
twx_config_log_kv("QtScript scripting" FLAG WITH_QTSCRIPT)
twx_config_log_kv("Lua scripting plugin" FLAG LUA_FOUND)
twx_config_log_kv("Python scripting plugin" FLAG PYTHONLIBS_FOUND)
twx_config_end  ()

twx_config_log("Build ID" ${TW_BUILD_ID})
twx_config_log("Compiler optimization" ${CMAKE_BUILD_TYPE})
if( APPLE )
  twx_config_log_kv("OS X system python" FLAG USE_SYSTEM_PYTHON)
endif()
twx_config_log("")

twx_config_begin(BOLD_BLUE "Libraries" VERBOSE)
twx_config_log_kv ("Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES)
twx_config_log_kv ("TeXworks" VAR TeXworks_LIBS)
twx_config_log_kv ("TeXworks additional" VAR TEXWORKS_ADDITIONAL_LIBS)
twx_config_end  ()

twx_config_begin(BOLD_BLUE "Build settings" VERBOSE)
twx_config_log_kv ("Compile definitions" VAR COMPILE_DEFINITIONS)
twx_config_log_kv ("Compile options" VAR COMPILE_OPTIONS)
twx_config_end  ()

twx_config_end  (NO_EOL)

twx_config_begin(BOLD_GREEN "TeXworks will be installed to:")
twx_config_log  ("  ${CMAKE_INSTALL_PREFIX}")

twx_config_end  ()
