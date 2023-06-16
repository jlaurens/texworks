#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxCore/Test Cmake file

Defines a test suite.

The test suite highly relies on the shape of the working directory.
In particular, changing names as well as removing folders can have dramatic consequences.

Input:
- `TwxCore_SOURCES`
- `TwxCore_HEADERS`
*/
/*
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.13 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

twx_module_guess ( VAR_MODULE TWX_MODULE VAR_NAME TWX_MODULE_NAME )
set ( TWX_NAME_TEST ${TWX_MODULE}Test )

if ( TARGET test_${TWX_MODULE} )
  return ()
endif ()

project ( ${TWX_NAME_TEST} )
include ( TwxBase )

twx_module_configure_test ()

#*/
