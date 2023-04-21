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
This is `<...>/src/Git/Test/CMakeLists.txt`

When used as primary `CMakeLists.txt` it defines
a standalone test for `Twx::Git` namespace.

Usage:
```
cd <...>/src/Git/Test/
mkdir build
cd build
cmake ..
cmake --build .
ctest .
```

It is also included by `/unit-tests/CMakeLists.txt`.

#]=======]

# Main files are defined in the `CMakeLists.txt` of
# the parent directory.

if (TWX_IS_BASED)
  message(STATUS "Generating test suite Git")
else ()
	# This file is primary
	cmake_minimum_required(VERSION 3.1)
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/Base.cmake"
		NO_POLICY_SCOPE
	)
	project(TestTwxGit)
	# Include the base once again to finish setup
	include (Base)

	include (InitWARNING)

	enable_testing()

	set (TWX_GIT_TEST_IS_ROOT ON)
endif ()

include (TwxGitSetup)

include (WithQt)
twx_append_QT (
	REQUIRED Test Core
)

# Add a test target for primary or secondary
# `CMakeLists`.

add_executable (
	test_TwxGit
	"${CMAKE_CURRENT_LIST_DIR}/TwxGitTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxGitTest.h"
	${Twx_Git_SOURCES}
	${Twx_Git_HEADERS}
)
# foreach (_header IN LIST Twx_Git_GENERATER_HEADERS)
# 	get_filename_component(_dir "${_header}" DIRECTORY)
# 	target_include_directories (
# 		test_TwxGit
# 		PRIVATE "${_dir}"
# 	)
# endforeach ()

target_include_directories (
	test_TwxGit
	PRIVATE "${TWX_DIR_src}"
	PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/src"
	PRIVATE "${CMAKE_BINARY_DIR}/src"
)

target_compile_options (
	test_TwxGit
	PRIVATE ${WARNING_OPTIONS}
)
target_link_libraries (
	test_TwxGit
	${QT_LIBRARIES}
)
target_compile_definitions (
	test_TwxGit
	PRIVATE Twx_Git_TEST
)
add_test (
	NAME test_TwxGit
	COMMAND test_TwxGit
	WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/TestCase"
)

if (TWX_GIT_TEST_IS_ROOT)

message("")

# Summary
# =======

# This section displays a nice configuration summary for the user.

twx_config_begin(
	BOLD_GREEN
"${PROJECT_NAME} has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
)
twx_config_begin(BOLD_MAGENTA "Git info")
twx_config_log("${PROJECT_NAME}" "${TeXworks_GIT_HASH}, ${TeXworks_GIT_DATE}, ${TeXworks_GIT_BRANCH}")
twx_config_end()

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
twx_config_log_kv ("SOURCES" VAR Twx_Git_SOURCES)
twx_config_log_kv ("HEADERS" VAR Twx_Git_HEADERS)
twx_config_end  ()

twx_config_end  (NO_EOL)

endif ()
