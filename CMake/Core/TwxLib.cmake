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
  * @param NO_TEST, optional flag to disable testing mode for all given libraries.
  *   A library name cannot be `NO_TEST`.
  *
  */
twx_lib_require ( ... [NO_TEST]) {}
/*
#]=======]
macro ( twx_lib_require )
  cmake_parse_arguments ( twx_lib_require.R "NO_TEST" "" "" ${ARGV} )
  set ( twx_lib_require./TWX/TESTING ${/TWX/TESTING} )
  foreach ( twx_lib_require.L IN LISTS twx_lib_require.R_UNPARSED_ARGUMENTS )
    set ( twx_lib_require.TEST ON )
    if ( "${twx_lib_require.L}" MATCHES "^(.+):TEST$" )
      set ( twx_lib_require.L "${CMAKE_MATCH_1}" ) # <- local variable
    elseif ( "${twx_lib_require.L}" MATCHES "^(.+):NO_TEST$" )
      set ( twx_lib_require.L "${CMAKE_MATCH_1}" ) # <- local variable
      set ( twx_lib_require.TEST OFF )
    endif ()
    if ( twx_lib_require.R_NO_TEST )
      set ( twx_lib_require.TEST OFF )
    elseif ( twx_lib_require./TWX/TESTING )
      if ( CMAKE_SCRIPT_MODE_FILE )
        set ( twx_lib_require.TEST OFF )
      endif ()
    else ()
      set ( twx_lib_require.TEST OFF )
    endif ()
    if ( /TWX/PREAMBLE )
      set ( twx_lib_require.TEST OFF )
    endif ()
    # list ( APPEND twx_lib_require.stack "${twx_lib_require.L}" )
    # message ( STATUS "twx_lib_require.L => ``${twx_lib_require.L}''..." )
    if ( twx_lib_require.TEST )
      set ( /TWX/TESTING ON )
      if ( ";Core;Base;Main;" MATCHES ";${twx_lib_require.L};" )
        include ( "${CMAKE_CURRENT_LIST_DIR}/../${twx_lib_require.L}/Test/${twx_lib_require.L}/Twx${twx_lib_require.L}Test.cmake" )
        continue ()
      endif ()
      set ( twx_lib_require.P "${CMAKE_CURRENT_LIST_DIR}/Test/${twx_lib_require.L}/Twx${twx_lib_require.L}Test.cmake" )
      if ( EXISTS "${twx_lib_require.P}" )
        message ( TRACE "1) ${twx_lib_require.P}" )
        include ( "${twx_lib_require.P}" )
        continue ()
      endif ()
      set ( twx_lib_require.P "${CMAKE_CURRENT_LIST_DIR}/${twx_lib_require.L}/Twx${twx_lib_require.L}Test.cmake" )
      if ( EXISTS "${twx_lib_require.P}" )
        message ( TRACE "1) ${twx_lib_require.P}" )
        include ( "${twx_lib_require.P}" )
        continue ()
      endif ()
      message ( DEBUG "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.L}/Twx${twx_lib_require.L}Test.cmake" )
      message ( DEBUG "${CMAKE_CURRENT_LIST_DIR}/${twx_lib_require.L}/Twx${twx_lib_require.L}Test.cmake" )
      message ( DEBUG "No ${twx_lib_require.L} testing(1)" )
      set ( /TWX/TESTING ${twx_lib_require./TWX/TESTING} )
    else ()
      message ( DEBUG "No ${twx_lib_require.L} testing(2)" )
    endif ()
    set ( twx_lib_require.P "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.L}Lib.cmake" )
    if ( EXISTS "${twx_lib_require.P}" )
      message ( TRACE "2) ${twx_lib_require.P}" )
      include ( "${twx_lib_require.P}" )
    else ()
      set ( twx_lib_require.P "${CMAKE_CURRENT_LIST_DIR}/../Twx${twx_lib_require.L}Lib.cmake" )
      if ( EXISTS "${twx_lib_require.P}" )
        message ( TRACE "2) ${twx_lib_require.P}" )
        include ( "${twx_lib_require.P}" )
      elseif ( ";Core;Base;Main;" MATCHES ";${twx_lib_require.L};" )
        message ( TRACE "3) Twx${twx_lib_require.L}" )
        include ( "Twx${twx_lib_require.L}" )
      else ()
        message ( TRACE "4) Twx${twx_lib_require.L}Lib" )
        include ( "Twx${twx_lib_require.L}Lib" )
      endif ()
    endif ()
    # list ( POP_BACK twx_lib_require.stack twx_lib_require.L )
    # message ( STATUS "twx_lib_require.L => ``${twx_lib_require.L}''... DONE" )
  endforeach ()
  twx_var_unset (
    L /TWX/TESTING TEST P
    VAR_PREFIX twx_lib_require.
  )
  set ( /TWX/TESTING ${twx_lib_require./TWX/TESTING} )
endmacro ()

foreach ( TwxLib.LIB Const Var Cmd Global Format Fatal Assert Expect Dir )
  include ( "${CMAKE_CURRENT_LIST_DIR}/Twx${TwxLib.LIB}Lib.cmake" )
endforeach ()

set ( TwxLib.LIB )

#*/
