#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Coloring messages.
  *
  * Only 16 bits colors are supported.
  *
  */
/** @brief Coloring
  *
  * Turn this off to disable coloring.
  */
/TWX/FORMAT/NO_COLOR;
/** @brief Support 24 bits coloring
  *
  * This must be set once for all before any 24 bits format definitions.
  * Turn this on to support 24 bits coloring.
  * For the same ID, define 16 bits colors then 24 bits colors,
  * such that when `/TWX/FORMAT/24` is set we get 24 bits coloring
  * otherwise we fall back to 16 bits coloring.
  */
/TWX/FORMAT/24;
/** @brief Coloring style
  *
  * Identifier used in format color definition.
  */
/TWX/FORMAT/STYLE;
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

string ( ASCII 27 /TWX/FORMAT/033 )

# ANCHOR: /TWX/FORMAT/RESET
#[=======[*/
/** @brief String to reset the format.
  *
  * Usage:
  *
  *   twx_format_define ( ID foo SCOPE <format specifiers> )
  *   message ( STATUS ... ${/TWX/FORMAT/foo} ... ${/TWX/FORMAT/RESET} ...)
  */
/TWX/FORMAT/RESET;
/*#]=======]
set ( /TWX/FORMAT/RESET  "${/TWX/FORMAT/033}[0m" )

# ANCHOR: twx_format_parse_color
#[=======[
*/
/**
  * @brief Parse a color argument
  *
  * Known color names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`.
  * Optional modifier is "bright".
  *
  * @param text_color, text color name or
  *   <index> specification or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer.
  * @param output for key `APPEND_TO` is the list format variable holding the result
  * @param BACK, optional flag for the background color.
  * @param REVERSE, optional flag.
  * Set the color iff this flag and `/TWX/FORMAT/REVERSE` have the same
  * truthy value.
  *
  */
twx_format_parse_color( color APPEND_TO format [BACK]) {}
/*
#]=======]
function ( twx_format_parse_color )
  twx_function_begin ()
  # Avoid possible name conflicts
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "BACK;REVERSE" "APPEND_TO" ""
  )
  list ( POP_FRONT ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${TWX_CMD}.COLOR )
  if ( NOT ${TWX_CMD}.R_UNPARSED_ARGUMENTS STREQUAL "" )
    message ( FATAL_ERROR " Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_APPEND_TO )
    message ( FATAL_ERROR " Bad usage: Missing APPEND_TO" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_APPEND_TO}" )
  set ( ${TWX_CMD}.PREFIX )
  string ( TOLOWER "${${TWX_CMD}.COLOR}" ${TWX_CMD}.COLOR )
  if ( "${${TWX_CMD}.COLOR}" MATCHES "^([0-9]+)/([0-9]+)/([0-9]+)$" )
    # Under development
    if ( NOT /TWX/FORMAT/24 )
      return ()
    elseif ( ${TWX_CMD}.R_BACK )
      list ( APPEND ${TWX_CMD}.PREFIX "48" "2" )
    else ()
      list ( APPEND ${TWX_CMD}.PREFIX "38" "2" )
    endif ()
    foreach ( i 1 2 3 )
      set ( RGB_${i} "${CMAKE_MATCH_${i}}" )
      if ( RGB_${i} LESS "256" )
        list ( APPEND ${TWX_CMD}.PREFIX "${RGB_${i}}" )
      else ()
        twx_format_warning ( "Unsupported text color ``${${TWX_CMD}.COLOR}''" )
        list ( APPEND ${TWX_CMD}.PREFIX "255" )
      endif ()
    endforeach ()
  elseif ( "${${TWX_CMD}.COLOR}" MATCHES "^([0-9]+)$" )
    if ( ${TWX_CMD}.R_BACK )
      list ( APPEND ${TWX_CMD}.PREFIX "48" "5" )
    else ()
      list ( APPEND ${TWX_CMD}.PREFIX "38" "5" )
    endif ()
    if ( CMAKE_MATCH_1 LESS "256" )
      list ( APPEND ${TWX_CMD}.PREFIX "${CMAKE_MATCH_1}" )
    else ()
      twx_format_warning ( "Unsupported text color ``${${TWX_CMD}.COLOR}''" )
      list ( APPEND ${TWX_CMD}.PREFIX "255" )
    endif ()
  else ()
    if ( "${${TWX_CMD}.COLOR}" MATCHES "^bright (.*)$" )
      set ( ${TWX_CMD}.COLOR "${CMAKE_MATCH_1}" )
      set ( bright_ ON )
    else ()
      set ( bright_ OFF )
    endif ()
    set ( colors_ black red green yellow blue magenta cyan white )
    list ( FIND colors_ "${${TWX_CMD}.COLOR}" i )
    if ( i LESS 0 )
      twx_format_warning ( "Unsupported text color ``${${TWX_CMD}.COLOR}''" )
      set ( i 1 )
    endif ()
    if ( bright_ )
      if ( ${TWX_CMD}.R_BACK )
        math ( EXPR i "${i}+100")
      else ()
        math ( EXPR i "${i}+90")
      endif ()
    elseif ( ${TWX_CMD}.R_BACK )
      math ( EXPR i "${i}+40")
    else ()
      math ( EXPR i "${i}+30")
    endif ()
    list ( APPEND ${TWX_CMD}.PREFIX "${i}" )
  endif ()
  list ( APPEND ${${TWX_CMD}.R_APPEND_TO} "${${TWX_CMD}.PREFIX}" )
  return ( PROPAGATE ${${TWX_CMD}.R_APPEND_TO} )
endfunction ( twx_format_parse_color )

# ANCHOR: twx_format_define
#[=======[
*/
/**
  * @brief Define a format
  *
  * Known color names: `BLACK`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,
  * This is based on `https://en.wikipedia.org/wiki/ANSI_escape_code`.
  *
  * @param BOLD, optional flag
  * @param UNDERLINE, optional flag
  * @param style for key `STYLE`, optional style name.
  * When not provided, the default style name is the empty string.
  * If the style is not exactly the global style defined by the
  * `/TWX/FORMAT/STYLE` variable, then this instruction is skipped.
  * @param text_color for key `TEXT_COLOR`, text color name or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer.
  * @param back_color for key `BACK_COLOR`, background color name or
  *   <r>/<g>/<b> specification  where each component is
  *   a 0 to 255 integer
  * @param id for key `ID`, the format identifier.
  *   The format will be exposed in the variable `/TWX/FORMAT/<id>`.
  * @param SCOPE, optional flag. When set, the format is defined only
  *   in the current scope, otherwise it is defined globally.
  *   When a format is defined globally, it can be exposed in any scope
  *   with a call to `twx_format_expose()`.
  */
twx_format_define( ID id [SCOPE] [BOLD] [UNDERLINE] [TEXT_COLOR color] [BACK_COLOR bg_color] ) {}
/*
#]=======]
function ( twx_format_define )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "BOLD;UNDERLINE;APPEND;SCOPE" "ID;TEXT_COLOR;BACK_COLOR;TEXT_COLOR_24;BACK_COLOR_24;STYLE" ""
  )
  if ( NOT "${twx.R_STYLE}" STREQUAL "${/TWX/FORMAT/STYLE}" )
    return ()
  endif ()
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
  if ( twx.R_APPEND )
    if ( NOT DEFINED prefix_ )
      return ()
    endif ()
    string ( APPEND /TWX/FORMAT/${twx.R_ID}  "${/TWX/FORMAT/033}[${prefix_}m" )
  else ()
    set ( /TWX/FORMAT/${twx.R_ID}  "${/TWX/FORMAT/033}[${prefix_}m" )
  endif ()
  if ( NOT twx.R_SCOPE )
    set_property (
      GLOBAL
      PROPERTY /TWX/FORMAT/${twx.R_ID} "${/TWX/FORMAT/${twx.R_ID}}"
    )
  endif ()
  return ( PROPAGATE /TWX/FORMAT/${twx.R_ID} )
endfunction ()

# ANCHOR: twx_format_expose
#[=======[
*/
/**
  * @brief Expose a format
  *
  * @param id for key `ID`, the format identifier.
  *   Set the variable `/TWX/FORMAT/<id>` to the format previously defined
  *   by a call to `twx_format_define()` with the same id.
  * @param OPTIONAL, optional flag. When unset, raise if the format id
  *   is not already defined. When set, does nothing.
  */
twx_format_expose(ID id) {}
/*
#]=======]
function ( twx_format_expose .ID twx.R_ID )
  twx_function_begin ()
  if ( ARGC GREATER 2 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( NOT .ID STREQUAL "ID" )
    message ( FATAL_ERROR "Unexpected: ``.ID => ${.ID}''" )
  endif ()
  twx_var_assert_name ( "${twx.R_ID}" )
  if ( NOT DEFINED /TWX/FORMAT/${twx.R_ID} )
    get_property (
      /TWX/FORMAT/${twx.R_ID}
      GLOBAL
      PROPERTY /TWX/FORMAT/${twx.R_ID}
    )
    if ( /TWX/FORMAT/${twx.R_ID} MATCHES "NOTFOUND$" )
      if ( NOT twx.R_OPTIONAL )
        message ( FATAL_ERROR "Unknown format: ``twx.R_ID => ${twx.R_ID}''" )
      endif ()
      return ()
    endif ()
    return ( PROPAGATE /TWX/FORMAT/${twx.R_ID} )
  endif ()
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
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "OPTIONAL" "IN_VAR;APPEND_TO;ID" ""
  )
  list ( POP_FRONT ${TWX_CMD}.R_UNPARSED_ARGUMENTS mode_ )
  if ( NOT DEFINED ${TWX_CMD}.R_ID )
    set ( ${TWX_CMD}.R_ID "${mode_}" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_ID}" )
  twx_format_expose ( ID "${${TWX_CMD}.R_ID}" )
  set ( l FATAL_ERROR SEND_ERROR WARNING AUTHOR_WARNING DEPRECATION NOTICE STATUS VERBOSE DEBUG TRACE CHECK_START CHECK_PASS CHECK_FAIL CONFIGURE_LOG )
  if ( mode_ IN_LIST l )
    string ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/${${TWX_CMD}.R_ID}}" )
    string ( APPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/RESET}" )
    if ( DEFINED ${TWX_CMD}.R_IN_VAR )
      twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
      set ( ${${TWX_CMD}.R_IN_VAR} "${${TWX_CMD}.R_UNPARSED_ARGUMENTS}" )
    elseif ( DEFINED ${TWX_CMD}.R_APPEND_TO )
      twx_var_assert_name ( "${${TWX_CMD}.R_APPEND_TO}" )
      string ( APPEND ${${TWX_CMD}.R_APPEND_TO} "${${TWX_CMD}.R_UNPARSED_ARGUMENTS}" )
    else ()
      message ( ${mode_} "${${TWX_CMD}.R_UNPARSED_ARGUMENTS}" )
    endif ()
  else ()
    if ( DEFINED ${TWX_CMD}.R_IN_VAR )
      list ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${mode_} )
      string ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/${${TWX_CMD}.R_ID}}" )
      string ( APPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/RESET}" )
      twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
      set ( ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_UNPARSED_ARGUMENTS} )
    endif ()
    if ( DEFINED ${TWX_CMD}.R_APPEND_TO )
      list ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${mode_} )
      string ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/${${TWX_CMD}.R_ID}}" )
      string ( APPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/RESET}" )
      twx_var_assert_name ( "${${TWX_CMD}.R_APPEND_TO}" )
      string ( APPEND ${${TWX_CMD}.R_APPEND_TO} ${${TWX_CMD}.R_UNPARSED_ARGUMENTS} )
    endif ()
    if ( NOT DEFINED ${TWX_CMD}.R_IN_VAR AND NOT DEFINED ${TWX_CMD}.R_APPEND_TO )
      string ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/${${TWX_CMD}.R_ID}}" )
      string ( APPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS "${/TWX/FORMAT/RESET}" )
      message ( ${mode_} ${${TWX_CMD}.R_UNPARSED_ARGUMENTS} )
    endif ()
  endif ()
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_APPEND_TO} )
endfunction ()

# ANCHOR: twx_format_warning
#[=======[
*/
/**
  * @brief Message warner.
  *
  * On the first use only, display the warning message.
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
    PROPERTY /TWX/FORMAT/NO_WARNING
  )
  if ( NOT no_warning_ )
    set_property (
      GLOBAL
      PROPERTY /TWX/FORMAT/NO_WARNING ON
    )
    twx_format_message ( WARNING ${ARGV} )
  endif ()
endfunction ()

twx_lib_require ( "Var" )

# twx_format_define ( ID A UNDERLINE )
# message ( STATUS "${/TWX/FORMAT/A}Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A BOLD )
# message ( STATUS "${/TWX/FORMAT/A}Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A TEXT_COLOR RED )
# message ( STATUS "${/TWX/FORMAT/A}RED Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A TEXT_COLOR Green )
# message ( STATUS "${/TWX/FORMAT/A}Green Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A TEXT_COLOR "bright Green" )
# message ( STATUS "${/TWX/FORMAT/A}bright Green Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A BACK_COLOR "Green" )
# message ( STATUS "${/TWX/FORMAT/A}bright Green Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID A TEXT_COLOR 100/20/40 )
# message ( STATUS "${/TWX/FORMAT/A}A Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID B TEXT_COLOR 200/20/240 )
# message ( STATUS "${/TWX/FORMAT/033}[38;2;200;20;255mB Hello Guys B${/TWX/FORMAT/RESET}" )
# message ( STATUS "${/TWX/FORMAT/B}B Hello Guys B${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID C TEXT_COLOR 117 )
# message ( STATUS "${/TWX/FORMAT/033}[38;5;117mC Hello Guys${/TWX/FORMAT/RESET}" )
# message ( STATUS "${/TWX/FORMAT/C}C Hello Guys${/TWX/FORMAT/RESET}" )

# message ( STATUS "${/TWX/FORMAT/033}[38;2;10;5;100mHello Guys 38;2;10;5;100${/TWX/FORMAT/RESET}" )
# # foreach ( i RANGE 0 255 )
# #   message ( STATUS "${/TWX/FORMAT/033}[38;5;${i}mHello Guys ${i}${/TWX/FORMAT/RESET}" )
# #   twx_format_define ( ID D SCOPE TEXT_COLOR ${i} )
# #   message ( STATUS "${/TWX/FORMAT/D}Hello Guys ${i}${/TWX/FORMAT/RESET}" )
# # endforeach ()
# message ( STATUS "${/TWX/FORMAT/033}[31mHello Guys RED${/TWX/FORMAT/RESET}" )
# message ( STATUS "${/TWX/FORMAT/033}[32mHello Guys GREEN${/TWX/FORMAT/RESET}" )

# message ( STATUS "${/TWX/FORMAT/033}[38;2;30;40;50mHello Guys 38;2;30;40;50${/TWX/FORMAT/RESET}" )

# twx_format_define ( ID D TEXT_COLOR 222 )
# message ( STATUS "${/TWX/FORMAT/D}D Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID D TEXT_COLOR 111 STYLE Reversed )
# message ( STATUS "${/TWX/FORMAT/D}D Hello Guys${/TWX/FORMAT/RESET}" )
# block ()
# set ( /TWX/FORMAT/STYLE Reversed )
# twx_format_define ( ID D TEXT_COLOR 111 STYLE Reversed )
# message ( STATUS "${/TWX/FORMAT/D}D Hello Guys${/TWX/FORMAT/RESET}" )
# endblock ()
# twx_format_define ( ID E TEXT_COLOR 91 )
# message ( STATUS "${/TWX/FORMAT/E}E Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID E BOLD APPEND )
# message ( STATUS "${/TWX/FORMAT/E}E Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID E TEXT_COLOR 58 APPEND )
# message ( STATUS "${/TWX/FORMAT/E}E Hello Guys${/TWX/FORMAT/RESET}" )
# twx_format_define ( ID E TEXT_COLOR 55/154/254 APPEND )
# message ( STATUS "${/TWX/FORMAT/E}E Hello Guys${/TWX/FORMAT/RESET}" )
# message ( FATAL_ERROR "${/TWX/FORMAT/033}[31;1mHello ${/TWX/FORMAT/033}[33;1mGuys${/TWX/FORMAT/033}[0m\n" )
# twx_format_define ( ID F BACK_COLOR 189 BACK )
# message ( STATUS "${/TWX/FORMAT/F}F Hello Guys${/TWX/FORMAT/RESET}" )

# message ( FATAL_ERROR "${/TWX/FORMAT/033}[31;1mHello ${/TWX/FORMAT/033}[33;1mGuys${/TWX/FORMAT/033}[0m\n" )

if ( /TWX/FORMAT/NIGHT_SHIFT )
  twx_format_define ( ID Var BACK_COLOR 25 BACK )
else ()
  twx_format_define ( ID Var BACK_COLOR 189 BACK )
endif ()

twx_lib_did_load ()

#*/
