#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Library related material
  *
  * This is the very first library that is loaded.
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

string ( ASCII 01 TWX_CHAR_SOH )
string ( ASCII 02 TWX_CHAR_STX )
string ( ASCII 03 TWX_CHAR_ETX )
string ( ASCII 25 TWX_CHAR_EM  )
string ( ASCII 26 TWX_CHAR_SUB )
string ( ASCII 28 TWX_CHAR_FS  )
string ( ASCII 29 TWX_CHAR_GS  )
string ( ASCII 30 TWX_CHAR_RS  )
string ( ASCII 31 TWX_CHAR_US  )

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
  if ( DEFINED twx_lib_will_load.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
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
  if ( COMMAND twx_log AND COMMAND twx_math )
    twx_log ( VERBOSE "Loading ${name_}..." )
  else ()
    message ( VERBOSE "Loading ${name_}..." )
  endif ()
  endblock ()
  if ( CMAKE_SCRIPT_MODE_FILE AND twx_lib_will_load.R_NO_SCRIPT )
    set ( twx_lib_will_load.R_NO_SCRIPT )
    message ( VERBOSE "Not in script mode." )
    twx_lib_did_load ( ${ARGV} )
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
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "NO_SCRIPT" "NAME" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR " Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
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
  if ( COMMAND twx_log )
    twx_log ( VERBOSE "Loading ${name_}... DONE" )
  else ()
    message ( VERBOSE "Loading ${name_}... DONE" )
  endif ()
endfunction ( twx_lib_did_load )

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
  * @param ..., list of library names or `<name>:TEST`.
  *   In the latter case, the library is loaded in test mode.
  * @param TEST, optional flag to enable testing mode for all libraries.
  *   A library name cannot be `TEST`.
  *
  */
twx_lib_require ( ... [TEST]) {}
/*
#]=======]
macro ( twx_lib_require )
  cmake_parse_arguments ( twx_lib_require.R "" "TEST" "" ${ARGV} )
  set ( twx_lib_require.TWX_TEST "${TWX_TEST}" )
  foreach ( twx_lib_require.lib ${twx_lib_require.R_UNPARSED_ARGUMENTS} )
    block ( PROPAGATE twx_lib_require.lib twx_lib_require.test )
      set ( twx_lib_require.test ON )
      if ( "${twx_lib_require.lib}" MATCHES "^(.*):TEST$" )
        set ( twx_lib_require.lib "${CMAKE_MATCH_1}" ) # <- local variable
      elseif ( twx_lib_require.TWX_TEST OR twx_lib_require.R_TEST )
        if ( CMAKE_SCRIPT_MODE_FILE )
          set ( twx_lib_require.test OFF )
        endif ()
      else ()
        set ( twx_lib_require.test OFF )
      endif ()
    endblock ()
    # list ( APPEND twx_lib_require.stack "${twx_lib_require.lib}" )
    # message ( STATUS "twx_lib_require.lib => ``${twx_lib_require.lib}''..." )
    if ( twx_lib_require.test )
      set ( TWX_TEST ON )
      if ( ";Core;Base;Main;" MATCHES ";${twx_lib_require.lib};" )
        include ( "${CMAKE_CURRENT_LIST_DIR}/../${twx_lib_require.lib}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        continue ()
      elseif ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        message ( TRACE "1) ${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        include ( "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        continue ()
      elseif ( ";Core;Base;Main;" MATCHES ";${twx_lib_require.lib};" )
        if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
          message ( TRACE "1') ${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
          include ( "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
          continue ()
        endif ()
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
  set ( TWX_TEST ${twx_lib_require.TWX_TEST} )
  set ( twx_lib_require.TWX_TEST )
  set ( twx_lib_require.test )
endmacro ()

foreach ( TwxLib.LIB Var Cmd Global Format Fatal Assert Expect Dir )
  include ( "${CMAKE_CURRENT_LIST_DIR}/Twx${TwxLib.LIB}Lib.cmake" )
endforeach ()

set ( TwxLib.LIB )

#*/
