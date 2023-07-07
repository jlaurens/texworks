#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  TwxExpectLib test suite.

Included by `TwxBase`.

Usage when `TwxBase` is not used :

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxExpectLib.cmake"
  )

*/
/*#]===============================================]

if ( COMMAND twx_expect_equal_string )
  return ()
endif ()

# ANCHOR: twx_expect_equal_string
#[=======[
*/
/** @brief Expect a string value
  *
  * Raises when `actual` is not `expected`.
  *
  * @param actual is the actual string value.
  * @param expected is the expected value.
  */
twx_expect_equal_string(actual expected) {}
/*
#]=======]
function ( twx_expect_equal_string actual_ expected_ )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( NOT "${actual_}" STREQUAL "${expected_}" )
    twx_fatal ( "Unexpected \"${actual_}\" instead of \"${expected_}\"")
    return ()
  endif ()
endfunction ()

# ANCHOR: twx_expect_unequal_string
#[=======[
*/
/** @brief Expect a different string value
  *
  * Raises when `actual` is `expected`.
  *
  * @param actual is a sring value.
  * @param expected is the expected string value.
  */
twx_expect_equal_string(actual expected) {}
/*
#]=======]
function ( twx_expect_unequal_string actual_ expected_ )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( "${actual_}" STREQUAL "${expected_}" )
    twx_fatal ( "Unexpected \"${actual_}\"" )
    return ()
  endif ()
endfunction ()

# ANCHOR: twx_expect_equal_number
#[=======[
*/
/** @brief Expect a number value
  *
  * Raises when `actual` is not `expected`.
  *
  * @param actual is the actual number value.
  * @param expected is the expected number value.
  */
twx_expect_equal_number(actual expected) {}
/*
#]=======]
function ( twx_expect_equal_number actual_ expected_ )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( NOT "${actual_}" EQUAL "${expected_}" )
    twx_fatal ( "Unexpected \"${actual_}\" instead of \"${expected_}\"" )
    return ()
  endif ()
endfunction ()

# ANCHOR: twx_expect_unequal_number
#[=======[
*/
/** @brief Expect a different number value
  *
  * Raises when `actual` is `expected`.
  *
  * @param actual is actual the number value.
  * @param expected is the expected number value.
  */
twx_expect_unequal_number(actual expected) {}
/*
#]=======]
function ( twx_expect_unequal_number actual_ expected_ )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( "${actual_}" EQUAL "${expected_}" )
    twx_fatal ( "Unexpected \"${actual_}\"" )
    return ()
  endif ()
endfunction ()

# ANCHOR: twx_expect
#[=======[
*/
/** @brief Expect a string value
  *
  * Raises when `actual` variable contents is not `expected`.
  *
  * @param actual_var is the name of the variable to test.
  *   Only one indirection.
  * @param expected_value is the expected value.
  * @param NUMBER, optional flag to switch to number comparison.
  */
twx_expect(actual_var expected_value [NUMBER] ) {}
/*
#]=======]
function ( twx_expect twx_expect.ACTUAL twx_expect.EXPECTED )
  cmake_parse_arguments (
    PARSE_ARGV 2 twxR
    "NUMBER" "" ""
  )
  if ( NOT "${twxR_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( NOT DEFINED "${twx_expect.ACTUAL}" )
    twx_fatal ( "Unexpected undefined \"${twx_expect.ACTUAL}\"")
    return ()
  endif ()
  if ( twxR_NUMBER )
    if ( NOT "${${twx_expect.ACTUAL}}" EQUAL "${twx_expect.EXPECTED}" )
      twx_fatal ( "Unexpected value \"${${twx_expect.ACTUAL}}\" of \"${twx_expect.ACTUAL}\" instead of \"${twx_expect.EXPECTED}\"")
      return ()
    endif ()
  else ()
    if ( NOT "${${twx_expect.ACTUAL}}" STREQUAL "${twx_expect.EXPECTED}" )
      twx_fatal ( "Unexpected value \"${${twx_expect.ACTUAL}}\" of \"${twx_expect.ACTUAL}\" instead of \"${twx_expect.EXPECTED}\"")
      return ()
    endif ()
  endif ()
endfunction ()

# ANCHOR: twx_unexpect
#[=======[
*/
/** @brief Unexpect a value
  *
  * Raises when `actual` variable contents is not `expected`.
  *
  * @param actual_var is the name of the variable to test.
  * @param expected_value is the expected value.
  * @param NUMBER, optional flag to switch to number comparison.
  */
twx_unexpect(actual_var expected_value [NUMBER] ) {}
/*
#]=======]
function ( twx_unexpect twx_unexpect.ACTUAL twx_unexpect.EXPECTED )
  cmake_parse_arguments (
    PARSE_ARGV 2 twxR
    "NUMBER" "" ""
  )
  if ( NOT "${twxR_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( NOT DEFINED "${twx_unexpect.ACTUAL}" )
    twx_fatal ( "Unexpected undefined \"${twx_unexpect.ACTUAL}\"")
    return ()
  endif ()
  if ( twxR_NUMBER )
    if ( "${${twx_unexpect.ACTUAL}}" EQUAL "${twx_unexpect.EXPECTED}" )
      twx_fatal ( "Unexpected value \"${${twx_unexpect.ACTUAL}}\" of \"${twx_unexpect.ACTUAL}\" instead of \"${twx_expect_unequal_string.EXPECTED}\"")
      return ()
    endif ()
  else ()
    if ( "${${twx_unexpect.ACTUAL}}" STREQUAL "${twx_unexpect.EXPECTED}" )
      twx_fatal ( "Unexpected value \"${${twx_unexpect.ACTUAL}}\" of \"${twx_unexpect.ACTUAL}\" instead of \"${twx_expect_unequal_string.EXPECTED}\"")
      return ()
    endif ()
  endif ()
endfunction ()

# ANCHOR: twx_expect_matches
#[=======[*/
/** @brief Raise when no match occurs
  *
  * The `CMAKE_MATCH_#` variables are available if the regular expression
  * has capture groups.
  *
  * @param actual is the actual string value
  * @param expected is the expected regular expression.
  */
twx_expect_matches( actual expected ) {}
/*#]=======]
macro ( twx_expect_matches twx_expect_matches.actual twx_expect_matches.expected )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( NOT "${twx_expect_matches.actual}" MATCHES "${twx_expect_matches.expected}" )
    twx_fatal ( "Failure: ${twx_expect_matches.actual} should match ${twx_expect_matches.expected}" )
  endif ()
endmacro ( twx_expect_matches )

# ANCHOR: twx_expect_unmatches
#[=======[*/
/** @brief Raise when match occurs
  *
  * @param actual is the actual text
  * Support the `$|` syntax.
  * @param expected is the expected regular expression.
  * Support the `$|` syntax.
  */
twx_expect_unmatches( actual expected ) {}
/*#]=======]
function ( twx_expect_unmatches actual_ expected_ )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong arguments: ARGV => ${ARGV}" )
  endif ()
  if ( "${actual_}" MATCHES "${expected_}" )
    twx_fatal ( "Failure: ${actual_} should not match ${expected_}" )
    return ()
  endif ()
endfunction ( twx_expect_unmatches )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

message ( DEBUG "TwxExpectLib loaded" )

#*/
