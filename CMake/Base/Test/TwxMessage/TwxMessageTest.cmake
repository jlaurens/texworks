#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxMessageLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

message ( STATUS "TwxMessageLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxMessageLib.cmake")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxMath/TwxMathTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxAssert/TwxAssertTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxArg/TwxArgTest.cmake")

block ()
twx_test_suite_will_begin ()

message ( STATUS "twx_message_log_level_order" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT log_level_order )
if ( TRUE )
  twx_message_log_level_order ( NOTICE <=> TRACE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" -1 )
  twx_message_log_level_order ( NOTICE <=> NOTICE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" 0 )
  twx_message_log_level_order ( TRACE <=> NOTICE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" 1 )
  twx_test_fatal ()
  twx_message_log_level_order ( NoTICE <=> TRACE IN_VAR ans )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
  twx_message_log_level_order ( NOTICE <=> TRaCE IN_VAR ans )
  twx_test_fatal_assert_failed ()
endif ()
endblock ()

message ( STATUS "twx_message_log_level_compare" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT log_level_compare )
if ( TRUE )
  foreach ( level ${TWX_MESSAGE_LOG_LEVELS} )
    set ( op ">" )
    foreach ( l ${TWX_MESSAGE_LOG_LEVELS} )
      if ( "${l}" STREQUAL "${level}" )
        twx_message_log_level_compare ( "${l}" "==" "${level}" IN_VAR ans )
        twx_assert_true ( ans )
        twx_message_log_level_compare ( "${l}" "="  "${level}" IN_VAR ans )
        twx_assert_true ( ans )
        twx_message_log_level_compare ( "${l}" "!=" "${level}" IN_VAR ans )
        twx_assert_false ( ans )
        twx_message_log_level_compare ( "${l}" "<>" "${level}" IN_VAR ans )
        twx_assert_false ( ans )
        set ( op "<" )
        continue ()
      endif ()
      # # message ( TR@CE "${level} ${op} ${l}" )
      twx_message_log_level_compare ( "${level}" "${op}" "${l}" IN_VAR ans )
      twx_assert_true ( ans )
    endforeach ()
  endforeach ()
endif ()
endblock ()

message ( STATUS "twx_message_prettify" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_message_prettify )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_message ( STATUS "THIS IS A TEST")
  twx_test_fatal ()
  twx_message_register_prettifier ( TwxMessageTest )
  twx_test_fatal_assert_failed ()
  function ( TwxMessageTest_prettify m IN_VAR v )
    # # message ( TR@CE "Ugly: ${m}")
    string ( REPLACE "a" "A" m "${m}" )
    # # message ( TR@CE "Pretty: ${m}")
    set ( ${v} "${m}" PARENT_SCOPE )
  endfunction ()
  twx_test_fatal ()
  twx_message_register_prettifier ( TwxMessageTest )
  twx_test_fatal_assert_passed ()
  twx_message_prettify ( "b" "a" "c" IN_VAR msg )
  twx_expect_equal_string ( "${msg}" "b;A;c" )
  twx_expect ( msg "b;A;c" )
  twx_test_fatal ()
  twx_message_unregister_prettifier ( TwxMessageTest )
  twx_test_fatal_assert_passed ()
  twx_message_prettify ( "b" "a" "c" IN_VAR msg )
  twx_expect_equal_string ( "${msg}" "b;a;c" )
endif ()
twx_test_fatal ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxMessageLib test... DONE")

#/*
