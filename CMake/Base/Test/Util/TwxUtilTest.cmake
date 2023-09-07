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

# ANCHOR: timestamp
twx_test_unit_push ( CORE "timestamp" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "Bad usage" )
  twx_util_timestamp ( filepath_ IN_VAR ans_ unexpected )
  twx_test_simple_fail ()

  twx_test_simple_check ( "IN_VARX" )
  twx_util_timestamp ( filepath_ IN_VARX ans_ )
  twx_test_simple_fail ()
  
  twx_test_simple_check ( "one more time" )
  twx_util_timestamp ( filepath_ IN_VAR "one more time" )
  twx_test_simple_fail ()
  
  twx_test_simple_check ( "Normal/Not exists" )
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_DIR}/dummy" IN_VAR ans_ )
  twx_assert_0 ( "${ans_}" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Normal/Exists" )
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_DIR}" IN_VAR ans_ )
  twx_assert_compare ( "${ans_}" > 0 )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#/*
