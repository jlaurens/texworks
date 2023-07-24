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

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( ID "log_level_order" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_message_log_level_order ( NOTICE <=> TRACE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" -1 )
  twx_message_log_level_order ( NOTICE <=> NOTICE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" 0 )
  twx_message_log_level_order ( TRACE <=> NOTICE IN_VAR ans )
  twx_expect_equal_number ( "${ans}" 1 )
  twx_fatal_test ()
  twx_message_log_level_order ( NoTICE <=> TRACE IN_VAR ans )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_message_log_level_order ( NOTICE <=> TRaCE IN_VAR ans )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( ID "log_level_compare" )
if ( TWX_TEST_UNIT_RUN )
  block ()
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
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( ID prettify )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_message ( STATUS "THIS IS A TEST")
  twx_fatal_test ()
  twx_message_register_prettifier ( TwxMessageTest )
  twx_fatal_assert_failed ()
  function ( TwxMessageTest_prettify m IN_VAR v )
    # # message ( TR@CE "Ugly: ${m}")
    string ( REPLACE "a" "A" m "${m}" )
    # # message ( TR@CE "Pretty: ${m}")
    set ( ${v} "${m}" PARENT_SCOPE )
  endfunction ()
  twx_fatal_test ()
  twx_message_register_prettifier ( TwxMessageTest )
  twx_fatal_assert_passed ()
  twx_message_prettify ( "b" "a" "c" IN_VAR msg )
  twx_expect_equal_string ( "${msg}" "b;A;c" )
  twx_expect ( msg "b;A;c" )
  twx_fatal_test ()
  twx_message_unregister_prettifier ( TwxMessageTest )
  twx_fatal_assert_passed ()
  twx_message_prettify ( "b" "a" "c" IN_VAR msg )
  twx_expect_equal_string ( "${msg}" "b;a;c" )
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#/*
