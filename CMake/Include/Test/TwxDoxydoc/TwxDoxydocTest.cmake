#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxUnitLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( NAME twx_doxydoc )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_doxydoc ( SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}" )
  message ( [[
Terminate the test with
make doxydoc
]])
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

message ( "PROJECT_NAME => ``${PROJECT_NAME}''" )

#*/
