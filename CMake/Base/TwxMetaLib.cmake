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
  * @param name, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_will_load ([name]) {}
/*
#]=======]
function ( twx_lib_will_load )
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)\\.cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)\\.cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )  
  elseif ( ARGC EQUAL 1 )
    set ( name_ "${ARGV0}" )  
  elseif ()
    set ( name_ "some library" )  
  endif ()
  message ( VERBOSE "Loading ${name_}..." )
endfunction ()

# ANCHOR: twx_lib_did_load ()
#[=======[
*/
/** @brief After a library has been loaded.
  *
  * Display some message in VERBOSE mode.
  * @param name, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_did_load ([name]) {}
/*
#]=======]
function ( twx_lib_did_load )
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)\\.cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)\\.cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )  
  elseif ( ARGC EQUAL 1 )
    message ( VERBOSE "Loading ${ARGV0}... DONE" )  
  elseif ()
    message ( VERBOSE "Loading some library... DONE" )  
  endif ()
endfunction ()

#*/
