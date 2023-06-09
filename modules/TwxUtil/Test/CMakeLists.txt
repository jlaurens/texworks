#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxUtil/Test Cmake file

Defines a test suite.

Input:
- `TwxUtil_SOURCES`
- `TwxUtil_HEADERS`
- `TWX_TEST_NO_OpenUrl`: when set (from the CLI) the tests for `openUrl`
  are neutralized.
*/
/*
#]===============================================]

if ( TARGET test_TwxUtil )
  return ()
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()
project ( TwxUtilTest )
include ( TwxBase )

include ( TwxQTLib )
twx_Qt_fresh()
twx_QT_append ( REQUIRED Test )

include ( TwxCfgLib )
twx_cfg_setup ()
include ( TwxModuleLib )
twx_module_setup ( NAME Util )

set ( TwxTypesetLib_DIR "${PROJECT_BINARY_DIR}/TwxModules/TwxTypeset" )

set ( TWX_TEST ON )
enable_testing ()

add_executable ( test_TwxUtil )
twx_module_src_include ( Util TARGETS test_TwxUtil )

target_compile_definitions (
	test_TwxUtil
	PRIVATE TWX_TEST TwxUtil_TEST
)

if ( TWX_TEST_NO_OpenUrl )
	target_compile_definitions (
		test_TwxUtil
		PRIVATE TwxUtil_TEST_NO_OpenUrl
	)
endif ()

target_link_libraries (
	test_TwxUtil
	${TwxUtil_LIBRARIES}
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning_target ( test_TwxUtil )

target_sources (
	test_TwxUtil
	PRIVATE ${TwxUtil_SOURCES} ${TwxUtil_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxUtilTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxUtilTest.h"
)

include ( TwxTestLib )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxUtil )

add_test (
	NAME test_TwxUtil
	COMMAND test_TwxUtil
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

# Finally the library test

add_executable (
	test_TwxUtilLib
	"${CMAKE_CURRENT_LIST_DIR}/TwxUtilLibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxUtilLibTest.h"
)

twx_module_add ( Util TARGETS test_TwxUtilLib )
twx_Qt_link_libraries ( test_TwxUtilLib )

target_compile_definitions ( 
  test_TwxUtilLib
  PRIVATE TwxUtilLib_TEST
)

add_test (
	NAME test_TwxUtilLib
	COMMAND test_TwxUtilLib
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
twx_summary_log ( "1" "test_TwxUtil" )
twx_summary_log ( "2" "test_TwxUtilLib" )
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

foreach ( t_ Util UtilLib )
	twx_summary_section_build_settings ( test_Twx${t_} VERBOSE )
	twx_summary_section_files ( test_Twx${t_} VERBOSE )
endforeach ()

twx_summary_end ()

#*/
