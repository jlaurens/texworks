#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Coloring log output of the summaries.

This is not available on windows.
Include this file on demand.

Known formats:
  `BOLD`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,
  `BOLD_RED`, `BOLD_GREEN`, `BOLD_YELLOW`, `BOLD_BLUE`, `BOLD_MAGENTA`, `BOLD_CYAN`, `BOLD_WHITE`
*/
**
@brief Coloring

Turn this off to disable coloring, or switch to windows.
*/
TWX_SUMMARY_NO_COLOR;
/*
Output:

* `twx_log`
* `twx_summary_log`
* `twx_summary_log_kv`
* `twx_summary_begin`
* `twx_summary_end`

Each function is documented below.

#]===============================================]

include_guard ( GLOBAL )

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "Base is not loaded." )
endif ()

set ( TWX_VERBOSE_SAVED ${TWX_VERBOSE} )
set ( TWX_VERBOSE OFF )
include ( TwxCfgLib )
twx_cfg_read ( factory git )
set ( TWX_VERBOSE ${TWX_VERBOSE_SAVED} )
unset ( TWX_VERBOSE_SAVED )

# Coloring output
# Standard feature to display colors on the terminal
if ( WIN32 OR TWX_SUMMARY_NO_COLOR )
  set ( twx-format-reset )
  set ( twx-format-key )
  set ( twx-format-value )
else ()
  # One character to reset format
  string ( ASCII 27 TWX_TWENTY_SEVEN )
  set ( twx-format-reset "${TWX_TWENTY_SEVEN}[m" )
  # This is a poor man map
  set (
    twx-format
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

# ANCHOR: twx_log_format
#[=======[
*//**
@brief Formatter

Enclose the input between appropriate formatting characters,
put the result in the variable pointed to by output.

@param format is one of the known formats
@param output for key `IN_VAR` is the variable name holding the result
@param ... for key `TEXT` is the list of texts to format

*/
twx_log_format( format IN_VAR output TEXT msg ) {}
/*
#]=======]
function ( twx_log_format format_ .IN_VAR var_ .TEXT msg_ )
  twx_arg_assert_count ( ${ARVC} == 5 )
  twx_arg_assert_keyword ( .IN_VAR .TEXT )
  twx_assert_variable_name ( "${var_}" )
  if ( "${format_}" STREQUAL "" )
    set( ${var_} "${msg_}" PARENT_SCOPE )
  else ()
    list ( FIND twx-format "${format_}" _i )
    if ( "${_i}" LESS "0" )
      twx_fatal ( "Unknown format ${format_}")
      return ()
    endif ()
    math ( EXPR _i "${_i}+1" )
    list ( GET twx-format "${_i}" _l )
    set ( _l "${TWX_TWENTY_SEVEN}[${_l}" )
    set ( ${var_} "${_l}${msg_}${twx-format-reset}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_log
#[=======[
*//**
@brief Print a message depending on a level.

@param format one of the known formats, optional
@param message some text
@param ... more messages
@param level is the log level, 0 to allways log, `+∞` to never log.
  `TWX_LOG_LEVEL_MAX` is the maximum value for display.
*/
twx_log ( [format] message ... [LEVEL level] ) {}
/**
@brief maximum value for display

Nothing is displayed if the given level is more than
`TWX_LOG_LEVEL_MAX`.
*/
TWX_LOG_LEVEL_MAX;
/*
#]=======]

if ( NOT DEFINED TWX_LOG_LEVEL_MAX )
  set ( TWX_LOG_LEVEL_MAX 0 )
endif ()

# `twx.R_ARGN` is a list variable.
# Empty `twx.R_ARGN` on `VERBOSE` mode.
# Parse the format, define shared variables
# `left` and `right`

# ANCHOR: __twx_summary_parse_arguments
# Private macro to parse the leading `<format>`
# and the trailing `VERBOSE`.
# Outputs twx.R_VERBOSE, twx.R_EOL
function ( __twx_summary_parse_arguments )
# nothing to show if the whole section is hidden

  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE;EOL" "" "" )
  if ( twx.R_VERBOSE  AND NOT TWX_VERBOSE )
    set ( twx.R_HIDE ON )
  endif ()
  set ( twx.R_ARGN "${twx.R_UNPARSED_ARGUMENTS}" )
  if ( NOT "${twx.R_ARGN}" STREQUAL "" )
    list ( GET twx.R_ARGN 0 twx.R_FORMAT )
    list ( FIND twx-format "${twx.R_FORMAT}" i )
    if ( "${_i}" LESS "0" )
      set ( twx.R_FORMAT )
    else ()
      list ( REMOVE_AT twx.R_ARGN 0 )
    endif ()
  endif ()
endfunction ()

# ANCHOR: __twx_summary_set_format
# Private macro to set the format
# __twx_summary_set_format ( format IN_VAR var )
# On return <var> is defined if the format is acceptable
# undefined otherwise.
function ( __twx_summary_set_format twx.R_FORMAT .IN_VAR twx.R_IN_VAR )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  twx_assert_undefined ( ARGN )
  list ( FIND twx-format "${twx.R_FORMAT}" i )
  if ( "${_i}" LESS "0" )
    unset ( ${twx.R_IN_VAR} PARENT_SCOPE )
  else ()
    set ( ${twx.R_IN_VAR} "${twx.R_FORMAT}" PARENT_SCOPE )
  endif ()
endfunction ( __twx_summary_set_format )

LEVEL

# ANCHOR: twx_log
function ( twx_log )
  if ( ${ARGC} EQUAL "0" )
    return ()
  endif ()
  __twx_summary_set_format ( "${ARG0}" IN_VAR twx.R_FORMAT )
  set ( i 0 )
  if ( DEFINED twx.R_FORMAT )
    set ( i 1 )
  endif ()
  cmake_parse_arguments ( PARSE_ARGV ${i} twx.R "VERBOSE;EOL" "" "" )
  if ( twx.R_VERBOSE  AND NOT TWX_VERBOSE )
    set ( twx.R_HIDE ON )
  else ()
    set ( twx.R_HIDE OFF )
  endif ()
  if ( twx.R_HIDE )
    # nothing to print
    message ( "" )
    return ()
  endif ()
  # Find the level
  if ( NOT "${twx.R_LEVEL}" GREATER "${TWX_LOG_LEVEL_MAX}" )
    set ( msg "[TWX]:${twx.R_UNPARSED_ARGUMENTS}" )
    if ( DEFINED twx.R_FORMAT )
      twx_log_format ( "${twx.R_FORMAT}" IN_VAR msg TEXT "${twx.R_UNPARSED_ARGUMENTS}" )
    endif ()
    message ( "${msg}" )
  endif ()
endfunction ( twx_log )

BROKEN
TWX_VERBOSE

# ANCHOR: twx_summary_log
#[=======[ `twx_summary_log`
*//**
@brief Basic logger

Other loggers depend on this one.

@param format is one of the knwon formats, optional
@param value optional text displayed on the right,
  with line break management
@param ... more optional values
@param `VERBOSE|DEBUG|TRACE` optional message log level.
*/
twx_summary_log( message value [format] [VERBOSE|DEBUG|TRACE] ) {}
/*
#]=======]
BROKEN twx_summary_log
function( twx_summary_log )
  if ( TWX_SUMMARY_section_hidden_l OR ${ARGC} EQUAL "0" )
    return ()
  endif ()
  set ( message_ "${ARGV0}" )
  set ( value_ "${ARGV1}" )
  __twx_summary_set_format ( "${ARG2}" IN_VAR twx.R_FORMAT )
  if ( DEFINED twx.R_FORMAT )
    if ( ${ARGC} EQUAL "4" )
      set ( twx.R_LEVEL "${ARGV3}" )
    elseif ( ${ARGC} GREATER "4" ) ()
      twx_fatal ( "Wrong number of arguments" )
      return ()
    endif ()
  elseif ( ${ARGC} EQUAL "3" )
    set ( twx.R_LEVEL "${ARGV2}" )
  elseif ( ${ARGC} GREATER "3" OR ${ARGC} LESS "2" ) ()
    twx_fatal ( "Wrong number of arguments" )
    return ()
  endif ()
  if ( twx.R_HIDE )
    message( "" )
    return ()
  endif ()
  set ( message_ "${message_}:" )
  if ( "${value_}" STREQUAL "" )
    if ( DEFINED twx.R_FORMAT )
      twx_log_format( ${twx.R_FORMAT} IN_VAR message_ TEXT "${message_}" )
    endif ()
    message ( "${TWX_SUMMARY_indentation}${message_}" )
    return ()
  endif ()
  # Hard wrap the remaining material.
  string ( LENGTH "${message_}" length_what_ )
  string ( LENGTH "${TWX_SUMMARY_indentation}" length_indent )
  math ( EXPR left_char "30 - ${length_what_} - ${length_indent}" )
  set ( blanks_ )
  foreach ( _i RANGE 1 ${left_char} )
    set ( blanks_ " ${blanks_}" )
    # string( APPEND blanks_ " " ) in modern cMake
  endforeach ()
  # wrap the value to just more than 80 characters
  set ( _prefix "${TWX_SUMMARY_indentation}${message_}${blanks_}" )
  # This is the prefix for the first line
  # for the next lines obtained by hard wrapping
  # this will be a blank string with the same length.
  string ( LENGTH "${_prefix}" _length )
  if ( DEFINED twx.R_FORMAT )
    twx_log_format( ${twx.R_FORMAT} IN_VAR _prefix TEXT "${_prefix}" )
  endif ()
  set ( blanks_ )
  foreach ( _i RANGE 1 ${_length} )
    set ( blanks_ " ${blanks_}" )
    # string( APPEND blanks_ " " ) in modern cMake
  endforeach()
  set ( _lines )
  foreach ( item ${value_} )
    set ( _line "${_line} ${item}" )
    string ( LENGTH "${_line}" _length )
    if    ( "${_length}" GREATER "50" )
      if ( DEFINED twx.R_FORMAT )
        twx_log_format( ${twx.R_FORMAT} IN_VAR _line TEXT "${_line}" )
      endif ()
      message ( "${_prefix}${_line}" )
      set ( _prefix "${blanks_}" )
      # `message_` and `_line` have been consumed,
      set ( message_ )
      set ( _line )
    endif ()
  endforeach ()
  # Everything consumed?
  if ( NOT "${_prefix}" STREQUAL "" OR NOT "${_line}" STREQUAL "" )
    if ( DEFINED twx.R_FORMAT AND NOT "${_line}" STREQUAL "" )
      twx_log_format( "${twx.R_FORMAT}" IN_VAR _line TEXT "${_line}" )
    endif ()
    message ( "${_prefix}${_line}" )
  endif ()
endfunction()

# ANCHOR: twx_summary_log_kv
#[=======[
*//**
@brief .....key:....value lines

@param format one of the known formats, optional
@param key some label
@param value is displayed as `yes` or `no` with `FLAG`,
  variable content with `VAR` and as is otherwise.
@param `VERBOSE` mode, when unset nothing is displayed except if
  `TWX_VERBOSE` is set.
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
  __twx_summary_set_format ( "${ARG0}" IN_VAR twx.R_FORMAT )
  if ( DEFINED twx.R_FORMAT )
    set ( i 1 )
  else ()
    set ( i 0 )
  endif ()
  cmake_parse_arguments (
    PARSE_ARG ${i} twx.R
    "VERBOSE;DEBUG;TRACE" "FLAG;VAR" ""
  )
  twx_arg_pass_option ( VERBOSE DEBUG TRACE )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    twx_assert_undefined ( twx.R_FLAG twx.R_VAR )
    set ( value "${twx.R_UNPARSED_ARGUMENTS}" )
  elseif ( DEFINED twx.R_FLAG )
    twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS twx.R_VAR )
    if ( ${${twx.R_FLAG}} )
      set ( value "yes" )
    else  ()
      set ( value "no" )
    endif ()
  elseif ( DEFINED twx.R_VAR )
    twx_assert_undefined ( twx.R_FLAG twx.R_UNPARSED_ARGUMENTS )
    set ( value "${${twx.R_VAR}}" )
  else ()
    message( "" )
    return ()
  endif ()
  twx_summary_log( "${key}" "${value}" ${twx.R_FORMAT} ${twx.R_VERBOSE}  ${twx.R_DEBUG}  ${twx.R_TRACE} )
endfunction( twx_summary_log_kv )
BROKEN twx_summary_log
# ANCHOR: twx_summary_begin
#[=======[
*/
/** @brief begin a new config section
  * 
  * Display the title and setup indentation.
  * Must be balanced by a `twx_summary_end()`.
  *
  *
  * @param format optional known format
  * @param title required
  * @param `VERBOSE` optional. When `VERBOSE` is provided, the whole section is hidden
  * unless `TWX_VERBOSE` is set.
  */
twx_summary_begin(format title VERBOSE) {}
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
set ( TWX_SUMMARY_stack )
function ( twx_summary_begin )
  twx_assert_compare ( 1 <= VAR ARGC <= 3 )
  __twx_summary_set_format ( "${ARG0}" IN_VAR twx.R_FORMAT )
  if ( DEFINED twx.R_FORMAT )
    set ( twx.R_TITLE "${ARGV1}" )
    twx_set_if_defined ( twx.R_LEVEL ARGV2 )
  else ()
    set ( twx.R_TITLE "${ARGV0}" )
    twx_set_if_defined ( twx.R_LEVEL ARGV1 )
  endif ()

  # Is this section hidden?
  __twx_summary_parse_arguments ( ${ARGN} )
  if ( twx.R_HIDE )
    set ( TWX_SUMMARY_section_hidden_l ON )
  endif ()
  if ( TWX_SUMMARY_section_hidden_l )
    list ( INSERT TWX_SUMMARY_stack 0 "-" )
  elseif ( TWX_SUMMARY_stack )
    # Propagate the visibility state: duplicate and insert.
    list ( GET TWX_SUMMARY_stack 0 _previous )
    list ( INSERT TWX_SUMMARY_stack 0 "${_previous}" )
  else  ()
    list( INSERT TWX_SUMMARY_stack 0 "+" )
  endif ()
  # export the main values
  twx_export ( TWX_SUMMARY_stack )
  twx_export ( TWX_SUMMARY_section_hidden_l )
  if ( NOT TWX_SUMMARY_section_hidden_l )
    set ( msg "${TWX_SUMMARY_indentation}${twx.R_ARGN}" )
    if ( twx.R_FORMAT )
      twx_log_format ( "${twx.R_FORMAT}" IN_VAR msg TEXT "${msg}" )
    endif ()
    message ( "${msg}" )
  endif ()
  # build the indentation from scratch
  set ( TWX_SUMMARY_indentation )
  foreach   ( _ IN LISTS TWX_SUMMARY_stack )
    set ( TWX_SUMMARY_indentation "  ${TWX_SUMMARY_indentation}" )
  endforeach ()
  set ( TWX_SUMMARY_indentation "${TWX_SUMMARY_indentation}" PARENT_SCOPE )
  if ( twx.R_EOL )
    message ( "" )
  endif ()
endfunction ()

# ANCHOR: twx_summary_end
#[=======[
*//**
@brief Balance a `twx_summary_begin`

End a config section, setup indentation and associate variables.
Must balance a previous `twx_summary_begin` in the same scope.

@param `NO_EOL` optional key to remove an extra EOL
*/
twx_summary_end( NO_EOL ) {}
/*
#]=======]
macro ( twx_summary_end )
  set ( TWX_break_l ON )
  if    ( "${ARGN}" STREQUAL "NO_EOL" )
    set ( TWX_break_l OFF )
  endif ()
  if ( TWX_break_l AND NOT TWX_SUMMARY_section_hidden_l )
    message( "" )
  endif ()
  set( TWX_SUMMARY_indentation )
  if ( TWX_SUMMARY_stack )
    list( REMOVE_AT TWX_SUMMARY_stack 0 )
    if    ( TWX_SUMMARY_stack )
      list( GET TWX_SUMMARY_stack 0 TWX_l )
      if    ( "${TWX_l}" STREQUAL "-" )
        set( TWX_SUMMARY_section_hidden_l ON )
      else  ()
        set ( TWX_SUMMARY_section_hidden_l OFF )
      endif ()
      foreach   ( TWX_l IN LISTS TWX_SUMMARY_stack )
        set ( TWX_SUMMARY_indentation "  ${TWX_SUMMARY_indentation}" )
      endforeach()
      unset ( TWX_l )
    else  ()
      set ( TWX_SUMMARY_section_hidden_l OFF )
    endif ()
    list ( LENGTH TWX_SUMMARY_stack TWX_l )
    twx_log( ">>> HIDDEN: ${TWX_SUMMARY_section_hidden_l}, DEPTH: ${TWX_l}" LEVEL 1000 )
    unset ( TWX_l )
  else ()
    twx_log( "Unexpected command `twx_summary_end`.\n" )
  endif ()
  unset( TWX_break_l )
endmacro ( twx_summary_end )

# ANCHOR: __twx_summary_common_ancestor
# problem if the arguments are not canonical paths
# @param `VAR_ANCESTOR` to collect the common ancestor
function ( __twx_summary_common_ancestor )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "VAR_ANCESTOR;VAR_RELATIVE" "" )
  set ( ${twx.R_VAR_ANCESTOR} )
  set ( ${twx.R_VAR_RELATIVE} "${twx.R_UNPARSED_ARGUMENTS}" )
  if ( NOT NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_export ( ${twx.R_VAR_ANCESTOR} )
    twx_export ( ${twx.R_VAR_RELATIVE} )
    return ()
  endif ()
  list ( GET twx.R_UNPARSED_ARGUMENTS 0 ref_ )
  while ( "${ref_}" MATCHES "^([^/]*/)(.+)$" )
    set ( common_ "${CMAKE_MATCH_1}" )
    set ( ref_ "${CMAKE_MATCH_2}" )
    set ( new_ )
    foreach ( x_ ${${twx.R_VAR_RELATIVE}} )
      if ( "${x_}" MATCHES "^${common_}(.+)$" )
        list ( APPEND new_ "${CMAKE_MATCH_1}" )
      else ()
        twx_export (
          ${twx.R_VAR_RELATIVE}
          ${twx.R_VAR_ANCESTOR}
        )
        return ()
      endif ()
    endforeach ( x_ )
    set ( ${twx.R_VAR_ANCESTOR} "${${twx.R_VAR_ANCESTOR}}${common_}" )
    set ( ${twx.R_VAR_RELATIVE} "${new_}" )
  endwhile ()
  twx_export (
    ${twx.R_VAR_RELATIVE}
    ${twx.R_VAR_ANCESTOR}
  )
endfunction ( __twx_summary_common_ancestor )

# SECTION: sections
# ANCHOR: twx_summary_section_compiler
#[=======[
*/
/** @brief Log target compiler info
  *
  * @param ... are target names.
  */
twx_summary_section_compiler( target ) {}
/*
#]=======]
function ( twx_summary_section_compiler )
  twx_summary_begin ( BOLD_MAGENTA "Compiler" ${twx.R_VERBOSE} )
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
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE" "" "" )
  twx_arg_pass_option ( VERBOSE )
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
    twx_summary_begin ( BOLD_BLUE "${target_} build settings" ${twx.R_VERBOSE} )
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
        __twx_summary_common_ancestor (
          VAR_ANCESTOR dir_
          VAR_RELATIVE rel_
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
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE" "" "" )
  twx_arg_pass_option ( VERBOSE )
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
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE" "" "" )
  twx_arg_pass_option ( VERBOSE )
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET "${target_}" )
      string ( PREPEND target_ "Twx" )
      if ( NOT TARGET "${target_}" )
        message ( WARNING "Unknown target: ${target_}" )
        continue( )
      endif ()
    endif ()
    twx_summary_begin ( BOLD_BLUE "${target_} directories" VERBOSE ${twx.R_VERBOSE} )
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
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE" "" "" )
  twx_arg_pass_option ( VERBOSE )
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
      twx_message ( VERBOSE "No SOURCES in target: ${target_}" )
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
      if ( "${f_}" MATCHES "/TwxBuild/" )
        list ( APPEND built_ "${f_}" )
      else ()
        list ( APPEND raw_ "${f_}" )
      endif ()
    endforeach ()
    __twx_summary_common_ancestor (
      VAR_ANCESTOR built_dir_
      VAR_RELATIVE built_rel_
      ${built_}
    )
    __twx_summary_common_ancestor (
      VAR_ANCESTOR raw_dir_
      VAR_RELATIVE raw_rel_
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
      elseif ( "${n_}" MATCHES "[.](c|m)" )
        list ( APPEND SOURCES_ "${n_}" )
      elseif ( "${n_}" MATCHES "[.]h" )
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
  set ( CMAKE_MESSAGE_LOG_LEVEL NOTICE )
  include ( TwxCfgLib )
  twx_cfg_setup ()
  twx_cfg_update_git ()
  twx_summary_begin ( BOLD_MAGENTA "Git info" )
  twx_summary_log ( "Hash"    "${TWX_CFG_GIT_HASH}" )
  twx_summary_log ( "Date"    "${TWX_CFG_GIT_DATE}" )
  twx_summary_log ( "Branch"  "${TWX_CFG_GIT_BRANCH}" )
  twx_summary_end ()
endfunction ()

#*/
