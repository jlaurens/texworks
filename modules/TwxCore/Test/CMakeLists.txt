#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxCore/Test Cmake file

Defines a test suite for the Core module.

The test suite highly relies on the shape of the working directory.
In particular, changing names as well as removing folders can have dramatic consequences
if you do not exactly know what you are doing.

Input:
- `TwxCore_SOURCES`
- `TwxCore_HEADERS`

Output state:
- `TWX_MODULE`
- `TWX_MODULE_NAME`
- `TWX_MODULE_TEST`
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

include ( TwxModuleLib )
twx_module_guess ( VAR_MODULE TWX_MODULE VAR_NAME TWX_MODULE_NAME )

if ( TARGET test_${TWX_MODULE} )
  return ()
endif ()

set ( TWX_MODULE_TEST ${TWX_MODULE}Test )

project ( ${TWX_MODULE_TEST} )
twx_base_after_project ()
twx_module_after_project ()

twx_module_configure_test ()

#*/
