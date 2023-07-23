#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Expect.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( NAME "twx_expect_equal_string" ID equal_string )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  twx_expect_equal_string ( "" "" )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  twx_expect_equal_string ( "ABC" "ABC" )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( DEF "ABC" )
  twx_expect_equal_string ( "ABC" "DEF" )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect_unequal_string" ID unequal_string )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  twx_expect_unequal_string ( "" "" )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_expect_unequal_string ( "ABC" "ABC" )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( DEF "ABC" )
  twx_expect_unequal_string ( "ABC" "DEF" )
  twx_fatal_assert_passed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect_equal_number" ID equal_number )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  twx_expect_equal_number ( 4 4 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  twx_expect_equal_number ( 4 0x4 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( 0x4 5 )
  twx_expect_equal_number ( 4 0x4 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  if ( "4" EQUAL "0x44" )
    message ( FATAL_ERROR "FAILED" )
  endif ()
  twx_expect_equal_number ( 4 0x44 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( 0x44 4 )
  twx_expect_equal_number ( 4 0x44 )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect_unequal_number" ID unequal_number )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  set ( 0x4 5 )
  twx_expect_unequal_number ( 4 0x4 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( 0x44 4 )
  twx_expect_unequal_number ( 4 0x44 )
  twx_fatal_assert_passed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect" ID expect )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  set ( ABC DEF )
  twx_expect ( ABC DEF )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC )
  twx_expect ( ABC DEF )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( ABC )
  set ( DEF ABC )
  twx_expect ( ABC DEF )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( ABC 4 )
  twx_expect ( ABC 0x4 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( ABC 4 )
  twx_expect ( ABC 0x4 NUMBER )
  twx_fatal_assert_passed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_unexpect" ID unexpect )
if ( TWX_TEST_UNIT_RUN )
  block ()
  unset ( ABC )
  unset ( DEF )
  twx_fatal_test ()
  set ( ABC ABC )
  twx_unexpect ( ABC DEF )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC DEF )
  twx_unexpect ( ABC DEF )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( ABC ABC )
  set ( DEF ABC )
  twx_unexpect ( ABC DEF )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC DEF )
  set ( DEF ABC )
  twx_unexpect ( ABC DEF )
  twx_fatal_assert_failed ()
  unset ( DEF )
  twx_fatal_test ()
  set ( ABC ABC )
  twx_unexpect ( ABC ABC )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( ABC DEF )
  twx_unexpect ( ABC ABC )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC DEF )
  set ( DEF ABC )
  twx_unexpect ( ABC ABC )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC 4 )
  twx_unexpect ( ABC 0x4 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( ABC 4 )
  twx_unexpect ( ABC 0x4 NUMBER )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect_matches" ID matches )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  twx_expect_matches ( "ABC" "^...$" )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  twx_expect_matches ( "ABC" "^..$" )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_expect_unmatches" ID unmatches )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  twx_expect_unmatches ( "ABC" "^...$" )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_expect_unmatches ( "ABC" "^..$" )
  twx_fatal_assert_passed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
