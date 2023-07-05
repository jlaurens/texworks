#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Collection of messaging utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxMessageLib.cmake"
  )

Included in `TwxBaseLib`.
*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_message )
  return ()
endif ()
# This has already been included

set (
  TWX_MESSAGE_LOG_LEVELS
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

# ANCHOR: twx_message_log_level_order
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
twx_message_log_level_order( lhs <=> rhs IN_VAR var ) {}
/*#]=======]
function ( twx_message_log_level_order twxR_LHS .LEG twxR_RHS .IN_VAR twxR_VAR )
  twx_arg_expect_keyword ( .LEG "<=>" )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable ( "${twxR_VAR}" )
  if ( twxR_LHS STREQUAL "" )
    set ( twxR_LHS NOTICE )
  endif ()
  if ( twxR_RHS STREQUAL "" )
    set ( twxR_RHS NOTICE )
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${twxR_LHS}" lhs_ )
  if ( "${lhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twxR_LHS}" )
    return ()
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${twxR_RHS}" rhs_ )
  if ( "${rhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twxR_RHS}" )
    return ()
  endif ()
  if ( "${lhs_}" LESS "${rhs_}" )
    set ( ${twxR_VAR} -1 PARENT_SCOPE )
  elseif ( "${lhs_}" GREATER "${rhs_}" )
    set ( ${twxR_VAR} 1 PARENT_SCOPE )
  else ()
    set ( ${twxR_VAR} 0 PARENT_SCOPE )
  endif ()
endfunction ( twx_message_log_level_order )

# ANCHOR: twx_message_log_level_compare
#[=======[*/
/** @brief Compares log levels.
  *
  *
  * @param lhs, a level name, raises when not recognized
  * @param op, binary comparison operator, raises when not recognized
  * @param rhs, a level name, raises when not recognized
  * @param var for key `IN_VAR`, will hold the result
  * ON when the comparison holds, OFF otherwise.
  * (Quite the index of the characters in `<=>`)
  */
twx_message_log_level_compare( lhs op rhs IN_VAR var ) {}
/*#]=======]
function ( twx_message_log_level_compare twxR_LHS twxR_OP twxR_RHS .IN_VAR twxR_VAR )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable ( "${twxR_VAR}" )
  if ( twxR_LHS STREQUAL "" )
    set ( twxR_LHS NOTICE )
  endif ()
  if ( twxR_RHS STREQUAL "" )
    set ( twxR_RHS NOTICE )
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${twxR_LHS}" lhs_ )
  if ( "${lhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twxR_LHS}" )
    return ()
  endif ()
  list ( FIND TWX_MESSAGE_LOG_LEVELS "${twxR_RHS}" rhs_ )
  if ( "${rhs_}" LESS "0" )
    twx_fatal ( "Unknown message log level ${twxR_RHS}" )
    return ()
  endif ()
  twx_math ( EXPR ans "${lhs_}${twxR_OP}${rhs_}" )
  if ( ans )
    set ( ${twxR_VAR} ON PARENT_SCOPE )
  else ()
    set ( ${twxR_VAR} OFF PARENT_SCOPE )
  endif ()
endfunction ( twx_message_log_level_compare )

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
function ( twx_message_prettify text_ IN_VAR_ var_ )
  cmake_parse_arguments ( PARSE_ARGV 1 twxR "NO_SHORT" "IN_VAR" "" )
  twx_assert_variable ( "${twxR_IN_VAR}" )
  set ( m )
  set ( i 0 )
  while ( TRUE )
    if ( ARGV${i} STREQUAL "IN_VAR" )
      twx_increment ( i )
      twx_arg_assert_count ( ${ARGC} == ${i} )
      break ()
    endif ()
    if ( ARGV${i} MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  if ( NOT twxR_NO_SHORT )
    string ( REPLACE "${CMAKE_SOURCE_DIR}" "<source dir>" m "${m}" )
    string ( REPLACE "${CMAKE_BINARY_DIR}" "<binary dir>" m "${m}" )
    string ( REPLACE "${TWX_DIR}" "<root dir>/" m "${m}" )
  endif ()
  if ( COMMAND twx_tree_prettify )
    twx_tree_prettify ( "${m}" IN_VAR m )
  endif ()
  set ( ${twxR_IN_VAR} "${m}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_message
#[=======[*/
/** @brief Log prettified message
  *
  * @param ... same arguments as `message()` except.
  * @param var for key `IN_VAR`, optional variable holding the message on return.
  * Mainly a testing facility.
  * @param DEEPER optional flag to add an indentation level.
  * @param NO_SHORT optional flag to disallow path shortcuts.
  */
twx_message(...) {}
/*#]=======]
function ( twx_message )
  if ( NOT DEFINED ARGV0 )
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
  unset ( twxR_IN_VAR )
  set ( twxR_DEEPER OFF )
  set ( twxR_NO_SHORT OFF )
  unset ( ARGV${ARGC} )
  while ( TRUE )
    if ( NOT DEFINED ARGV${i} )
      break()
    endif ()
    if ( ARGV${i} STREQUAL "IN_VAR" )
      twx_increment ( VAR i )
      set ( twxR_IN_VAR "${ARGV${i}}" )
      twx_assert_variable ( "${twxR_IN_VAR}" )
      twx_increment ( VAR i )
      if ( NOT DEFINED ARGV${i} )
        break ()
      endif ()
    endif ()
    if ( ARGV${i} STREQUAL "DEEPER" )
      set ( twxR_DEEPER ON )
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
    endif ()
    if ( ARGV${i} STREQUAL "NO_SHORT" )
      twx_increment_and_assert ( VAR i == ${ARGC} )
      set ( twxR_NO_SHORT ON )
      break ()
    endif ()
    if ( ARGV${i} MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    twx_increment_and_break_if( VAR i >= ${ARGC} )
  endwhile ()
  twx_arg_pass_option ( NO_SHORT )
  twx_message_prettify ( "${m}" IN_VAR m ${twxR_NO_SHORT} )
  if ( DEFINED twxR_IN_VAR )
    twx_assert_variable ( "${twxR_IN_VAR}" )
    list ( APPEND ${twxR_IN_VAR} "${msg_}" )
    twx_export ( "${twxR_IN_VAR}" )
  else ()
    foreach ( msg_ ${m} )
      message ( ${mode_} "${msg_}" )
    endforeach ()
  endif ()
  if ( twxR_DEEPER )
    set ( CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}  " PARENT_SCOPE )
  endif ()
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMathLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )

message ( VERBOSE "TwxMessageLib loaded" )

#*/
