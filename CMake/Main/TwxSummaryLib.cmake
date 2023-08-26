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
TWX_SUMMARY_NO_COLOR;
/*
Output:

* `twx_format_ter_log`
* `twx_summary_log`
* `twx_summary_log_kv`
* `twx_summary_begin`
* `twx_summary_end`

Each function is documented below.

#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ( NO_SCRIPT )

twx_cfg_read ( factory git )

# Coloring output
# Standard feature to display colors on the terminal
if ( WIN32 OR TWX_SUMMARY_NO_COLOR )
  set ( TWX_FORMAT.reset )
  set ( twx-summary-format-key )
  set ( twx-summary-format-value )
else ()
  # One character to reset format
  string ( ASCII 27 TWX_SUMMARY_CHAR_ESCAPE )
  set ( TWX_FORMAT.reset "${TWX_SUMMARY_CHAR_ESCAPE}[m" )
  # This is a poor man map
  set (
    twx-summary-format
    BOLD         "1m"
    RED          "31m"
    GREEN        "32m"
    YELLOW       "33m"
    BLUE         "34m"
    MAGENTA      "35m"
    CYAN         "36m"
    WHITE        "37m"
    BOLD_RED     "1\;31m"
    BOLD_GREEN   "1\;32m"
    BOLD_YELLOW  "1\;33m"
    BOLD_BLUE    "1\;34m"
    BOLD_MAGENTA "1\;35m"
    BOLD_CYAN    "1\;36m"
    BOLD_WHITE   "1\;37m"
  )
endif ()

# ANCHOR: twx_format_ter_message
#[=======[
*/
/**
  * @brief Formatter
  *
  * Enclose the input between appropriate formatting characters,
  * put the result in the variable pointed to by output.
  *
  * @param format is one of the known formats, optional
  * @param output for key `IN_VAR` is the variable name holding the result
  * @param ... for key `TEXT`, is the optional list of texts to format.
  *   When not provided, the contents of *<output>* is used instead
  *
  */
twx_format_ter_message( [format] [TEXT msg ...] IN_VAR output ) {}
/*
#]=======]
function ( twx_format_ter_message )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR" "TEXT"
  )
  list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS twx.R_FORMAT )
  twx_arg_assert_parsed ()
  twx_var_assert_name ( "${twx.R_VAR}" )
  if ( NOT DEFINED twx.R_TEXT )
    set ( twx.R_TEXT "${${twx.R_VAR}}" )
  endif ()
  if ( "${twx.R_FORMAT}" STREQUAL "" )
    set( ${twx.R_VAR} "${twx.R_TEXT}" PARENT_SCOPE )
    return ()
  endif ()
  list ( FIND twx-summary-format "${twx.R_FORMAT}" i )
  if ( "${i}" LESS "0" )
    twx_fatal ( "Unknown format ${twx.R_FORMAT}" )
    return ()
  endif ()
  math ( EXPR i "${i}+1" )
  list ( GET twx-summary-format "${i}" l )
  set ( l "${TWX_SUMMARY_CHAR_ESCAPE}[${l}" )
  set (
    ${twx.R_VAR}
    "${l}${twx.R_TEXT}${TWX_FORMAT.reset}"
    PARENT_SCOPE
  )
endfunction ()

# ANCHOR: twx_format_ter_log
#[=======[
*/
/** @brief Print a message depending on a level.
  *
  * @param format one of the known formats, optional
  * @param message some text
  * @param ... more messages
  * @param level is the log level, 0 to allways log, `+∞` to never log.
  *   `TWX_SUMMARY_LOG_LEVEL_CURRENT` is the maximum value for display.
  */
twx_format_ter_log ( [format] message ... [LEVEL level] ) {}
/** @brief maximum value for display
  *
  * Nothing is displayed if the given level is more than
  * `TWX_SUMMARY_LOG_LEVEL_CURRENT`.
  */
TWX_SUMMARY_LOG_LEVEL_CURRENT;
/*
#]=======]

if ( NOT DEFINED TWX_SUMMARY_LOG_LEVEL_CURRENT )
  set ( TWX_SUMMARY_LOG_LEVEL_CURRENT 0 )
endif ()

# `twx.R_ARGN` is a list variable.
# Empty `twx.R_ARGN` on `VERBOSE` mode.
# Parse the format, define shared variables
# `left` and `right`

# ANCHOR: twx_summary__parse_arguments
# Private macro to parse the leading `<format>`
# and the trailing `VERBOSE|DEBUG|TRACE`.
# Outputs twx.R_HIDE, twx.R_EOL, twx.R_UNPARSED_ARGUMENTS
macro ( twx_summary__parse_arguments )
  # nothing to show if the whole section is hidden
  cmake_parse_arguments ( twx.R "VERBOSE;DEBUG;TRACE;EOL" "" "" ${ARGV} )
  twx_message_log_level_index ( STATUS IN_VAR log_level_status_ )
  set ( log_level_ STATUS )
  if ( twx.R_VERBOSE )
    twx_assert_undefined ( twx.R_DEBUG twx.R_TRACE )
    set ( log_level_ VERBOSE )
  elseif ( twx.R_DEBUG )
    twx_assert_undefined ( twx.R_TRACE twx.R_VERBOSE )
    set ( log_level_ DEBUG )
  elseif ( twx.R_TRACE )
    twx_assert_undefined ( twx.R_VERBOSE twx.R_DEBUG )
    set ( log_level_ TRACE )
  endif ()
  twx_message_log_level_index ( ${log_level_} IN_VAR log_level_ )
  if ( log_level_ GREATER log_level_status_ )
    set ( twx.R_HIDE ON )
  endif ()
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    list ( GET twx.R_UNPARSED_ARGUMENTS 0 twx.R_FORMAT )
    if ( twx.R_FORMAT IN_LIST twx-summary-format )
      list ( REMOVE_AT twx.R_UNPARSED_ARGUMENTS 0 )
    else ()
      set ( twx.R_FORMAT )
    endif ()
  endif ()
endmacro ()

# ANCHOR: twx_summary__set_format
# Private function to set the format
# twx_summary__set_format ( format IN_VAR var )
# On return <var> is defined if the format is acceptable
# undefined otherwise.
function ( twx_summary__set_format twx.R_FORMAT .IN_VAR twx.R_IN_VAR )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  list ( FIND twx-summary-format "${twx.R_FORMAT}" i )
  if ( "${i}" LESS "0" )
    set ( ${twx.R_IN_VAR} PARENT_SCOPE )
  else ()
    set ( ${twx.R_IN_VAR} "${twx.R_FORMAT}" PARENT_SCOPE )
  endif ()
endfunction ( twx_summary__set_format )

# ANCHOR: twx_format_ter_log
function ( twx_format_ter_log )
  if ( ${ARGC} EQUAL "0" )
    return ()
  endif ()
  twx_summary__parse_arguments ( ${ARGV} )
  if ( twx.R_HIDE )
    # nothing to print
    message ( "" )
    return ()
  endif ()
  if ( DEFINED twx.R_FORMAT )
    twx_format_ter_message ( "${twx.R_FORMAT}" TEXT "${twx.R_UNPARSED_ARGUMENTS}" IN_VAR msg_ )
  else ()
    set ( msg_ "[TWX]:${twx.R_UNPARSED_ARGUMENTS}" )
  endif ()
  message ( "${msg_}" )
endfunction ( twx_format_ter_log )

# ANCHOR: twx_summary_log
#[=======[ `twx_summary_log`
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
  * @param `VERBOSE|DEBUG|TRACE` optional message log level.
  */
twx_summary_log([format] message value [VERBOSE|DEBUG|TRACE]) {}
/*
#]=======]
function ( twx_summary_log )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  if ( TWX_SUMMARY_section_hidden_l OR ${ARGC} EQUAL "0" )
    return ()
  endif ()
  set ( ARGV${ARGC} )
  twx_summary__parse_arguments ( ${ARGV} )
  list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS msg_ value_ )
  twx_arg_assert_parsed ()
  if ( twx.R_HIDE )
    message( "" )
    return ()
  endif ()
  if ( NOT DEFINED value_ )
    twx_format_ter_message( ${twx.R_FORMAT} IN_VAR msg_ )
    message ( "${TWX_SUMMARY_indentation}${msg_}" )
    return ()
  endif ()
  string ( APPEND msg_ ":" )
  if ( "${value_}" STREQUAL "" )
  endif ()
  # Hard wrap the remaining material.
  string ( LENGTH "${msg_}" length_what_ )
  string ( LENGTH "${TWX_SUMMARY_indentation}" length_indent )
  math ( EXPR left_char "30 - ${length_what_} - ${length_indent}" )
  set ( blanks_ )
  foreach ( _i RANGE 1 ${left_char} )
    set ( blanks_ " ${blanks_}" )
    # string( APPEND blanks_ " " ) in modern cMake
  endforeach ()
  # wrap the value to just more than 80 characters
  set ( prefix_ "${TWX_SUMMARY_indentation}${msg_}${blanks_}" )
  # This is the prefix for the first line
  # for the next lines obtained by hard wrapping
  # this will be a blank string with the same length.
  string ( LENGTH "${prefix_}" length_ )
  twx_format_ter_message( ${twx.R_FORMAT} IN_VAR prefix_ )
  set ( blanks_ )
  foreach ( _i RANGE 1 ${length_} )
    set ( blanks_ " ${blanks_}" )
    # string( APPEND blanks_ " " ) in modern cMake
  endforeach()
  set ( _lines )
  foreach ( item ${value_} )
    string ( APPEND line_ " ${item}" )
    string ( LENGTH "${line_}" length_ )
    if ( "${length_}" GREATER "50" )
      twx_format_ter_message( ${twx.R_FORMAT} IN_VAR line_ )
      message ( "${prefix_}${line_}" )
      set ( prefix_ "${blanks_}" )
      # `msg_` and `line_` have been consumed,
      set ( msg_ )
      set ( line_ )
    endif ()
  endforeach ()
  # Everything consumed?
  if ( NOT "${prefix_}" STREQUAL "" OR NOT "${line_}" STREQUAL "" )
    if ( NOT "${line_}" STREQUAL "" )
      twx_format_ter_message( ${twx.R_FORMAT} IN_VAR line_ )
    endif ()
    message ( "${prefix_}${line_}" )
  endif ()
endfunction ( twx_summary_log )

# ANCHOR: twx_summary_log_kv
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
twx_summary_log_kv ( [format] key [FLAG|VAR] value [VERBOSE|DEBUG|TRACE] ) {}
/*
#]=======]
function( twx_summary_log_kv )
  if ( twx.R_HIDE )
    message( "" )
    return ()
  endif ()
  if ( TWX_SUMMARY_section_hidden_l )
    return ()
  endif ()
  if ( ${ARGC} LESS "1" )
    return ()
  endif ()
  twx_summary__set_format ( "${ARGV0}" IN_VAR twx.R_FORMAT )
  if ( DEFINED twx.R_FORMAT )
    set ( i 1 )
  else ()
    set ( i 0 )
  endif ()
  set ( key_ "${ARGV${i}}" )
  math ( EXPR i "${i}+1" )
  cmake_parse_arguments (
    PARSE_ARGV "${i}" twx.R
    "VERBOSE;DEBUG;TRACE" "FLAG;VAR" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    twx_assert_undefined ( twx.R_FLAG twx.R_VAR )
    list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS value_ )
    twx_arg_assert_parsed ()
  elseif ( DEFINED twx.R_FLAG )
    twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS twx.R_VAR )
    if ( "${${twx.R_FLAG}}" )
      set ( value_ "yes" )
    else  ()
      set ( value_ "no" )
    endif ()
  elseif ( DEFINED twx.R_VAR )
    twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS twx.R_FLAG )
    set ( value_ "${${twx.R_VAR}}" )
  else ()
    message( "" )
    return ()
  endif ()
  twx_summary_log( ${twx.R_FORMAT} "${key_}" "${value_}" ${twx.R_VERBOSE} ${twx.R_DEBUG} ${twx.R_TRACE} )
endfunction ( twx_summary_log_kv )

# ANCHOR: twx_summary_begin
#[=======[
*/
/** @brief begin a new summary section
  * 
  * Display the title and setup indentation.
  * Must be balanced by a `twx_summary_end()`.
  *
  *
  * @param format optional known format
  * @param title required
  * @param `VERBOSE|DEBUG|TRACE` optional, log level.
  * @param `EOL` optional, instert a new line at the end.
  */
twx_summary_begin([format] title [VERBOSE|DEBUG|TRACE]) {}
/*
Implementation detail:
* `TWX_SUMMARY_stack` keeps track of enclosing section.
  It is a list of `+` and `-`, the latter
  means that the section is hidden.
  **NB:** Testing that this list is empty is
  equivalent to testing for its content as string.
* `TWX_SUMMARY_section_hidden_l` keeps track of
  the visibility state of the current section
* `TWX_SUMMARY_indentation` is bigger in embedded sections.
#]=======]
function ( twx_summary_begin )
  twx_summary__parse_arguments ( ${ARGN} )
  list ( POP_FRONT twx.R_UNPARSED_ARGUMENTS twx.R_TITLE )
  twx_arg_assert_parsed ()
  if ( twx.R_HIDE )
    set ( TWX_SUMMARY_section_hidden_l ON )
  endif ()
  if ( TWX_SUMMARY_section_hidden_l )
    list ( PUSH_FRONT TWX_SUMMARY_stack "-" )
  elseif ( TWX_SUMMARY_stack )
    # Propagate the visibility state: duplicate and insert.
    list ( GET TWX_SUMMARY_stack 0 previous_ )
    list ( PUSH_FRONT TWX_SUMMARY_stack "${previous_}" )
  else  ()
    list ( PUSH_FRONT TWX_SUMMARY_stack "+" )
  endif ()
  # export the main values
  if ( NOT TWX_SUMMARY_section_hidden_l )
    block ()
    set ( m "${TWX_SUMMARY_indentation}${twx.R_TITLE}" )
    twx_format_ter_message ( ${twx.R_FORMAT} IN_VAR m )
    message ( "${m}" )
    endblock ()
  endif ()
  # build the indentation from scratch
  list ( LENGTH TWX_SUMMARY_stack l )
  string ( REPEAT "  " ${l} TWX_SUMMARY_indentation )
  if ( twx.R_EOL )
    message ( "" )
  endif ()
  twx_export (
    TWX_SUMMARY_indentation
    TWX_SUMMARY_stack
    TWX_SUMMARY_section_hidden_l
  )
endfunction ()

# ANCHOR: twx_summary_end
#[=======[
*/
/** @brief Balance a `twx_summary_begin`
  *
  * End a config section, setup indentation and associate variables.
  * Must balance a previous `twx_summary_begin` in the same scope.
  *
  * @param `NO_EOL` optional key to remove an extra EOL
  */
twx_summary_end([NO_EOL]) {}
/*
#]=======]
function ( twx_summary_end )
  if ( NOT TWX_SUMMARY_stack )
    twx_fatal ( "Missing ``twx_summary_begin()''" )
  endif ()
  block ()
  set ( break_ ON )
  if ( "${ARGV}" STREQUAL "NO_EOL" )
    set ( break_ OFF )
  elseif ( ARGC GREATER 0 )
    twx_fatal ( " Bad usage: ``${ARGV}''")
    return ()
  endif ()
  if ( break_ AND NOT TWX_SUMMARY_section_hidden_l )
    message( "" )
  endif ()
  endblock ()
  list( POP_FRONT TWX_SUMMARY_stack )
  if( TWX_SUMMARY_stack )
    block ( PROPAGATE TWX_SUMMARY_section_hidden_l TWX_SUMMARY_indentation )
    list( GET TWX_SUMMARY_stack 0 l )
    if( "${l}" STREQUAL "-" )
      set( TWX_SUMMARY_section_hidden_l ON )
    else  ()
      set ( TWX_SUMMARY_section_hidden_l OFF )
    endif ()
    list ( LENGTH TWX_SUMMARY_stack l )
    string ( REPEAT "  " ${l} TWX_SUMMARY_indentation )
    endblock ()
  else  ()
    set ( TWX_SUMMARY_section_hidden_l OFF )
    set( TWX_SUMMARY_indentation )
  endif ()
  block ()
  list ( LENGTH TWX_SUMMARY_stack l )
  twx_format_ter_log( ">>> HIDDEN: ${TWX_SUMMARY_section_hidden_l}, DEPTH: ${l}" TRACE )
  endblock ()
  twx_export (
    TWX_SUMMARY_stack
    TWX_SUMMARY_indentation
    TWX_SUMMARY_section_hidden_l
  )
endfunction ( twx_summary_end )

# ANCHOR: twx_summary__common_ancestor
# problem if the arguments are not canonical paths
# @param `...` to collect the common ancestor
# @param `IN_VAR_ANCESTOR` to collect the common ancestor
# @param `IN_VAR_RELATIVE` to collect the relative paths
function ( twx_summary__common_ancestor )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR_ANCESTOR;IN_VAR_RELATIVE" ""
  )
  twx_var_assert_name (
    "${twx.R_IN_VAR_ANCESTOR}"
    "${twx.R_IN_VAR_RELATIVE}"
  )
  set ( ${twx.R_IN_VAR_ANCESTOR} )
  if ( "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_export ( ${twx.R_IN_VAR_ANCESTOR} )
    twx_export ( ${twx.R_IN_VAR_RELATIVE} UNSET )
    return ()
  endif ()
  list ( GET twx.R_UNPARSED_ARGUMENTS 0 ref_ )
  while ( "${ref_}" MATCHES "^([^/]*/)(.+)$" )
    set ( common_ "${CMAKE_MATCH_1}" )
    set ( ref_ "${CMAKE_MATCH_2}" )
    set ( new_ )
    foreach ( full_ ${twx.R_UNPARSED_ARGUMENTS} )
      if ( "${full_}" MATCHES "^${common_}(.+)$" )
        list ( APPEND new_ "${CMAKE_MATCH_1}" )
      else ()
        twx_export (
          ${twx.R_IN_VAR_RELATIVE}
          ${twx.R_IN_VAR_ANCESTOR}
        )
        return ()
      endif ()
    endforeach ( full_ )
    set ( ${twx.R_IN_VAR_ANCESTOR} "${${twx.R_VAR_ANCESTOR}}${common_}" )
    set ( ${twx.R_IN_VAR_RELATIVE} "${new_}" )
  endwhile ()
  twx_export (
    ${twx.R_IN_VAR_RELATIVE}
    ${twx.R_IN_VAR_ANCESTOR}
  )
endfunction ( twx_summary__common_ancestor )

# SECTION: sections
# ANCHOR: twx_summary_section_compiler
#[=======[
*/
/** @brief Log compiler info
  *
  */
twx_summary_section_compiler() {}
/*
#]=======]
function ( twx_summary_section_compiler )
  twx_assert_parsed ()
  twx_summary_begin ( BOLD_MAGENTA "Compiler" VERBOSE )
  twx_summary_log_kv ( "ID" ${CMAKE_CXX_COMPILER_ID})
  twx_summary_log_kv ( "Version" ${CMAKE_CXX_COMPILER_VERSION})
  if ( NOT "${CMAKE_BUILD_TYPE}" STREQUAL "" )
    twx_summary_log_kv ( "Optimization" ${CMAKE_BUILD_TYPE} )
  endif ()
  twx_summary_end ( EOL )
endfunction ()

# ANCHOR: twx_summary_section_build_settings
#[=======[
*/
/** @brief Log target build settings info
  *
  * @param ... are target names.
  */
twx_summary_section_build_settings( target ) {}
/*
#]=======]
function ( twx_summary_section_build_settings )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "VERBOSE;DEBUG;TRACE" "" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET ${target_} )
      string ( PREPEND target_ "Twx" )
      if ( NOT TARGET ${target_} )
        twx_fatal ( "Unknown target ${target_}" )
        return ()
      endif ()
    endif ()
    foreach ( t_ COMPILE_OPTIONS COMPILE_DEFINITIONS INCLUDE_DIRECTORIES )
      get_target_property (
        ${t_}_
        ${target_}
        ${t_}
      )
    endforeach ()
    if ( "${COMPILE_OPTIONS_}" MATCHES "NOTFOUND"
    AND "${COMPILE_DEFINITIONS_}" MATCHES "NOTFOUND"
    AND "${INCLUDE_DIRECTORIES_}" MATCHES "NOTFOUND")
      continue ()
    endif ()
    twx_summary_begin ( BOLD_BLUE "${target_} build settings" ${twx.R_VERBOSE} ${twx.R_DEBUG} ${twx.R_TRACE} )
    if ( NOT "${COMPILE_OPTIONS_}" MATCHES "NOTFOUND" )
      # TODO: include the test in twx_summary_log_kv
      twx_summary_log_kv ( "Compile options" VAR COMPILE_OPTIONS_ )
    endif ()
    if ( NOT "${COMPILE_DEFINITIONS_}" MATCHES "NOTFOUND" )
      list ( REMOVE_DUPLICATES COMPILE_DEFINITIONS_ )
      twx_summary_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS_ )
    endif ()
    if ( NOT "${INCLUDE_DIRECTORIES_}" MATCHES "NOTFOUND" )
      include ( TwxModuleLib )
      twx_module_expose ( ${target_} OPTIONAL )
      if ( ${target_}_IS_MODULE )
        twx_module_shorten (
          VAR INCLUDE_DIRECTORIES_
          MODULE ${target_} ${${target_}_MODULES}
        )
      else ()
        twx_summary__common_ancestor (
          IN_VAR_ANCESTOR dir_
          IN_VAR_RELATIVE rel_
          ${INCLUDE_DIRECTORIES_}
        )
        if ( NOT "${dir_}" STREQUAL "" )
          twx_summary_log_kv ( "Include from" VAR dir_ )
        endif ()
        if ( NOT "${rel_}" STREQUAL "" )
          list ( REMOVE_DUPLICATES rel_ )
          twx_summary_log_kv ( "Include directories" VAR rel_ )
        endif ()
      endif ()
    endif ()
    twx_summary_end ()
  endforeach ()
endfunction ( twx_summary_section_build_settings )

# ANCHOR: twx_summary_section_libraries
#[=======[
*/
/** @brief Log target libraries
  *
  * @param ... are target names.
  */
twx_summary_section_libraries( target ... ) {}
/*
#]=======]
function ( twx_summary_section_libraries )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "VERBOSE;DEBUG;TRACE" "" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET ${target_} )
      string ( PREPEND target_ "Twx" )
      if ( NOT TARGET ${target_} )
        twx_fatal ( "Unknown target ${target_}" )
        return ()
      endif ()
    endif ()
    get_target_property (
      libraries_
      ${target_}
      LINK_LIBRARIES
    )
    if ( "${libraries_}" MATCHES "NOTFOUND" )
      continue ()
    endif ()
    set ( Qt_libraries_ )
    set ( Twx_libraries_ )
    set ( Other_libraries_ )
    foreach ( l_ IN LISTS libraries_ )
      if ( ${l_} MATCHES "^Twx" )
        list ( APPEND Twx_libraries_ ${l_} )
      elseif ( ${l_} MATCHES "^Qt" )
        list ( APPEND Qt_libraries_ ${l_} )
      else ()
        list ( APPEND Other_libraries_ ${l_} )
      endif ()
    endforeach ()
    twx_summary_begin ( BOLD_BLUE "${target_} libraries" ${twx.R_VERBOSE} )
      if ( NOT "${Qt_libraries_}" STREQUAL "" )
        list ( REMOVE_DUPLICATES Qt_libraries_ )
        twx_summary_log_kv ( "${QtMAJOR} libraries" VAR Qt_libraries_ )
      endif ()
      if ( NOT "${Twx_libraries_}" STREQUAL "" )
        list ( REMOVE_DUPLICATES Twx_libraries_ )
        string ( REPLACE "Twx" "Twx::" Twx_libraries_ "${Twx_libraries_}")
        twx_summary_log_kv ( "Twx modules" VAR Twx_libraries_ )
      endif ()
      if ( NOT "${Other_libraries_}" STREQUAL "" )
        list ( REMOVE_DUPLICATES Other_libraries_ )
        twx_summary_log_kv ( "Other libraries" VAR Other_libraries_ )
      endif ()
    twx_summary_end ()
  endforeach ()
endfunction ( twx_summary_section_libraries )

# ANCHOR: twx_summary_section_directories
#[=======[
*/
/** @brief Log current project directories info
  *
  */
twx_summary_section_directories() {}
/*
#]=======]
function ( twx_summary_section_directories )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "VERBOSE;DEBUG;TRACE" "" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET "${target_}" )
      string ( PREPEND target_ "Twx" )
      if ( NOT TARGET "${target_}" )
        message ( WARNING "Unknown target: ${target_}" )
        continue( )
      endif ()
    endif ()
    twx_summary_begin ( BOLD_BLUE "${target_} directories" ${twx.R_VERBOSE} ${twx.R_DEBUG} ${twx.R_TRACE} )
    twx_summary_log_kv ( "root"   VAR TWX_DIR )
    twx_summary_log_kv ( "source" VAR CMAKE_SOURCE_DIR )
    twx_summary_log_kv ( "binary" VAR CMAKE_BINARY_DIR )
    twx_summary_end ( EOL )
  endforeach ()
endfunction ( twx_summary_section_directories )

# ANCHOR: twx_summary_section_files
#[=======[
*/
/** @brief Log target files info
  *
  * @param ... are target names with
  * `..._SOURCES`, `..._HEADERS`, `..._UIS`.
  */
twx_summary_section_files( target ) {}
/*
#]=======]
function ( twx_summary_section_files )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "VERBOSE;DEBUG;TRACE" "" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET "${target_}" )
      string ( PREPEND target_ "Twx" )
      if ( NOT TARGET "${target_}" )
        message ( WARNING "Unknown target: ${target_}" )
        continue( )
      endif ()
    endif ()
    twx_target_expose ( ${target_} PROPERTIES SOURCES )
    if ( files_ MATCHES "NOTFOUND$" )
      twx_message_log ( VERBOSE "No SOURCES in target: ${target_}" )
      continue ()
    endif ()
    include ( TwxModuleLib )
    twx_module_expose ( ${target_} OPTIONAL )
    if ( ${target_}_IS_MODULE )
      twx_module_shorten (
        VAR files_
        MODULE ${target_} ${${target_}_MODULES}
      )
    endif ()
    # get_target_property (
    #   dirs_
    #   ${target_}
    #   TWX_SOURCES_DIRS <==== to be defined (and used), maybe (JL)
    # )
    # separate files in a TwxBuild folder from the rest
    set ( built_ )
    set ( raw_ )
    foreach ( f_ ${files_} )
      if ( f_ MATCHES "/TwxBuild/" )
        list ( APPEND built_ "${f_}" )
      else ()
        list ( APPEND raw_ "${f_}" )
      endif ()
    endforeach ()
    twx_summary__common_ancestor (
      IN_VAR_ANCESTOR built_dir_
      IN_VAR_RELATIVE built_rel_
      ${built_}
    )
    twx_summary__common_ancestor (
      IN_VAR_ANCESTOR raw_dir_
      IN_VAR_RELATIVE raw_rel_
      ${raw_}
    )
    set ( Private_ )
    set ( SOURCES_ )
    set ( HEADERS_ )
    set ( Other_ )
    foreach ( f_ ${built_rel_} ${raw_rel_} )
      get_filename_component ( n_ "${f_}" NAME )
      if ( "${n_}" MATCHES "_private" )
        list ( APPEND Private_ "${n_}" )
      elseif ( "${n_}" MATCHES "[.](c|m)[^.]$" )
        list ( APPEND SOURCES_ "${n_}" )
      elseif ( "${n_}" MATCHES "[.]h[^.]$" )
        list ( APPEND HEADERS_ "${n_}" )
      else ()
        list ( APPEND Other_ "${n_}" )
      endif ()
    endforeach ()
    if (  "${Private_}" STREQUAL ""
      AND "${SOURCES_}" STREQUAL ""
      AND "${HEADERS_}" STREQUAL ""
      AND "${Other_}"   STREQUAL "" )
      continue ()
    endif ()
    set ( twx.R_VERBOSE )
    twx_summary_begin ( BOLD_BLUE "${target_} files" VERBOSE ${twx.R_VERBOSE} )
    if ( NOT "${built_dir_}" STREQUAL "" )
      twx_summary_log_kv ( "Build dir" VAR built_dir_ )
    endif ()
    if ( NOT "${raw_dir_}" STREQUAL "" )
      twx_summary_log_kv ( "Source dir" VAR raw_dir_ )
    endif ()
    foreach ( t_ SOURCES HEADERS Other Private )
      if ( NOT "${${t_}_}" STREQUAL "" )
        twx_summary_log_kv ( "${t_}" VAR ${t_}_ )
      endif ()
    endforeach ()
    twx_summary_end ( EOL )
  endforeach ()
endfunction ( twx_summary_section_files )

# ANCHOR: twx_summary_section_git
#[=======[
*/
/** @brief Log git status */
twx_summary_section_git() {}
/*
#]=======]
function ( twx_summary_section_git )
  include ( TwxCfgLib )
  twx_cfg_setup ()
  twx_cfg_update_git ()
  twx_summary_begin ( BOLD_MAGENTA "Git info" )
  twx_summary_log ( "Hash"    "${TWX_CFG_GIT_HASH}" )
  twx_summary_log ( "Date"    "${TWX_CFG_GIT_DATE}" )
  twx_summary_log ( "Branch"  "${TWX_CFG_GIT_BRANCH}" )
  twx_summary_end ()
endfunction ()

twx_lib_did_load ()

#*/
