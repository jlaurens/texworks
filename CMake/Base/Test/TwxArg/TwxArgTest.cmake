#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxArgLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( NAME "twx_arg_assert_count" ID assert_count )
if ( TWX_TEST_UNIT_RUN )
  block ()
  function ( TwxArgTest_test1 op right )
    twx_arg_assert_count ( ${ARGC} ${op} ${right} )
  endfunction ()
  twx_fatal_test ()
  TwxArgTest_test1 ( < 3 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( < 1 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( <= 3 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( <= 1 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( <= 2 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( == 2 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( == 1 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( >= 2 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( >= 3 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( >= 1 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( > 1 )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgTest_test1 ( > 3 )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_arg_pass_option(1)" ID pass_option_1 )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_assert_passed ()
  set ( twx.R_CHI ON )
  twx_arg_pass_option ( CHI )
  if ( NOT twx.R_CHI STREQUAL "CHI" )
    message ( FATAL_ERROR "FAILED" )
  endif ()
  set ( twx.R_CHI OFF )
  twx_arg_pass_option ( CHI )
  if ( DEFINED twx.R_CHI )
    message ( FATAL_ERROR "FAILED" )
  endif ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_arg_pass_option(2)" ID pass_option_2 )
if ( TWX_TEST_UNIT_RUN )
  block ()
  function ( TwxArgTest_pass_option_2 CHI FOO )
    set ( twx.R_CHI ${CHI} )
    set ( twx.R_FOO ${FOO} )
    twx_arg_pass_option ( CHI FOO )
    foreach ( what CHI FOO )
      if ( ${${what}} )
        if ( NOT twx.R_${what} STREQUAL "${what}" )
          message ( FATAL_ERROR "FAILED" )
        endif ()
      else ()
        if ( DEFINED twx.R_${what} )
          message ( FATAL_ERROR "FAILED" )
        endif ()
      endif ()
    endforeach ()
  endfunction ()
  TwxArgTest_pass_option_2 ( ON   ON  )
  TwxArgTest_pass_option_2 ( ON   OFF )
  TwxArgTest_pass_option_2 ( OFF  ON  )
  TwxArgTest_pass_option_2 ( OFF  OFF )
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_arg_expect_keyword" ID expect_keyword )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_fatal_test ()
  set ( actual EXPECTED )
  twx_arg_expect_keyword ( actual "EXPECTED" )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( actual UNEXPECTED )
  twx_arg_expect_keyword ( actual "EXPECTED" )
  twx_fatal_assert_failed ()
  # twx_fatal_test ()
  # twx_arg_expect_keyword ( actual ) can't catch too few arguments
  # twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_arg_expect_keyword ( actual actual actual )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_arg_assert_parsed" ID assert_parsed )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( twx.R_FOO_B. FOO )
  set ( twx.R_FOO_BAR. FOO_BAR )
  twx_arg_assert_keyword ( twx.R_FOO_B. twx.R_FOO_BAR. )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  set ( twx.R_FOO_B. FOOX )
  set ( twx.R_FOO_BAR. FOO_BAR )
  twx_arg_assert_keyword ( twx.R_FOO_B. twx.R_FOO_BAR. )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( twx.R_FOO_B. FOO )
  set ( twx.R_FOO_BAR. FOO_BARX )
  twx_arg_assert_keyword ( twx.R_FOO_B. twx.R_FOO_BAR. )
  twx_fatal_assert_failed ()

  twx_fatal_test ()
  set ( MY_FOO_B. FOOX )
  set ( MY_FOO_BAR. FOO_BAR )
  twx_arg_assert_keyword ( FOO_B. FOO_BAR. PREFIX MY)
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( MY_FOO_B. FOO )
  set ( MY_FOO_BAR. FOO_BARX )
  twx_arg_assert_keyword ( FOO_B. FOO_BAR. PREFIX MY)
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "twx_arg_assert_parsed" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  function ( TwxArgLib_assert_parsed_1 )
    cmake_parse_arguments ( twx.R "" "KEY" "" ${ARGN} )
    twx_arg_assert_parsed ()
  endfunction()
  twx_fatal_test ()
  TwxArgLib_assert_parsed_1 ( )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgLib_assert_parsed_1 ( KEY key )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  TwxArgLib_assert_parsed_1 ( youpi )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
