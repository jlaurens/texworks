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

include ( TwxModuleLib )

twx_module_setup ( NAME Core )

set ( TwxTypesetLib_DIR "${PROJECT_BINARY_DIR}/TwxModules/TwxTypeset" )

set ( TWX_TEST ON )
enable_testing ()

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )
include ( TwxCfgLib )

twx_cfg_setup ()

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)

twx_summary_begin ( BOLD_MAGENTA "Git info" )
twx_summary_log ( "Hash" "${TWX_CFG_GIT_HASH}" )
twx_summary_log ( "Date" "${TWX_CFG_GIT_DATE}" )
twx_summary_log ( "Branch" "${TWX_CFG_GIT_BRANCH}" )
twx_summary_end ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
twx_summary_log ( "" )

twx_summary_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_summary_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_summary_end ()

twx_summary_begin ( BOLD_BLUE "Files" VERBOSE )
twx_summary_log_kv ( "SOURCES" VAR TwxEngine_SOURCES )
twx_summary_log_kv ( "HEADERS" VAR TwxEngine_SOURCES )
twx_summary_end ()

twx_summary_end ( NO_EOL )

#*/
