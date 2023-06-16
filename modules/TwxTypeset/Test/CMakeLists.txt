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

if ( TARGET test_TwxW3 )
  return ()
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.13 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_guess ( VAR_MODULE TWX_MODULE VAR_NAME TWX_MODULE_NAME )

project ( ${TWX_MODULE}Test )
include ( TwxBase )

twx_module_configure_test ()

#*/
