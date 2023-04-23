#[=====================================[

The build system has been improved to help people develop and test
new features without building the whole TeXworks package.

#]=====================================]

# CMake 3.1 significantly improves support for imported targets, Qt5, c++11, etc.
# This must be first
cmake_minimum_required ( VERSION 3.1 )

# Always start with the base
include (
  "${CMAKE_CURRENT_LIST_DIR}/CMake/Include/Base.cmake"
  NO_POLICY_SCOPE
)
# ANCHOR: Project
# Set project name.
project ( TeXworks )
# Include the base once again to finish setup
include ( Base )
include ( TwxVersionSetup )
include ( TwxGitSetup )
# Declare Project Options
# -----------------------

# These are options that users can set at configure-time to determine how the
# application is built and what functionalities it will have. Here we declare
# these options by setting default values.

set (
  TW_BUILD_ID "personal"
  CACHE
  STRING "A distribution-specific identifier for TeXworks"
)

# Build with shared libs by default
OPTION ( TWX_BUILD_SHARED_LIBRARIES "Build with shared libs?" ON )
MARK_AS_ADVANCED ( TWX_BUILD_SHARED_LIBRARIES )

# Build shared plugins by default
OPTION ( TWX_BUILD_SHARED_PLUGINS "Build shared plugins?" ${TWX_BUILD_SHARED_LIBRARIES} )
MARK_AS_ADVANCED ( TWX_BUILD_SHARED_PLUGINS )

OPTION ( TWX_PREFER_BUNDLED_SyncTeX "Use SyncTeX bundled with TeXworks even if a shared library is found?" OFF )
MARK_AS_ADVANCED ( TWX_PREFER_BUNDLED_SyncTeX )

OPTION ( TWX_WITH_TESTS "build unit tests" ON )
IF ( TWX_WITH_TESTS )
  ENABLE_TESTING ( TRUE )
ENDIF ( TWX_WITH_TESTS )

option ( TWX_WITH_COVERAGE "build with lcov coverage support" OFF )
if ( TWX_WITH_COVERAGE )
  if ( NOT ( CMAKE_BUILD_TYPE STREQUAL "Debug" AND TWX_WITH_TESTS ))
    message (
      WARNING
      "Coverage support is intended to be used with Debug builds and testing enabled"
    )
  endif ()
  include ( CodeCoverage )
  set (
    COVERAGE_COMPILER_FLAGS
    "${COVERAGE_COMPILER_FLAGS} -fno-inline"
  )
  append_coverage_compiler_flags ()
  if ( UNIX )
    set ( COVERAGE_LCOV_EXCLUDES '/usr/*' )
  endif ()
  setup_target_for_coverage_lcov ( NAME coverage EXECUTABLE "${CMAKE_CTEST_COMMAND}" )
endif ( TWX_WITH_COVERAGE )

SET ( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} CACHE PATH "Path to place libraries in" )
SET ( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR} CACHE PATH "Path to place programs in" )
MARK_AS_ADVANCED ( CMAKE_LIBRARY_OUTPUT_DIRECTORY CMAKE_RUNTIME_OUTPUT_DIRECTORY )

# On UNIX, CMake installs to `/usr/local` by default. However, Mac users
# will probably find `/Applications` a more convenient default.
if ( APPLE AND CMAKE_INSTALL_PREFIX MATCHES "/usr/local" )
  set ( CMAKE_INSTALL_PREFIX "/Applications" )
endif ()

# Do an optimized release build by default
IF ( NOT CMAKE_BUILD_TYPE )
  SET ( CMAKE_BUILD_TYPE "Release" )
ENDIF ()

# Options controlling the creation of scripting language plugins.
OPTION ( TWX_WITH_LUA "Build TeXworks Lua plugin?" ON )
OPTION ( TWX_WITH_PYTHON "Build TeXworks Python plugin?" OFF )

# On OS X we default to linking against the Python libraries provided by Apple
# even if other Pythons are available. This helps when building
# re-distributable `.app` packages. By disabling this option, a Mac user can
# link against whatever Python they wish for a personal build.
IF ( APPLE )
  OPTION ( USE_SYSTEM_PYTHON "Link against Python Framework distributed with OS X?" ON )
ENDIF ()

IF ( UNIX AND NOT APPLE )
  SET ( TeXworks_HELP_DIR share/doc/texworks-help CACHE PATH "Path where TeXworks looks for help files" )
  SET ( TeXworks_DIC_DIR /usr/share/hunspell:/usr/share/myspell/dicts CACHE PATH "Path where TeXworks looks for spellchecking dictionaries" )
  SET ( TeXworks_DOCS_DIR share/doc/texworks CACHE PATH "Path in which documentation files are installed" )
  SET ( TeXworks_ICON_DIR share/icons/hicolor CACHE PATH "Path in which icons are installed" )
  SET ( TeXworks_MAN_DIR share/man/man1 CACHE PATH "Path in which manpages are installed" )
  SET ( TeXworks_DESKTOP_DIR share/applications CACHE PATH "Path in which .desktop files are installed" )
  SET ( TeXworks_APPDATA_DIR share/metainfo CACHE PATH "Path in which .appdata.xml files are installed" )
  MARK_AS_ADVANCED ( TeXworks_HELP_DIR )
  MARK_AS_ADVANCED ( TeXworks_DIC_DIR )
  MARK_AS_ADVANCED ( TeXworks_DOCS_DIR )
  MARK_AS_ADVANCED ( TeXworks_ICON_DIR )
  MARK_AS_ADVANCED ( TeXworks_MAN_DIR )
  MARK_AS_ADVANCED ( TeXworks_DESKTOP_DIR )
  MARK_AS_ADVANCED ( TeXworks_APPDATA_DIR )
  IF ( EXISTS ${TeXworks_SOURCE_DIR}/manual/ )
    INSTALL ( DIRECTORY ${TeXworks_SOURCE_DIR}/manual/ DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_HELP_DIR}/ OPTIONAL )
  ENDIF ()
ENDIF ()

# Dependency Configuration
# ========================

# ANCHOR: Qt

include ( WithQt )
include ( WithQtPlugins )

twx_append_QT(
  REQUIRED Widgets Gui UiTools Concurrent Xml Qml
)
find_package ( ${QtMAJOR} REQUIRED COMPONENTS LinguistTools )

if ( UNIX AND NOT APPLE )
  twx_append_QT ( REQUIRED DBus )
endif ()

if ( QT_VERSION_MAJOR EQUAL 6 )
	# Check for Qt6
  twx_append_QT ( REQUIRED Core5Compat )
  twx_setup_QT_PLUGINS ()

else ()
	# Check for Qt5
  twx_append_QT ( OPTIONAL Script ScriptTools )
	if ( ${QtMAJOR}Script_FOUND AND ${QtMAJOR}ScriptTools_FOUND )
		set ( WITH_QTSCRIPT ON )
	endif ()

	if ( WIN32 AND NOT TWX_BUILD_SHARED_LIBRARIES )
    twx_append_QT ( REQUIRED WindowsPlatformSupport )
	endif ()
  # Next instruction needs explanations
	set ( WITH_QTSCRIPT ON )
endif ()

if ( TWX_WITH_TESTS )
  twx_append_QT ( OPTIONAL Test )
  if ( NOT ${QtMAJOR}Test_FOUND )
    set ( TWX_WITH_TESTS OFF )
  endif ()
endif ()

FIND_PACKAGE ( ZLIB REQUIRED )
FIND_PACKAGE ( Hunspell REQUIRED )
FIND_PACKAGE ( Synctex QUIET )

# Aggregate library names and include directories into variables for easy
# access.

set ( TWX_LIBRARIES
  SyncTeX::synctex
  Hunspell::hunspell
  ${QT_LIBRARIES}
  ZLIB::ZLIB
  ${TWX_ADDITIONAL_LIBRARIES}
)


# Configure Optional Dependencies
# -------------------------------

IF ( TWX_WITH_LUA )
  find_package ( TwxLua )
ENDIF ()

IF ( TWX_WITH_PYTHON )
  IF ( USE_SYSTEM_PYTHON )
  # This is on apple only
    SET ( PYTHON_LIBRARIES "-F/System/Library/Frameworks -framework Python" CACHE PATH "Python library." )
    SET ( PYTHON_INCLUDE_DIR "/System/Library/Framework/Python.framework/Headers" CACHE PATH "Python framework." )
    MARK_AS_ADVANCED ( PYTHON_LIBRARIES )
    MARK_AS_ADVANCED ( PYTHON_INCLUDE_DIR )
    SET ( PythonLibs_FOUND TRUE )
  ELSE ()
    # **NOTE**
    # In order to find the correct version of 'PythonLibs', it seems that we need to run 'FIND_PACKAGE ( PythonInterp )' firstly.
    # In order to find the correct version of 'PythonInterp', we need to set 'PYTHONHOME' environment variable
    FIND_PACKAGE ( PythonInterp )
    FIND_PACKAGE ( PythonLibs )
  ENDIF ()
ENDIF ()

IF ( LUA_FOUND AND TWX_WITH_LUA AND NOT ${TWX_BUILD_SHARED_PLUGINS} )
  ADD_DEFINITIONS ( -DQT_STATICPLUGIN -DTwxLuaPlugin_STATIC )
ENDIF ()

IF ( PythonLibs_FOUND AND TWX_WITH_PYTHON AND NOT ${TWX_BUILD_SHARED_PLUGINS} )
  ADD_DEFINITIONS ( -DQT_STATICPLUGIN -DSTATIC_PYTHON_SCRIPTING_PLUGIN )
ENDIF ()

# Building
# ========

# ANCHOR: WARNING
include ( InitWARNING )

# Build modules
add_subdirectory ( modules )

# Build Plugins
# -------------

# On OS X, the plugins should live inside the application bundle.
IF ( APPLE )
  SET ( TWX_PLUGIN_DIR ${PROJECT_NAME}.app/Contents/PlugIns )
  # Plugins are built as shared libraries that contain undefined symbols.
  # Pass `-undefined dynamic_lookup` so that the Apple linker does not
  # freak out about this.
  SET ( CMAKE_MODULE_LINKER_FLAGS
    "${CMAKE_MODULE_LINKER_FLAGS} -undefined dynamic_lookup" )
ELSEIF ( WIN32 )
  # Put plugins alongside the main app in the root installation folder on Windows
  SET ( TWX_PLUGIN_DIR . CACHE PATH "Path where TeXworks looks for plugins" )
  MARK_AS_ADVANCED ( TWX_PLUGIN_DIR )
ELSE ()
  # Set the plugin installation path. This is a good default for UNIX-like
  # systems, but is not appropriate for Windows.
  SET ( TWX_PLUGIN_DIR lib/texworks CACHE PATH "Path where TeXworks looks for plugins" )
  MARK_AS_ADVANCED ( TWX_PLUGIN_DIR )
ENDIF ()

# Build main TeXworks application
# -------------------------------
add_subdirectory ( src )

# Build Plugins
# -------------

# Build scripting language plugins if the required libraries are available.

add_subdirectory (
  ${TWX_DIR_plugins-src}/TwxLuaPlugin
)

add_subdirectory ( 
  ${TWX_DIR_plugins-src}/TwxPythonPlugin 
)

# Tests
# -----
add_subdirectory ( unit-tests )

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
# be bundled into packages. ( Required on APPLE for a consistent macOS look&feel )
foreach ( _target ${Qt5Gui_PLUGINS} ${Qt5Widgets_PLUGINS} )
	get_target_property( _path ${_target} LOCATION_Release )
	list ( APPEND QT_PLUGINS ${_path} )
endforeach ()

# The file `CMake/packaging/CMakeLists.txt` controls the execution of tasks
# specific to preparing binaries for packaging on a given platform. This script
# is invoked via `ADD_SUBDIRECTORY` so that it executes after TeXworks and its
# components are built and installed. You cannot fixup an application bundle
# before it has been created...

add_subdirectory ( "${TWX_DIR_CMake}/packaging" )

# Set CPack variables.
SET ( CPACK_PACKAGE_VERSION_MAJOR ${TWX_VERSION_MAJOR} )
SET ( CPACK_PACKAGE_VERSION_MINOR ${TWX_VERSION_MINOR} )
SET ( CPACK_PACKAGE_VERSION_PATCH ${TWX_VERSION_PATCH} )
SET ( CPACK_PACKAGE_VERSION ${TWX_VERSION} )

SET ( CPACK_PACKAGE_NAME ${PROJECT_NAME} )

# Configure Drag N' Drop installer.
if ( APPLE )
  set (
    MAC_PACK_BITS
    "${TWX_DIR_CMake}/packaging/mac"
  )
  set ( CPACK_GENERATOR DragNDrop )
  set (
    CPACK_DMG_BACKGROUND_IMAGE
    "${MAC_PACK_BITS}/texworks_dmg_background.png"
  )
  # Configure an AppleScript for applying a nice window layout to Drag N' Drop disk
  # image.
  set (
    CPACK_DMG_DS_STORE_SETUP_SCRIPT
    "${MAC_PACK_BITS}/DMGSetup.scpt"
  )
endif ()

include ( CPack )


# ANCHOR: Summary
# Summary
# =======

# This section displays a nice configuration summary for the user.

twx_config_begin ( BOLD_GREEN "TeXworks has been configured ( CMake ${CMAKE_VERSION}, ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION} ):\n" )
twx_config_begin ( BOLD_MAGENTA "Version info" )
twx_config_log ( "${PROJECT_NAME}" "${TeXworks_VERSION} ( ${TeXworks_GIT_HASH}, ${TeXworks_GIT_DATE}, ${TeXworks_GIT_BRANCH} )" )
# Hunspell does not have a reliable way to determine its version
twx_config_log_kv ( "Hunspell" FLAG HUNSPELL_FOUND )
IF ( TWX_WITH_LUA )
  twx_config_log ( "Lua" "${LUA_VERSION_STRING}" )
ENDIF ()
if ( TWX_WITH_PYTHON )
  twx_config_log ( "Python" "${PYTHON_VERSION_STRING}" )
endif ()
twx_config_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_config_log ( "SyncTeX" "${SyncTeX_VERSION}" )
twx_config_log ( "zlib" "${ZLIB_VERSION_STRING}" )
twx_config_end ()

twx_config_begin ( BOLD_MAGENTA "Scripting" )
twx_config_log_kv ( "ECMA scripting" FLAG "ON" )
twx_config_log_kv ( "QtScript scripting" FLAG WITH_QTSCRIPT )
twx_config_log_kv ( "Lua scripting plugin" FLAG LUA_FOUND )
twx_config_log_kv ( "Python scripting plugin" FLAG PythonLibs_FOUND )
twx_config_end  ()

twx_config_log ( "Build ID" ${TW_BUILD_ID} )
twx_config_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
if( APPLE )
  twx_config_log_kv ( "OS X system python" FLAG USE_SYSTEM_PYTHON )
endif ()
twx_config_log ( "" )

twx_config_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_config_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_config_log_kv ( "TeXworks" VAR TWX_LIBRARIES )
twx_config_log_kv ( "TeXworks additional" VAR TWX_ADDITIONAL_LIBRARIES )
twx_config_end  ()

twx_config_begin ( BOLD_BLUE "Build settings" VERBOSE )
twx_config_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
twx_config_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
twx_config_end  ()

twx_config_end  ( NO_EOL )

twx_config_begin ( BOLD_GREEN "TeXworks will be installed to:" )
twx_config_log  ( "  ${CMAKE_INSTALL_PREFIX}" )

twx_config_end  ()
