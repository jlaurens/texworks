#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxTypeset/Test Cmake file

Defines a test suite for the Typeset module.

Input:
- `TwxTypeset_SOURCES`
- `TwxTypeset_HEADERS`

Output state:
- `TWX_MODULE`
- `TWX_MODULE_NAME`
- `TWX_MODULE_TEST`
*/
/*
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.25 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Base/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxModuleLib )
twx_module_guess ()

if ( TARGET test_${TWX_MODULE} )
  return ()
endif ()

set ( TWX_MODULE_TEST ${TWX_MODULE}Test )

project ( ${TWX_MODULE_TEST} )
twx_base_after_project ()
twx_module_after_project ()

twx_module_configure_test ()

#*/
