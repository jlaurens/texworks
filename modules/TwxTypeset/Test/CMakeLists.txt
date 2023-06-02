#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxEngine/Test Cmake file

Defines a test suite.

Input:
- `TwxEngine_SOURCES`
- `TwxEngine_HEADERS`
*/
/*
#]===============================================]

if ( NOT TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()
project ( TwxTypesetTest )
include ( TwxBase )

include ( TwxQTLib )
twx_Qt_fresh()
twx_QT_append ( REQUIRED Test )

include ( TwxModuleLib )

twx_module_setup ( NAME Typeset )

set ( TwxTypesetLib_DIR "${PROJECT_BINARY_DIR}/TwxModules/TwxTypeset" )

set ( TWX_TEST ON )
enable_testing ()

add_executable (
	test_TwxTypeset
	${TwxTypeset_SOURCES} ${TwxTypeset_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetTest.h"
)

twx_module_src_include ( Typeset TARGETS test_TwxTypeset )

target_compile_definitions (
	test_TwxTypeset
	PRIVATE TWX_TEST TwxTypeset_TEST
)
twx_Qt_link_libraries ( test_TwxTypeset )

twx_module_add ( Core TARGETS test_TwxTypeset )

include ( TwxTestCase )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxTypeset )

add_test (
	NAME test_TwxTypeset
	COMMAND test_TwxTypeset
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

unset ( twx_WorkingDirectory )

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )
include ( TwxCfgLib )

twx_cfg_setup ()
twx_cfg_update_git ()

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)

twx_summary_section_git ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
twx_summary_log ( "" )

twx_summary_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_summary_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_summary_end ()

twx_summary_section_build_settings ( test_TwxTypeset )
twx_summary_section_files ( test_TwxTypeset )

twx_summary_end ( NO_EOL )

#*/
