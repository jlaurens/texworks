#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Coloring messages.
  *
  *
  * Known formats:
  *   `BOLD`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,
  *   `BOLD_RED`, `BOLD_GREEN`, `BOLD_YELLOW`, `BOLD_BLUE`, `BOLD_MAGENTA`, `BOLD_CYAN`, `BOLD_WHITE`
  */
/** @brief Coloring
  *
  * Turn this off to disable coloring, or switch to windows.
  */
TWX_FORMAT_NO_COLOR;
/*
Output:

* `twx_format_message`
* `twx_format_log`
* `twx_format_log_kv`
* `twx_format_begin`
* `twx_format_end`

Each function is documented below.

#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

string ( ASCII 27 TWX_FORMAT_033 )

# ANCHOR: TWX_FORMAT_RESET
#[=======[*/
/** @brief String to reset the format.
  *
  * Usage:
  *
  *   twx_format_define ( ID foo SCOPE <format specifiers> )
  *   message ( STATUS ... ${TWX_FORMAT/foo} ... ${TWX_FORMAT_RESET} ...)
  */
TWX_FORMAT_RESET;
/*#]=======]
set ( TWX_FORMAT_RESET  "${TWX_FORMAT_033}[0m" )

# ANCHOR: twx_format_parse_color
#[=======[
*/
/**
  * @brief Parse a color argument
  *
  * Known color names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`.
  * Optional modifier is "bright".

  * @param text_color, text color name or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer.
  * @param output for key `APPEND_TO` is the list format variable holding the result
  * @param BACK, optional flag for the background color.
  *
  */
twx_format_parse_color( color APPEND_TO format [BACK]) {}
/*
#]=======]
function ( twx_format_parse_color )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  # Avoid possible name conflicts
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_format_parse_color.R
    "BACK" "APPEND_TO" ""
  )
  list ( POP_FRONT twx_format_parse_color.R_UNPARSED_ARGUMENTS twx_format_parse_color.R_COLOR )
  if ( NOT twx_format_parse_color.R_UNPARSED_ARGUMENTS STREQUAL "" )
    twx_fatal ( " Bad usage: ``${twx_format_parse_color.R_UNPARSED_ARGUMENTS}''" )
    return ()
  endif ()
  if ( NOT DEFINED twx_format_parse_color.R_APPEND_TO )
    twx_fatal ( " Bad usage: Missing APPEND_TO" )
    return ()
  endif ()
  twx_var_assert_name ( "${twx_format_parse_color.R_APPEND_TO}" )
  set ( twx_format_parse_color.PREFIX )
  string ( TOLOWER "${twx_format_parse_color.R_COLOR}" twx_format_parse_color.COLOR )
  if ( "${twx_format_parse_color.COLOR}" MATCHES "^([0-9]+)/([0-9]+)/([0-9]+)$" )
    if ( twx_format_parse_color.BACK )
      list ( APPEND twx_format_parse_color.PREFIX "48" "5" )
    else ()
      list ( APPEND twx_format_parse_color.PREFIX "38" "5" )
    endif ()
    foreach ( i 1 2 3 )
      set ( RGB_${i} "${CMAKE_MATCH_${i}}" )
      if ( RGB_${i} LESS "256" )
        list ( APPEND twx_format_parse_color.PREFIX "${RGB_${i}}" )
      else ()
        twx_format_warning ( "Unsupported text color ``${twx_format_parse_color.R_COLOR}''" )
        list ( APPEND twx_format_parse_color.PREFIX "255" )
      endif ()
    endforeach ()
  else ()
    set ( twx_format_parse_color.COLORS black red green yellow blue magenta cyan white )
    list ( FIND twx_format_parse_color.COLORS "${twx_format_parse_color.COLOR}" i )
    if ( i LESS 0 )
      twx_format_warning ( "Unsupported text color ``${twx_format_parse_color.R_COLOR}''" )
      set ( i 1 )
    endif ()
    if ( "${twx_format_parse_color.R_COLOR}" MATCHES "bright" )
      if ( twx_format_parse_color.R_BACK )
        math ( EXPR i "${i}+99")
      else ()
        math ( EXPR i "${i}+89")
      endif ()
    elseif ( twx_format_parse_color.R_BACK )
      math ( EXPR i "${i}+39")
    else ()
      math ( EXPR i "${i}+29")
    endif ()
    list ( APPEND twx_format_parse_color.PREFIX "${i}" )
  endif ()
  list ( APPEND ${twx_format_parse_color.R_APPEND_TO} "${twx_format_parse_color.PREFIX}" )
  return ( PROPAGATE ${twx_format_parse_color.R_APPEND_TO} )
endfunction ( twx_format_parse_color )

# ANCHOR: twx_format_define
#[=======[
*/
/**
  * @brief Define a format
  *
  * Known color names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,

  * @param BOLD, optional
  * @param UNDERLINE, optional
  * @param text_color for key TEXT_COLOR, text color name or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer.
  * @param back_color for key BACK_COLOR, background color name or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer
  * @param id for key `ID`, the format identifier.
  *   The format will be exposed in the variable `TWX_FORMAT/<id>`.
  * @param SCOPE, optional flag. The format is defined globally
  *   whether this flag is set or not. When a format is defined globally,
  *   it can be exposed in any scope with a call to `twx_format_expose ()`.
  */
twx_format_define( ID id [SCOPE] [BOLD] [UNDERLINE] [TEXT_COLOR color] [BACK_COLOR bg_color] ) {}
/*
#]=======]
function ( twx_format_define )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "BOLD;UNDERLINE;APPEND" "ID;TEXT_COLOR;BACK_COLOR" ""
  )
  twx_var_assert_name ( "${twx.R_ID}" )
  set ( prefix_ )
  if ( twx.R_BOLD )
    list ( APPEND prefix_ "1" )
  endif ()
  if ( twx.R_UNDERLINE )
    list ( APPEND prefix_ "4" )
  endif ()
  if ( DEFINED twx.R_TEXT_COLOR )
    twx_format_parse_color ( "${twx.R_TEXT_COLOR}" APPEND_TO prefix_ )
  endif ()
  if ( DEFINED twx.R_BACK_COLOR )
    twx_format_parse_color ( "${twx.R_BACK_COLOR}" APPEND_TO prefix_ BACK )
  endif ()
  set ( TWX_FORMAT/${twx.R_ID}  "${TWX_FORMAT_033}[${prefix_}m" )
  if ( NOT twx.R_SCOPE )
    set_property (
      GLOBAL
      PROPERTY TWX_FORMAT/${twx.R_ID} "${TWX_FORMAT/${twx.R_ID}}"
    )
  endif ()
  return ( PROPAGATE TWX_FORMAT/${twx.R_ID} )
endfunction ()

# ANCHOR: twx_format_expose
#[=======[
*/
/**
  * @brief Expose a format
  *
  * @param id for key `ID`, the format identifier.
  *   Set the variable `TWX_FORMAT[<id>]` to the format previously defined
  *   by a call to `twx_format_define()` with the same id.
  * @param OPTIONAL, optional flag. When unset, raise if the format id
  *   is not already defined. When set, does nothing.
  */
twx_format_expose(ID id) {}
/*
#]=======]
function ( twx_format_expose .ID twx.R_ID )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  if ( ARGC GREATER 2 )
    twx_fatal ( " Bad usage: ``${ARGV}''" )
    return ()
  endif ()
  if ( NOT .ID STREQUAL "ID" )
    twx_fatal ( "Unexpected: ``${.ID}''" )
    return ()
  endif ()
  twx_var_assert_name ( "${twx.R_ID}" )
  get_property (
    TWX_FORMAT/${twx.R_ID}
    GLOBAL
    PROPERTY TWX_FORMAT/${twx.R_ID}
  )
  if ( TWX_FORMAT/${twx.R_ID} MATCHES "NOTFOUND$" )
    if ( NOT twx.R_OPTIONAL )
      twx_fatal ( "Unknown format: ``${twx.R_ID}''" )
      return ()
    endif ()
    return ()
  endif ()
  return ( PROPAGATE TWX_FORMAT/${twx.R_ID} )
endfunction ()

# ANCHOR: twx_format_message
#[=======[
*/
/**
  * @brief Message formatter
  *
  * Enclose the input between appropriate formatting characters,
  * put the result in the variable pointed to by output.
  *
  * Known color names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,

  * @param id for key `ID`, format identifier
  * @param OPTIONAL, optional flag. When unset, raise if the format id
  *   is not already defined. When set, does nothing.
  * 
  * @param output for key `IN_VAR` is the variable name holding the result
  * @param ... everything else consists of a standard message argument.
  *
  */
twx_format_message( ... ID id IN_VAR output [OPTIONAL] ) {}
/*
#]=======]
function ( twx_format_message )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "OPTIONAL" "IN_VAR;ID" ""
  )
  list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS mode_ )
  if ( NOT DEFINED twx.R_ID )
    set ( twx.R_ID "${mode_}" )
  endif ()
  twx_var_assert_name ( "${twx.R_ID}" )
  twx_format_expose ( ID "${twx.R_ID}" )
  string ( FIND ";FATAL_ERROR;SEND_ERROR;WARNING;AUTHOR_WARNING;DEPRECATION;NOTICE;STATUS;VERBOSE;DEBUG;TRACE;CHECK_START;CHECK_PASS;CHECK_FAIL;CONFIGURE_LOG;" ";${mode_};" where_ )
  if ( where_ LESS 0 )
    if ( DEFINED twx.R_IN_VAR )
      twx_var_assert_name ( "${twx.R_IN_VAR}" )
      set ( ${twx.R_IN_VAR} "${TWX_FORMAT/${twx.R_ID}}" ${mode_} ${twx.R_UNPARSED_ARGUMENTS} ${TWX_FORMAT_RESET} )
    else ()
      message ( "${TWX_FORMAT/${twx.R_ID}}" ${mode_} ${twx.R_UNPARSED_ARGUMENTS} ${TWX_FORMAT_RESET} )
    endif ()
  else ()
    if ( DEFINED twx.R_IN_VAR )
      twx_var_assert_name ( "${twx.R_IN_VAR}" )
      set ( ${twx.R_IN_VAR} "${TWX_FORMAT/${twx.R_ID}}" ${twx.R_UNPARSED_ARGUMENTS} ${TWX_FORMAT_RESET} )
    else ()
      message ( ${mode_} "${TWX_FORMAT/${twx.R_ID}}" ${twx.R_UNPARSED_ARGUMENTS} ${TWX_FORMAT_RESET} )
    endif ()
  endif ()
endfunction ()

# ANCHOR: twx_format_warning
#[=======[
*/
/**
  * @brief Message warner.
  *
  * On theh first use only, display the warning message.
  *
  * @param ..., message to display.
  *
  */
twx_format_warning(...) {}
/*
#]=======]
function ( twx_format_warning )
  get_property (
    no_warning_
    GLOBAL
    PROPERTY TWX_FORMAT_NO_WARNING
  )
  if ( no_warning_ MATCHES "NOTFOUND$" )
    set_property (
      GLOBAL
      PROPERTY TWX_FORMAT_NO_WARNING ON
    )
    twx_format_message ( WARNING ${ARGV} )
  endif ()
endfunction ()

twx_lib_did_load ()

#*/
