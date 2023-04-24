#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or ( at your option ) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

#[=======[
This is `<...>/src/Core/Test/CMakeLists.txt`

When used as primary `CMakeLists.txt` it defines
a standalone test for `Twx::Core` namespace.

Usage:
```
cd <...>/src/Core/Test/
mkdir build
cd build
cmake ..
cmake --build .
ctest .
```

It is also included by `/unit-tests/CMakeLists.txt`.

#]=======]

# Main files are defined in the `Setup.cmake` of
# the parent directory.

if ( TWX_IS_BASED )
  message ( STATUS "Generating test suite Core" )
else ()
	# This file is primary
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/Base.cmake"
		NO_POLICY_SCOPE
	)
	project ( TestTwxCore )
	# Include the base once again to finish setup
	include ( Base )

if ( QT_VERSION_MAJOR EQUAL 6 )
	# Check for Qt6
  twx_append_QT ( REQUIRED Core5Compat )
else ()
	if ( WIN32 AND NOT BUILD_SHARED_LIBS )
    twx_append_QT ( REQUIRED WindowsPlatformSupport )
	endif ()
endif ()

include ( InitWARNING )

enable_testing ()

set ( TwxCore_TEST_IS_ROOT ON )
endif ()

set ( TwxCore_TEST ON )

include ( TwxCoreSetup )

# Add a test target for primary or secondary
# `CMakeLists`.

add_executable (
	test_TwxCore
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.h"
	${TwxCore_SOURCES}
	${TwxCore_HEADERS}
	"${TWX_DIR_src}/Settings.cpp"
	"${TWX_DIR_src}/Settings.h"
)
target_include_directories (
	test_TwxCore
	PRIVATE "${TWX_DIR_src}"
	PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/src"
)
target_compile_options (
	test_TwxCore
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_TwxCore
	${QT_LIBRARIES}
)
target_compile_definitions (
	test_TwxCore
	PRIVATE TwxCore_TEST
)
add_test (
	NAME test_TwxCore
	COMMAND test_TwxCore
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/TestCase"
)

if ( TwxCore_TEST_IS_ROOT )

message ( "" )

# Summary
# =======

# This section displays a nice configuration summary for the user.

twx_config_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)
twx_config_begin ( BOLD_MAGENTA "Version info" )
twx_config_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_config_end ()

twx_config_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
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
