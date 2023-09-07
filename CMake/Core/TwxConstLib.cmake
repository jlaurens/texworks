#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Constantss
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxConstLib.cmake"
  *   )
  *
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

string ( ASCII 01 /TWX/CHAR/SOH )
string ( ASCII 02 /TWX/CHAR/STX )
string ( ASCII 03 /TWX/CHAR/ETX )
string ( ASCII 25 /TWX/CHAR/EM  )
string ( ASCII 26 /TWX/CHAR/SUB )
string ( ASCII 28 /TWX/CHAR/FS  )
string ( ASCII 29 /TWX/CHAR/GS  )
string ( ASCII 30 /TWX/CHAR/RS  )
string ( ASCII 31 /TWX/CHAR/US  )

# ANCHOR: /TWX/CONST/VARIABLE_RE
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
/TWX/CONST/VARIABLE_RE;
/*#]=======]
set (
  /TWX/CONST/VARIABLE_RE
  "^([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)*$"
)

# ANCHOR: /TWX/CONST/MESSAGE/MODES
#[=======[*/
/** @brief List of message modes
  *
  *  `FATAL_ERROR`, `SEND_ERROR`...
  */
/TWX/CONST/MESSAGE/MODES;
/*#]=======]
set ( /TWX/CONST/MESSAGE/MODES "FATAL_ERROR;SEND_ERROR;WARNING;AUTHOR_WARNING;DEPRECATION;NOTICE;STATUS;VERBOSE;DEBUG;TRACE;CHECK_START;CHECK_PASS;CHECK_FAIL;CONFIGURE_LOG" )

# ANCHOR: twx_const_placeholder
#[=======[
/** @brief Declares a placeholder
  *
  * @param key, create `/TWX/PLACEHOLDER/<key>` with appropriate content.
  *   This content contains no space.
  */
twx_const_placeholder(key) {}
/*#]=======]
macro ( twx_const_placeholder twx_const_placeholder.KEY )
  if ( NOT "${twx_const_placeholder.KEY}" MATCHES "${/TWX/CONST/VARIABLE_RE}" )
    message ( FATAL_ERROR "Bad argument: ``${twx_const_placeholder.KEY}''" )
  endif ()
  set (
    /TWX/PLACEHOLDER/${twx_const_placeholder.KEY}
    "${/TWX/CHAR/STX}PLACEHOLDER:${twx_const_placeholder.KEY}/${/TWX/CHAR/ETX}"
  )
endmacro ()

twx_const_placeholder ( EMPTY_STRING )

# ANCHOR: twx_const_empty_string_encode
#[=======[
/** @brief Encode empty strings in the list variables
  *
  * @param ... for key `VAR`, list of list variable names.
  *   When no result variable is given, the changes occur in place.
  * @param ... for key `IN_VAR`, optional list of result variables.
  *   When no result variable is given, the changes occur in place.
  */
twx_const_empty_string_encode(VAR ... [IN_VAR ...]) {}
/*#]=======]
macro ( twx_const_empty_string_encode )
  cmake_parse_arguments (
    TwxConstLib_encode.R
    "" "" "VAR;IN_VAR"
    ${ARGV}
  )
  if ( DEFINED TwxConstLib_encode.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${TwxConstLib_encode.R_UNPARSED_ARGUMENTS}''")
  endif ()
  if ( NOT DEFINED TwxConstLib_encode.R_IN_VAR )
    set ( TwxConstLib_encode.R_IN_VAR ${TwxConstLib_encode.R_VAR} )
  endif ()
  if ( DEFINED TwxConstLib_encode.R_VAR )
    foreach (
      TwxConstLib_encode.VAR
      TwxConstLib_encode.IN_VAR
      IN ZIP_LISTS
        TwxConstLib_encode.R_VAR
        TwxConstLib_encode.R_IN_VAR
    )
      if ( DEFINED ${TwxConstLib_encode.VAR} )
        if ( ${TwxConstLib_encode.VAR} STREQUAL "" )
          set (
            TwxConstLib_encode.OUT
            "${/TWX/PLACEHOLDER/EMPTY_STRING}"
          )
        else ()
          string (
            REGEX REPLACE "^;" "${/TWX/PLACEHOLDER/EMPTY_STRING};"
            TwxConstLib_encode.OUT
            "${${TwxConstLib_encode.VAR}}"
          )
          string (
            REGEX REPLACE ";;" ";${/TWX/PLACEHOLDER/EMPTY_STRING};"
            TwxConstLib_encode.OUT
            "${TwxConstLib_encode.OUT}"
          )
          string (
            REGEX REPLACE ";$" ";${/TWX/PLACEHOLDER/EMPTY_STRING}"
            TwxConstLib_encode.OUT
            "${TwxConstLib_encode.OUT}"
          )
        endif ()
        if ( DEFINED TwxConstLib_encode.IN_VAR )
          set (
            ${TwxConstLib_encode.IN_VAR}
            "${TwxConstLib_encode.OUT}"
          )
        else ()
          set (
            ${TwxConstLib_encode.VAR}
            "${TwxConstLib_encode.OUT}"
          )
        endif ()
      elseif ( DEFINED TwxConstLib_encode.VAR )
        set (
          ${TwxConstLib_encode.VAR}
        )
      endif ()
    endforeach ()
  else ()
    set ( TwxConstLib_encode.OUT "Bad usage: ARGV => ``${ARGV}''" ) 
    if ( COMMAND twx_fatal )
      twx_fatal ( "${TwxConstLib_encode.OUT}" )
    else ()
      message ( FATAL_ERROR "${TwxConstLib_encode.OUT}" )
    endif ()
  endif ()
  foreach ( X VAR IN_VAR OUT R_VAR R_IN_VAR R_UNPARSED_ARGUMENTS R_KEYWORDS_MISSING_VALUES )
    set ( TwxConstLib_encode.${X} )
  endforeach ()
endmacro ()

# ANCHOR: twx_const_empty_string_decode
#[=======[
/** @brief Decode empty strings in the list variables
  *
  * @param ... for key `VAR`, list of list variable names.
  *   When no result variable is given, the changes occur in place.
  * @param ... for key `IN_VAR`, optional list of result variables.
  *   When no result variable is given, the changes occur in place.
  */
twx_const_empty_string_decode(VAR ... [IN_VAR ...]) {}
/*#]=======]
macro ( twx_const_empty_string_decode )
  cmake_parse_arguments (
    TwxConstLib_decode.R
    "" "" "VAR;IN_VAR"
    ${ARGV}
  )
  if ( DEFINED TwxConstLib_decode.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${TwxConstLib_decode.R_UNPARSED_ARGUMENTS}''")
  endif ()
  if ( NOT DEFINED TwxConstLib_decode.R_IN_VAR )
    set ( TwxConstLib_decode.R_IN_VAR ${TwxConstLib_decode.R_VAR} )
  endif ()
  if ( DEFINED TwxConstLib_decode.R_VAR )
    foreach (
      TwxConstLib_decode.VAR
      TwxConstLib_decode.IN_VAR
      IN ZIP_LISTS
        TwxConstLib_decode.R_VAR
        TwxConstLib_decode.R_IN_VAR
    )
      if ( DEFINED ${TwxConstLib_decode.VAR} )
        string (
          REGEX REPLACE "${/TWX/PLACEHOLDER/EMPTY_STRING}" ""
          TwxConstLib_decode.OUT
          "${${TwxConstLib_decode.VAR}}"
        )
        if ( DEFINED TwxConstLib_decode.IN_VAR )
          set (
            ${TwxConstLib_decode.IN_VAR}
            "${TwxConstLib_decode.OUT}"
          )
        else ()
          set (
            ${TwxConstLib_decode.VAR}
            "${TwxConstLib_decode.OUT}"
          )
        endif ()
      elseif ( DEFINED TwxConstLib_decode.IN_VAR )
        set (
          ${TwxConstLib_decode.IN_VAR}
        )
      endif ()
    endforeach ()
  else ()
    set ( TwxConstLib_decode.OUT "Bad usage: ARGV => ``${ARGV}''" ) 
    if ( COMMAND twx_fatal )
      twx_fatal ( "${TwxConstLib_decode.OUT}" )
    else ()
      message ( FATAL_ERROR "${TwxConstLib_decode.OUT}" )
    endif ()
  endif ()
  foreach ( X VAR IN_VAR OUT R_VAR R_IN_VAR R_UNPARSED_ARGUMENTS R_KEYWORDS_MISSING_VALUES )
    set ( TwxConstLib_decode.${X} )
  endforeach ()
endmacro ()


twx_lib_did_load ()

#*/
