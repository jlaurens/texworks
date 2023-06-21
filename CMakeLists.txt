#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks

*//** @file
@brief The root CMakeLists file

This is the top level CMakeLists file
*//*
#]===============================================]


# Top-level build file for [TeXworks][tw], a simple editor for TeX and friends.
#
# This buildsystem uses [CMake][cmake] and consists of the following files:
#
# <pre>
#   TeXworks
#   ├── <a href="CMakeLists.html">CMakeLists.txt</a>
#   ├── src
#   │   └── <a href="src/CMakeLists.html">CMakeLists.txt</a>
#   ├── modules
#   │   ├── <a href="modules/CMakeLists.html">CMakeLists.txt</a>
#   │   ├── synctex
#   │   │   └── <a href="modules/synctex/CMakeLists.html">CMakeLists.txt</a>
#   │   └── QtPDF (documented separately)
#   ├── plugins-src
#   │   ├── TWLuaPlugin
#   │   │   └── <a href="plugins-src/TWLuaPlugin/CMakeLists.html">CMakeLists.txt</a>
#   │   └── TWPythonPlugin
#   │       └── <a href="plugins-src/TWPythonPlugin/CMakeLists.html">CMakeLists.txt</a>
#   ├── unit-tests
#   │   └── <a href="unit-tests/CMakeLists.html">CMakeLists.txt</a>
#   └── CMake
#       └── packaging
#           ├── <a href="Package/CMakeLists.html">CMakeLists.txt</a>
#           └── mac
#               └── <a href="Package/mac/MacPackagingTasks.cmake.html">MacPackagingTasks.in.cmake</a>
# </pre>
#
# Using CMake as a buildsystem offers some nice advantages:
#
#   * Supports component discovery and configuration for all three major
#     operating systems and can set TeXworks up to be built using GNU
#     Makefiles, XCode or Visual Studio.
#
#   * Includes CPack, a tool which simplifies the task of packaging the
#     TeXworks app for release after it has been built. CPack can generate
#     Drag N' Drop installers for the Mac, Nullsoft installers for Windows and
#     `.deb` or `.rpm` packages for Linux.
#
# Comments in the CMake files follow [Markdown][md] formatting conventions.
# This convention allows the `CMakeLists.txt` files to be passed through a tool
# such as [Docco][docco] to create a nicely annotated README for the benefit of
# future developers and maintainers.
#
#   [cmake]: http://www.cmake.org
#   [docco]: http://jashkenas.github.com/docco
#   [md]: http://daringfireball.net/projects/markdown/
#   [tw]: https://github.com/TeXworks/texworks


# Setup and User Options
# ======================

cmake_minimum_required ( VERSION 3.13 )

include (
  ${CMAKE_CURRENT_LIST_DIR}/CMake/Include/TwxBase.cmake
  NO_POLICY_SCOPE
)
# Set project name.
project ( ${TWX_NAME} )
twx_base_after_project ()
include ( TwxCfgLib )
twx_cfg_setup ()

IF(WIN32 AND MINGW)
  # Ensure that no cpp flags are passed to windres, the Windows resource compiler.
  # At least with MinGW 4 on Windows, that would cause problems
  SET(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> -O coff <DEFINES> <SOURCE> <OBJECT>")
ENDIF()

if (MSVC)
	add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
	add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
endif (MSVC)

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
    SET(COVERAGE_LCOV_EXCLUDES '/usr/*')#*/ balance the long comment
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
  SET(TeXworks_HELP_DIR share/doc/${TWX_COMMAND}-help CACHE PATH "Path where TeXworks looks for help files")
  SET(TeXworks_DIC_DIR /usr/share/hunspell:/usr/share/myspell/dicts CACHE PATH "Flat path list where TeXworks looks for spellchecking dictionaries")
  SET(TeXworks_DOCS_DIR share/doc/${TWX_COMMAND} CACHE PATH "Path in which documentation files are installed")
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
  IF (EXISTS ${TWX_DIR}manual/)
    INSTALL(DIRECTORY ${TWX_DIR}/manual/ DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_HELP_DIR}/ OPTIONAL)
  ENDIF()
ENDIF()

# Dependency Configuration
# ========================

include ( TwxQtLib )

if (QT_DEFAULT_MAJOR_VERSION EQUAL 6)
	# Check for Qt6
	find_package(Qt6 REQUIRED COMPONENTS Core Core5Compat Widgets Gui UiTools Concurrent Xml LinguistTools Qml)
	set(QT_LIBRARIES Qt6::Core Qt6::Core5Compat Qt6::Widgets Qt6::Gui Qt6::UiTools Qt6::Concurrent Qt6::Xml Qt6::Qml)

	if (UNIX AND NOT APPLE)
	  find_package(Qt6 REQUIRED COMPONENTS DBus)
	  list(APPEND QT_LIBRARIES Qt6::DBus)
	endif ()

	if (WITH_TESTS)
	  find_package(Qt6 OPTIONAL_COMPONENTS Test QUIET)
	  if (NOT Qt6Test_FOUND)
		set(WITH_TESTS OFF)
	  else ()
		list(APPEND QT_LIBRARIES Qt6::Test)
	  endif ()
	endif ()

	if (APPLE)
		# Inspired by https://github.com/MaximAlien/macdeployqt/blob/bc9c0ba199f323a42e3f1cc04d4b66e3e59ac995/macdeployqt/shared.cpp
		if (QT_PLUGIN_PATH)
			set(_pluginDir "${QT_PLUGIN_PATH}")
		else ()
			get_target_property(_pluginDir Qt6::Widgets LOCATION)
			get_filename_component(_pluginDir "${_pluginDir}" REALPATH)
			get_filename_component(_pluginDir "${_pluginDir}" DIRECTORY)
			set(_pluginDir "${_pluginDir}/../../../../share/qt/plugins")
			get_filename_component(_pluginDir "${_pluginDir}" REALPATH)
		endif ()

		foreach (_lib IN ITEMS platforms/qcocoa styles/qmacstyle)
			get_filename_component(_lib_name ${_lib} NAME)
			get_filename_component(_lib_dir ${_lib} DIRECTORY)
			find_library(_plugin_${_lib_name} NAMES ${_lib_name} HINTS ${_pluginDir} PATH_SUFFIXES ${_lib_dir})
			if (NOT _plugin_${_lib_name})
				message(FATAL_ERROR "Could not find plugin ${_lib} in ${_pluginDir}")
			else ()
				list(APPEND QT_PLUGINS "${_plugin_${_lib_name}}")
			endif ()
		endforeach ()

		message(STATUS "QT_PLUGINS = ${QT_PLUGINS}")
	endif ()

else ()
	# Check for Qt5
	find_package(Qt5 REQUIRED COMPONENTS Core Widgets Gui UiTools Concurrent Xml LinguistTools Qml OPTIONAL_COMPONENTS Script ScriptTools)
	set(QT_LIBRARIES Qt5::Core Qt5::Widgets Qt5::Gui Qt5::UiTools Qt5::Concurrent Qt5::Xml Qt5::Qml)

	if (Qt5Script_FOUND AND Qt5ScriptTools_FOUND)
		list(APPEND QT_LIBRARIES Qt5::ScriptTools Qt5::Script)
		set(WITH_QTSCRIPT ON)
	endif()

	if (UNIX AND NOT APPLE)
	  find_package(Qt5 REQUIRED COMPONENTS DBus)
	  list(APPEND QT_LIBRARIES Qt5::DBus)
	endif ()

	if (WITH_TESTS)
	  find_package(Qt5 OPTIONAL_COMPONENTS Test QUIET)
	  if (NOT Qt5Test_FOUND)
		set(WITH_TESTS OFF)
	  else ()
		list(APPEND QT_LIBRARIES Qt5::Test)
	  endif ()
	endif ()

	if (WIN32 AND NOT BUILD_SHARED_LIBS)
	  find_package(Qt5WindowsPlatformSupport)
	  list(APPEND QT_LIBRARIES Qt5::WindowsPlatformSupport)
	endif ()

	set(WITH_QTSCRIPT ON)
endif ()

FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(Hunspell REQUIRED)
FIND_PACKAGE(Synctex QUIET)

# Aggregate library names and include directories into variables for easy
# access.

SET(TeXworks_LIBRARIES
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

# Building
# ========

if (MSVC)
	set(WARNING_OPTIONS /W4)
else ()
	set(WARNING_OPTIONS -Wall -Wpedantic -Wextra -Wconversion -Wold-style-cast -Woverloaded-virtual)
	if (NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "5.6.0")
		# Old Qt versions were heavily using 0 instead of nullptr, giving lots
		# of false positives
		list(APPEND WARNING_OPTIONS -Wzero-as-null-pointer-constant)
	endif ()
endif ()

include ( TwxDoxydocLib )
twx_doxydoc ()

# Build modules
add_subdirectory ( modules TwxModules )

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
if ( APPLE )
  set ( TWX_GUI_TYPE MACOSX_BUNDLE )
  set (
    TWX_APP_ICONS
    "${TWX_DIR}res/os_darwin/TeXworks.icns"
    "${TWX_DIR}res/os_darwin/TeXworks-doc.icns"
  )
  set_source_files_properties (
    ${TWX_APP_ICONS}
    PROPERTIES
      MACOSX_PACKAGE_LOCATION Resources
  )
endif ( APPLE )

# **WARNING:** _Windows is untested_
if ( WIN32 )
  set ( TWX_GUI_TYPE WIN32 )
endif ()

add_executable (
  TeXworks
  ${TWX_GUI_TYPE}
  ${TWX_APP_ICONS}
)

# For OS X, generate `Info.plist` and add it to the `.app` bundle.
if ( APPLE )
  set (
    input_
    "${TWX_DIR}res/os_darwin/${TWX_NAME}.in.plist"
  )
  set (
    output_
    "${TWX_PROJECT_BUILD_DIR}res/os_darwin/${TWX_NAME}.plist"
  )
  twx_state_serialize ()
  add_custom_command (
    COMMAND "${CMAKE_COMMAND}"
    "-DTWX_INPUT=${PROJECT_NAME}"
    "-DTWX_OUTPUT=${PROJECT_BINARY_DIR}"
    "${TWX_STATE_ARGUMENT}"
    -P "${TWX_DIR}CMake/Command/TwxCfgOneFileCommand.cmake"
    DEPENDS
      ${TWX_${PROJECT_NAME}_INI}
    COMMENT
      "Update ${PROJECT_NAME} factory Cfg information"
    OUTPUT "${OUTPUT}"
  )
  set_target_properties (
    TeXworks
    PROPERTIES
      MACOSX_BUNDLE_INFO_PLIST "${OUTPUT}"
  )
  # twx_cfg_files (
  #   ID 			PACKAGE_DARWIN
  #   FILES 	${TWX_NAME}.in.plist
  #   IN_DIR 	"${TWX_DIR}res/os_darwin"
  #   OUT_DIR "${TWX_PROJECT_BUILD_DIR}res/os_darwin"
  #   EXPORT  twx
  # )
  # set_target_properties (
  #   TeXworks
  #   PROPERTIES
  #     MACOSX_BUNDLE_INFO_PLIST ${twx_PACKAGE_DARWIN}
  # )
  # twx_assert_non_void ( twx_PACKAGE_DARWIN_target ) 
  # add_dependencies(
  #   TeXworks
  #   ${twx_PACKAGE_DARWIN_target}
  # )
endif ()

target_compile_definitions ( 
  TeXworks
  PRIVATE TW_BUILD_ID="${TW_BUILD_ID}"
)

macro ( twx_target_add_path_define target_ name_ path_ )
  if ( IS_ABSOLUTE ${path_} )
    target_compile_definitions ( ${target_} PRIVATE ${name_}="${path_}" )
  else ()
    target_compile_definitions ( ${target_} PRIVATE ${name_}="${CMAKE_INSTALL_PREFIX}/${path_}" )
  endif ()
endmacro ()

if ( UNIX AND NOT APPLE )
  twx_target_add_path_define ( TeXworks "TW_HELPPATH"      "${TeXworks_HELP_DIR}" )
  twx_target_add_path_define ( TeXworks "TW_PLUGINPATH"  "${TeXworks_PLUGIN_DIR}" )
  twx_target_add_path_define ( TeXworks "TW_DICPATH"      "${TeXworks_DIC_DIR}" )
  twx_target_add_path_define ( TeXworks "TWX_DICTIONARY_PATH" "${TeXworks_DIC_DIR}" )
endif ()

# Change the name of the output, here comes the "-dev" suffix
if (UNIX AND NOT APPLE)
  set_target_properties(
    TeXworks
    PROPERTIES
      OUTPUT_NAME ${TWX_COMMAND}
  )
else ()
  set_target_properties (
    TeXworks
    PROPERTIES
      OUTPUT_NAME ${TWX_NAME}
  )
endif ()

# TODO: put the .app bundles in the build product directory
# set_target_properties(
#   TeXworks
#   PROPERTIES
#     RUNTIME_OUTPUT_DIRECTORY ${TWX_PROJECT_PRODUCT_DIR}
# )

add_subdirectory ( src "${TWX_PROJECT_BUILD_DIR}src/" )

# Add translations
add_subdirectory ( trans "${TWX_PROJECT_BUILD_DIR}trans/" )

# On OS X, ensure there is always a `qt.conf` file as all hell will break loose
# if one isn't there.  This may need to be customized for use on non-Apple
# systems.
#
# Protip: If there are wierd errors like "Qt libraries loaded twice" or
# "looking for a tablet device", then something may have gone pear shaped with
# `qt.conf`.
if ( APPLE )
  set ( dir_ "${PROJECT_NAME}.app/Contents/Resources" )
  set ( contents_ "[Paths]\nPlugins = PlugIns" )

  install ( CODE
    "
    file ( WRITE
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${dir_}/qt.conf\"
      \"${contents_}\"
    )
    "
  )
endif ()

# Build Plugins
# -------------

# One package.sh needs the version 

twx_state_serialize ()
add_custom_command (
  TARGET TeXworks
  POST_BUILD
  COMMAND ${CMAKE_COMMAND}
    "-DTWX_CONTENTS=${TWX_CFG_VERSION}"
    "-DTWX_OUTPUT=${PROJECT_BINARY_DIR}/TwxVersion.txt"
    "${TWX_STATE_ARGUMENT}"
    -P "${TWX_DIR}CMake/Command/TwxWriteCommand.cmake"
)

# Build scripting language plugins if the required libraries are available.
IF ( LUA_FOUND AND WITH_LUA )
  ADD_SUBDIRECTORY(${TWX_DIR}plugins-src/TWLuaPlugin)
ENDIF ()

IF ( PYTHONLIBS_FOUND AND WITH_PYTHON )
  ADD_SUBDIRECTORY(${TWX_DIR}plugins-src/TWPythonPlugin)
ENDIF ()

# Tests
# -----
IF ( WITH_TESTS )
  add_subdirectory ( unit-tests "${TWX_PROJECT_BUILD_DIR}" )
endif ()

# Install
# -------
# Installation
# ------------
if (WIN32)
  # On Windows, put everything into the root install directory
  INSTALL(TARGETS TeXworks
    RUNTIME DESTINATION . COMPONENT
  )
else ()
  INSTALL(TARGETS TeXworks
    RUNTIME DESTINATION bin COMPONENT
    BUNDLE DESTINATION . COMPONENT
  )
endif ()

IF ( UNIX AND NOT APPLE )
  set ( images_DIR "${TWX_DIR}res/images" )
  set ( destination_DIR "${CMAKE_INSTALL_PREFIX}/${TeXworks_ICON_DIR}" )
  install (
    FILES "${images_DIR}/${TWX_NAME}.png"
    DESTINATION "${destination_DIR}/512x512/apps"
  )
  foreach ( s_twx 128 64 48 )
    install (
      FILES "${images_DIR}/${TWX_NAME}-${s_twx}.png"
      DESTINATION "${destination_DIR}/${s_twx}x${s_twx}/apps"
      RENAME ${TWX_NAME}.png
    )
  endforeach ()
  install (
    FILES
      "${TWX_DIR}COPYING"
      "${TWX_DIR}README.md"
      "${TWX_DIR}NEWS"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${TeXworks_DOCS_DIR}"
  )
  set ( code_ "" )
  
  install(
    CODE "
      set (
        TWX_CFG_INI_DIR
        \"${TWX_CFG_INI_DIR}\"
      )
      include ( \"${TWX_DIR}CMake/Include/TwxBase.cmake\" )
      include ( \"${TWX_DIR}CMake/Include/TwxCfgLib.cmake\" )
      twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
      configure_file (
        \"${TWX_DIR}res/os_other/${TWX_COMMAND}.in.1\"
        \"${TWX_PROJECT_BUILD_DIR}res/os_other/${TWX_COMMAND}.1\"
        @ONLY
      )
      configure_file (
        \"${TWX_DIR}res/os_other/${COMMAND}.in.desktop\"
        \"${TWX_PROJECT_BUILD_DIR}res/os_other/${COMMAND}.desktop\"
        @ONLY
      )
      configure_file (
        \"${TWX_DIR}res/os_other/${COMMAND}.in.appdata.xml\"
        \"${TWX_PROJECT_BUILD_DIR}res/os_other/${COMMAND}.appdata.xml\"
        @ONLY
      )
    "
  )
  install (
    FILES "${TWX_PROJECT_BUILD_DIR}res/os_other/${TWX_COMMAND}.1"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${TeXworks_MAN_DIR}"
  )
  install (
    FILES "${TWX_PROJECT_BUILD_DIR}res/os_other/${COMMAND}.desktop"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${TeXworks_DESKTOP_DIR}"
  )
  install (
    FILES "${TWX_PROJECT_BUILD_DIR}res/os_other/${COMMAND}.appdata.xml"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${TeXworks_APPDATA_DIR}"
  )
ENDIF ( UNIX AND NOT APPLE )

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

# The file `Package/CMakeLists.txt` controls the execution of tasks
# specific to preparing binaries for packaging on a given platform. This script
# is invoked via `ADD_SUBDIRECTORY` so that it executes after TeXworks and its
# components are built and installed. You cannot fixup an application bundle
# before it has been created...
add_subdirectory ( "${TWX_DIR}Package" )

# # Set CPack variables.
# SET(CPACK_PACKAGE_VERSION_MAJOR ${TWX_CFG_VERSION_MAJOR})
# SET(CPACK_PACKAGE_VERSION_MINOR ${TWX_CFG_VERSION_MINOR})
# SET(CPACK_PACKAGE_VERSION_PATCH ${TWX_CFG_VERSION_PATCH})
# SET(CPACK_PACKAGE_VERSION ${TWX_CFG_VERSION})

# SET(CPACK_PACKAGE_NAME ${TWX_NAME})

# # Configure Drag N' Drop installer.
# IF ( APPLE )
#   SET(mac_DIR_tws "${TWX_DIR}Package/mac")
#   SET(CPACK_GENERATOR DragNDrop)
#   SET( CPACK_DMG_BACKGROUND_IMAGE "${mac_DIR_tws}/texworks_dmg_background.png" )
#   # Configure an AppleScript for applying a nice window layout to Drag N' Drop disk
#   # image.
#   twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
#   configure_file (
#     "${mac_DIR_tws}/DMGSetup.in.scpt"
#     "${TWX_PROJECT_BUILD_DATA_DIR}DMGSetup.scpt"
#     @ONLY
#   )
#   set(CPACK_DMG_DS_STORE_SETUP_SCRIPT "${TWX_PROJECT_BUILD_DATA_DIR}DMGSetup.scpt" )
#   unset ( mac_DIR_tws )
# ENDIF ()

# INCLUDE(CPack)

# Summary
# =======

message ( "" )

include ( TwxSummaryLib )

twx_summary_begin (
	BOLD_GREEN
  "${TWX_NAME} has been configured (CMake ${CMAKE_VERSION})"
  EOL
)

twx_summary_section_compiler ()

twx_summary_begin (
  BOLD_MAGENTA
  "Version info"
)
twx_summary_log_kv (
  "${PROJECT_NAME}"
  "${TWX_CFG_VERSION} (${TWX_CFG_GIT_HASH}, ${TWX_CFG_GIT_DATE})"
)
# Hunspell does not have a reliable way to determine its version
twx_summary_log_kv (
  Hunspell FLAG HUNSPELL_FOUND
)
if ( WITH_LUA )
  twx_summary_log_kv ( "Lua" "${LUA_VERSION_STRING}" )
endif ()
if ( WITH_PYTHON )
twx_summary_log_kv ( "Python" "${PYTHON_VERSION_STRING}" )
endif()
twx_summary_log_kv ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_log_kv ( "SyncTeX" "${SYNCTEX_VERSION_STRING}")
twx_summary_log_kv ( "zlib" "${ZLIB_VERSION_STRING}"  )
twx_summary_end()

twx_summary_begin ( BOLD_MAGENTA "Scripting")
twx_summary_log_kv ( "ECMA scripting" FLAG ON)
twx_summary_log_kv ( "QtScript scripting" FLAG WITH_QTSCRIPT)
twx_summary_log_kv ( "Lua scripting plugin" FLAG LUA_FOUND)
twx_summary_log_kv ( "Python scripting plugin" FLAG PYTHONLIBS_FOUND)
if ( APPLE )
  twx_summary_log_kv ("OS X system python" FLAG USE_SYSTEM_PYTHON)
endif ()
twx_summary_end()

twx_summary_log_kv ( "Build ID" ${TW_BUILD_ID} )

MESSAGE("")

MESSAGE("  TeXworks will be installed to:")
MESSAGE("      ${CMAKE_INSTALL_PREFIX}")
MESSAGE("")

twx_summary_end ( EOL )

#[=======[
*/
#]=======]
