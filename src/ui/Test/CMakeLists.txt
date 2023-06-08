#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/ui/CMakeLists.txt`

It can be used as standalone testing project,
testing auxiliary or source provider.

## Standalone testing project

When used as primary `CMakeLists.txt` it defines
a standalone test suite for `Tw` namespace.

Usage from an external build directory:
```
cmake .../src/ui
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
* `TwxUI_SOURCES`, a `;` separated list of full paths
* `TwxUI_HEADERS`, a `;` separated list of full paths

NB: The transition to Twx is not complete
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
	# This file is primary
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

project ( TwxUI_Test )
include ( TwxBase )

set ( TWX_TEST ON	)
set ( TwxUI_TEST ON	)
set ( TwxUI_TEST_IS_ROOT ON )

enable_testing ()

include ( TwxQTLib )
twx_Qt_fresh ( TEST )
twx_QT_append ( REQUIRED Widgets )

include ( SrcTwxUISetup )

list (
	APPEND TwxUI_SOURCES
	"${CMAKE_CURRENT_LIST_DIR}/TwxUITest.cpp"
)
list (
	APPEND TwxUI_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/TwxUITest.h"
)

add_executable (
	test_TwxUI
	${TwxUI_SOURCES} ${TwxUI_HEADERS} ${TwxUI_UIS}
)

twx_target_include_src ( test_TwxUI )

target_compile_definitions (
	test_TwxUI
	PRIVATE TWX_TEST TwxUI_TEST
)

target_link_libraries (
	test_TwxUI
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning_target ( test_TwxUI )

include ( TwxTestCase )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxUI )

add_test (
	NAME test_TwxUI
	COMMAND test_TwxUI
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

add_executable(
	byte_echo_TwxUI
	${CMAKE_CURRENT_LIST_DIR}/byte_echo_test.cpp
)
twx_warning_target ( byte_echo_TwxUI )

set_target_properties (
	byte_echo_TwxUI
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY
		"${twx_WorkingDirectory}"
)

unset ( twx_WorkingDirectory )

# ANCHOR - Summary
# =======

if ( TwxUI_TEST_IS_ROOT )

	message ( "" )

	include ( TwxSummaryLib )

	twx_summary_begin (
		BOLD_GREEN
	"${PROJECT_NAME} test suite has been configured \
	(CMake ${CMAKE_VERSION}, \
	${CMAKE_CXX_COMPILER_ID} \
	${CMAKE_CXX_COMPILER_VERSION}):\n"
		)
	
	twx_summary_begin ( BOLD_MAGENTA "Version info" )
	twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
	twx_summary_end ()

	twx_summary_log ( "Compiler optimization:" ${CMAKE_BUILD_TYPE} )
	twx_summary_log ( "" )

	twx_summary_begin ( BOLD_BLUE "Libraries" VERBOSE )
	twx_summary_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
	twx_summary_end ()

	twx_summary_begin ( BOLD_BLUE "Build settings" VERBOSE )
	get_target_property (
		COMPILE_DEFINITIONS
		test_TwxUI
		COMPILE_DEFINITIONS
	)
	twx_summary_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
	get_target_property (
		COMPILE_OPTIONS
		test_TwxUI
		COMPILE_OPTIONS
	)
	twx_summary_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
	twx_summary_end ()

	twx_summary_section_files ( test_TwxUI )
	
	twx_summary_end ()

endif ()
