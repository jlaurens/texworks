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

twx_lib_will_load ()

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
  * No more than 10 such arguments are allowed.
  * @param prefix for key `VAR_PREFIX`, optional prefix prepended to all the variables above before exportation.
  * @param UNSET, optional flag to unset the variable.
  *   Ignored when a non empty value is given.
  * @param EMPTY, optional flag to set the variable to an empty string.
  *   Ignored when a non empty value is given.
  */
twx_export(... [VAR_PREFIX prefix] [EMPTY] [UNSET]){}
/*
#]=======]
macro ( twx_export twx_export.kv. )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_export" )
  # message ( TR@CE "ARGC => ${ARGC}" )
  if ( twx_export.DURING )
    twx_fatal ( "twx_export is not reentrant.")
  endif ()
  set ( twx_export.DURING ON )
  cmake_parse_arguments (
    twx_export.R
    "EMPTY;UNSET"
    "VAR_PREFIX"
    ""
    ${ARGV}
  )
  set ( twx_export.KEYS "EMPTY;UNSET;VAR_PREFIX")
  set ( twx_export.0 )
  set ( twx_export.1 )
  set ( twx_export.2 )
  set ( twx_export.3 )
  set ( twx_export.4 )
  set ( twx_export.5 )
  set ( twx_export.6 )
  set ( twx_export.7 )
  set ( twx_export.8 )
  set ( twx_export.9 )
  set ( twx_export.10 )
  if ( ${ARGC} GREATER 0 )
    if ( NOT "${ARGV0}" IN_LIST twx_export.KEYS )
      set ( twx_export.0 "${ARGV0}" )
  if ( ${ARGC} GREATER 1 )
    if ( NOT "${ARGV1}" IN_LIST twx_export.KEYS )
      set ( twx_export.1 "${ARGV1}" )
  if ( ${ARGC} GREATER 2 )
    if ( NOT "${ARGV2}" IN_LIST twx_export.KEYS )
      set ( twx_export.2 "${ARGV2}" )
  if ( ${ARGC} GREATER 3 )
    if ( NOT "${ARGV3}" IN_LIST twx_export.KEYS )
      set ( twx_export.3 "${ARGV3}" )
  if ( ${ARGC} GREATER 4 )
    if ( NOT "${ARGV4}" IN_LIST twx_export.KEYS )
      set ( twx_export.4 "${ARGV4}" )
  if ( ${ARGC} GREATER 5 )
    if ( NOT "${ARGV5}" IN_LIST twx_export.KEYS )
      set ( twx_export.5 "${ARGV5}" )
  if ( ${ARGC} GREATER 6 )
    if ( NOT "${ARGV6}" IN_LIST twx_export.KEYS )
      set ( twx_export.6 "${ARGV6}" )
  if ( ${ARGC} GREATER 7 )
    if ( NOT "${ARGV7}" IN_LIST twx_export.KEYS )
      set ( twx_export.7 "${ARGV7}" )
  if ( ${ARGC} GREATER 8 )
    if ( NOT "${ARGV8}" IN_LIST twx_export.KEYS )
      set ( twx_export.8 "${ARGV8}" )
  if ( ${ARGC} GREATER 9 )
    if ( NOT "${ARGV9}" IN_LIST twx_export.KEYS )
      set ( twx_export.9 "${ARGV9}" )
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()
    endif ()
  endif ()

  # block ()
  # foreach ( i RANGE 10 )
  #   message ( TRACE "***** twx_export.${i} => \"${twx_export.${i}}\"")
  #   if ( DEFINED "twx_export.${i}" )
  #     message ( TRACE "***** DEFINED")
  #   else ()
  #     message ( TRACE "***** UNDEFINED")
  #   endif ()
  # endforeach ()
  # endblock ()
  # message ( TR@CE "twx_export.R_EMPTY => \"${twx_export.R_EMPTY}\"")
  # message ( TR@CE "twx_export.R_UNSET => \"${twx_export.R_UNSET}\"")
  # message ( TR@CE "twx_export.R_VAR_PREFIX => \"${twx_export.R_VAR_PREFIX}\"")
  if ( NOT "${twx_export.R_VAR_PREFIX}" STREQUAL "" )
    string ( APPEND twx_export.R_VAR_PREFIX "_" )
  endif ()
  set ( twx_export.i 0 )
  set ( twx_export.kv ${twx_export.${twx_export.i}} )
  # message ( TR@CE "TEST twx_export.1 => \"${twx_export.1}\"")
  if ( NOT DEFINED twx_export.kv )
    twx_fatal ( "Nothing to export" )
  endif ()
  set ( twx_export.DONE OFF )
  while ( TRUE )
    # block ()
    # foreach ( i RANGE 10 )
    #   message ( TRACE "***** twx_export.${i} => \"${twx_export.${i}}\"")
    #   if ( DEFINED twx_export.${i} )
    #     message ( TRACE "***** DEFINED")
    #   else ()
    #     message ( TRACE "***** UNDEFINED")
    #   endif ()
    # endforeach ()
    # endblock ()
    # message ( TR@CE "0) twx_export.i => \"${twx_export.i}\"")
    # message ( TR@CE "0) twx_export.kv => \"${twx_export.kv}\"")
    twx_split_assign (
      "${twx_export.kv}"
      IN_KEY twx_export.IN_KEY
      IN_VALUE twx_export.IN_VALUE
    )
    # message ( TR@CE "1) twx_export.IN_KEY => \"${twx_export.IN_KEY}\"")
    # if ( DEFINED twx_export.IN_VALUE )
    #   message ( TRACE "2) twx_export.IN_VALUE => \"${twx_export.IN_VALUE}\"")
    # else ()
    #   message ( TRACE "3) twx_export.IN_VALUE => UNSET ")
    # endif ()
    string ( PREPEND twx_export.IN_KEY "${twx_export.R_VAR_PREFIX}" )
    if ( DEFINED twx_export.IN_VALUE )
      # message ( TR@CE "4) \"${twx_export.IN_KEY}\" => \"${twx_export.IN_VALUE}\"" )
      set (
        "${twx_export.IN_KEY}"
        "${twx_export.IN_VALUE}"
        PARENT_SCOPE
      )
    elseif ( twx_export.R_EMPTY )
      # message ( TR@CE "5) \"${twx_export.IN_KEY}\" => empty string" )
      set (
        "${twx_export.IN_KEY}"
        ""
        PARENT_SCOPE
      )
    elseif ( twx_export.R_UNSET )
      # message ( TR@CE "6) \"${twx_export.IN_KEY}\" => UNSET" )
      set (
        "${twx_export.IN_KEY}"
        PARENT_SCOPE
      )
      # message ( TR@CE "7) ${twx_export.IN_KEY} => \"${${twx_export.IN_KEY}}\"" )
    elseif ( DEFINED "${twx_export.IN_KEY}" )
      # message ( TR@CE "8) \"${twx_export.IN_KEY}\" => \"${${twx_export.IN_KEY}}\"" )
      set (
        "${twx_export.IN_KEY}"
        "${${twx_export.IN_KEY}}"
        PARENT_SCOPE
      )
    else ()
      # message ( TR@CE "9) \"${twx_export.IN_KEY}\" => UNSET(2)" )
      set (
        "${twx_export.IN_KEY}"
        PARENT_SCOPE
      )
    endif ()
    # message ( TR@CE "twx_export.i => \"${twx_export.i}\"" )
    twx_increment ( VAR twx_export.i )
    # message ( TR@CE "twx_export.i => \"${twx_export.i}\"" )
    # block ()
    # foreach ( i RANGE 10 )
    #   message ( TRACE "***** twx_
    #   export.${i} => \"${twx_export.${i}}\"")
    #   if ( DEFINED twx_export.${i} )
    #     message ( TRACE "***** DEFINED")
    #   else ()
    #     message ( TRACE "***** UNDEFINED")
    #   endif ()
    # endforeach ()
    # endblock ()
    if ( NOT DEFINED twx_export.${twx_export.i} )
      break ()
    endif ()
    if ( twx_export.i EQUAL 10 )
      break ()
    endif ()
    set ( twx_export.kv "${twx_export.${twx_export.i}}" )
    # message ( TR@CE "10) twx_export.kv => \"${twx_export.kv}\"" )
  endwhile ()
  set ( twx_export.i )
  set ( twx_export.kv )
  set ( twx_export.IN_KEY )
  set ( twx_export.IN_VALUE )
  set ( twx_export.DONE )
  set ( twx_export.R_EMPTY )
  set ( twx_export.R_UNSET )
  set ( twx_export.R_VAR_PREFIX )
  set ( twx_export.0 )
  set ( twx_export.1 )
  set ( twx_export.2 )
  set ( twx_export.3 )
  set ( twx_export.4 )
  set ( twx_export.5 )
  set ( twx_export.6 )
  set ( twx_export.7 )
  set ( twx_export.8 )
  set ( twx_export.9 )
  set ( twx_export.DURING )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

twx_lib_require ( "Fatal" "Core" "Arg" "Increment" "Split" )

twx_lib_did_load ()

#*/
