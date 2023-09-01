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

twx_test_unit_push ( CORE "get/set" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_fatal_get ( IN_VAR var )
  twx_assert_undefined ( var )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( CORE "catch" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( TWX_FATAL_CATCH ON )
  twx_expect_equal_string ( "${twx_fatal.MSG}" "" )
  twx_fatal_clear ()
  twx_fatal ( "ABCDE" )
  twx_fatal_catched ( IN_VAR v )
  if ( NOT "${v}" MATCHES "ABCDE$" )
    message ( FATAL_ERROR " FAILURE 1: v => ``${v}''" )
  endif ()
  twx_fatal_clear ()
  twx_fatal_catched ( IN_VAR v )
  if ( NOT "${v}" STREQUAL "" )
    message ( FATAL_ERROR " FAILURE 2: v => ``${v}''" )
  endif ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
