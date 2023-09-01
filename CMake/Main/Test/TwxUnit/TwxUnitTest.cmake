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

twx_test_suite_push ()
block ()

add_executable (
  test_TwxUnitTest.cmake
  "${CMAKE_CURRENT_LIST_DIR}/SOURCES/main.c"
)
  
twx_test_unit_push ( CORE case )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_unit_case ( IN_VAR twx_WorkingDirectory TARGET test_TwxUnitTest.cmake )
  twx_fatal_assert_pass ()
  twx_assert_matches ( "${twx_WorkingDirectory}" "\\.WorkingDirectory/")
  twx_fatal_assert_pass ()
  message ( STATUS "twx_WorkingDirectory => ``${twx_WorkingDirectory}''" )
  add_test (
    NAME TwxUnitTest.cmake
    COMMAND test_TwxUnitTest.cmake
    WORKING_DIRECTORY
      "${twx_WorkingDirectory}"
  )
  message ( STATUS "To terminate the test run\nmake test_TwxUnitTest.cmake" )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
