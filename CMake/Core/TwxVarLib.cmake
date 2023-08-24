#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Variable utilities
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxVarLib.cmake"
  *   )
  *
  * Output state:
  * - `twx_var_assert_name ()`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: TWX_CORE_VARIABLE_RE
#[=======[*/
/** @brief Regular expression for variables
  *
  * Quoted CMake documentation:
  *   > Literal variable references may consist of
  *   > alphanumeric characters,
  *   > the characters /_.+-,
  *   > and Escape Sequences.
  * where "An escape sequence is a \ followed by one character:"
  *   > escape_sequence  ::=  escape_identity | escape_encoded | escape_semicolon
  *   > escape_identity  ::=  '\' <match '[^A-Za-z0-9;]'>
  *   > escape_encoded   ::=  '\t' | '\r' | '\n'
  *   > escape_semicolon ::=  '\;'
  */
TWX_CORE_VARIABLE_RE;
/*#]=======]
set (
  TWX_CORE_VARIABLE_RE
  "^([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)*$"
)

# ANCHOR: twx_var_assert_name
#[=======[*/
/** @brief Raise when not a literal variable name.
  *
  * @param ..., non empty list of variables names to test.
  */
twx_var_assert_name(...) {}
/*#]=======]
function ( twx_var_assert_name .name )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => ``${v}''" )
    if ( NOT v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      set ( msg "Not a variable name: ``${v}''" )
      if ( COMMAND twx_fatal )
        twx_fatal ( "${msg}" RETURN )
      else ()
        message ( FATAL_ERROR "${msg}" )
      endif ()
    endif ()
    math ( EXPR i "${i}+1" )
    if ( i GREATER_EQUAL ARGC )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_var_assert_name )

# ANCHOR: twx_var_log
#[=======[*/
/** @brief Log variable status.
  *
  * @param MODE, optional `message()` mode, defaults to `NOTICE`.
  * @param msg for key `MSG`, optional banner message.
  * @param var, the variable.
  */
twx_var_log( [MODE] [MSG msg] var ) {}
/*#]=======]
function ( twx_var_log )
  # Possible name conflicts
  string ( FIND ";FATAL_ERROR;SEND_ERROR;WARNING;AUTHOR_WARNING;DEPRECATION;NOTICE;STATUS;VERBOSE;DEBUG;TRACE;CHECK_START;CHECK_PASS;CHECK_FAIL;CONFIGURE_LOG;" ";${ARGV0};" twx_var_log.WHERE )
  if ( twx_var_log.WHERE LESS 0 )
    set ( twx_var_log.MODE )
    set ( twx_var_log.I 0 )
  else ()
    set ( twx_var_log.MODE "${ARGV0}" )
    set ( twx_var_log.I 1 )
  endif ()
  # message ( "*************** twx_var_log.I => ``${twx_var_log.I}''")
  cmake_parse_arguments (
    PARSE_ARGV "${twx_var_log.I}" twx_var_log.R
    "" "MSG" ""
  )
  if ( twx_var_log.R_MSG )
    set ( twx_var_log.R_MSG " ${twx_var_log.R_MSG}: " )
  else ()
    set ( twx_var_log.R_MSG " " )
  endif ()
  # message ( "*************** twx_var_log.R_UNPARSED_ARGUMENTS => ``${twx_var_log.R_UNPARSED_ARGUMENTS}''")
  # message ( "*************** ARGV => ``${ARGV}''")
  foreach ( twx_var_log.VAR ${twx_var_log.R_UNPARSED_ARGUMENTS} )
    if ( DEFINED "${twx_var_log.VAR}" )
      message ( ${} "${twx_var_log.R_MSG}${twx_var_log.VAR} => ``${${twx_var_log.VAR}}''" )
    else ()
      message ( ${} "${twx_var_log.R_MSG}${twx_var_log.VAR} -> UNDEFINED")
    endif ()
  endforeach ()
endfunction ( twx_var_log )

twx_lib_did_load ()

#*/
