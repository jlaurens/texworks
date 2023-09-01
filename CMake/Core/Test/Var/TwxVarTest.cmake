#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Core.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

twx_test_unit_push ( NAME "assert_name" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( TWX_FATAL_CATCH ON )
  twx_fatal_clear ()
  twx_var_assert_name ( "Ç" )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_var_assert_name ( "a_1" )
  twx_fatal_clear ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
