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
if ( COMMAND twx_increment )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_increment ()
#[=======[
/** @brief Increment a variable
  *
  * Increment the counter.
  *
  * @param counter: name or the variable to increment.
  * Raise when undefined.
  * @param step for key `STEP`: optional value, defaults to 1.
  * Support `$|` syntax.
  */
twx_increment(VAR counter) {}
/*#]=======]
function ( twx_increment )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "VAR;STEP" "" )
  if ( NOT "${twxR_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Unexpected arguments: ARGV => \"${ARGV}\"" )
    return ()
  endif ()
  twx_arg_assert_parsed ()
  if ( NOT DEFINED twxR_VAR )
    twx_fatal ( "Missing argument: VAR in \"${ARGV}\"")
    return ()
  endif ()
  if ( NOT DEFINED twxR_STEP )
    if ( NOT ${ARGC} EQUAL 2 )
    twx_fatal ( "Wrong arguments: ARGV => \"${ARGV}\"" )
    return ()
    endif ()
    set ( twxR_STEP 1 )
  else ()
    if ( NOT ${ARGC} EQUAL 4 )
    twx_fatal ( "Wrong arguments: ARGV => \"${ARGV}\"" )
    return ()
    endif ()
  endif ()
  # No twx_assert_variable
  if ( NOT "${twxR_VAR}" MATCHES "${TWX_VARIABLE_RE}" )
    twx_fatal ( "Not a variable name: \"${twxR_VAR}\"" )
    return ()
  endif ()
  set ( .value "${${twxR_VAR}}" )
  math ( EXPR .value "${.value}+(${twxR_STEP})" )
  set ( ${twxR_VAR} "${.value}" PARENT_SCOPE )
endfunction ( twx_increment )

# ANCHOR: twx_break_if ()
#[=======[
/** @brief Break if a counter exceeds a value
  *
  * Both arguments may be interpreted as variables.
  * @param left, a value.
  * @param op comparison binary operator.
  * @param right, a value.
  */
twx_break_if(left op right) {}
/*#]=======]
macro ( twx_break_if left_ op_ right_ )
  if ( NOT ${ARGC} EQUAL 3 )
    twx_fatal ( "Wrong arguments: ARGV => \"${ARGV}\"" )
    return ()
  endif ()
  # message ( TR@CE "twx_break_if: ${left_} ${op_} ${right_}")
  if ( "${op_}" STREQUAL "<" )
    if ( "${left_}" LESS "${right_}" )
      break ()
    endif ()
  elseif ( "${op_}" STREQUAL "<=" )
    if ( "${left_}" LESS_EQUAL "${right_}" )
      break ()
    endif ()
  elseif ( "${op_}" STREQUAL "==" OR "${op_}" STREQUAL "=" )
    if ( "${left_}" EQUAL "${right_}" )
      break ()
    endif ()
  elseif ( "${op_}" STREQUAL ">=" )
    if ( "${left_}" GREATER_EQUAL "${right_}" )
      break ()
    endif ()
  elseif ( "${op_}" STREQUAL ">" )
    if ( "${left_}" GREATER "${right_}" )
      break ()
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (3), got \"${op_}\" instead" )
    return ()
  endif ()
endmacro ()

#[=======[
When done, cmake_parse_arguments will consider for each of the keywords
listed in <options>, <one_value_keywords> and <multi_value_keywords>
a variable composed of the given <prefix> followed by "_" and the name
of the respective keyword. These variables will then hold the respective
value from the argument list or be undefined if the associated option
could not be found. For the <options> keywords, these will always be
defined, to TRUE or FALSE, whether the option is in the argument list
or not.
#]=======]

# ANCHOR: twx_increment_and_break_if ()
#[=======[
/** @brief Increment a variable and break eventually
  *
  * Increment the counter and break if the ordering is satisfied.
  *
  * @param counter is the variable name to increment.
  * Support the `$|` syntax.
  * @param op, comparison binary operator
  * @param right, value.
  * Support the `$|` syntax.
  */
twx_increment_and_break_if(VAR counter op right) {}
/*#]=======]
macro ( twx_increment_and_break_if VAR_ counter_ op_ right_)
  if ( NOT ${ARGC} EQUAL 4 )
    twx_fatal ( "Wrong arguments: ARGV => \"${ARGV}\"" )
    return ()
  endif ()
  twx_increment ( "${VAR_}" "${counter_}" )
  twx_break_if ( "${${counter_}}" "${op_}" "${right_}" )
endmacro ( twx_increment_and_break_if )

# ANCHOR: twx_increment_and_assert ()
#[=======[
/** @brief Increment a variable and raise eventually
  *
  * Increment the counter and raise if the ordering is not satisfied.
  *
  * @param counter is the variable name to increment.
  * Support the `$|` syntax.
  * @param op, comparison binary operator
  * @param right, value.
  * Support the `$|` syntax.
  */
twx_increment_and_assert(VAR counter op right) {}
/*#]=======]
macro ( twx_increment_and_assert VAR_ counter_ op_ right_)
  if ( NOT ${ARGC} EQUAL 4 )
    twx_fatal ( "Wrong arguments: ARGV => \"${ARGV}\"" )
    return ()
  endif ()
  twx_increment ( "${VAR_}" "${counter_}" )
  if ( "${op_}" STREQUAL "<" )
    if ( NOT "${left_}" LESS "${right_}" )
      twx_fatal ( "Missed ${left_} {op_} ${right_}" )
      return ()
    endif ()
  elseif ( "${op_}" STREQUAL "<=" )
    if ( NOT "${left_}" LESS_EQUAL "${right_}" )
      twx_fatal ( "Missed ${left_} {op_} ${right_}" )
      return ()
    endif ()
  elseif ( "${op_}" STREQUAL "==" OR "${op_}" STREQUAL "=" )
    if ( NOT "${left_}" EQUAL "${right_}" )
      twx_fatal ( "Missed ${left_} {op_} ${right_}" )
      return ()
    endif ()
  elseif ( "${op_}" STREQUAL ">=" )
    if ( NOT "${left_}" GREATER_EQUAL "${right_}" )
      twx_fatal ( "Missed ${left_} {op_} ${right_}" )
      return ()
    endif ()
  elseif ( "${op_}" STREQUAL ">" )
    if ( NOT "${left_}" GREATER "${right_}" )
      twx_fatal ( "Missed ${left_} {op_} ${right_}" )
      return ()
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (3), got \"${op_}\" instead" )
    return ()
  endif ()
endmacro ( twx_increment_and_assert )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )

message ( VERBOSE "TwxIncrementLib loaded" )

#*/
