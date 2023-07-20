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

message ( STATUS "TwxUtilLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxCore/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxAssert/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExpect/TwxExpectTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxArg/TwxArgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExport/TwxExportTest.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxUtilLib.cmake" )

block ()
twx_test_suite_will_begin ()

message ( "twx_util_timestamp" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_increment )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_test_fatal ()
  twx_util_timestamp ( filepath_ IN_VAR ans unexpected )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
  twx_util_timestamp ( filepath_ IN_VARX ans )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
  twx_util_timestamp ( filepath_ IN_VAR "one more time" )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_DIR}/dummy" IN_VAR ans )
  twx_test_fatal_assert_passed ()
  twx_expect ( ans 0 )
  twx_test_fatal ()
  twx_util_timestamp ( "${CMAKE_CURRENT_LIST_FILE}" IN_VAR ans )
  twx_test_fatal_assert_passed ()
  twx_assert_compare ( "${ans}" > 0 )
  twx_test_fatal ()
endif ()
twx_test_fatal_assert_passed ()
endblock ()

message ( "twx_complete_dir_var" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT complete_dir_var )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( TwxUtiTest.VAR )
  twx_test_fatal ()
  twx_complete_dir_var ( TwxUtiTest.VAR )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
  set ( TwxUtiTest.VAR "ABC" )
  twx_complete_dir_var ( TwxUtiTest.VAR )
  twx_test_fatal_assert_passed ()
  twx_expect ( TwxUtiTest.VAR "ABC/" )
  twx_test_fatal ()
  set ( TwxUtiTest.VAR "ABC/" )
  twx_complete_dir_var ( TwxUtiTest.VAR )
  twx_test_fatal_assert_passed ()
  twx_expect ( TwxUtiTest.VAR "ABC/" )
  twx_test_fatal ()
  set ( TwxUtiTest.VAR "ABC//" )
  twx_complete_dir_var ( TwxUtiTest.VAR )
  twx_test_fatal_assert_passed ()
  twx_expect ( TwxUtiTest.VAR "ABC//" )
  twx_test_fatal ()
endif ()
twx_test_fatal_assert_passed ()
twx_test_fatal ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxUtilLib test... DONE")

#/*
