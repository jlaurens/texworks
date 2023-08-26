#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxDoxydocLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ()
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


twx_test_unit_will_begin ( ID 2 )
if ( TWX_TEST_UNIT_RUN )
  block ()
  project ( TwxDoxydocTest.cmake2 )
  twx_doxydoc ( SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}" )
  twx_fatal_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
