#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxW3/Test Cmake file

Defines a test suite.

Input:
- `TwxW3_SOURCES`
- `TwxW3_HEADERS`
- `TWX_TEST_NO_OpenUrl`: when set (from the CLI) the tests for `openUrl`
  are neutralized.
*/
/*
#]===============================================]

if ( TARGET test_TwxW3 )
  return ()
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()
project ( TwxW3Test )
include ( TwxBase )

include ( TwxQTLib )
twx_Qt_fresh()
twx_QT_append ( REQUIRED Test )

include ( TwxCfgLib )
twx_cfg_setup ()
include ( TwxModuleLib )
twx_module_setup ( NAME W3 )

set ( TwxTypesetLib_DIR "${PROJECT_BINARY_DIR}/TwxModules/TwxTypeset" )

set ( TWX_TEST ON )
enable_testing ()

add_executable ( test_TwxW3 )
twx_module_src_include ( W3 TARGETS test_TwxW3 )

target_compile_definitions (
	test_TwxW3
	PRIVATE TWX_TEST TwxW3_TEST
)

if ( TWX_TEST_NO_OpenUrl )
	target_compile_definitions (
		test_TwxW3
		PRIVATE TwxW3_TEST_NO_OpenUrl
	)
endif ()

target_link_libraries (
	test_TwxW3
	${TwxW3_LIBRARIES}
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning_target ( test_TwxW3 )

target_sources (
	test_TwxW3
	PRIVATE ${TwxW3_SOURCES} ${TwxW3_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxW3Test.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxW3Test.h"
)

include ( TwxTestLib )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxW3 )

add_test (
	NAME test_TwxW3
	COMMAND test_TwxW3
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

# Finally the library test

add_executable (
	test_TwxW3Lib
	"${CMAKE_CURRENT_LIST_DIR}/TwxW3LibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxW3LibTest.h"
)

twx_module_add ( W3 TARGETS test_TwxW3Lib )
twx_Qt_link_libraries ( test_TwxW3Lib )

target_compile_definitions ( 
  test_TwxW3Lib
  PRIVATE TwxW3Lib_TEST
)

add_test (
	NAME test_TwxW3Lib
	COMMAND test_TwxW3Lib
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

unset ( twx_WorkingDirectory )

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)
twx_summary_begin ( BOLD_MAGENTA "Tests" )
twx_summary_log ( "1" "test_TwxW3" )
twx_summary_log ( "2" "test_TwxW3Lib" )
twx_summary_end ()

twx_summary_section_git ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
twx_summary_log ( "" )

twx_summary_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_summary_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_summary_end ()

foreach ( t_ W3 W3Lib )
	twx_summary_section_build_settings ( test_Twx${t_} VERBOSE )
	twx_summary_section_files ( test_Twx${t_} VERBOSE )
endforeach ()

twx_summary_end ()

#*/
