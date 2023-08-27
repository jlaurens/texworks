#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Collection of messaging utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxMessageLib.cmake"
  )

Included in `TwxBaseLib`.
*/
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

if ( NOT CMAKE_SCRIPT_MODE_FILE )
  add_custom_target (
    TwxMessageLib.cmake
  )
  define_property (
    TARGET PROPERTY TWX_MESSAGE_PRETTIFIERS
  )
endif ()

if ( NOT CMAKE_SCRIPT_MODE_FILE )
# ANCHOR: twx_message_register_prettifier
#[=======[*/
/** @brief Register a prettyfier
  *
  * Global domain.
  *
  * @param ... is a non void list of <id>s,
  *   where each <id>_prettify must be a known command.
  */
twx_message_register_prettifier( id ... ) {}
/*#]=======]
function ( twx_message_register_prettifier .id )
  get_target_property(
    prettifiers_
    TwxMessageLib.cmake
    TWX_MESSAGE_PRETTIFIERS
  )
  if ( "${prettifiers_}" MATCHES "-NOTFOUND" )
    set ( prettifiers_ )
  endif ()
  set ( i 0 )
  while ( TRUE )
    set ( c "${ARGV${i}}_prettify" )
    twx_assert_command ( "${c}" )
    list ( REMOVE_ITEM prettifiers_ "${c}" )
    list ( APPEND prettifiers_ "${c}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  set_target_properties (
    TwxMessageLib.cmake
    PROPERTIES
      TWX_MESSAGE_PRETTIFIERS "${prettifiers_}"
  )
endfunction ()

# ANCHOR: twx_message_unregister_prettifier
#[=======[*/
/** @brief Unregister a prettyfier
  *
  * @param ... is a non void list of <id>s,
  *   where each <id>_prettify must be a known command.
  */
twx_message_unregister_prettifier( id ... ) {}
/*#]=======]
function ( twx_message_unregister_prettifier .id )
  get_target_property(
    prettifiers_
    TwxMessageLib.cmake
    TWX_MESSAGE_PRETTIFIERS
  )
  if ( "${prettifiers_}" MATCHES "-NOTFOUND" )
    set ( prettifiers_ )
  endif ()
  set ( i 0 )
  while ( TRUE )
    set ( c "${ARGV${i}}_prettify" )
    list ( REMOVE_ITEM prettifiers_ "${c}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  set_target_properties (
    TwxMessageLib.cmake
    PROPERTIES
      TWX_MESSAGE_PRETTIFIERS "${prettifiers_}"
  )
endfunction ()
endif ()

# ANCHOR: twx_message_prettify
#[=======[*/
/** @brief Prettify the messages
  *
  * @param ..., a non empy list of text messages
  * @param var for key `IN_VAR`, holds the prettified message on return.
  * @param NO_SHORT, flag to disable short replacement.
  */
twx_message_prettify( ... IN_VAR var [NO_SHORT] ) {}
/*#]=======]
function ( twx_message_prettify .text .IN_VAR .var )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "NO_SHORT" "IN_VAR" "" )
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  set ( m )
  set ( i 0 )
  while ( TRUE )
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      if ( twx.R_NO_SHORT )
        twx_increment ( VAR i STEP 3 )
      else ()
        twx_increment ( VAR i STEP 2 )
      endif ()
      twx_arg_assert_count ( ${ARGC} == ${i} )
      break ()
    endif ()
    if ( "${ARGV${i}}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  # if ( NOT twx.R_NO_SHORT )
  #   string ( REPLACE "${CMAKE_SOURCE_DIR}" "<source dir>" m "${m}" )
  #   string ( REPLACE "${CMAKE_BINARY_DIR}" "<binary dir>" m "${m}" )
  #   string ( REPLACE "${TWX_DIR}" "<root dir>/" m "${m}" )
  # endif ()
  if ( NOT CMAKE_SCRIPT_MODE_FILE )
    get_target_property (
      prettifiers_
      TwxMessageLib.cmake
      TWX_MESSAGE_PRETTIFIERS
    )
    if ( "${prettifiers_}" MATCHES "-NOTFOUND" )
      set ( prettifiers_ )
    endif ()
    foreach ( prettifier ${prettifiers_} )
      # message ( TR@CE "Prettifier: ``${prettifier}''")
      cmake_language ( CALL "${prettifier}" "${m}" IN_VAR m )
    endforeach ()
    # message ( TR@CE "``${m}'' => ${twx.R_IN_VAR}")
  endif ()
  set ( ${twx.R_IN_VAR} "${m}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_message_log
#[=======[*/
/** @brief Log prettified message
  *
  * @param ... same arguments as `message()` except.
  * @param var for key `IN_VAR`, optional variable holding the message on return.
  * Mainly a testing facility.
  * @param DEEPER optional flag to add an indentation level.
  * @param NO_SHORT optional flag to disallow path shortcuts.
  */
twx_message_log(...) {}
/*#]=======]
function ( twx_message_log )
  if ( ARGC EQUAL "0" )
    message ()
    return()
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${ARGV0}" ARGV0_i )
  if ( "${ARGV0_i}" GREATER "-1" )
    set ( i 1 )
    set ( mode_ "${ARGV0}" )
  else ()
    set ( i 0 )
    unset ( mode_ )
  endif ()
  set ( m )
  set ( twx.R_IN_VAR )
  set ( twx.R_DEEPER OFF )
  set ( twx.R_NO_SHORT OFF )
  set ( ARGV${ARGC} )
  while ( TRUE )
    if ( "${i}" GREATER_EQUAL ${ARGC} )
      break()
    endif ()
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      twx_increment ( VAR i )
      set ( twx.R_IN_VAR "${ARGV${i}}" )
      twx_var_assert_name ( "${twx.R_IN_VAR}" )
      twx_increment ( VAR i )
      if ( "${i}" GREATER_EQUAL ${ARGC} )
        break ()
      endif ()
    endif ()
    if ( "${ARGV${i}}" STREQUAL "DEEPER" )
      set ( twx.R_DEEPER ON )
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
    endif ()
    if ( "${ARGV${i}}" STREQUAL "NO_SHORT" )
      twx_increment_and_assert ( VAR i == ${ARGC} )
      set ( twx.R_NO_SHORT ON )
      break ()
    endif ()
    if ( "${ARGV${i}}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    twx_increment_and_break_if( VAR i >= ${ARGC} )
  endwhile ()
  twx_arg_pass_option ( NO_SHORT )
  twx_message_prettify ( "${m}" IN_VAR m ${twx.R_NO_SHORT} )
  if ( DEFINED twx.R_IN_VAR )
    twx_var_assert_name ( "${twx.R_IN_VAR}" )
    list ( APPEND ${twx.R_IN_VAR} "${m}" )
    twx_export ( "${twx.R_IN_VAR}" )
  else ()
    foreach ( msg_ ${m} )
      message ( ${mode_} "${msg_}" )
    endforeach ()
  endif ()
  if ( twx.R_DEEPER )
    set ( CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}  " PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_message
#[=======[*/
/** @brief Log prettified message
  *
  * @param ... same arguments as `message()` except.
  * @param var for key `IN_VAR`, optional variable holding the message on return.
  *   Mainly a testing facility.
  * @param DEEPER optional flag to add an indentation level.
  * @param NO_SHORT optional flag to disallow path shortcuts.
  */
twx_message_log(...) {}
/*#]=======]
function ( twx_message_log )
  if ( ARGC EQUAL "0" )
    message ()
    return()
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${ARGV0}" ARGV0_i )
  if ( "${ARGV0_i}" GREATER "-1" )
    set ( i 1 )
    set ( mode_ "${ARGV0}" )
  else ()
    set ( i 0 )
    unset ( mode_ )
  endif ()
  set ( m )
  set ( twx.R_IN_VAR )
  set ( twx.R_DEEPER OFF )
  set ( twx.R_NO_SHORT OFF )
  set ( ARGV${ARGC} )
  while ( TRUE )
    if ( "${i}" GREATER_EQUAL ${ARGC} )
      break()
    endif ()
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      twx_increment ( VAR i )
      set ( twx.R_IN_VAR "${ARGV${i}}" )
      twx_var_assert_name ( "${twx.R_IN_VAR}" )
      twx_increment ( VAR i )
      if ( "${i}" GREATER_EQUAL ${ARGC} )
        break ()
      endif ()
    endif ()
    if ( "${ARGV${i}}" STREQUAL "DEEPER" )
      set ( twx.R_DEEPER ON )
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
    endif ()
    if ( "${ARGV${i}}" STREQUAL "NO_SHORT" )
      twx_increment_and_assert ( VAR i == ${ARGC} )
      set ( twx.R_NO_SHORT ON )
      break ()
    endif ()
    if ( "${ARGV${i}}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    twx_increment_and_break_if( VAR i >= ${ARGC} )
  endwhile ()
  twx_arg_pass_option ( NO_SHORT )
  twx_message_prettify ( "${m}" IN_VAR m ${twx.R_NO_SHORT} )
  if ( DEFINED twx.R_IN_VAR )
    twx_var_assert_name ( "${twx.R_IN_VAR}" )
    list ( APPEND ${twx.R_IN_VAR} "${m}" )
    twx_export ( "${twx.R_IN_VAR}" )
  else ()
    foreach ( msg_ ${m} )
      message ( ${mode_} "${msg_}" )
    endforeach ()
  endif ()
  if ( twx.R_DEEPER )
    set ( CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}  " PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_message_newline
#[=======[*/
/** @brief Insert a line separator
  *
  */
twx_message_newline() {}
/*#]=======]
function ( twx_message_newline )
  twx_arg_assert_count ( ${ARGC} == 0 )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  message ( "" )
endfunction ()

twx_lib_require ( "Fatal" "Assert" "Arg" "Increment" "Export" "Math" )

twx_lib_did_load ()

#*/