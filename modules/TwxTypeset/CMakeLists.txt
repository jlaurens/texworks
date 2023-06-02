#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxTypeset/Test Cmake file

Defines a test suite.

Input:
- `TwxTypeset_SOURCES`
- `TwxTypeset_HEADERS`
*/
/*
#]===============================================]

if ( TARGET TwxTypeset )
  twx_fatal ( "FAIL" )
endif ()

if ( NOT TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_name ( TWX_MODULE_NAME )
twx_assert_non_void ( TWX_MODULE_NAME )
set ( TWX_TEST OFF )

project ( ${TWX_MODULE_NAME} )
include ( TwxBase )
twx_assert_non_void ( TWX_BUILD_DATA_DIR )

include ( TwxQTLib )
twx_Qt_fresh ()
if ( TARGET TwxTypeset )
  twx_fatal ( "FAIL" )
endif ()
twx_module_configure ()

include ( TwxDoxydocLib )
twx_doxydoc ()

if ( NOT TWX_NO_TEST )
  set ( TWX_TEST ON )
	enable_testing ()
	add_subdirectory ( Test TwxTest)
endif ()

if ( NOT TARGET Twx::Typeset )
  add_library( Twx::Typeset ALIAS TwxTypeset )
endif ()

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

twx_summary_begin ( BOLD_BLUE "Build settings" VERBOSE )
get_target_property (
	COMPILE_DEFINITIONS
	test_TwxCore
	COMPILE_DEFINITIONS
)
twx_summary_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
get_target_property (
	COMPILE_OPTIONS
	test_TwxCore
	COMPILE_OPTIONS
)
twx_summary_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
twx_summary_end ()

twx_summary_begin ( BOLD_BLUE "Files" VERBOSE )
twx_summary_log_kv ( "SOURCES" VAR TwxCore_SOURCES )
twx_summary_log_kv ( "HEADERS" VAR TwxCore_HEADERS )
twx_summary_end ()

twx_summary_end ( NO_EOL )

#*/
