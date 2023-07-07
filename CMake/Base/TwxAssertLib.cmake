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
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxAssertLib.cmake"
  *     NO_POLICY_SCOPE
  *   )
  * or `include ( TwxAssertLib )` when `Base` is already available.
  */
/*#]===============================================]

# Full include only once
if ( COMMAND twx_assert_undefined )
  return ()
endif ()

# ANCHOR: twx_assert_undefined
#[=======[
*/
/** @brief Expect an undefined variable
  *
  * Raises when `name` is the name of a defined variable.
  *
  * @param ... is a non empty list of variable names.
  * support the `$|` syntax
  */
twx_assert_undefined ( ... ) {}
/*
#]=======]
function ( twx_assert_undefined twx_assert_undefined.v )
  set ( twx_assert_undefined.i 0 )
  while ( TRUE )
    set ( twx_assert_undefined.v ${ARGV${twx_assert_undefined.i}} )
    if ( DEFINED ${twx_assert_undefined.v} )
      twx_fatal ( "Unexpected defined \"${twx_assert_undefined.v}\"" )
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
  set ( twx_assert_defined.i 0 )
  while ( TRUE )
    set ( twx_assert_defined.n ${ARGV${twx_assert_defined.i}} )
    if ( NOT DEFINED ${twx_assert_defined.n} )
      twx_fatal ( "Unexpected undefined \"${twx_assert_defined.n}\"" )
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
  * @param left, number value.
  * Support `$|` syntax.
  * @param op, comparison binary operator.
  * @param right, number value.
  * Support `$|` syntax.
  */
twx_assert_compare( left op right ) {}
/*#]=======]
function ( twx_assert_compare left_ op_ right_ )
  set ( left_ "${ARGV0}" )
  set ( i 1 )
  while ( TRUE )
    set ( op_ "${ARGV${i}}" )
    math ( EXPR i "${i}+1" ) 
    if ( ${ARGC} EQUAL i )
      message ( FATAL_ERROR "Missing VAR argument" )
    endif ()
    set ( right_ "${ARGV${i}}" )
    if ( op_ STREQUAL "<" )
      if ( NOT "${left_}" LESS "${right_}" )
        twx_fatal ( "Unexpected ${left_} >= ${right_}" )
      endif ()
    elseif ( op_ STREQUAL "<=" )
      if ( NOT "${left_}" LESS_EQUAL "${right_}" )
        twx_fatal ( "Unexpected ${left_} > ${right_}" )
      endif ()
    elseif ( op_ STREQUAL "==" OR op_ STREQUAL "=" )
      if ( NOT "${left_}" EQUAL "${right_}" )
        twx_fatal ( "Unexpected ${left_} != ${right_}" )
      endif ()
    elseif ( op_ STREQUAL ">=" )
      if ( NOT "${left_}" GREATER_EQUAL "${right_}" )
        twx_fatal ( "Unexpected ${left_} < ${right_}" )
      endif ()
    elseif ( op_ STREQUAL ">" )
      if ( NOT "${left_}" GREATER "${right_}" )
        twx_fatal ( "Unexpected ${left_} <= ${right_}" )
      endif ()
    else ()
      twx_fatal ( "Missing comparison binary operator (2), got \"${op_}\" instead" )
    endif ()
    set ( left_ "${right_}" )
    math ( EXPR i "${i}+1" ) 
    if ( ${ARGC} EQUAL i )
      break ()
    endif ()
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
function ( twx_assert_non_void var_ )
  set ( twx_assert_non_void.i 0 ) 
  while ( TRUE )
    set ( twx_assert_non_void.v "${ARGV${twx_assert_non_void.i}}" )
    if ( twx_assert_non_void.v MATCHES "^ARG(C|[VN][0-9]*)$" )
      twx_fatal ( "Unsupported argument: \"${twx_assert_non_void.v}\"")
    endif ()
    if ( "${${twx_assert_non_void.v}}" STREQUAL "" )
      twx_fatal ( "Missing ${twx_assert_non_void.v}" )
    endif ()
    math ( EXPR twx_assert_non_void.i "${twx_assert_non_void.i}+1" )
    if ( "${twx_assert_non_void.i}" EQUAL "${ARGC}" )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_assert_0 )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => \"${v}\"" )
    if ( NOT "${v}" EQUAL "0" )
      twx_fatal ( "Unexpected \"${v}\" instead of 0")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL "${ARGC}" )
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
    if ( "${i}" EQUAL "${ARGC}" )
      break ()
    endif ()
  endwhile ( )
endfunction ()

# ANCHOR: twx_assert_false
#[=======[*/
/** @brief Raise when the argument is not a falsy value
  *
  * @param ... is a non empty list of values
  * Support the `$|` syntax.
  */
twx_assert_false( ... ) {}
/*#]=======]
function ( twx_assert_false value_ )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( NOT ( NOT ${v} ) )
      twx_fatal ( "Unexpected truthy ${v}")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL "${ARGC}" )
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
function ( twx_assert_exists path_ )
  set ( i 0 )
  while ( TRUE )
    set ( p "${ARGV${i}}" )
    if ( NOT EXISTS "${p}" )
      twx_fatal ( "Missing file/directory at ${p}")
    endif ()
    math ( EXPR i "${i}+1" )
    if ( "${i}" EQUAL "${ARGC}" )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_exists )

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
    if ( "${i}" EQUAL "${ARGC}" )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_target )

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
    if ( "${i}" EQUAL "${ARGC}" )
      break ()
    endif ()
  endwhile ( )
endfunction ( twx_assert_command )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

message ( VERBOSE "TwxAssertLib loaded." )
#*/
