#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Collection of core utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxCoreLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_fatal()`
  * - `twx_assert_variable()`
  * - `twx_regex_escape()`
  *
  * Testing utilities:
  * - `twx_fatal_clear()`
  * - `twx_fatal_catched()`
  */
/*#]===============================================]

# Full include only once
if ( COMMAND twx_fatal )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_regex_escape ()
#[=======[
/** @brief Escape strings to be used in regular expression
  *
  * @param ... non empty list of strings
  * @param var for key `IN_VAR`, the variable named <var> will hold the result on return
  */
twx_regex_escape(... IN_VAR var ) {}
/*#]=======]

set ( twx_regex_escape_RE [=[[]()|?+*[\\.$^-]]=] )

function ( twx_regex_escape .text .IN_VAR .var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_regex_escape )
  cmake_parse_arguments ( PARSE_ARGV 1 twxR "" "IN_VAR" "" )
  if ( NOT DEFINED twxR_IN_VAR )
    twx_fatal ( "Missing IN_VAR argument.")
    return ()
  endif ()
  twx_assert_variable ( twxR_IN_VAR )
  set ( m )
  set ( i 0 )
  while ( TRUE )
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      math ( EXPR i "${i}+2" )
      if ( "${i}" LESS "${ARGC}" )
        twx_fatal ( "Unexpected argument: ${ARGV${i}}")
        return ()
      endif ()
      break ()
    endif ()
    # message ( TR@CE "IN => \"${ARGV${i}}\"" )
    string (
      REGEX REPLACE "([]()|?+*[\\\\.$^-])" "\\\\\\1"
      out_
      "${ARGV${i}}"
    )
    # message ( TR@CE "OUT => \"${out_}\"" )
    list ( APPEND m "${out_}" )
    math ( EXPR i "${i}+1" )
    if ( "${i}" GREATER_EQUAL "${ARGC}" )
      break ()
    endif ()
  endwhile ()
  set ( "${twxR_IN_VAR}" "${m}" PARENT_SCOPE )
endfunction ()

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
  "^([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9/_.+-]|\\[^a-zA-Z0-9;]|\\[trn]|\\;)*$"
)

# ANCHOR: twx_assert_variable
#[=======[*/
/** @brief Raise when not a literal variable name.
  *
  * @param ..., non empty list of variables names to test.
  * Support `$|` syntax (`$|<name>` is a shortcut to the more readable `"${<name>}"`)
  */
twx_assert_variable(...) {}
/*#]=======]
function ( twx_assert_variable name_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_assert_variable )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => \"${v}\"" )
    if ( NOT v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      twx_fatal ( "Not a variable name: \"${v}\"" )
      return ()
    endif ()
    math ( EXPR i "${i}+1" )
    if ( i GREATER_EQUAL ARGC )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_assert_variable )

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
  "^([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9/_.+-]|\\[^a-zA-Z0-9;]|\\[trn]|\\;)*$"
)

# ANCHOR: twx_assert_variable
#[=======[*/
/** @brief Raise when not a literal variable name.
  *
  * @param ..., non empty list of variables names to test.
  * Support `$|` syntax (`$|<name>` is a shortcut to the more readable `"${<name>}"`)
  */
twx_assert_variable(...) {}
/*#]=======]
function ( twx_assert_variable name_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_assert_variable )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => \"${v}\"" )
    if ( NOT v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      twx_fatal ( "Not a variable name: \"${v}\"" )
      return ()
    endif ()
    math ( EXPR i "${i}+1" )
    if ( i GREATER_EQUAL ARGC )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_assert_variable )

add_custom_target (
  TwxCoreLib.cmake
)

define_property (
  TARGET PROPERTY TWX_FATAL_MESSAGE
)

# ANCHOR: twx_fatal
#[=======[
*//** @brief Terminate with a FATAL_ERROR message. */
twx_fatal(...){}
/*
#]=======]
function ( twx_fatal )
  set ( m )
  set ( i 0 )
  unset ( ARGV${ARGC} )
  while ( TRUE )
    if ( NOT DEFINED ARGV${i} )
      break ()
    endif ()
    if ( ARGV${i} MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    math ( EXPR i "${i}+1" )
  endwhile ()
  if ( TWX_FATAL_CATCH )
    get_target_property(
      fatal_
      TwxCoreLib.cmake
      TWX_FATAL_MESSAGE
    )
    if ( fatal_ STREQUAL "fatal_-NOTFOUND")
      set ( fatal_ )
    endif ()
    list ( APPEND fatal_ "${m}" )
    set_target_properties (
      TwxCoreLib.cmake
      PROPERTIES
        TWX_FATAL_MESSAGE "${fatal_}"
    )
  else ()
    message ( FATAL_ERROR ${m} )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_catched
#[=======[
*/
/** @brief Catch fatal messages.
  *
  * For testing purposes only.
  * If the `twx_fatal()` call has no really bad consequences,
  * we can catch the message.
  *
  * @param var for key `IN_VAR`, contains the list of messages on return.
  */
twx_fatal_catched (IN_VAR var){}
/*
#]=======]
function ( twx_fatal_catched .IN_VAR twxR_VAR )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong number of arguments: ${ARGC} instead of 2." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Missing IN_VAR key: got \"${.IN_VAR}\" instead." )
  endif ()
  twx_assert_variable ( "${twxR_VAR}" )
  
  get_target_property(
    ${twxR_VAR}
    TwxCoreLib.cmake
    TWX_FATAL_MESSAGE
  )
  if ( ${twxR_VAR} STREQUAL "fatal_-NOTFOUND")
    set ( ${twxR_VAR} "" )
  endif ()
  set ( ${twxR_VAR} "${${twxR_VAR}}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_fatal_clear
#[=======[
*/
/** @brief Clear catched fatal messages.
  *
  * For testing purposes only.
  *
  */
twx_fatal_clear (){}
/*
#]=======]
function ( twx_fatal_clear )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Too many arguments: ${ARGC} instead of 0." )
  endif ()
  set_target_properties (
    TwxCoreLib.cmake
    PROPERTIES
      TWX_FATAL_MESSAGE ""
  )
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

message ( DEBUG "TwxCoreLib loaded ${TWX_DIR}" )

#*/
