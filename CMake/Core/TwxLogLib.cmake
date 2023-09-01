#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Coloring log output of the summaries.
  *
  * This is not available on windows.
  * Include this file on demand.
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

* `twx_log_message`
* `twx_log`
* `twx_log_kv`
* `twx_log_begin`
* `twx_log_end`

Each function is documented below.

#]===============================================]

include_guard ( GLOBAL )

twx_lib_require ( "Var" "Fatal" "Format" "Arg" )


twx_lib_will_load ()

set (
  TWX_CORE_LOG_LEVELS
    FATAL_ERROR
    SEND_ERROR
    WARNING
    AUTHOR_WARNING
    DEPRECATION
    NOTICE
    STATUS
    VERBOSE
    DEBUG
    TRACE
)

# ANCHOR: twx_log_level_index
#[=======[*/
/** @brief Return the log level index.
  *
  * FATAL_ERROR has lower index, TRACE has higher index.
  *
  * @param level, a known level name, raises when not recognized
  * @param var for key `IN_VAR`, will hold the result.
  */
twx_log_level_index( level IN_VAR var ) {}
/*#]=======]
function ( twx_log_level_index twx.R_LEVEL .IN_VAR twx.R_VAR )
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    twx_fatal ( "Unexpected: ``${.IN_VAR}''")
    return ()
  endif ()
  twx_var_assert_name ( "${twx.R_VAR}" )
  if ( twx.R_LEVEL STREQUAL "" )
    set ( twx.R_LEVEL NOTICE )
  endif ()
  list ( FIND TWX_CORE_LOG_LEVELS "${twx.R_LEVEL}" ${twx.R_VAR} )
  if ( ${twx.R_VAR} LESS 0 )
    set ( ${twx.R_VAR} )
  endif ()
  return ( PROPAGATE ${twx.R_VAR} )
endfunction ()

# ANCHOR: twx_log_level_order
#[=======[*/
/** @brief Order log levels.
  *
  * Returns -1 if the arguments are in ascending order,
  * 0 for equality, 1 for descending.
  * (Quite the index of the characters in `<=>`)
  *
  * @param lhs, a level name, raises when not recognized
  * @param rhs, a level name, raises when not recognized
  * @param var for key `IN_VAR`, will hold the result.
  */
twx_log_level_order( lhs <=> rhs IN_VAR var ) {}
/*#]=======]
function ( twx_log_level_order twx.R_LHS .LEG twx.R_RHS .IN_VAR twx.R_VAR )
  if ( NOT .LEG STREQUAL "<=>" )
    twx_fatal ( "Unexpected: ``${.LEG}''")
    return ()
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    twx_fatal ( "Unexpected: ``${.IN_VAR}''")
    return ()
  endif ()
  twx_var_assert_name ( "${twx.R_VAR}" )
  if ( twx.R_LHS STREQUAL "" )
    set ( twx.R_LHS NOTICE )
  endif ()
  if ( twx.R_RHS STREQUAL "" )
    set ( twx.R_RHS NOTICE )
  endif ()
  list ( FIND TWX_CORE_LOG_LEVELS "${twx.R_LHS}" lhs_ )
  if ( "${lhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twx.R_LHS}" )
    return ()
  endif ()
  list ( FIND TWX_CORE_LOG_LEVELS "${twx.R_RHS}" rhs_ )
  if ( "${rhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twx.R_RHS}" )
    return ()
  endif ()
  if ( "${lhs_}" LESS "${rhs_}" )
    set ( ${twx.R_VAR} -1 PARENT_SCOPE )
  elseif ( "${lhs_}" GREATER "${rhs_}" )
    set ( ${twx.R_VAR} 1 PARENT_SCOPE )
  else ()
    set ( ${twx.R_VAR} 0 PARENT_SCOPE )
  endif ()
endfunction ( twx_log_level_order )

# ANCHOR: twx_log_level_compare
#[=======[*/
/** @brief Compares log levels.
  *
  * @param lhs, a level name, raises when not recognized
  * @param op, binary comparison operator, raises when not recognized
  * @param rhs, a level name, raises when not recognized
  * @param var for key `IN_VAR`, will hold the result
  *   ON when the comparison holds, OFF otherwise.
  */
twx_log_level_compare( lhs op rhs IN_VAR var ) {}
/*#]=======]
function (
  twx_log_level_compare
  twx_log_level_compare.R_LHS
  twx_log_level_compare.R_OP
  twx_log_level_compare.R_RHS
  twx_log_level_compare.R_IN_VAR
  twx_log_level_compare.R_VAR
)
  if ( NOT twx_log_level_compare.R_IN_VAR STREQUAL "IN_VAR" )
    twx_fatal ( "Unexpected: ``${twx_log_level_compare.R_IN_VAR}''")
    return ()
  endif ()
  twx_var_assert_name ( "${twx_log_level_compare.R_VAR}" )
  if ( twx_log_level_compare.R_LHS STREQUAL "" )
    set ( twx_log_level_compare.R_LHS NOTICE )
  endif ()
  if ( twx_log_level_compare.R_RHS STREQUAL "" )
    set ( twx_log_level_compare.R_RHS NOTICE )
  endif ()
  list ( FIND TWX_CORE_LOG_LEVELS "${twx_log_level_compare.R_LHS}" lhs_ )
  if ( "${lhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twx_log_level_compare.R_LHS}" )
    return ()
  endif ()
  list ( FIND TWX_CORE_LOG_LEVELS "${twx_log_level_compare.R_RHS}" rhs_ )
  if ( "${rhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twx_log_level_compare.R_RHS}" )
    return ()
  endif ()
  twx_math ( EXPR ans "${lhs_}${twx_log_level_compare.R_OP}${rhs_}" )
  if ( ans )
    set ( ${twx_log_level_compare.R_VAR} ON PARENT_SCOPE )
  else ()
    set ( ${twx_log_level_compare.R_VAR} OFF PARENT_SCOPE )
  endif ()
endfunction ( twx_log_level_compare )

# ANCHOR: twx_log_parse_color
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
twx_log_parse_color( color APPEND_TO format [BACK]) {}
/*
#]=======]
function ( twx_log_parse_color )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  # Avoid possible name conflicts
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_log_parse_color.R
    "BACK" "APPEND_TO" ""
  )
  list ( POP_FRONT twx_log_parse_color.R_UNPARSED_ARGUMENTS twx_log_parse_color.R_COLOR )
  if ( NOT twx_log_parse_color.R_UNPARSED_ARGUMENTS STREQUAL "" )
    twx_fatal ( " Bad usage: UNPARSED_ARGUMENTS -> ``${twx_log_parse_color.R_UNPARSED_ARGUMENTS}''" )
    return ()
  endif ()
  if ( NOT DEFINED twx_log_parse_color.R_APPEND_TO )
    twx_fatal ( " Bad usage: Missing APPEND_TO" )
    return ()
  endif ()
  twx_var_assert_name ( "${twx_log_parse_color.R_APPEND_TO}" )
  set ( twx_log_parse_color.PREFIX )
  string ( TOLOWER "${twx_log_parse_color.R_COLOR}" twx_log_parse_color.R_COLOR )
  if ( "${twx_log_parse_color.R_COLOR}" MATCHES "^([0-9]+)/([0-9]+)/([0-9]+)$" )
    if ( twx_log_parse_color.BACK )
      list ( APPEND twx_log_parse_color.PREFIX "48" "5" )
    else ()
      list ( APPEND twx_log_parse_color.PREFIX "38" "5" )
    endif ()
    foreach ( i 1 2 3 )
      set ( RGB_${i} "${CMAKE_MATCH_${i}}" )
      if ( CMAKE_MATCH_${i} LESS "256" )
        list ( APPEND twx_log_parse_color.PREFIX "${CMAKE_MATCH_${i}}" )
      else ()
        if ( NOT TWX_FORMAT_NO_WARN )
          message ( WARNING "Unsupported text color ``${twx_log_parse_color.R_COLOR}''")
          set ( TWX_FORMAT_NO_WARN ON CACHE INTERNAL "Private" )
        endif ()
        list ( APPEND twx_log_parse_color.PREFIX "255" )
      endif ()
    endforeach ()
  else ()
    set ( twx_log_parse_color.COLORS black red green yellow blue magenta cyan white )
    list ( INDEX twx_log_parse_color.COLORS "${twx_log_parse_color.R_COLOR}" i )
    if ( i LESS 0 )
      if ( NOT TWX_FORMAT_NO_WARN )
        message ( WARNING "Unsupported text color ``${twx_log_parse_color.R_COLOR}''")
        set ( TWX_FORMAT_NO_WARN ON CACHE INTERNAL "Private" )
      endif ()
      set ( i 1 )
    endif ()
    if ( "${twx_log_parse_color.R_COLOR}" MATCHES "bright" )
      if ( twx_log_parse_color.R_BACK )
        math ( EXPR i "${i}+99")
      else ()
        math ( EXPR i "${i}+89")
      endif ()
    elseif ( twx_log_parse_color.R_BACK )
      math ( EXPR i "${i}+39")
    else ()
      math ( EXPR i "${i}+29")
    endif ()
    list ( APPEND twx_log_parse_color.PREFIX "${i}" )
  endif ()
  list ( APPEND ${twx_log_parse_color.R_APPEND_TO} "${twx_log_parse_color.PREFIX}" )
  return ( PROPAGATE ${twx_log_parse_color.R_APPEND_TO} )
endfunction ()

# ANCHOR: twx_log_parse_format
#[=======[
*/
/**
  * @brief Message formatter
  *
  * Enclose the input between appropriate formatting characters,
  * put the result in the variable pointed to by output.
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
  * @param output for key `IN_VAR` is the variable name holding the result
  * @param APPEND, optional flag to append to the <output> variable.
  *   Before formatting use, append the letter 'm' to this variable.
  *
  */
twx_log_parse_format( [BOLD] [UNDERLINE] [TEXT_COLOR color] [BACK_COLOR bg_color] IN_VAR format [APPEND] ) {}
/*
#]=======]
function ( twx_log_parse_format )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_log_parse_format.R
    "BOLD;UNDERLINE;APPEND" "IN_VAR;TEXT_COLOR;BACK_COLOR" ""
  )
  twx_var_assert_name ( "${twx_log_parse_format.R_IN_VAR}" )
  set ( twx_log_parse_format.PREFIX )
  if ( twx_log_parse_format.R_BOLD )
    list ( APPEND twx_log_parse_format.PREFIX "1" )
  endif ()
  if ( twx_log_parse_format.R_UNDERLINE )
    list ( APPEND twx_log_parse_format.PREFIX "4" )
  endif ()
  if ( DEFINED twx_log_parse_format.R_TEXT_COLOR )
    twx_log_parse_color ( "${twx_log_parse_format.R_TEXT_COLOR}" APPEND twx_log_parse_format.PREFIX )
  endif ()
  if ( DEFINED twx_log_parse_format.R_BACK_COLOR )
    twx_log_parse_color ( "${twx_log_parse_format.R_BACK_COLOR}" APPEND twx_log_parse_format.PREFIX BACK )
  endif ()
  if ( twx_log_parse_format.PREFIX STREQUAL "" )
    set ( ${twx_log_parse_format.R_IN_VAR} PARENT_SCOPE )
    return ()
  endif ()
  string ( ASCII 27 char033 )
  if ( twx_log_parse_format.R_APPEND )
    string (
      APPEND
      ${twx_log_parse_format.R_IN_VAR}
      "${char033}[${twx_log_parse_format.PREFIX}m"
    )
  else ()
    set (
      ${twx_log_parse_format.R_IN_VAR}
      "${char033}[${twx_log_parse_format.PREFIX}m"
    )
  endif ()
  return ( PROPAGATE ${twx_log_parse_format.R_IN_VAR} )
endfunction ( twx_log_parse_format )

# ANCHOR: twx_log
#[=======[ `twx_log`
*/
/**
  * @brief Basic logger
  *
  * Other loggers depend on this one.
  *
  * @param format is one of the known formats, optional
  * @param message, text displayed from the left
  * @param value optional text displayed on the right,
  *   with line break management
  * @param `STATUS|VERBOSE|DEBUG|TRACE` optional message log level.
  *   Only one level at a time.
  */
twx_log([STATUS|VERBOSE|DEBUG|TRACE] MSG message [VALUE value] [EOL]) {}
/*
#]=======]
function ( twx_log )
  if ( NOT COMMAND twx_math )
    message ( ${ARGV} )
    return ()
  endif ()
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  if ( TWX_LOG.section_hidden OR ${ARGC} EQUAL "0" )
    return ()
  endif ()
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "STATUS;VERBOSE;DEBUG;TRACE;EOL" "MSG;VALUE" ""
  )
  twx_arg_pass_option ( STATUS VERBOSE DEBUG TRACE )
  set ( level_ ${twx.R_STATUS} ${twx.R_VERBOSE} ${twx.R_DEBUG} ${twx.R_TRACE} )
  if ( "${level_}" MATCHES ";" )
    message ( FATAL_ERROR " Bad usage: level_ => ``${level_}''" )
  elseif (level_ STREQUAL "" )
    set ( level_ NOTICE )
  endif ()
  cmake_language ( GET_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  twx_log_level_compare ( "${CMAKE_MESSAGE_LOG_LEVEL}" < "${level_}" IN_VAR ans_ )

  # if ( twx.R_HIDE )
  #   message( "" )
  #   return ()
  # endif ()

  twx_log_parse_format ( ${twx.R_UNPARSED_ARGUMENTS} IN_VAR format_ )
  if ( NOT DEFINED twx.R_VALUE )
    if ( DEFINED twx.R_MSG )
      message ( "${format_}${twx.R_MSG}" )
    endif ()
    return ()
  endif ()
  string ( APPEND twx.R_MSG ":" )
  if ( "${twx.R_VALUE}" STREQUAL "" )
  endif ()
  # Hard wrap the remaining material.
  string ( LENGTH "${twx.R_MSG}" length_what_ )
  string ( LENGTH "${TWX_FORMAT.indentation}" length_indent )
  math ( EXPR left_char "30 - ${length_what_} - ${length_indent}" )
  set ( blanks_ )
  foreach ( _i RANGE 1 ${left_char} )
    string( APPEND blanks_ " " )
  endforeach ()
  # wrap the value to just more than 80 characters
  set ( prefix_ "${TWX_FORMAT.indentation}${twx.R_MSG}${blanks_}" )
  # This is the prefix for the first line
  # for the next lines obtained by hard wrapping
  # this will be a blank string with the same length.
  string ( LENGTH "${prefix_}" length_ )
  set ( blanks_ )
  foreach ( _i RANGE 1 ${length_} )
    string( APPEND blanks_ " " )
  endforeach()
  set ( _lines )
  foreach ( item ${twx.R_VALUE} )
    string ( APPEND line_ " ${item}" )
    string ( LENGTH "${line_}" length_ )
    if ( "${length_}" GREATER "50" )
      twx_log_apply ( "${format_}" TO_VAR line_ )
      message ( "${prefix_}${line_}" )
      set ( prefix_ "${blanks_}" )
      # `twx.R_MSG` and `line_` have been consumed,
      set ( twx.R_MSG )
      set ( line_ )
    endif ()
  endforeach ()
  # Everything consumed?
  if ( NOT "${prefix_}" STREQUAL "" OR NOT "${line_}" STREQUAL "" )
    if ( NOT "${line_}" STREQUAL "" )
      twx_log_message( ${twx.R_FORMAT} IN_VAR line_ )
    endif ()
    message ( "${prefix_}${line_}" )
  endif ()
endfunction ( twx_log )

# ANCHOR: twx_log_kv
#[=======[
*/
/**
  * @brief .....key:....value lines
  *
  * @param format one of the known formats, optional
  * @param key some label
  * @param value is displayed as `yes` or `no` with `FLAG`,
  *   variable content with `VAR` and as is otherwise.
  * @param `VERBOSE|DEBUG|TRACE` mode.
  */
twx_log_kv ( [format] key [FLAG|VAR] value [VERBOSE|DEBUG|TRACE] ) {}
/*
#]=======]
function( twx_log_kv )
  if ( twx.R_HIDE )
    message( "" )
    return ()
  endif ()
  if ( TWX_LOG.section_hidden )
    return ()
  endif ()
  if ( ${ARGC} LESS "1" )
    return ()
  endif ()
  twx_log__set ( "${ARGV0}" IN_VAR twx.R_FORMAT )
  if ( DEFINED twx.R_FORMAT )
    set ( i 1 )
  else ()
    set ( i 0 )
  endif ()
  set ( twx.R_KEY "${ARGV${i}}" )
  math ( EXPR i "${i}+1" )
  cmake_parse_arguments (
    PARSE_ARGV "${i}" twx.R
    "VERBOSE;DEBUG;TRACE" "FLAG;VAR" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    twx_assert_undefined ( twx.R_FLAG twx.R_VAR )
    list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS twx.R_VALUE )
    if ( NOT twx.R_UNPARSED_ARGUMENTS STREQUAL "" )
      set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
      twx_fatal ( " Bad usage: ARGV => ``${ARGV}''" )
    return ()
  endif ()
  elseif ( DEFINED twx.R_FLAG )
    twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS twx.R_VAR )
    if ( "${${twx.R_FLAG}}" )
      set ( twx.R_VALUE "yes" )
    else  ()
      set ( twx.R_VALUE "no" )
    endif ()
  elseif ( DEFINED twx.R_VAR )
    twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS twx.R_FLAG )
    set ( twx.R_VALUE "${${twx.R_VAR}}" )
  else ()
    message( "" )
    return ()
  endif ()
  twx_log ( ${twx.R_FORMAT} "${twx.R_KEY}" "${twx.R_VALUE}" ${twx.R_VERBOSE} ${twx.R_DEBUG} ${twx.R_TRACE} )
endfunction ( twx_log_kv )

# ANCHOR: twx_log_begin
#[=======[
*/
/** @brief begin a new summary section
  * 
  * Display the title and setup indentation.
  * Must be balanced by a `twx_log_end()`.
  *
  *
  * @param format optional known format
  * @param title required
  * @param `VERBOSE|DEBUG|TRACE` optional, log level.
  * @param `EOL` optional, instert a new line at the end.
  */
twx_log_begin([format] title [VERBOSE|DEBUG|TRACE]) {}
/*
Implementation detail:
* `TWX_FORMAT_stack` keeps track of enclosing section.
  It is a list of `+` and `-`, the latter
  means that the section is hidden.
  **NB:** Testing that this list is empty is
  equivalent to testing for its content as string.
* `TWX_LOG.section_hidden` keeps track of
  the visibility state of the current section
* `TWX_FORMAT.indentation` is bigger in embedded sections.
#]=======]
function ( twx_log_begin )
  twx_log__parse_arguments ( ${ARGN} )
  list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS twx.R_TITLE )
  if ( NOT twx.R_UNPARSED_ARGUMENTS STREQUAL "" )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
    twx_fatal ( " Bad usage: ARGV => ``${ARGV}''" )
    return ()
  endif ()
  if ( twx.R_HIDE )
    set ( TWX_LOG.section_hidden ON )
  endif ()
  if ( TWX_LOG.section_hidden )
    list ( PUSH_FRONT TWX_FORMAT_stack "-" )
  elseif ( TWX_FORMAT_stack )
    # Propagate the visibility state: duplicate and insert.
    list ( GET TWX_FORMAT_stack 0 previous_ )
    list ( PUSH_FRONT TWX_FORMAT_stack "${previous_}" )
  else  ()
    list ( PUSH_FRONT TWX_FORMAT_stack "+" )
  endif ()
  # export the main values
  if ( NOT TWX_LOG.section_hidden )
    block ()
    set ( m "${TWX_FORMAT.indentation}${twx.R_TITLE}" )
    twx_log_message ( ${twx.R_FORMAT} IN_VAR m )
    message ( "${m}" )
    endblock ()
  endif ()
  # build the indentation from scratch
  list ( LENGTH TWX_FORMAT_stack l )
  string ( REPEAT "  " ${l} TWX_FORMAT.indentation )
  if ( twx.R_EOL )
    message ( "" )
  endif ()
  twx_export (
    TWX_FORMAT.indentation
    TWX_FORMAT_stack
    TWX_LOG.section_hidden
  )
endfunction ()

# ANCHOR: twx_log_end
#[=======[
*/
/** @brief Balance a `twx_log_begin`
  *
  * End a config section, setup indentation and associate variables.
  * Must balance a previous `twx_log_begin` in the same scope.
  *
  * @param `NO_EOL` optional key to remove an extra EOL
  */
twx_log_end([NO_EOL]) {}
/*
#]=======]
function ( twx_log_end )
  if ( NOT TWX_FORMAT_stack )
    twx_fatal ( "Missing ``twx_log_begin()''" )
  endif ()
  block ()
  set ( break_ ON )
  if ( "${ARGV}" STREQUAL "NO_EOL" )
    set ( break_ OFF )
  elseif ( ARGC GREATER 0 )
    twx_fatal ( " Bad usage: ARGV => ``${ARGV}''")
    return ()
  endif ()
  if ( break_ AND NOT TWX_LOG.section_hidden )
    message( "" )
  endif ()
  endblock ()
  list( POP_FRONT TWX_FORMAT_stack )
  if( TWX_FORMAT_stack )
    block ( PROPAGATE TWX_LOG.section_hidden TWX_FORMAT.indentation )
    list( GET TWX_FORMAT_stack 0 l )
    if( "${l}" STREQUAL "-" )
      set( TWX_LOG.section_hidden ON )
    else  ()
      set ( TWX_LOG.section_hidden OFF )
    endif ()
    list ( LENGTH TWX_FORMAT_stack l )
    string ( REPEAT "  " ${l} TWX_FORMAT.indentation )
    endblock ()
  else  ()
    set ( TWX_LOG.section_hidden OFF )
    set( TWX_FORMAT.indentation )
  endif ()
  block ()
  list ( LENGTH TWX_FORMAT_stack l )
  twx_log( ">>> HIDDEN: ${TWX_LOG.section_hidden}, DEPTH: ${l}" TRACE )
  endblock ()
  twx_export (
    TWX_FORMAT_stack
    TWX_FORMAT.indentation
    TWX_LOG.section_hidden
  )
endfunction ( twx_log_end )

twx_lib_require ( Math )

twx_lib_did_load ()

#*/
