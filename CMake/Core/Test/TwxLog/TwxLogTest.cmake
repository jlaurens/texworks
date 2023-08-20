#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxModuleLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( )
if ( TWX_TEST_UNIT_RUN )
  block ()
  message ( "NO DEDICATED TEST" )
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
