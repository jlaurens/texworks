#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Argument utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxArgLib.cmake"
  )

Output state:
- `twx_arg_assert()`
- `twx_arg_assert_count()`
- `twx_arg_assert_keyword()`
- `twx_arg_expect_keyword()`
- `twx_arg_pass_option()`
- `twx_arg_assert_parsed()`

*/
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_require ( "Var" "Fatal" "Assert" "Increment" )

twx_lib_will_load ()

# ANCHOR: twx_arg_assert
#[=======[*/
/** @brief Raises when an argument is not provided.
  *
  * @param ... non empty list of argument names. (Without `twx.R_` prefix)
  */
twx_arg_assert(name ... ) {}
/*#]=======]
function ( twx_arg_assert name_ )
  # NO: twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_arg_assert
    "" "PREFIX" ""
  )
  if ( NOT DEFINED twx_arg_assert.R_PREFIX )
    cmake_parse_arguments (
      twx_arg_assert.R
      "PREFIX" "" ""
      ${ARGV}
    )
    if ( twx_arg_assert.R_PREFIX AND DEFINED TWX_CMD )
      set ( twx_arg_assert.R_PREFIX ${TWX_CMD}.R )
    else ()
      set ( twx_arg_assert.R_PREFIX twx.R )
    endif ()
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
    if ( "${${twx.R_PREFIX}_${v}}" STREQUAL "" )
      twx_fatal ( "Missing argument for key ${v}" )
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
  twx_function_begin ()
  # message ( TR@CE "${argc_} ${op_} ${right_}" )
  if ( ARGC GREATER 3 )
    twx_fatal ( "Too many arguments(${ARGC}>3)\nARGV => ``${ARGV}''" RETURN )
  elseif ( ARGC LESS 3 )
    twx_fatal ( "Too few arguments" RETURN ) # Unreachable code, CMake breaks before
  elseif ( op_ STREQUAL "<" )
    if ( NOT "${argc_}" LESS "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  elseif ( op_ STREQUAL "<=" )
    if ( NOT "${argc_}" LESS_EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  elseif ( op_ STREQUAL "==" OR op_ STREQUAL "=" )
    if ( NOT "${argc_}" EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  elseif ( op_ STREQUAL "!=" OR op_ STREQUAL "<>" )
    if ( "${argc_}" EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  elseif ( op_ STREQUAL ">=" )
    if ( NOT "${argc_}" GREATER_EQUAL "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  elseif ( op_ STREQUAL ">" )
    if ( NOT "${argc_}" GREATER "${right_}" )
      twx_fatal ( "Unsatisfied ARGC(${argc_}) ${op_} ${right_}" RETURN )
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (1), got ``${op_}'' instead" RETURN )
  endif ()
endfunction ( twx_arg_assert_count )

# ANCHOR: twx_arg_pass_option
#[=======[*/
/** @brief Forward a flag in the arguments.
  *
  * Used in conjunction with `cmake_parse_arguments()`.
  * When an option FOO is parsed, we retrieve either `TRUE` or `FALSE`
  * in `twx.R_FOO`. `twx_arg_pass_option` transforms this contents in `FOO` or an empty string
  * to allow the usage of `twx.R_FOO` as argument of a command that accepts
  * the same FOO flag.
  * Moreover, the `TWX-D_FOO` is defined to be used where
  * a `-D...` argument is required.
  *
  * @param ... is a non empty list of flag names
  * @param prefix for key `PREFIX`, optional variable name prefix defaults to `twx.R`.
  */
twx_arg_pass_option( ... [PREFIX prefix]) {}
/*#]=======]
function ( twx_arg_pass_option option_ )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "PREFIX" ""
  )
  if ( DEFINED ${TWX_CMD}.R_PREFIX )
    set ( ${TWX_CMD}.PREFIX ${${TWX_CMD}.R_PREFIX} )
  else ()
    set ( ${TWX_CMD}.PREFIX twx.R )
  endif ()
  foreach ( ${TWX_CMD}.OPTION IN LISTS twx_arg_pass_option.R_UNPARSED_ARGUMENTS )
    if ( ${${TWX_CMD}.PREFIX}_${${TWX_CMD}.OPTION} )
      set ( ${${TWX_CMD}.PREFIX}_${${TWX_CMD}.OPTION} ${${TWX_CMD}.OPTION} PARENT_SCOPE )
      set ( TWX-D_${${TWX_CMD}.OPTION} "-DTWX_${${TWX_CMD}.OPTION}=${${TWX_CMD}.OPTION}" PARENT_SCOPE )
    else ()
      set ( ${${TWX_CMD}.PREFIX}_${${TWX_CMD}.OPTION} PARENT_SCOPE )
      set ( TWX-D_${${TWX_CMD}.OPTION} PARENT_SCOPE )
    endif ()
  endforeach ()
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
  twx_function_begin ()
  twx_arg_assert_count ( ${ARGC} == 2 )
  if ( NOT "${${twx_arg_expect_keyword.ACTUAL}}" STREQUAL "${twx_arg_expect_keyword.EXPECTED}" )
    twx_fatal ( "Missing keyword: ${${twx_arg_expect_keyword.ACTUAL}} \
should be ${twx_arg_expect_keyword.EXPECTED} \
instead of ``${${twx_arg_expect_keyword.ACTUAL}}''" )
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
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "PREFIX" ""
  )
  foreach ( ${TWX_CMD}.ACTUAL IN LISTS ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    if ( DEFINED ${TWX_CMD}.R_PREFIX )
      string ( PREPEND ${TWX_CMD}.ACTUAL "${${TWX_CMD}.R_PREFIX}_" )
    endif ()
    if ( ${TWX_CMD}.ACTUAL MATCHES "^[A-Z][A-Z]_([A-Z_]+[A-Z][A-Z])" )
      twx_arg_expect_keyword ( "${${TWX_CMD}.ACTUAL}" "${CMAKE_MATCH_1}" )
    elseif ( ${TWX_CMD}.ACTUAL MATCHES "[A-Z][A-Z][A-Z_]*[A-Z][A-Z]" )
      twx_arg_expect_keyword ( "${${TWX_CMD}.ACTUAL}" "${CMAKE_MATCH_0}" )
    elseif ( ${TWX_CMD}.ACTUAL MATCHES "[^A_Z][A-Z][A-Z]_+([A-Z][A-Z]+)" )
      twx_arg_expect_keyword ( "${${TWX_CMD}.ACTUAL}" "${CMAKE_MATCH_1}" )
    elseif ( ${TWX_CMD}.ACTUAL MATCHES "[A-Z][A-Z]+" )
      twx_arg_expect_keyword ( "${${TWX_CMD}.ACTUAL}" "${CMAKE_MATCH_0}" )
    else ()
      twx_fatal ( "Unsatisfied argument ``${${TWX_CMD}.ACTUAL}''" )
      return ()
    endif ()
  endforeach ()
endfunction ( twx_arg_assert_keyword )

# ANCHOR: twx_arg_assert_parsed
#[=======[*/
/** @brief Raise if there are unparsed arguments.
  *
  * @param prefix for key `PREFIX`, optional variable name prefix defaults to `twx.R`.
  * @param ... for key `UNEXPECTED`, unexpected extra arguments.
  * @param PREFIX, optional flag. When provided this is
  *   equivalent to `PREFIX ${TWX_CMD}.R` or `PREFIX twx.R`.
  */
twx_arg_assert_parsed([PREFIX [prefix]] [UNEXPECTED ...]) {}
/*#]=======]
macro ( twx_arg_assert_parsed )
  # NO: twx_function_begin
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_arg_assert_parsed )
  cmake_parse_arguments (
    twx_arg_assert_parsed.R
    "" "PREFIX" "UNEXPECTED"
    ${ARGV}
  )
  if ( DEFINED twx_arg_assert_parsed.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_arg_assert_parsed.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED twx_arg_assert_parsed.R_PREFIX )
    cmake_parse_arguments (
      twx_arg_assert_parsed.R
      "PREFIX" "" ""
      ${ARGV}
    )
    if ( twx_arg_assert_parsed.R_PREFIX AND DEFINED TWX_CMD )
      set ( twx_arg_assert_parsed.R_PREFIX ${TWX_CMD}.R )
    else ()
      set ( twx_arg_assert_parsed.R_PREFIX twx.R )
    endif ()
  endif ()
  twx_assert_non_void ( twx_arg_assert_parsed.R_PREFIX )
  # NB remember that arguments in functions and macros are not the same
  if ( NOT "${${twx_arg_assert_parsed.R_PREFIX}_UNPARSED_ARGUMENTS}" STREQUAL "" )
    if ( DEFINED twx_arg_assert_parsed.R_UNEXPECTED )
      twx_fatal ( "Unparsed arguments ``${twx_arg_assert_parsed.R_UNEXPECTED}''" )
    else ()
      twx_fatal ( "Unparsed arguments ``${${twx_arg_assert_parsed.R_PREFIX}_UNPARSED_ARGUMENTS}''" )
    endif ()
  endif ()
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  foreach ( X R_PREFIX R_UNEXPECTED R_UNPARSED_ARGUMENTS R_KEYWORDS_MISSING_VALUES )
    set ( twx_arg_assert_parsed.${X} )
  endforeach ()
endmacro ( twx_arg_assert_parsed )

twx_lib_did_load ()

#*/
