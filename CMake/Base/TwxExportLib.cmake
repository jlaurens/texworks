#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Export utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxExportLib.cmake"
  )

Output state:
- `TWX_DIR`

*/
/*#]===============================================]

# Full include only once
if ( DEFINED TWX_DIR )
  return ()
endif ()
# This has already been included

# ANCHOR: TWX_EXPORT_EMPTY
#[=======[*/
/** @brief Value placeholder for an empty exportation.
  *
  */
TWX_EXPORT_EMPTY;
/*#]=======]
string(ASCII 26 TWX_EXPORT_EMPTY ) # SUBstitute

# ANCHOR: TWX_EXPORT_UNDEFINE
#[=======[*/
/** @brief Value placeholder for an unexportation.
  *
  */
TWX_EXPORT_UNDEFINE;
/*#]=======]
string(ASCII 27 TWX_EXPORT_UNDEFINE ) # ESCape

# ANCHOR: twx_split
#[=======[
*/
/** @brief Split "key=value"
  *
  * Split "<key>=<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  *
  * @param kv, value to split.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  */
twx_split(kv IN_KEY key IN_VALUE value) {}
/*
#]=======]
function ( twx_split .kv .IN_KEY .key .IN_VALUE .value )
  twx_arg_assert_count ( ${ARGC} = 5 )
  twx_arg_assert_keyword ( .IN_KEY .IN_VALUE )
  twx_assert_variable ( "${.key}" "${.value}" )
  twx_expect_unequal ( "${.key}" "${.value}" )
  if ( .kv MATCHES "^([^=]+)=(.*)$" )
    set ( ${.key} "${CMAKE_MATCH_1}" PARENT_SCOPE )
    set ( ${.value} "${CMAKE_MATCH_2}" PARENT_SCOPE )
  elseif ( .kv MATCHES "^=" )
    twx_fatal ( "Unexpected argument: ${.kv}" )
    return ()
  else ()
    set ( ${.key} "${.kv}" PARENT_SCOPE )
    unset ( ${.value} PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_export
#[=======[
*/
/** @brief Convenient shortcut to export variables to the parent scope.
  *
  * Entries are "<key>=<value>" arguments.
  * If a value is given, set a variable named "<key>" with value "<value>"
  * in the parent scope. Otherwise, if a variable named "<key>" is defined,
  * define a variable with the same name and value in the parent scope,
  * except when either flag `EMPTY` or `UNSET` is set.
  * In other situations, unset the variable with that name.
  *
  * @param ... the non empty list of <key>=<value> arguments.
  * @param prefix for key `VAR_PREFIX`, optional prefix prepended to all the variables above before exportation.
  * @param UNSET, optional flag to unset the variable.
  *   Ignored when a non empty value is given.
  * @param EMPTY, optional flag to set the variable to an empty string.
  *   Ignored when a non empty value is given.
  */
twx_export(... [VAR_PREFIX prefix] [EMPTY] [UNSET]){}
/*
#]=======]
macro ( twx_export twx_export.kv )
  cmake_parse_arguments (
    twx_export
    "EMPTY;UNSET"
    "VAR_PREFIX"
    ""
    ${ARGV}
  )
  if ( NOT "${twx_export_VAR_PREFIX}" STREQUAL "" )
    string ( APPEND twx_export_VAR_PREFIX "_" )
  endif ()
  set ( twx_export.i 0 )
  set ( twx_export.DONE OFF )
  while ( true )
    set ( twx_export.kv "${ARGV${twx_export.i}}" )
    if ( twx_export.kv STREQUAL "VAR_PREFIX" )
      twx_increment ( VAR twx_export.i )
      twx_arg_assert_count ( ${ARGC} > "${twx_export.i}" )
      twx_increment_and_break_if ( VAR twx_export.i >= ${ARGC} )
      set ( twx_export.DONE ON )
      set ( twx_export.kv "${ARGV${twx_export.i}}" )
    endif ()
    if ( twx_export.kv MATCHES "EMPTY|UNSET" )
      while ( true )
        twx_increment_and_break_if ( VAR twx_export.i >= ${ARGC} )
        set ( twx_export.kv "${ARGV${twx_export.i}}" )
        if ( NOT twx_export.kv MATCHES "EMPTY|UNSET" )
          twx_fatal ( "Unexpected argument: ${twx_export.kv}")
          return ()
        endif ()
      endwhile ()
      break ()
    elseif ( twx_export.DONE )
      twx_arg_assert_count ( ${ARGC} = "${twx_export.i}" )
      break ()
    endif ()
    twx_split (
      "${twx_export.kv}"
      IN_KEY twx_export.IN_KEY
      IN_VALUE twx_export.IN_VALUE
    )
    if ( DEFINED twx_export.IN_VALUE )
      set (
        "${twx_export.VAR_PREFIX}${twx_export.IN_KEY}"
        "${twx_export.IN_VALUE}"
        PARENT_SCOPE
      )
    elseif ( twx_export_EMPTY )
      set (
        "${twx_export_VAR_PREFIX}${twx_export.IN_KEY}"
        ""
        PARENT_SCOPE
      )
    elseif ( twx_export_UNSET )
      unset (
        "${twx_export_VAR_PREFIX}${twx_export.IN_KEY}"
        PARENT_SCOPE
      )
    else ()
      set (
        "${twx_export_VAR_PREFIX}${twx_export.IN_KEY}"
        "${${twx_export_VAR_PREFIX}${twx_export.IN_KEY}}"
        PARENT_SCOPE
      )
    endif ()
    twx_increment_and_break_if ( VAR twx_export.i >= ${ARGC} )
  endwhile ()
  unset ( twx_export.i )
  unset ( twx_export.kv )
  unset ( twx_export.DONE )
  unset ( twx_export.IN_KEY )
  unset ( twx_export.IN_VALUE )
  unset ( twx_export_EMPTY )
  unset ( twx_export_VAR_PREFIX )
  unset ( twx_export_UNPARSED_ARGUMENTS )
endmacro ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementLib.cmake" )

message ( VERBOSE "TwxExportLib" )

#*/
