#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxCore Cmake file

Static library with technologies related to typesetting.

Includes Test as a subdirectory.
*/
/*
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.13 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_guess ( VAR_MODULE TWX_MODULE VAR_NAME TWX_MODULE_NAME )

if ( TARGET ${TWX_MODULE} )
  twx_fatal ( "${TWX_MODULE} is already defined" )
endif ()

project ( ${TWX_MODULE} )
twx_base_after_project ()
twx_module_after_project ()

twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )

enable_language ( OBJCXX )

twx_message_deeper()

twx_module_configure_main ()

#*/
