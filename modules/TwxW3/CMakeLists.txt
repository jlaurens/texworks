#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//** @file
@brief TwxCore Cmake file

Includes Test as a subdirectory.
*/
/*
#]===============================================]

if ( TARGET TwxW3 )
  twx_fatal ( "FAIL" )
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.13 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_guess ( VAR_MODULE TWX_MODULE VAR_NAME TWX_MODULE_NAME )
twx_assert_non_void ( TWX_MODULE )
set ( TWX_TEST OFF )

project ( ${TWX_MODULE} )
twx_base_after_project ()

twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )

include ( TwxQTLib )
twx_Qt_fresh ()

twx_module_configure ()

include ( TwxDoxydocLib )
twx_doxydoc ()

twx_module_test ()

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
