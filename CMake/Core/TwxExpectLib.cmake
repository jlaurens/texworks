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

include_guard ( GLOBAL )
twx_lib_will_load ()

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
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  if ( NOT "${actual_}" STREQUAL "${expected_}" )
    twx_fatal ( "Unexpected ``${actual_}'' instead of ``${expected_}''")
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
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  if ( "${actual_}" STREQUAL "${expected_}" )
    twx_fatal ( "Unexpected ``${actual_}''" )
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
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  if ( NOT "${actual_}" EQUAL "${expected_}" )
    twx_fatal ( "Unexpected ``${actual_}'' instead of ``${expected_}''" )
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
    twx_fatal ( "Wrong arguments:" VAR ARGV )
    return ()
  endif ()
  if ( "${actual_}" EQUAL "${expected_}" )
    twx_fatal ( "Unexpected ``${actual_}''" )
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
  * @param expected_value is the expected value or nothing .
  * @param NUMBER, optional flag to switch to number comparison.
  */
twx_expect(actual_var expected_value [NUMBER] ) {}
/*
#]=======]
function ( twx_expect twx.R_ACTUAL_VAR twx.R_EXPECTED )
  cmake_parse_arguments (
    PARSE_ARGV 2 twx.R
    "NUMBER" "" ""
  )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Wrong arguments\nARGV => ${ARGV}" )
    return ()
  endif ()
  if ( NOT DEFINED "${twx.R_ACTUAL_VAR}" )
    twx_fatal ( "Unexpected undefined ``${twx.R_ACTUAL_VAR}''")
    return ()
  endif ()
  if ( twx.R_NUMBER )
    if ( NOT "${${twx.R_ACTUAL_VAR}}" EQUAL "${twx.R_EXPECTED}" )
      twx_fatal ( "Unexpected value ``${${twx.R_ACTUAL_VAR}}'' of ``${twx.R_ACTUAL_VAR}'' instead of ``${twx.R_EXPECTED}''")
      return ()
    endif ()
  else ()
    if ( NOT "${${twx.R_ACTUAL_VAR}}" STREQUAL "${twx.R_EXPECTED}" )
      twx_fatal ( "Unexpected value ``${${twx.R_ACTUAL_VAR}}'' of ``${twx.R_ACTUAL_VAR}'' instead of ``${twx.R_EXPECTED}''")
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
function ( twx_unexpect twx.R_ACTUAL_VAR twx.R_EXPECTED )
  cmake_parse_arguments (
    PARSE_ARGV 2 twx.R
    "NUMBER" "" ""
  )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
  endif ()
  if ( NOT DEFINED "${twx.R_ACTUAL_VAR}" )
    twx_fatal ( "Unexpected undefined ``${twx.R_ACTUAL_VAR}''")
    return ()
  endif ()
  if ( twx.R_NUMBER )
    if ( "${${twx.R_ACTUAL_VAR}}" EQUAL "${twx.R_EXPECTED}" )
      twx_fatal ( "Unexpected value ``${${twx.R_ACTUAL_VAR}}'' of ``${twx.R_ACTUAL_VAR}'' instead of ``${twx_expect_unequal_string.EXPECTED}''")
      return ()
    endif ()
  else ()
    if ( "${${twx.R_ACTUAL_VAR}}" STREQUAL "${twx.R_EXPECTED}" )
      twx_fatal ( "Unexpected value ``${${twx.R_ACTUAL_VAR}}'' of ``${twx.R_ACTUAL_VAR}'' instead of ``${twx_expect_unequal_string.EXPECTED}''")
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
macro ( twx_expect_matches twx_expect_matches.R_ACTUAL twx_expect_matches.R_EXPECTED )
  if ( NOT ${ARGC} EQUAL 2 )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
  endif ()
  if ( NOT "${twx_expect_matches.R_ACTUAL}" MATCHES "${twx_expect_matches.R_EXPECTED}" )
    twx_fatal ( "Failure: ${twx_expect_matches.R_ACTUAL} should match ${twx_expect_matches.R_EXPECTED}" )
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
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
  endif ()
  if ( "${actual_}" MATCHES "${expected_}" )
    twx_fatal ( "Failure: ${actual_} should not match ${expected_}" )
    return ()
  endif ()
endfunction ( twx_expect_unmatches )

# ANCHOR: twx_expect_list
#[=======[*/
/** @brief Raise when not the expected list
  *
  * @param actual is the actual unordered list to test
  * @param expected is the expected unorderd list.
  */
twx_expect_list( actual expected ) {}
/*#]=======]
function ( twx_expect_list actual_ )
  list ( SORT "${actual_}" )
  list ( SORT "ARGN" )
  twx_expect ( "${actual_}" "${ARGN}" )
endfunction ()

# ANCHOR: twx_expect_in_list
#[=======[*/
/** @brief Raise when not in list
  *
  * @param actual is the actual list item
  * @param ... are the expected list items.
  */
twx_expect_in_list( actual expected ) {}
/*#]=======]
function ( twx_expect_in_list actual_ expected_ )
  if ( NOT ARGC EQUAL 2 )
    twx_fatal ( " Bad usage (ARGN => ``${ARGN}'')" )
    return ()
  endif ()
  if ( NOT "${actual_}" IN_LIST "${expected_}" )
    twx_fatal ( "${actual_} is not one of ${expected_}" )
  endif ()
endfunction ()

# ANCHOR: twx_expect_not_in_list
#[=======[*/
/** @brief Raise when not in list
  *
  * @param actual is the actual list item
  * @param ... are the expected list items.
  */
twx_expect_not_in_list( actual expected ) {}
/*#]=======]
function ( twx_expect_not_in_list actual_ expected_ )
  if ( NOT ARGC EQUAL 2 )
    twx_fatal ( " Bad usage (ARGN => ``${ARGN}'')" )
    return ()
  endif ()
  if ( "${actual_}" IN_LIST "${expected_}" )
    twx_fatal ( "${actual_} is one of ${expected_}" )
  endif ()
endfunction ()

# ANCHOR: twx_expect_in
#[=======[*/
/** @brief Raise when not one of the given arguments
  *
  * @param actual is the actual list item
  * @param ... are the expected list items.
  */
twx_expect_in( actual ... ) {}
/*#]=======]
function ( twx_expect_in actual_ )
  if ( NOT "${actual_}" IN_LIST ARGN )
    twx_fatal ( "${actual_} is not one of ${ARGN}" )
  endif ()
endfunction ()

# ANCHOR: twx_expect_not_in
#[=======[*/
/** @brief Raise when one of the items
  *
  * @param actual is the actual list item
  * @param ... are the unexpected list items.
  */
twx_expect_in( actual ... ) {}
/*#]=======]
function ( twx_expect_in actual_ )
  if ( "${actual_}" IN_LIST ARGN )
    twx_fatal ( "${actual_} is one of ${ARGN}" )
  endif ()
endfunction ()

twx_lib_require ( "Fatal" )

twx_lib_did_load ()

#*/
