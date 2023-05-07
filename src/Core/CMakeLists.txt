#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/Core/CMakeLists.txt`

It can be used as standalone testing project,
testing auxiliary or source provider.

## Standalone testing project

When used as primary `CMakeLists.txt` it defines
a standalone test suite for `Twx::Core` namespace.

Usage from an external build directory:
```
cmake .../Core
cmake --build .
ctest .
```

## Subdirectory

When loaded by `add_subdirectory`.

### In testing context

It defines a test suite as part of a more general test.
See `/unit-tests/CMakeLists.txt`.

### In normal context

Output:
* `TwxCore_SOURCES`, a `;` separated list of full paths
* `TwxCore_HEADERS`, a `;` separated list of full paths

#]===============================================]

set ( TwxCore_SOURCES )
set ( TwxCore_HEADERS )

if ( NOT TWX_IS_BASED )

	# This file is primary
	cmake_minimum_required ( VERSION 3.25 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
	project ( TwxCoreTest )
	include ( TwxBase )
	set (
		TWX_PROJECT.ini
		"${CMAKE_CURRENT_LIST_DIR}/Test/${PROJECT_NAME}.ini"
	)
	set ( TWX_TEST ON	)
	set ( TwxCore_TEST_IS_ROOT ON )
	enable_testing ()
	set ( CMAKE_CXX_STANDARD 11 )
	# Tell CMake to run moc when necessary:
	set ( CMAKE_AUTOMOC ON )
	
	# As moc files are generated in the binary dir, tell CMake
	# to always look for includes there:
	set ( CMAKE_INCLUDE_CURRENT_DIR ON )
	
elseif ( TWX_TEST )
	project ( TwxCoreTest )
	include ( TwxBase )
	set (
		TWX_PROJECT.ini
		"${CMAKE_CURRENT_LIST_DIR}/Test/${PROJECT_NAME}.ini"
	)
	set ( TwxCore_TEST_IS_ROOT ON )
endif ()

include ( TwxConfigureFileLib )
twx_configure_file_prepare ()
twx_configure_file_add (
	out_twx
	"${CMAKE_CURRENT_LIST_DIR}/TwxInfo.in.cpp"
)
twx_configure_file_proceed ( )

list (
	APPEND TwxCore_SOURCES
	${out_twx}
)

list (
	APPEND TwxCore_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/TwxInfo.h"
)

if ( NOT TWX_TEST )
	return (
		PROPAGATE TwxCore_SOURCES TwxCore_HEADERS
	)
endif ()

add_executable ( test_TwxCore )

add_test (
	NAME test_TwxCore
	COMMAND test_TwxCore
	WORKING_DIRECTORY
	"${CMAKE_CURRENT_LIST_DIR}/Test/TestCase"
)
target_include_directories (
	test_TwxCore
	PRIVATE ${TWX_DIR}/src ${PROJECT_BUILD_DIR}/src
)
target_compile_definitions (
	test_TwxCore
	PRIVATE TwxCore_TEST
)

include ( WithQT )
# if ( QT_VERSION_MAJOR EQUAL 6 )
# 	# Check for Qt6
# 	twx_append_QT ( REQUIRED Core5Compat )
# else ()
# 	if ( WIN32 AND NOT BUILD_SHARED_LIBS )
# 		twx_append_QT ( REQUIRED WindowsPlatformSupport )
# 	endif ()
# endif ()

target_link_libraries (
	test_TwxCore
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning ( test_TwxCore )

list (
	APPEND
	TwxCore_SOURCES
	Test/TwxCoreTest.cpp
)
list (
	APPEND
	TwxCore_HEADERS
	Test/TwxCoreTest.h
)

target_sources (
	test_TwxCore
	PRIVATE ${TwxCore_SOURCES} ${TwxCore_HEADERS}
)

# ANCHOR - Summary
# =======

if ( TwxCore_TEST_IS_ROOT )

	message ( "" )

	include ( TwxConfigLog )
	include ( TwxInfoLib )
	twx_info_update ()
	twx_info_read ( GIT )

	twx_config_begin (
		BOLD_GREEN
	"${PROJECT_NAME} test suite has been configured \
	(CMake ${CMAKE_VERSION}, \
	${CMAKE_CXX_COMPILER_ID} \
	${CMAKE_CXX_COMPILER_VERSION}):\n"
		)
	twx_config_begin ( BOLD_MAGENTA "Git info" )
	twx_config_log ( "Hash" "${TWX_INFO_GIT_HASH}" )
	twx_config_log ( "Date" "${TWX_INFO_GIT_DATE}" )
	twx_config_log ( "Branch" "${TWX_INFO_GIT_BRANCH}" )
	twx_config_end ()

	twx_config_begin ( BOLD_MAGENTA "Version info" )
	twx_config_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
	twx_config_end ()

	twx_config_log ( "Compiler optimization:" ${CMAKE_BUILD_TYPE} )
	twx_config_log ( "" )

	twx_config_begin ( BOLD_BLUE "Libraries" VERBOSE )
	twx_config_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
	twx_config_end ()

	twx_config_begin ( BOLD_BLUE "Build settings" VERBOSE )
	twx_config_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
	twx_config_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
	twx_config_end ()

	twx_config_begin ( BOLD_BLUE "Files" VERBOSE )
	twx_config_log_kv ( "SOURCES" VAR TwxCore_SOURCES )
	twx_config_log_kv ( "HEADERS" VAR TwxCore_HEADERS )
	twx_config_end ()

	twx_config_end ( NO_EOL )

endif ()
