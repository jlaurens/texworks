#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Collection of core utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxCoreLib.cmake"
  )

Output state:
- `TWX_DIR`

*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_arg_assert )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_arg_assert
#[=======[*/
/** @brief Raises when an argument is not provided.
  *
  * @param ... non empty list of argument names. (Without `twxR_` prefix)
  */
twx_arg_assert(name ... ) {}
/*#]=======]
function ( twx_arg_assert name_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_assert )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_arg_assert_parsed
    "" "PREFIX" ""
  )
  if ( NOT DEFINED twxR_PREFIX )
    set ( twxR_PREFIX twxR )
  endif ()
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( v STREQUAL "PREFIX" )
      twx_math ( EXPR a "${ARGC}=${i}+2" )
      if ( NOT a )
        twx_fatal ( "Wrong arguments" )
        return ()
      endif ()
    endif ()
    if ( "${${twxR_PREFIX}_${v}}" STREQUAL "" )
      twx_fatal ( "Missing argument of key ${v}" )
      return ()
    endif ()
    twx_increment_and_break_if ( i >= ${ARGC} )
  endwhile ( )
endfunction ( twx_arg_assert )

# ANCHOR: twx_arg_assert_count
#[=======[
/** @brief Raise when the argument count is not expected
  *
  * @param argc, value of ARGC,
  * @param op, comparison binary operator.
  * @param right, number value.
  */
twx_arg_assert_count(argc op right) {}
/*#]=======]
function ( twx_arg_assert_count argc_ op_ right_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_assert_count )
  # message ( TR@CE "${argc_} ${op_} ${right_}" )
  if ( ARGC GREATER "3" )
    if ( "${ARGC}" GREATER 3 )
    else ()
      message ( FATAL_ERROR "ARGC(${ARGC}) <= 3" )
    endif ()
    twx_fatal ( "Too many arguments(${ARGC}>3): ARGV => \"${ARGV}\"" )
    return ()
  elseif ( "${ARGC}" LESS "3" )
    twx_fatal ( "Too few arguments" ) # Unreachable code, CMake breaks before
    return ()
  endif ()
  if ( op_ STREQUAL "<" )
    if ( NOT "${argc_}" LESS "${right_}" )
      twx_fatal ( "Unsatisfied ARGC < ${right_}" )
      return ()
    endif ()
  elseif ( op_ STREQUAL "<=" )
    if ( NOT "${argc_}" LESS_EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC <= ${right_}" )
      return ()
    endif ()
  elseif ( op_ STREQUAL "==" OR op_ STREQUAL "=" )
    if ( NOT "${argc_}" EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC == ${right_}" )
      return ()
    endif ()
  elseif ( op_ STREQUAL ">=" )
    if ( NOT "${argc_}" GREATER_EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC >= ${right_}" )
      return ()
    endif ()
  elseif ( op_ STREQUAL ">" )
    if ( NOT "${argc_}" GREATER "${right_}" )
      twx_fatal ( "Unsatisfied ARGC > ${right_}" )
      return ()
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (1), got \"${op_}\" instead" )
    return ()
  endif ()
endfunction ( twx_arg_assert_count )

# ANCHOR: twx_arg_pass_option
#[=======[*/
/** @brief Forward a flag in the arguments.
  *
  * Used in conjunction with `cmake_parse_arguments()`.
  * When an option FOO is parsed, we retrieve either `TRUE` or `FALSE`
  * in `twxR_FOO`. `twx_arg_pass_option` transforms this contents in `FOO` or an empty string
  * to allow the usage of `twxR_FOO` as argument of a command that accepts
  * the same FOO flag.
  * Moreover, the `TWX-D_FOO` is defined to be used where
  * a `-D...` argument is required.
  *
  * @param ... is a non empty list of flag names
  * @param prefix for key `PREFIX`, optional variable name prefix defaults to `twxR`.
  */
twx_arg_pass_option( ... [PREFIX prefix]) {}
/*#]=======]
function ( twx_arg_pass_option option_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_pass_option )
  set ( i 0 )
  while ( TRUE )
    set ( o "${ARGV${i}}" )
    if ( twxR_${o} )
      set ( twxR_${o} ${o} PARENT_SCOPE )
      set ( TWX-D_${o} "-DTWX_${o}=${o}" PARENT_SCOPE )
    else ()
      set ( twxR_${o} PARENT_SCOPE )
      set ( TWX-D_${o} PARENT_SCOPE )
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
endfunction ()

# ANCHOR: twx_arg_expect_keyword
#[=======[*/
/** @brief Raise when arguments are different.
  *
  * @param actual is the actual variable name.
  * @param expected is the expected value.
  */
twx_arg_expect_keyword( actual_var expected_value ) {}
/*#]=======]
function ( twx_arg_expect_keyword twx_arg_expect_keyword.ACTUAL twx_arg_expect_keyword.EXPECTED )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_expect_keyword )
  twx_arg_assert_count ( ${ARGC} == 2 )
  if ( NOT "${${twx_arg_expect_keyword.ACTUAL}}" STREQUAL "${twx_arg_expect_keyword.EXPECTED}" )
    twx_fatal ( "Missing keyword: ${${twx_arg_expect_keyword.ACTUAL}} should be ${twx_arg_expect_keyword.EXPECTED}" )
    return ()
  endif ()
endfunction ( twx_arg_expect_keyword )

# ANCHOR: twx_arg_assert_keyword
#[=======[*/
/** @brief Raise when arguments are different.
  *
  * @param ..., non empty list of variable names.
  * The expected value is the longest part of the name matching `[A-Z][A-Z][A-Z_]*[A-Z][A-Z]`.
  */
twx_arg_assert_keyword( ... ) {}
/*#]=======]
function ( twx_arg_assert_keyword twx_arg_assert_keyword.ACTUAL )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_assert_keyword )
  foreach ( twx_arg_assert_keyword.ACTUAL ${ARGV} )
    if ( twx_arg_assert_keyword.ACTUAL MATCHES "[A-Z][A-Z]([A-Z_]*[A-Z][A-Z]|[A-Z]*)" )
      twx_arg_expect_keyword ( "${twx_arg_assert_keyword.ACTUAL}" "${CMAKE_MATCH_0}" )
    else ()
      twx_fatal ( "Unsatisfied argument \"${twx_arg_assert_keyword.ACTUAL}\"" )
      return ()
    endif ()
  endforeach ()
endfunction ( twx_arg_assert_keyword )

# ANCHOR: twx_arg_assert_parsed
#[=======[*/
/** @brief Raise if there are unparsed arguments.
  *
  * @param prefix for key `PREFIX`, optional variable name prefix defaults to `twxR`.
  */
twx_arg_assert_parsed([PREFIX prefix]) {}
/*#]=======]
function ( twx_arg_assert_parsed )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_assert_parsed )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_arg_assert_parsed
    "" "PREFIX" ""
  )
  if ( DEFINED twx_arg_assert_parsed_PREFIX )
    twx_arg_assert_count ( ${ARGC} == 2 )
    twx_assert_non_void ( twx_arg_assert_parsed_PREFIX )
  else ()
    twx_arg_assert_count ( ${ARGC} == 0 )
    set ( twx_arg_assert_parsed_VAR_PREFIX twxR )
  endif ()
  # NB remember that arguments in functions and macros are not the same
  if ( NOT "${${twx_arg_assert_parsed_VAR_PREFIX}_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Unparsed arguments ${${twx_arg_assert_parsed_VAR_PREFIX}_UNPARSED_ARGUMENTS}" )
    return ()
  endif ()
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMathLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementLib.cmake" )

message ( DEBUG "TwxArgLib loaded" )

#*/
