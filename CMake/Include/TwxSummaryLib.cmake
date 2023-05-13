#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Coloring log output of the summaries.

This is not available on windows.

Known formats:
  `BOLD`, `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`,
  `BOLD_RED`, `BOLD_GREEN`, `BOLD_YELLOW`, `BOLD_BLUE`, `BOLD_MAGENTA`, `BOLD_CYAN`, `BOLD_WHITE`
*/
/**
@brief Verbosity

When set more information is displayed.
*/
TWX_VERBOSE;
/**
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

if ( DEFINED twx-format-reset )
  return ()
endif ()

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
@param output for key VAR is the variable name holding the result
@param ... for key TEXT is the list of texts to format

*/
twx_log_format( format VAR output TEXT ... ) {}
/*
#]=======]
function ( twx_log_format )
  twx_parse_arguments ( "" "VAR" "TEXT" ${ARGN} )
  if ( "${my_twx_VAR}" STREQUAL ""
    OR "${my_twx_TEXT}" STREQUAL "" )
    message ( FATAL_ERROR "Wrong parameters" )
  endif ()
  set ( format_ "${my_twx_UNPARSED_ARGUMENTS}" )
  if ( "${format_}" STREQUAL "" )
    set( ${my_twx_VAR} "${my_twx_TEXT}" )
  else ()
    list ( FIND twx-format "${format_}" _i )
    if    ( _i LESS 0 )
      message ( FATAL_ERROR "Unknown format ${format_}")
    endif ()
    math ( EXPR _i "${_i}+1" )
    list ( GET twx-format "${_i}" _l )
    set ( _l "${TWX_TWENTY_SEVEN}[${_l}" )
    set ( ${my_twx_VAR} "${_l}${my_twx_TEXT}${twx-format-reset}" )
  endif ()
  twx_export ( ${my_twx_VAR} )
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

# `my_twx_ARGN` is a list variable.
# Empty `my_twx_ARGN` on `VERBOSE` mode.
# Parse the format, define shared variables
# `left` and `right`

# ANCHOR: __twx_summary_parse_arguments
# Private macro to parse the leading `<format>`
# and the trailing `VERBOSE`.
# Outputs my_twx_VERBOSE, my_twx_HIDE, my_twx_ARGN
macro ( __twx_summary_parse_arguments )
# nothing to show if the whole section is hidden
  twx_parse_arguments ( "VERBOSE" "" "" ${ARGN} )
  if ( my_twx_VERBOSE  AND NOT TWX_VERBOSE )
    set ( my_twx_HIDE ON )
  endif ()
  set ( my_twx_ARGN "${my_twx_UNPARSED_ARGUMENTS}" )
  if ( NOT "${my_twx_ARGN}" STREQUAL "" )
    list ( GET my_twx_ARGN 0 my_twx_FORMAT )
    list ( FIND twx-format "${my_twx_FORMAT}" i )
    if ( i LESS 0 )
      set ( my_twx_FORMAT )
    else ()
      list ( REMOVE_AT my_twx_ARGN 0 )
    endif ()
  endif ()
endmacro ()

# ANCHOR: twx_log
function ( twx_log )
  __twx_summary_parse_arguments ( ${ARGN} )
  if ( my_twx_HIDE )
    # nothing to print
    message ( "" )
    return ()
  endif ()
  # Find the level
  twx_parse_arguments ( "" "LEVEL" "" ${my_twx_ARGN} )
  if ( "${my_twx_LEVEL}" STREQUAL "" )
    set ( my_twx_LEVEL 0 )
  endif ()
  if ( NOT my_twx_LEVEL GREATER TWX_LOG_LEVEL_MAX )
    set ( msg "[TWX]:${my_twx_UNPARSED_ARGUMENTS}" )
    if ( my_twx_FORMAT )
      twx_log_format ( "${my_twx_FORMAT}" VAR msg TEXT "${msg}" )
    endif ()
    message ( "${msg}" )
  endif ()
endfunction ()

option ( TWX_VERBOSE "Display more informations about the configuration" )
# NB: from the CLI use `cmake -DTWX_VERBOSE=ON ...`

# ANCHOR: twx_summary_log
#[=======[ `twx_summary_log`
*//**
@brief Basic logger

Other loggers depend on this one.

@param format is one of the knwon formats, optional
@param value optional text displayed on the right,
  with line break management
@param ... more optional values
@param VERBOSE optional key that disables logging when given,
  unless `TWX_VERBOSE` is set.
*/
twx_summary_log( [format] message value ... [VERBOSE] ) {}
/*
#]=======]
function( twx_summary_log )
  if ( TWX_SUMMARY_section_hidden_l )
    return ()
  endif ()
  __twx_summary_parse_arguments ( ${ARGN} )
  if ( my_twx_HIDE OR "${my_twx_ARGN}" STREQUAL "" )
    message( "" )
    return ()
  endif ()
  list ( GET my_twx_ARGN 0 what )
  set ( what "${what}:" )
  list ( REMOVE_AT my_twx_ARGN 0 )
  if    ( "${my_twx_ARGN}" STREQUAL "" )
    if ( my_twx_FORMAT )
      twx_log_format( ${my_twx_FORMAT} VAR what TEXT "${what}" )
    endif ()
    message ( "${TWX_SUMMARY_indentation}${what}" )
    return ()
  endif ()
  # Hard wrap the remain material.
  string ( LENGTH "${what}" length_what )
  string ( LENGTH "${TWX_SUMMARY_indentation}" length_indent )
  math ( EXPR left_char "30 - ${length_what} - ${length_indent}" )
  set ( blanks )
  foreach ( _i RANGE 1 ${left_char} )
    set ( blanks " ${blanks}" )
    # string( APPEND blanks " " ) in modern cMake
  endforeach ()
  # wrap the value to just more than 80 characters
  set ( _prefix "${TWX_SUMMARY_indentation}${what}${blanks}" )
  # This is the prefix for the first line
  # for the next lines obtained by hard wrapping
  # this will be a blank string with the same length.
  string ( LENGTH "${_prefix}" _length )
  if ( my_twx_FORMAT )
    twx_log_format( ${my_twx_FORMAT} VAR _prefix TEXT "${_prefix}" )
  endif ()
  set ( blanks )
  foreach ( _i RANGE 1 ${_length} )
    set ( blanks " ${blanks}" )
    # string( APPEND blanks " " ) in modern cMake
  endforeach()
  set ( _lines )
  foreach    ( item IN LISTS my_twx_ARGN )
    set ( _line "${_line} ${item}" )
    string ( LENGTH "${_line}" _length )
    if    ( _length GREATER 50 )
      if ( my_twx_FORMAT )
        twx_log_format( ${my_twx_FORMAT} VAR _line TEXT "${_line}" )
      endif ()
      message ( "${_prefix}${_line}" )
      set ( _prefix "${blanks}" )
      # `what` and `_line` have been consumed, 
      set ( what )
      set ( _line )
    endif ()
  endforeach ()
  # Everything consumed?
  if    ( what OR _line )
    if ( my_twx_FORMAT AND _line )
      twx_log_format( ${my_twx_FORMAT} VAR _line TEXT "${_line}" )
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
@param VERBOSE mode, nothing is displayed except if
  `TWX_VERBOSE` is set.
*/
twx_summary_log_kv ( [format] key [FLAG|VAR] value [VERBOSE] ) {}
/*
#]=======]
function( twx_summary_log_kv )
  if ( TWX_SUMMARY_section_hidden_l )
    return ()
  endif ()
  __twx_summary_parse_arguments ( ${ARGN} )
  twx_parse_arguments ( "" "FLAG;VAR" "" ${my_twx_ARGN} )
  set ( my_twx_ARGN "${my_twx_UNPARSED_ARGUMENTS}" )
  if ( my_twx_HIDE OR "${my_twx_ARGN}" STREQUAL "" )
    message( "" )
    return ()
  endif ()
  list ( GET my_twx_ARGN 0 key )
  list ( REMOVE_AT my_twx_ARGN 0 )
  if ( NOT "${my_twx_FLAG}" STREQUAL "" )
    if    ( ${${my_twx_FLAG}} )
      set ( value "yes" )
    else  ()
      set ( value "no" )
    endif ()
  elseif ( NOT "${my_twx_VAR}" STREQUAL "" )
    set ( value "${${my_twx_VAR}}" )
  else ()
    set ( value "${my_twx_ARGN}" )
  endif ()
  if ( my_twx_VERBOSE )
    set ( my_twx_VERBOSE VERBOSE )
  else ()
    set ( my_twx_VERBOSE )
  endif ()
  twx_summary_log( ${my_twx_FORMAT} "${key}" "${value}" ${my_twx_VERBOSE} )
  endfunction()

# ANCHOR: twx_summary_begin
#[=======[
*//**
@brief begin a new config section

Display the title and setup indentation.
Must be balanced by a `twx_summary_end()`.

.
@param format optional known format
@param title required
@param VERBOSE optional. When `VERBOSE` is provided, the whole section is hidden
unless `TWX_VERBOSE` is set.
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
  # Is this section hidden?
  __twx_summary_parse_arguments ( ${ARGN} )
  if ( my_twx_HIDE )
    set ( TWX_SUMMARY_section_hidden_l on )
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
    set ( msg "${TWX_SUMMARY_indentation}${my_twx_ARGN}" )
    if ( my_twx_FORMAT )
      twx_log_format ( "${my_twx_FORMAT}" VAR msg TEXT "${msg}" )
    endif ()
    message ( "${msg}" )
  endif ()
  # build the indentation from scratch
  set ( TWX_SUMMARY_indentation )
  foreach   ( _ IN LISTS TWX_SUMMARY_stack )
    set ( TWX_SUMMARY_indentation "  ${TWX_SUMMARY_indentation}" )
  endforeach()
  set ( TWX_SUMMARY_indentation "${TWX_SUMMARY_indentation}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_summary_end
#[=======[
*//**
@brief Balance a `twx_summary_begin`

End a config section, setup indentation and associate variables.
Must balance a previous `twx_summary_begin` in the same scope.

@param NO_EOL optional key to remove an extra EOL
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
endmacro ()

# ANCHOR: __twx_summary_common_ancestor
# problem if the arguments are not canonical paths
function ( __twx_summary_common_ancestor ancestor_ relative_ )
  set ( ${ancestor_} )
  set ( ${relative_} "${ARGN}" )
  if ( "${ARGN}" STREQUAL "" )
    twx_export ( ${ancestor_} )
    twx_export ( ${relative_} )
    return ()
  endif ()
  list ( GET ARGN 0 ref_ )
  while ( "${ref_}" MATCHES "^([^/]*/)(.+)$" )
    set ( common_ "${CMAKE_MATCH_1}" )
    set ( ref_ "${CMAKE_MATCH_2}" )
    set ( new_ )
    foreach ( x_ ${${relative_}} )
      if ( "${x_}" MATCHES "^${common_}(.+)$" )
        list ( APPEND new_ "${CMAKE_MATCH_1}" )
      else ()
        twx_export ( ${relative_} ${ancestor_} )
        return ()
      endif ()  
    endforeach ()
    set ( ${ancestor_} "${${ancestor_}}${common_}" )
    set ( ${relative_} "${new_}" )
  endwhile ()
  twx_export ( ${relative_} ${ancestor_} )
endfunction ()

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
  twx_parse_arguments ( "VERBOSE" "" "" ${ARGN} )
  if ( my_twx_VERBOSE )
    set ( my_twx_VERBOSE VERBOSE )
  else ()
    set ( my_twx_VERBOSE )
  endif ()
  foreach ( target_ ${my_twx_UNPARSED_ARGUMENTS} )
    if ( NOT TARGET "${target_}" )
      message ( WARNING "Unknown target: ${target_}" )
      continue( )
    endif ()
    get_target_property (
      files_
      ${target_}
      SOURCES
    )
    if ( files_ MATCHES "NOTFOUND" )
      continue ()
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
    __twx_summary_common_ancestor ( built_dir_ built_rel_ ${built_} )
    __twx_summary_common_ancestor ( raw_dir_   raw_rel_   ${raw_} )
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
    twx_summary_begin ( BOLD_BLUE "${target_} files" ${my_twx_VERBOSE} )
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
  endforeach ()
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
  twx_parse_arguments ( "VERBOSE" "" "" ${ARGN} )
  if ( my_twx_VERBOSE )
    set ( my_twx_VERBOSE VERBOSE )
  else ()
    set ( my_twx_VERBOSE )
  endif ()
  foreach ( target_ IN LISTS my_twx_UNPARSED_ARGUMENTS )
    if ( TARGET ${target_} )
      foreach ( t_ IN ITEMS OPTIONS DEFINITIONS )
        get_target_property (
          ${t_}_
          ${target_}
          COMPILE_${t_}
        )
      endforeach ()
      if ( "${OPTIONS_}" MATCHES "NOTFOUND"
      AND "${DEFINITIONS_}" MATCHES "NOTFOUND")
        continue ()
      endif ()
      twx_summary_begin ( BOLD_BLUE "${target_} build settings" ${my_twx_VERBOSE} )
      if ( NOT "${OPTIONS_}" MATCHES "NOTFOUND" )
        # TODO: include the test in twx_summary_log_kv
        twx_summary_log_kv ( "Compile options" VAR OPTIONS_ )
      endif ()
      if ( NOT "${DEFINITIONS_}" MATCHES "NOTFOUND" )
        twx_summary_log_kv ( "Compile definitions" VAR DEFINITIONS_ )
      endif ()
      twx_summary_end ()
    else ()
      message ( FATAL_ERROR "Unknown target ${target_}" )
    endif ()
  endforeach ()
endfunction ()

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
  twx_parse_arguments ( "VERBOSE" "" "" ${ARGN} )
  if ( my_twx_VERBOSE )
    set ( my_twx_VERBOSE VERBOSE )
  else ()
    set ( my_twx_VERBOSE )
  endif ()
  foreach ( target_ IN LISTS my_twx_UNPARSED_ARGUMENTS )
    if ( TARGET ${target_} )
      get_target_property (
        libraries_
        ${target_}
        LINK_LIBRARIES
      )
      if ( NOT "${libraries_}" MATCHES "NOTFOUND" )
        #
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
        twx_summary_begin ( BOLD_BLUE "${target_} libraries" ${my_twx_VERBOSE} )
          if ( NOT "${Qt_libraries_}" STREQUAL "" )
            twx_summary_log_kv ( "${QtMAJOR} libraries" VAR Qt_libraries_ )
          endif ()
          if ( NOT "${Twx_libraries_}" STREQUAL "" )
            twx_summary_log_kv ( "Twx modules" VAR Twx_libraries_ )
          endif ()
          if ( NOT "${Other_libraries_}" STREQUAL "" )
            twx_summary_log_kv ( "Other libraries" VAR Other_libraries_ )
          endif ()
        twx_summary_end ()
      endif ()
    else ()
      message ( FATAL_ERROR "Unknown target ${target_}" )
    endif ()
  endforeach ()
endfunction ()

# ANCHOR: twx_summary_section_git
#[=======[
*/
/** @brief Log git status */
twx_summary_section_git() {}
/*
#]=======]
function ( twx_summary_section_git )
  set ( TWX_VERBOSE OFF )
  include ( TwxCfgLib )
  twx_cfg_setup ()
  twx_summary_begin ( BOLD_MAGENTA "Git info" )
  twx_summary_log ( "Hash" "${TWX_CFG_GIT_HASH}" )
  twx_summary_log ( "Date" "${TWX_CFG_GIT_DATE}" )
  twx_summary_log ( "Branch" "${TWX_CFG_GIT_BRANCH}" )
  twx_summary_end ()
endfunction ()


#*/
