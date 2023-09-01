#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxUtilLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

twx_test_unit_push ( NAME "twx_util_timestamp" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_fatal_test ()
  twx_util_timestamp ( filepath_ IN_VAR ans unexpected )
  twx_fatal_assert_fail ()
  twx_fatal_test ()
  twx_util_timestamp ( filepath_ IN_VARX ans )
  twx_fatal_assert_fail ()
  twx_fatal_test ()
  twx_util_timestamp ( filepath_ IN_VAR "one more time" )
  twx_fatal_assert_fail ()
  twx_fatal_test ()
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_DIR}/dummy" IN_VAR ans )
  twx_fatal_assert_pass ()
  twx_expect ( ans 0 )
  twx_fatal_test ()
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_FILE}" IN_VAR ans )
  twx_fatal_assert_pass ()
  twx_assert_compare ( "${ans}" > 0 )
  twx_fatal_test ()
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_dir_complete_var" ID complete_dir_var )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( TwxUtiTest.VAR )
  twx_fatal_test ()
  twx_dir_complete_var ( TwxUtiTest.VAR )
  twx_fatal_assert_fail ()
  twx_fatal_test ()
  set ( TwxUtiTest.VAR "ABC" )
  twx_dir_complete_var ( TwxUtiTest.VAR )
  twx_fatal_assert_pass ()
  twx_expect ( TwxUtiTest.VAR "ABC/" )
  twx_fatal_test ()
  set ( TwxUtiTest.VAR "ABC/" )
  twx_dir_complete_var ( TwxUtiTest.VAR )
  twx_fatal_assert_pass ()
  twx_expect ( TwxUtiTest.VAR "ABC/" )
  twx_fatal_test ()
  set ( TwxUtiTest.VAR "ABC//" )
  twx_dir_complete_var ( TwxUtiTest.VAR )
  twx_fatal_assert_pass ()
  twx_expect ( TwxUtiTest.VAR "ABC//" )
  twx_fatal_test ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#/*
