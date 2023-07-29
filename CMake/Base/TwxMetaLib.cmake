#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Meta material
  *
  * Commands
  *
  * - `twx_lib_will_load()`
  * - `twx_lib_did_load()`
  *
  */
/*#]===============================================]

include_guard ()

# ANCHOR: twx_lib_will_load ()
#[=======[
*/
/** @brief Before a library starts loading.
  *
  * Display some message in VERBOSE mode.
  * @param name for key `NAME`, optional libray name used when
  *   not guessed from the current list file name.
  * @param name, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_will_load ([NAME name] [NO_SCRIPT]) {}
/*
#]=======]
macro ( twx_lib_will_load )
  cmake_parse_arguments ( twx_lib_will_load.R "NO_SCRIPT" "NAME" "" ${ARGV} )
  if ( NOT "${twx_lib_will_load.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  block ()
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)[.]cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)[.]cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )  
  elseif ( DEFINED twx_lib_will_load.R_NAME )
    set ( name_ "${twx_lib_will_load.R_NAME}" )
  elseif ()
    set ( name_ "some library" )
  endif ()
  message ( VERBOSE "Loading ${name_}..." )
  endblock ()
  set ( twx_lib_will_load.R_UNPARSED_ARGUMENTS )
  if ( CMAKE_SCRIPT_MODE_FILE AND twx_lib_will_load.R_NO_SCRIPT )
    set ( twx_lib_will_load.R_NO_SCRIPT )
    message ( VERBOSE "Not in script mode." )
    twx_lib_did_load( ${ARGV} )
    return ()
  endif ()
  set ( twx_lib_will_load.R_NO_SCRIPT )
endmacro ()

# ANCHOR: twx_lib_did_load ()
#[=======[
*/
/** @brief After a library has been loaded.
  *
  * Display some message in VERBOSE mode.
  * @param name for key `NAME`, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_did_load ([NAME name]) {}
/*
#]=======]
function ( twx_lib_did_load )
  cmake_parse_arguments ( twx.R "NO_SCRIPT" "NAME" "" ${ARGV} )
  if ( NOT "${twx_lib_will_load.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)[.]cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)[.]cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )  
  elseif ( DEFINED twx.R_NAME )
    message ( VERBOSE "Loading ${twx.R_NAME}... DONE" )  
  elseif ()
    message ( VERBOSE "Loading some library... DONE" )  
  endif ()
endfunction ()

#*/
