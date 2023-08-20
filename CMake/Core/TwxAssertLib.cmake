#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief sAssert library
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxAssertLib.cmake"
  *     NO_POLICY_SCOPE
  *   )
  * or `include ( TwxAssertLib )` when `Base` is already available.
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# Full include only once
# ANCHOR: twx_assert_undefined
#[=======[
*/
/** @brief Expect an undefined variable
  *
  * Raises when one of the arguments is the name of a defined variable.
  *
  * @param ... is a non empty list of variable names.
  */
twx_assert_undefined ( ... ) {}
/*
#]=======]
function ( twx_assert_undefined twx_assert_undefined.v )
  # Beware of name conflicts
  # Local variables should not hide arguments
  set ( twx_assert_undefined.i 0 )
  while ( TRUE )
    set ( twx_assert_undefined.v ${ARGV${twx_assert_undefined.i}} )
    if ( DEFINED ${twx_assert_undefined.v} )
      twx_fatal ( "Unexpected defined ``${twx_assert_undefined.v}''" )
    endif ()
    math ( EXPR twx_assert_undefined.i "${twx_assert_undefined.i}+1" ) 
    if ( ${ARGC} EQUAL twx_assert_undefined.i )
      break ()
    endif ()
  endwhile ()
endfunction ()

# ANCHOR: twx_assert_defined
#[=======[
*/
/** @brief Expect a defined variable
  *
  * Raises when `name` is not the name of a defined variable.
  *
  * @param ... is a non empty list of variable names.
  * support the `$|` syntax
  */
twx_assert_defined ( ... ) {}
/*
#]=======]
function ( twx_assert_defined twx_assert_defined.n )
  # Beware of name conflicts
  # Local variables should not hide arguments
  set ( twx_assert_defined.i 0 )
  while ( TRUE )
    set ( twx_assert_defined.n ${ARGV${twx_assert_defined.i}} )
    if ( NOT DEFINED ${twx_assert_defined.n} )
      twx_fatal ( "Unexpected undefined ``${twx_assert_defined.n}''" )
    endif ()
    math ( EXPR twx_assert_defined.i "${twx_assert_defined.i}+1" ) 
    if ( ${ARGC} EQUAL twx_assert_defined.i )
      break ()
    endif ()
  endwhile ()
endfunction ()

# ANCHOR: twx_assert_compare
#[=======[*/
/** @brief Raise when ordering is not satisfied.
  *
  * Usages:
  * - `twx_assert_compare ( left op1 right1 [op2 right2]...)`
  *
  * @param NUMBER, optional flag for number comparison. The default.
  * @param STR, optional flag for string comparison.
  * @param left, number value.
  * @param op, comparison binary operator.
  * @param right, number value.
  */
twx_assert_compare( [NUMBER|STR] left op right ) {}
/*#]=======]
function ( twx_assert_compare .left .op .right )
  set ( left_ "${ARGV1}" )
  set ( i 2 )
  set ( prefix_ "" )
  if ( "${ARGV0}" STREQUAL "STR" )
    set ( prefix STR )
  elseif ( NOT "${ARGV0}" STREQUAL "NUMBER" )
    set ( left_ "${ARGV0}" )
    set ( i 1 )
  endif ()
  while ( TRUE )
    set ( op_ "${ARGV${i}}" )
    math ( EXPR i "${i}+1" )
    if ( ${ARGC} EQUAL i )
      message ( FATAL_ERROR "Missing rhs" )
    endif ()
    set ( right_ "${ARGV${i}}" )
    if ( op_ STREQUAL "<" )
      if ( NOT "${left_}" ${prefix_}LESS "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    elseif ( op_ STREQUAL "<=" )
      if ( NOT "${left_}" ${prefix_}LESS_EQUAL "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    elseif ( op_ STREQUAL "==" OR op_ STREQUAL "=" )
      if ( NOT "${left_}" ${prefix_}EQUAL "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    elseif ( op_ STREQUAL ">=" )
      if ( NOT "${left_}" ${prefix_}GREATER_EQUAL "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    elseif ( op_ STREQUAL ">" )
      if ( NOT "${left_}" ${prefix_}GREATER "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    elseif ( op_ STREQUAL "!=" OR op_ STREQUAL "<>" )
      if ( "${left_}" ${prefix_}EQUAL "${right_}" )
        twx_fatal ( "Unsatisfied ${left_} ${op_} ${right_}" )
      endif ()
    else ()
      twx_fatal ( "Missing comparison binary operator (2), got ``${op_}'' instead" )
    endif ()
    math ( EXPR i "${i}+1" ) 
    if ( ${ARGC} EQUAL i )
      break ()
    endif ()
    set ( left_ "${right_}" )
  endwhile ()
endfunction ( twx_assert_compare )

# ANCHOR: twx_assert_non_void
#[=======[*/
/** @brief Raises when one of the variables is empty.
  *
  * @param ... non empty list of variable names.
  */
twx_assert_non_void( ... ) {}
/*#]=======]
# TODO: twx_fatal_message ( IN_VAR ... )
function ( twx_assert_non_void .var )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( v MATCHES "^ARG(C|[VN][0-9]*)$" )
      twx_fatal ( "Unsupported argument: ``${v}''")
    endif ()
    if ( "${${v}}" STREQUAL "" )
      twx_fatal ( "Missing ${v}" )
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_non_void )

# ANCHOR: twx_assert_0
#[=======[*/
/** @brief Raise when the argument is not 0
  *
  * The argument is in general the return value of a command.
  * @param ... is a non empty list of values.
  * Support the `$|` syntax.
  */
twx_assert_0( ... ) {}
/*#]=======]
function ( twx_assert_0 v )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => ``${v}''" )
    if ( NOT "${v}" EQUAL "0" )
      twx_fatal ( "Unexpected ``${v}'' instead of 0")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_assert_0 )

# ANCHOR: twx_assert_true
#[=======[*/
/** @brief Raise when the argument is not a truthy value
  *
  * @param ... is non empty list of values.
  * Support the `$|` syntax.
  */
twx_assert_true( ... ) {}
/*#]=======]
function ( twx_assert_true value_ )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( NOT ${v} )
      twx_fatal ( "Unexpected falsy ${v}")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ()

# ANCHOR: twx_assert_false
#[=======[*/
/** @brief Raise when the argument is not a falsy value
  *
  * @param ... is a non empty list of value names
  */
twx_assert_false( ... ) {}
/*#]=======]
function ( twx_assert_false .value )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( ${v} )
      twx_fatal ( "Unexpected truthy ${v}")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ()

# ANCHOR: twx_assert_exists
#[=======[*/
/** @brief Raises when a file or directory is missing.
  *
  * @param ... is a non empty list of candidate path values.
  * When the path is relative,
  * the current default resolution applies.
  * Support `$|` syntax.
  */
twx_assert_exists(actual) {}
/*#]=======]
function ( twx_assert_exists .p )
  set ( i 0 )
  while ( TRUE )
    set ( p "${ARGV${i}}" )
    if ( NOT EXISTS "${p}" )
      twx_fatal ( "Missing file/directory at ${p}")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_exists )

# ANCHOR: twx_assert_matches
#[=======[*/
/** @brief Raises when no match.
  *
  * @param actual, text to test.
  * @param regex, the regular expression.
  */
twx_assert_matches(actual regex) {}
/*#]=======]
function ( twx_assert_matches a m )
  if ( NOT a MATCHES "${m}" )
    twx_fatal ( "Failure: ``${a}'' does not match ``${m}''" )
  endif ()
endfunction ()

# ANCHOR: twx_assert_not_matches
#[=======[*/
/** @brief Raises when match.
  *
  * @param actual, text to test.
  * @param regex, the regular expression.
  */
twx_assert_not_matches(actual regex) {}
/*#]=======]
function ( twx_assert_not_matches a m )
  if ( a MATCHES "${m}" )
    twx_fatal ( "Failure: ``${a}'' does not match ``${m}''" )
  endif ()
endfunction ()

# ANCHOR: twx_assert_target
#[=======[*/
/** @brief Raise when a target does not exist.
  *
  * @param ... is a non empty list of candidate target names.
  */
twx_assert_target(...) {}
/*#]=======]
function ( twx_assert_target .t )
  set ( i 0 )
  while ( TRUE )
    set ( t "${ARGV${i}}" )
    if ( NOT TARGET "${t}" )
      twx_fatal ( "Unknown target ${t}" )
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ()

# ANCHOR: twx_assert_command
#[=======[*/
/** @brief Raise when a command does not exist.
  *
  * @param ... is a non empty list of candidate command names.
  */
twx_assert_command(...) {}
/*#]=======]
function ( twx_assert_command .c )
  set ( i 0 )
  while ( TRUE )
    set ( c "${ARGV${i}}" )
    if ( NOT COMMAND "${c}" )
      twx_fatal ( "Unknown command ${c}" )
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_command )

# ANCHOR: twx_assert_error
#[=======[*/
/** @brief Raise when no error is pending.
  *
  * Raises when the `twx.ERROR_VARIABLE` is undefined.
  */
twx_assert_error(...) {}
/*#]=======]
function ( twx_assert_error )
  twx_assert_defined ( twx.ERROR_VARIABLE )
  set ( twx.ERROR_VARIABLE PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_assert_no_error
#[=======[*/
/** @brief Raise when an error is pending.
  *
  * Raises when the `twx.ERROR_VARIABLE` is defined.
  */
twx_assert_no_error(...) {}
/*#]=======]
function ( twx_assert_no_error )
  if ( "${twx.RESULT_VARIABLE}" EQUAL 1 AND DEFINED twx.ERROR_VARIABLE )
    twx_fatal ( "Unexpected error: ``${twx.ERROR_VARIABLE}''" )
  endif ()
endfunction ()

twx_lib_require ( "Fatal" )

twx_lib_did_load ()
#*/
