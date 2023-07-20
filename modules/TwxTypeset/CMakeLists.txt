#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxTypeset Cmake file

Static library with core technologies.
*/
/*
#]===============================================]

include_guard ( GLOBAL )

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.25 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Base/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_guess ()

if ( TARGET ${TWX_MODULE} )
  twx_fatal ( "${TWX_MODULE} is already defined" )
  return ()
endif ()

project ( ${TWX_MODULE} )
twx_base_after_project ()
twx_module_after_project ()

twx_module_configure_main ()

#*/
