#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

#[=======[
This is `<...>/src/Typeset/Test/CMakeLists.txt`

When used as primary `CMakeLists.txt` it defines
a standalone test for `Twx::Typeset` namespace.

Usage:
```
cd <...>/src/Typeset/Test/
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

if (TWX_IS_BASED)
  message(STATUS "Generating test suite Typeset")
else ()
	# This file is primary
	cmake_minimum_required(VERSION 3.1)
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/Base.cmake"
		NO_POLICY_SCOPE
	)
	project(TestTwxTypeset)
	# Include the base once again to finish setup
	include (Base)
	
	# if (UNIX AND NOT APPLE)
	# 	twx_append_QT(REQUIRED DBus)
	# endif ()

if (QT_VERSION_MAJOR EQUAL 6)
	# Check for Qt6
  twx_append_QT (REQUIRED Core5Compat)
else ()
	if (WIN32 AND NOT TWX_BUILD_SHARED_LIBRARIES)
    twx_append_QT (REQUIRED WindowsPlatformSupport)
	endif ()
endif ()

include (InitWARNING)

enable_testing()

set (TWX_TYPESET_TEST_IS_ROOT ON)
endif ()

set (Twx_Typeset_TEST ON)

include (TwxTypesetSetup)

# Add a test target for primary or secondary
# `CMakeLists`.

add_executable (
	test_TwxTypeset
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetTest.h"
	${Twx_Typeset_SOURCES}
	${Twx_Typeset_HEADERS}
)
target_include_directories (
	test_TwxTypeset
	PRIVATE "${TWX_DIR_src}"
	PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/src"
)
target_compile_options (
	test_TwxTypeset
	PRIVATE ${TWX_WARNING_OPTIONS}
)
target_link_libraries (
	test_TwxTypeset
	${QT_LIBRARIES}
)
target_compile_definitions (
	test_TwxTypeset
	PRIVATE Twx_Typeset_TEST
)
add_test (
	NAME test_TwxTypeset
	COMMAND test_TwxTypeset
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/TestCase"
)

if (TWX_TYPESET_TEST_IS_ROOT)

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

twx_config_begin(BOLD_BLUE "Files" VERBOSE)
twx_config_log_kv ("SOURCES" VAR Twx_Typeset_SOURCES)
twx_config_log_kv ("HEADERS" VAR Twx_Typeset_HEADERS)
twx_config_end  ()

twx_config_end  (NO_EOL)

endif ()
