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

add_executable (
  test_TwxUnitTest.cmake
  "${CMAKE_CURRENT_LIST_DIR}/SOURCES/dummy.c"
)

twx_test_unit_will_begin ( ID case )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_unit_case ( IN_VAR twx_WorkingDirectory TARGET TwxUnitTest.cmake )
  twx_fatal_assert_passed ()
  add_test (
    NAME TwxUnitTest.cmake
    COMMAND test_TwxUnitTest.cmake
    WORKING_DIRECTORY
      "${twx_WorkingDirectory}"
  )
  
  message ( STATUS "WHATEVER" )
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
