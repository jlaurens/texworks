#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxHelp/Test Cmake file

Defines a test suite.

Input:
- `TwxHelp_SOURCES`
- `TwxHelp_HEADERS`
*/
/*
#]===============================================]

if ( TARGET test_TwxHelp )
  return ()
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.13 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()
project ( TwxHelpTest )
include ( TwxBase )

include ( TwxQTLib )
twx_Qt_fresh()
twx_QT_append ( REQUIRED Test )

include ( TwxCfgLib )
twx_cfg_setup ()
include ( TwxModuleLib )
twx_module_setup ( NAME Help )

set ( TwxHelpLib_DIR "${PROJECT_BINARY_DIR}/TwxModules/TwxHelp" )

set ( TWX_TEST ON )
enable_testing ()

add_executable (
	test_TwxHelp
	${TwxHelp_SOURCES} ${TwxHelp_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxHelpTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxHelpTest.h"
)

twx_module_includes ( Help TARGETS test_TwxHelp )
target_compile_definitions (
	test_TwxHelp
	PRIVATE TWX_TEST TwxHelp_TEST
)
twx_Qt_link_libraries ( TARGETS test_TwxHelp )

twx_module_add ( NAMES Help TO_TARGETS test_TwxHelp )
  
include ( TwxTestLib )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxHelp )

add_test (
	NAME test_TwxHelp
	COMMAND test_TwxHelp
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

unset ( twx_WorkingDirectory )

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )
twx_cfg_update_git ()

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}):\n"
	)

twx_summary_section_compiler ()
twx_summary_section_git ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_section_libraries ( test_TwxHelp )
twx_summary_section_build_settings ( test_TwxHelp )
twx_summary_section_files ( test_TwxHelp )

twx_summary_end ( NO_EOL )

#*/
