#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Collection of messaging utilities
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxMessageLib.cmake"
  *   )
  *
  * Included in `TwxBase`.
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

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
  twx_global_get ( KEY /TWX/MESSAGE/PRETTIFIERS IN_VAR prettifiers_ )
  set ( i 0 )
  while ( TRUE )
    set ( c "${ARGV${i}}_prettify" )
    twx_assert_command ( "${c}" )
    list ( REMOVE_ITEM prettifiers_ "${c}" )
    list ( APPEND prettifiers_ "${c}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_global_set ( "${prettifiers_}" KEY /TWX/MESSAGE/PRETTIFIERS )
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
  twx_global_get ( KEY /TWX/MESSAGE/PRETTIFIERS IN_VAR prettifiers_ )
  set ( i 0 )
  while ( TRUE )
    set ( c "${ARGV${i}}_prettify" )
    list ( REMOVE_ITEM prettifiers_ "${c}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_global_set ( "${prettifiers_}" KEY /TWX/MESSAGE/PRETTIFIERS )
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
function ( twx_message_prettify twx_message_prettify.text twx_message_prettify.IN_VAR twx_message_prettify.var )
  cmake_parse_arguments (
    PARSE_ARGV 1 twx_message_prettify.R
    "NO_SHORT" "IN_VAR" ""
  )
  twx_var_assert_name ( "${twx_message_prettify.R_IN_VAR}" )
  set ( twx_message_prettify.M )
  set ( twx_message_prettify.I 0 )
  while ( TRUE )
    if ( "${ARGV${twx_message_prettify.I}}" STREQUAL "IN_VAR" )
      twx_increment ( VAR twx_message_prettify.I STEP 1 )
    elseif ( "${ARGV${twx_message_prettify.I}}" STREQUAL "NO_SHORT" )
    elseif ( "${ARGV${twx_message_prettify.I}}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND twx_message_prettify.M "${ARGV${twx_message_prettify.I}}\\" )
    else ()
      list ( APPEND twx_message_prettify.M "${ARGV${twx_message_prettify.I}}" )
    endif ()
    twx_increment_and_break_if ( VAR twx_message_prettify.I >= ${ARGC} )
  endwhile ()
  # if ( NOT twx_message_prettify.R_NO_SHORT )
  #   string ( REPLACE "${CMAKE_SOURCE_DIR}" "<source dir>" m "${m}" )
  #   string ( REPLACE "${CMAKE_BINARY_DIR}" "<binary dir>" m "${m}" )
  #   string ( REPLACE "${TWX_DIR}" "<root dir>/" m "${m}" )
  # endif ()
  twx_global_get (
    KEY /TWX/MESSAGE/PRETTIFIERS
    IN_VAR twx_message_prettify.PRETTIFIERS
  )
  foreach ( twx_message_prettify.P ${twx_message_prettify.PRETTIFIERS} )
    # message ( TR@CE "Prettifier: ``${prettifier}''")
    cmake_language ( 
      CALL "${twx_message_prettify.P}"
        "${twx_message_prettify.M}"
        IN_VAR twx_message_prettify.M
    )
  endforeach ()
  twx_export ( "${twx_message_prettify.R_IN_VAR}=${twx_message_prettify.M}" )
endfunction ()

# ANCHOR: twx_message_log
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
  if ( ARGV0 IN_LIST /TWX/CONST/MESSAGE/MODES )
    set ( twx_message_log.I 1 )
    set ( twx_message_log.MODE "${ARGV0}" )
  else ()
    set ( twx_message_log.I 0 )
    unset ( twx_message_log.MODE )
  endif ()
  set ( twx_message_log.MSG )
  set ( twx_message_log.R_IN_VAR )
  set ( twx_message_log.R_DEEPER OFF )
  set ( twx_message_log.R_NO_SHORT OFF )
  set ( ARGV${ARGC} )
  while ( TRUE )
    if ( "${twx_message_log.I}" GREATER_EQUAL ${ARGC} )
      break()
    endif ()
    if ( "${ARGV${twx_message_log.I}}" STREQUAL "IN_VAR" )
      twx_increment ( VAR twx_message_log.I )
      set ( twx_message_log.R_IN_VAR "${ARGV${twx_message_log.I}}" )
      twx_var_assert_name ( "${twx_message_log.R_IN_VAR}" )
      twx_increment ( VAR twx_message_log.I )
      if ( "${twx_message_log.I}" GREATER_EQUAL ${ARGC} )
        break ()
      endif ()
    endif ()
    if ( "${ARGV${twx_message_log.I}}" STREQUAL "DEEPER" )
      set ( twx_message_log.R_DEEPER ON )
      twx_increment_and_break_if ( VAR twx_message_log.I >= ${ARGC} )
    endif ()
    if ( "${ARGV${twx_message_log.I}}" STREQUAL "NO_SHORT" )
      twx_increment_and_assert ( VAR twx_message_log.I == ${ARGC} )
      set ( twx_message_log.R_NO_SHORT ON )
      break ()
    endif ()
    if ( "${ARGV${twx_message_log.I}}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND twx_message_log.MSG "${ARGV${twx_message_log.I}}\\" )
    else ()
      list ( APPEND twx_message_log.MSG "${ARGV${twx_message_log.I}}" )
    endif ()
    twx_increment_and_break_if( VAR twx_message_log.I >= ${ARGC} )
  endwhile ()
  twx_arg_pass_option ( NO_SHORT )
  twx_message_prettify ( "${twx_message_log.MSG}" IN_VAR twx_message_log.MSG ${twx_message_log.R_NO_SHORT} )
  if ( DEFINED twx_message_log.R_IN_VAR )
    twx_var_assert_name ( "${twx_message_log.R_IN_VAR}" )
    list ( APPEND ${twx_message_log.R_IN_VAR} "${twx_message_log.MSG}" )
    twx_export ( "${twx_message_log.R_IN_VAR}" )
  else ()
    foreach ( m ${twx_message_log.MSG} )
      message ( ${twx_message_log.MODE} "${m}" )
    endforeach ()
  endif ()
  if ( twx_message_log.R_DEEPER )
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

# ANCHOR: twx_message_mode_index
#[=======[*/
/** @brief Get the message mode as an index
  *
  */
twx_message_mode_index(IN_VAR index) {}
/*#]=======]
function ( twx_message_mode_index )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_message_mode_index.R
    "" "IN_VAR" ""
  )
  twx_var_assert_name ( "${twx_message_mode_index.R_IN_VAR}" )
  list (
    FIND /TWX/CONST/MESSAGE/MODES
    "${twx_message_mode_index.R_UNPARSED_ARGUMENTS}"
    ${twx_message_mode_index.R_IN_VAR}
  )
  return ( PROPAGATE ${twx_message_mode_index.R_IN_VAR} )
endfunction ()

# ANCHOR: twx_message_mode_order
#[=======[*/
/** @brief Compare the modes
  *
  */
twx_message_mode_order( left `<=>` right IN_VAR ans) {}
/*#]=======]
function ( twx_message_mode_order twx_message_mode_order.R_LEFT twx_message_mode_order.R_BIN twx_message_mode_order.R_RIGHT )
  cmake_parse_arguments (
    PARSE_ARGV 3 twx_message_mode_order.R
    "" "IN_VAR" ""
  )
  twx_var_assert_name ( "${twx_message_mode_order.R_IN_VAR}" )
  twx_arg_assert_parsed ()
  twx_arg_expect_keyword ( twx_message_mode_order.R_BIN "<=>" )
  list (
    FIND /TWX/CONST/MESSAGE/MODES
    "${twx_message_mode_order.R_LEFT}"
    twx_message_mode_order.LEFT
  )
  list (
    FIND /TWX/CONST/MESSAGE/MODES
    "${twx_message_mode_order.R_RIGHT}"
    twx_message_mode_order.RIGHT
  )
  if ( twx_message_mode_order.LEFT LESS 0 )
    set ( ${twx_message_mode_order.R_IN_VAR} PARENT_SCOPE )
  elseif ( twx_message_mode_order.RIGHT LESS 0 )
    set ( ${twx_message_mode_order.R_IN_VAR} PARENT_SCOPE )
  elseif ( twx_message_mode_order.LEFT LESS twx_message_mode_order.RIGHT )
    set ( ${twx_message_mode_order.R_IN_VAR} -1 PARENT_SCOPE )
  elseif ( twx_message_mode_order.LEFT GREATER twx_message_mode_order.RIGHT )
    set ( ${twx_message_mode_order.R_IN_VAR} 1 PARENT_SCOPE )
  else ()
    set ( ${twx_message_mode_order.R_IN_VAR} 0 PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_message_mode_compare
#[=======[*/
/** @brief Compare the modes
  *
  */
twx_message_mode_compare( left op right IN_VAR ans) {}
/*#]=======]
function ( twx_message_mode_compare twx_message_mode_compare.R_LEFT twx_message_mode_compare.R_BIN twx_message_mode_compare.R_RIGHT )
  cmake_parse_arguments (
    PARSE_ARGV 3 twx_message_mode_compare.R
    "" "IN_VAR" ""
  )
  twx_var_assert_name ( "${twx_message_mode_compare.R_IN_VAR}" )
  twx_arg_assert_parsed ()
  list (
    FIND /TWX/CONST/MESSAGE/MODES
    "${twx_message_mode_compare.R_LEFT}"
    twx_message_mode_compare.LEFT
  )
  list (
    FIND /TWX/CONST/MESSAGE/MODES
    "${twx_message_mode_compare.R_RIGHT}"
    twx_message_mode_compare.RIGHT
  )
  if ( twx_message_mode_compare.LEFT LESS 0 )
    set ( ${twx_message_mode_compare.R_IN_VAR} PARENT_SCOPE )
  elseif ( twx_message_mode_compare.RIGHT LESS 0 )
    set ( ${twx_message_mode_compare.R_IN_VAR} PARENT_SCOPE )
  else ()
    twx_math_evaluate ( "${twx_message_mode_compare.LEFT}${twx_message_mode_compare.R_BIN}${twx_message_mode_compare.RIGHT}" IN_VAR ${twx_message_mode_compare.R_IN_VAR} )
    twx_export ( ${twx_message_mode_compare.R_IN_VAR} )
  endif ()
endfunction ()

twx_lib_require ( "Fatal" "Assert" "Arg" "Increment" "Export" "Math" )

twx_lib_did_load ()

#*/
