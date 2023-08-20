#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Incrementation utilities
  *
  * Loaded by the `Core` library with
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxIncrementLib.cmake"
  *   )
  *
  * Output state:
  * - `twx_increment()`
  * - `twx_break_if()`
  * - `twx_increment_and_break_if()`
  * - `twx_increment_and_assert()`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_increment ()
#[=======[
/** @brief Increment a variable
  *
  * Increment the counter.
  *
  * @param counter: name or the variable to increment.
  * Raise when undefined.
  * @param step for key `STEP`: optional value, defaults to 1.
  */
twx_increment(VAR counter) {}
/*#]=======]
function ( twx_increment )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "VAR;STEP" "" )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  if ( NOT DEFINED twx.R_VAR )
    twx_fatal ( "Missing argument: VAR in ``${ARGV}''")
    return ()
  endif ()
  if ( NOT DEFINED twx.R_STEP )
    if ( NOT ${ARGC} EQUAL 2 )
      twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
      return ()
    endif ()
    set ( twx.R_STEP 1 )
  else ()
    if ( NOT ${ARGC} EQUAL 4 )
      twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
      return ()
    endif ()
  endif ()
  # No twx_var_assert_name
  twx_var_assert_name ( "${twx.R_VAR}" )
  set ( .value "${${twx.R_VAR}}" )
  math ( EXPR .value "${.value}+(${twx.R_STEP})" )
  set ( ${twx.R_VAR} "${.value}" PARENT_SCOPE )
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
macro (
  twx_break_if
  twx_break_if.left
  twx_break_if.op
  twx_break_if.right
)
  if ( NOT ${ARGC} EQUAL 3 )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    break ()
  elseif ( "${twx_break_if.op}" STREQUAL "<" )
    if ( "${twx_break_if.left}" LESS "${twx_break_if.right}" )
      break ()
    endif ()
  elseif ( "${twx_break_if.op}" STREQUAL "<=" )
    if ( "${twx_break_if.left}" LESS_EQUAL "${twx_break_if.right}" )
      break ()
    endif ()
  elseif ( "${twx_break_if.op}" STREQUAL "==" OR "${twx_break_if.op}" STREQUAL "=" )
    if ( "${twx_break_if.left}" EQUAL "${twx_break_if.right}" )
      break ()
    endif ()
  elseif ( "${twx_break_if.op}" STREQUAL "!=" OR "${twx_break_if.op}" STREQUAL "<>" )
    if ( NOT "${twx_break_if.left}" EQUAL "${twx_break_if.right}" )
      break ()
    endif ()
  elseif ( "${twx_break_if.op}" STREQUAL ">=" )
    if ( "${twx_break_if.left}" GREATER_EQUAL "${twx_break_if.right}" )
      break ()
    endif ()
  elseif ( "${twx_break_if.op}" STREQUAL ">" )
    if ( "${twx_break_if.left}" GREATER "${twx_break_if.right}" )
      break ()
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (3), got ``${twx_break_if.op}'' instead" )
    break ()
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
macro (
  twx_increment_and_break_if
  twx_increment_and_break_if.VAR
  twx_increment_and_break_if.counter
  twx_increment_and_break_if.op
  twx_increment_and_break_if.right
)
  if ( NOT ${ARGC} EQUAL 4 )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  twx_increment (
    "${twx_increment_and_break_if.VAR}"
    "${twx_increment_and_break_if.counter}"
  )
  twx_break_if (
    "${${twx_increment_and_break_if.counter}}"
    "${twx_increment_and_break_if.op}"
    "${twx_increment_and_break_if.right}"
  )
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
macro (
  twx_increment_and_assert
  twx_increment_and_assert.VAR
  twx_increment_and_assert.counter
  twx_increment_and_assert.op
  twx_increment_and_assert.right
)
  if ( NOT ${ARGC} EQUAL 4 )
    twx_fatal ( "Wrong arguments:\nARGV => ``${ARGV}''" )
    return ()
  endif ()
  twx_increment (
    "${twx_increment_and_assert.VAR}"
    "${twx_increment_and_assert.counter}"
  )
  if ( "${twx_increment_and_assert.op}" STREQUAL "<" )
    if ( NOT "${${twx_increment_and_assert.counter}}" LESS "${twx_increment_and_assert.right}" )
      twx_fatal ("Missed ${twx_increment_and_assert.counter} {twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  elseif ( "${twx_increment_and_assert.op}" STREQUAL "<=" )
    if ( NOT "${${twx_increment_and_assert.counter}}" LESS_EQUAL "${twx_increment_and_assert.right}" )
      twx_fatal ( "Missed ${twx_increment_and_assert.counter} ${twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  elseif ( "${twx_increment_and_assert.op}" STREQUAL "==" OR "${twx_increment_and_assert.op}" STREQUAL "=" )
    if ( NOT "${${twx_increment_and_assert.counter}}" EQUAL "${twx_increment_and_assert.right}" )
      twx_fatal ( "Missed ${twx_increment_and_assert.counter} ${twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  elseif ( "${twx_increment_and_assert.op}" STREQUAL "!=" OR "${twx_increment_and_assert.op}" STREQUAL "<>" )
    if ( "${${twx_increment_and_assert.counter}}" EQUAL "${twx_increment_and_assert.right}" )
      twx_fatal ( "Missed ${twx_increment_and_assert.counter} ${twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  elseif ( "${twx_increment_and_assert.op}" STREQUAL ">=" )
    if ( NOT "${${twx_increment_and_assert.counter}}" GREATER_EQUAL "${twx_increment_and_assert.right}" )
      twx_fatal ( "Missed ${twx_increment_and_assert.counter} ${twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  elseif ( "${twx_increment_and_assert.op}" STREQUAL ">" )
    if ( NOT "${${twx_increment_and_assert.counter}}" GREATER "${twx_increment_and_assert.right}" )
      twx_fatal ( "Missed ${twx_increment_and_assert.counter} ${twx_increment_and_assert.op} ${twx_increment_and_assert.right}" )
      return ()
    endif ()
  else ()
    twx_fatal ( "Missing comparison binary operator (3), got ``${twx_increment_and_assert.op}'' instead" )
    return ()
  endif ()
endmacro ( twx_increment_and_assert )

twx_lib_require ( "Fatal" )

twx_lib_did_load ()

#*/
