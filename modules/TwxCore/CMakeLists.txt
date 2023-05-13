#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//** @file
@brief TwxCore Cmake file

Includes Test as a subdirectory.
*/
/*
#]===============================================]

if ( NOT TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

set ( TWX_MODULE_NAME TwxCore )

set ( TWX_TEST OFF )

project ( ${TWX_MODULE_NAME} )
include ( TwxBase )

include ( TwxQTLib )
twx_Qt_fresh ()

include ( TwxDoxydocLib )
twx_doxydoc ( "${PROJECT_BINARY_DIR}" )

include (
	"${CMAKE_CURRENT_LIST_DIR}/src/Setup.cmake"
)

include ( TwxModuleLib )
twx_module_setup ( Core )

if ( NOT TWX_NO_TEST )
  set ( TWX_TEST ON )
	enable_testing ()
	add_subdirectory ( Test TwxTest)
endif ()

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )
include ( TwxCfgLib )

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} library has been configured \
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

twx_summary_section_libraries ( ${TWX_MODULE_NAME} )

twx_summary_section_build_settings ( ${TWX_MODULE_NAME} )

twx_summary_section_files ( ${TWX_MODULE_NAME} )

twx_summary_end ()

#*/
