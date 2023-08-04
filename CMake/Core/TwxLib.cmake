#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Library related material
  *
  * Commands
  *
  * - `twx_lib_will_load()`
  * - `twx_lib_did_load()`
  * - `twx_lib_require()`
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
    set ( name_ "${CMAKE_MATCH_1}" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)[.]cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )  
  elseif ( DEFINED twx_lib_will_load.R_NAME )
    set ( name_ "${twx_lib_will_load.R_NAME}" )
  elseif ()
    set ( name_ "some library" )
  endif ()
  message ( VERBOSE "Loading ${name_}... DONE" )
endfunction ()

# ANCHOR: twx_lib_require
#[=======[
*/
/** @brief Require a library
  *
  * Include the libraries with given names.
  * The behavior differs whether testing or not.
  *
  * `twx_lib_require()` is called from a library during its inclusion process.
  * A library can only require another library that stands next to it
  * or is available through `CMAKE_MODULE_PATH`.
  *
  * In normal mode, `twx_lib_require()` just executes `include()`
  * whereas in testing mode, it includes the test file associate to the library.
  * This test file will in turn include the library and then run tests.
  *
  */
twx_lib_require ( ... ) {}
/*
#]=======]
macro ( twx_lib_require )
  foreach ( twx_lib_require.lib ${ARGV} )
    # list ( APPEND twx_lib_require.stack "${twx_lib_require.lib}" )
    # message ( STATUS "twx_lib_require.lib => ``${twx_lib_require.lib}''..." )
    if ( TWX_TEST AND NOT CMAKE_SCRIPT_MODE_FILE )
      if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        message ( TRACE "1) ${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        include ( "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        continue ()
      endif ()
    endif ()
    if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
      message ( TRACE "2) ${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
      include ( "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
    elseif ( ";Core;Base;Main;" MATCHES ";${twx_lib_require.lib};" )
      message ( TRACE "3) Twx${twx_lib_require.lib}" )
      include ( "Twx${twx_lib_require.lib}" )
    else ()
      message ( TRACE "4) Twx${twx_lib_require.lib}Lib" )
      include ( "Twx${twx_lib_require.lib}Lib" )
    endif ()
    # list ( POP_BACK twx_lib_require.stack twx_lib_require.lib )
    # message ( STATUS "twx_lib_require.lib => ``${twx_lib_require.lib}''... DONE" )
  endforeach ()
  set ( twx_lib_require.lib )
endmacro ()

#*/
