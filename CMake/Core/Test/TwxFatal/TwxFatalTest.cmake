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

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( ID "get/set" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_get ( IN_VAR var )
  twx_assert_undefined ( var )
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( ID "catch" )
if ( TWX_TEST_UNIT_RUN )
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
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
