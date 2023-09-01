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

twx_test_suite_push ()
block ()
  
twx_test_unit_push ( CORE ... )
if ( TWX_TEST_UNIT.RUN )
  block ()
  message ( "NO TEST YET" )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
