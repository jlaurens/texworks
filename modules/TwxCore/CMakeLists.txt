#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//** @file
@brief TwxCore Cmake file

Includes Test as a subdirectory.
*/
/*
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_name ( TWX_MODULE NAME TWX_MODULE_NAME )

project ( ${TWX_MODULE} )
include ( TwxBase )

twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )

enable_language ( OBJCXX )

include ( TwxQTLib )
twx_Qt_fresh ()

twx_module_configure ()

include ( TwxDoxydocLib )
twx_doxydoc ()

if ( NOT TWX_NO_TEST )
  set ( TWX_TEST ON )
	enable_testing ()
	add_subdirectory ( Test TwxTest)
endif ()

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} library has been configured \
(CMake ${CMAKE_VERSION}):\n"
	)
twx_summary_section_compiler ()
twx_summary_section_git ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_section_libraries ( ${TWX_MODULE_NAME} )

twx_summary_section_build_settings ( ${TWX_MODULE_NAME} )

twx_summary_section_files ( ${TWX_MODULE_NAME} )

twx_summary_end ()

#*/
