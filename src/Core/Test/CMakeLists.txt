# This is .../src/Core/Test/CmakeLists.txt

# Main files
get_filename_component(
	TWX_d
	"${CMAKE_CURRENT_LIST_DIR}"
	DIRECTORY
)
include ("${TWX_d}/CMakeLists.txt")

if (NOT TWX_DIR_ROOT)
	# Actual location .../src/Core/Test
	# We look for .../src/Core/../../..
	get_filename_component(
		TWX_DIR_ROOT
		"${CMAKE_CURRENT_LIST_DIR}/../../.."
		REALPATH
	)
	
	message("TWX_DIR_ROOT => ${TWX_DIR_ROOT}")

endif ()
if (NOT PROJECT_NAME)

	cmake_minimum_required(VERSION 3.1)
	project(TeXworksTest)
	CMAKE_POLICY(VERSION 3.1)

	# Silence warning about linking to qtmain.lib statically on Windows
	IF(POLICY CMP0020)
		cmake_policy(SET CMP0020 NEW)
	ENDIF()

	# Silence warning about using @rpath on OS X.
	if(POLICY CMP0042)
		cmake_policy(SET CMP0042 NEW)
	endif()

	# Silence warning about ninja custom command byproducts
	if(POLICY CMP0058)
		cmake_policy(SET CMP0058 NEW)
	endif()

	# Prefer newer OpenGL libraries over legacy ones
	if (POLICY CMP0072)
		cmake_policy(SET CMP0072 NEW)
	endif ()

	# Silence warning about option() treating variables differently on the first run
	if(POLICY CMP0077)
		cmake_policy(SET CMP0077 NEW)
	endif()
		
	SET(CMAKE_COLOR_MAKEFILE ON)
	# Always add the current source and binary directories to the header include
	# path when compiling.
	SET(CMAKE_INCLUDE_CURRENT_DIR ON)
	SET(CMAKE_AUTOMOC TRUE)
	SET(CMAKE_AUTORCC TRUE)
	SET(CMAKE_AUTOUIC TRUE)

	# Make the contents of `CMake/Modules` available. Among other things, this
	# directory contains scripts that locate project components such as hunspell.
	SET(CMAKE_MODULE_PATH "${TWX_DIR_ROOT}/CMake/Modules" "${TWX_DIR_ROOT}/modules/QtPDF/CMake/Modules" ${CMAKE_MODULE_PATH})

	IF(WIN32 AND MINGW)
		# Ensure that no cpp flags are passed to windres, the Windows resource compiler.
		# At least with MinGW 4 on Windows, that would cause problems
		SET(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> -O coff <DEFINES> <SOURCE> <OBJECT>")
	ENDIF()

	if (MSVC)
		add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
		add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
	endif (MSVC)


	# Determine Version Numbers
	# -------------------------

	# The values recovered here are used in the filenames of packaged builds and
	# influence parts of the application such as the "About" dialog.

	#include(TeXworksVersion)
	#
	#GetTeXworksVersion()
	#UpdateGitRevInfo()
	#GetGitRevInfo()

	# Recover canonical (x.y.z) version number from `src/TWVersion.h`.
	FILE(STRINGS ${TWX_DIR_ROOT}/src/TWVersion.h TeXworks_VER_MAJOR REGEX "VER_MAJOR")
	STRING(REGEX MATCH "([0-9]+)" TeXworks_VER_MAJOR ${TeXworks_VER_MAJOR})
	FILE(STRINGS ${TWX_DIR_ROOT}/src/TWVersion.h TeXworks_VER_MINOR REGEX "VER_MINOR")
	STRING(REGEX MATCH "([0-9]+)" TeXworks_VER_MINOR ${TeXworks_VER_MINOR})
	FILE(STRINGS ${TWX_DIR_ROOT}/src/TWVersion.h TeXworks_VER_PATCH REGEX "VER_BUGFIX")
	STRING(REGEX MATCH "([0-9]+)" TeXworks_VER_PATCH ${TeXworks_VER_PATCH})
	SET(TeXworks_VERSION ${TeXworks_VER_MAJOR}.${TeXworks_VER_MINOR}.${TeXworks_VER_PATCH})

	# Make sure we have up-to-date git commit infos
	execute_process(COMMAND "${CMAKE_COMMAND}" "-DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}/src" -P "${TWX_DIR_ROOT}/CMake/Modules/getGitRevInfo.cmake" WORKING_DIRECTORY "${TWX_DIR_ROOT}")
	add_custom_target(GitRev ALL "${CMAKE_COMMAND}" "-DOUTPUT_DIR=${CMAKE_CURRENT_BINARY_DIR}/src" -P "${TWX_DIR_ROOT}/CMake/Modules/getGitRevInfo.cmake" WORKING_DIRECTORY "${TWX_DIR_ROOT}" COMMENT "Update git commit info")

	# Recover git commit info from `src/GitRev.h`.
	FILE(STRINGS ${CMAKE_CURRENT_BINARY_DIR}/src/GitRev.h TeXworks_GIT_INFO)
	LIST(GET TeXworks_GIT_INFO 1 TeXworks_GIT_COMMIT)
	STRING(REGEX REPLACE "#define GIT_COMMIT_HASH \"([a-f0-9]+\\*?)\"" "\\1" TeXworks_GIT_HASH "${TeXworks_GIT_COMMIT}")
	LIST(GET TeXworks_GIT_INFO 2 TeXworks_GIT_COMMIT)
	STRING(REGEX REPLACE "#define GIT_COMMIT_DATE \"([-+:0-9TZ]+)\"" "\\1" TeXworks_GIT_DATE "${TeXworks_GIT_COMMIT}")


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

	set (CMAKE_CXX_STANDARD 11)

	# Dependency Configuration
	# ========================

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

		set(QT_VERSION_MAJOR "${Qt6_VERSION_MAJOR}")
		set(QT_VERSION_MINOR "${Qt6_VERSION_MINOR}")
		set(QT_VERSION_PATCH "${Qt6_VERSION_PATCH}")
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

		set(QT_VERSION_MAJOR "${Qt5_VERSION_MAJOR}")
		set(QT_VERSION_MINOR "${Qt5_VERSION_MINOR}")
		set(QT_VERSION_PATCH "${Qt5_VERSION_PATCH}")
		set(WITH_QTSCRIPT ON)
	endif ()

	# Expose the major version number of Qt to the preprocessor. This is necessary
	# to include the correct Qt headers (as QTVERSION is not defined before any Qt
	# headers are included)
	ADD_DEFINITIONS(-DQT_VERSION_MAJOR=${QT_VERSION_MAJOR})
endif (NOT PROJECT_NAME)

include_directories(
	"${TWX_DIR_ROOT}/src"
	"${CMAKE_CURRENT_LIST_DIR}"
	${TeXworks_INCLUDE_DIRS}
)

# Test

add_executable(
	test_Core
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.h"
	"${CMAKE_CURRENT_LIST_DIR}/DefaultBinaryPaths.h"
	${Twx_Core_SOURCES}
	${Twx_Core_HEADERS}
	"${TWX_DIR_ROOT}/src/Settings.cpp"
	"${TWX_DIR_ROOT}/src/Settings.h"
)
target_compile_options(
	test_Core
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries(
	test_Core
	${QT_LIBRARIES}
)
target_compile_definitions(
	test_Core
	PRIVATE Twx_Core_TEST
)
add_test(
	NAME test_Core
	COMMAND test_Core
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/TestCase"
)
