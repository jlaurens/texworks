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
This is `<...>/src/Test/CMakeLists.txt`

An umbrella test.

Usage:
```
cd <...>/src/Test/
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

if (NOT TWX_IS_BASED)
	# This file is primary
	cmake_minimum_required(VERSION 3.1)
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/Base.cmake"
		NO_POLICY_SCOPE
	)
	project(TestTwx)
	# Include the base once again to finish setup
	include (Base)

	include (InitWARNING)

	enable_testing()

	set (TWX_TEST_IS_ROOT ON)
endif ()

# if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
#   set (
# 		CMAKE_RUNTIME_OUTPUT_DIRECTORY
# 		CMAKE_CURRENT_BINARY_DIRECTORY
# 	)
# endif ()

include (
	"${TWX_DIR_src}/Version/Test/CMakeLists.txt"
)
include (
	"${TWX_DIR_src}/Git/Test/CMakeLists.txt"
)
include (
	"${TWX_DIR_src}/Core/Test/CMakeLists.txt"
)
include (
	"${TWX_DIR_src}/Typeset/Test/CMakeLists.txt"
)

if (TwxVersion_TEST_IS_ROOT)

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
twx_contwx_config_log("${PROJECT_NAME}" "${TeXworks_VERSION} (${TWX_GIT_HASH}, ${TWX_GIT_DATE}, ${TWX_GIT_BRANCH})")
fig_log("Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH})
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
twx_config_log_kv ("HEADERS" VAR TwxVersion_HEADERS)
twx_config_log_kv ("SOURCES" VAR TwxVersion_SOURCES)
twx_config_log_kv ("HEADERS" VAR TwxGit_HEADERS)
twx_config_log_kv ("SOURCES" VAR TwxGit_SOURCES)
twx_config_log_kv ("HEADERS" VAR TwxCore_HEADERS)
twx_config_log_kv ("SOURCES" VAR TwxCore_SOURCES)
twx_config_log_kv ("HEADERS" VAR TwxTypeset_HEADERS)
twx_config_log_kv ("SOURCES" VAR TwxTypeset_SOURCES)
twx_config_end  ()

twx_config_end  (NO_EOL)

endif ()
