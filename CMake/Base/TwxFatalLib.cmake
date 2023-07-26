#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Fatal utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxFatalLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_fatal()`, a shortcut to `message(FATAL_ERROR ...)``
  *   with some testing facilities.
  *
  * Testing utilities:
  * - `twx_fatal_catched()`
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# We define a custom target as global scope.
if ( NOT CMAKE_SCRIPT_MODE_FILE )
  add_custom_target (
    TwxFatalLib.cmake
  )
  define_property (
    TARGET PROPERTY TWX_FATAL_MESSAGE
  )
endif ()

# ANCHOR: twx_fatal
#[=======[
*/
/** @brief Terminate with a FATAL_ERROR message.
  *
  * @param ..., non empty list of text messages.
  *   In normal mode, all parameters are forwarded as is to `message(FATAL_ERROR ...)`.
  *   In test mode, the parameters are recorded for later use,
  *   nothing is displayed and the program does not stop.
  *   As there is no `try-catch` mechanism in `CMake`,
  *   a `return()` or `break()` statement may follow a `twx_fatal()` instruction.
  *
  */
twx_fatal(...){}
/*
#]=======]
function ( twx_fatal )
  set ( m )
  set ( i 0 )
  set ( ARGV${ARGC} )
  while ( TRUE )
    if ( NOT DEFINED ARGV${i} )
      break ()
    endif ()
    if ( ARGV${i} MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    math ( EXPR i "${i}+1" )
  endwhile ()
  if ( TWX_FATAL_CATCH AND TARGET TwxFatalLib.cmake )
    get_target_property (
      fatal_
      TwxFatalLib.cmake
      TWX_FATAL_MESSAGE
    )
    if ( fatal_ MATCHES "-NOTFOUND$")
      set ( fatal_ )
    endif ()
    list ( APPEND fatal_ "${m}" )
    set_target_properties (
      TwxFatalLib.cmake
      PROPERTIES
        TWX_FATAL_MESSAGE "${fatal_}"
    )
  else ()
    message ( FATAL_ERROR ${m} )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_clear
#[=======[
*/
/** @brief Clear catched fatal messages.
  *
  * For testing purposes only.
  *
  */
twx_fatal_clear (){}
/*
#]=======]
function ( twx_fatal_clear )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Too many arguments: ${ARGC} instead of 0." )
  endif ()
  if ( TARGET TwxFatalLib.cmake )
    set_target_properties (
      TwxFatalLib.cmake
      PROPERTIES
        TWX_FATAL_MESSAGE ""
    )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_test
#[=======[
*/
/** @brief After the test suite runs
  *
  * Must balance a `twx_test_suite_will_begin()`.
  *
  */
twx_fatal_test (ID id) {}
/*
#]=======]
function ( twx_fatal_test )
  if ( NOT DEFINED twx_fatal_test.CATCH_SAVED )
    set ( twx_fatal_test.CATCH_SAVED "${TWX_FATAL_CATCH}" PARENT_SCOPE )
  endif ()
  set ( TWX_FATAL_CATCH ON PARENT_SCOPE )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_clear ()
endfunction ()

# ANCHOR: twx_fatal_assert_passed
#[=======[
*/
/** @brief Raise when a test unexpectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_fatal_assert_passed () {}
/*
#]=======]
function ( twx_fatal_assert_passed )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_fatal_assert_passed.v )
  if ( twx_fatal_assert_passed.v AND NOT twx_fatal_assert_passed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE: ``${twx_fatal_assert_passed.v}''" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_fatal_test.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_assert_failed
#[=======[
*/
/** @brief Raise when a test did not expectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_fatal_assert_failed () {}
/*
#]=======]
function ( twx_fatal_assert_failed )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_fatal_assert_failed.v )
  if ( NOT twx_fatal_assert_failed.v OR twx_fatal_assert_failed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_fatal_test.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_catched
#[=======[
*/
/** @brief Catch fatal messages.
  *
  * For testing purposes only.
  * If the `twx_fatal()` call has no really bad consequences,
  * we can catch the message.
  *
  * @param var for key `IN_VAR`, contains the list of messages on return.
  */
twx_fatal_catched (IN_VAR var){}
/*
#]=======]
function ( twx_fatal_catched .IN_VAR twx.R_VAR )
  if ( NOT ${ARGC} EQUAL 2 )
    message ( FATAL_ERROR "Wrong number of arguments: ${ARGC} instead of 2." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Missing IN_VAR key: got ``${.IN_VAR}'' instead." )
  endif ()
  twx_assert_variable_name ( "${twx.R_VAR}" )
  
  if ( TARGET TwxFatalLib.cmake )
    get_target_property(
      ${twx.R_VAR}
      TwxFatalLib.cmake
      TWX_FATAL_MESSAGE
    )
  endif ()
  if ( ${twx.R_VAR} STREQUAL "fatal_-NOTFOUND")
    set ( ${twx.R_VAR} "" )
  endif ()
  set ( ${twx.R_VAR} "${${twx.R_VAR}}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_fatal_catched
#[=======[
*/
/** @brief Catch fatal messages.
  *
  * For testing purposes only.
  * If the `twx_fatal()` call has no really bad consequences,
  * we can catch the message.
  *
  * @param var for key `IN_VAR`, contains the list of messages on return.
  */
twx_fatal_catched (IN_VAR var){}
/*
#]=======]
macro ( twx_return_on_fatal )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Bad usage: ``${ARGV}''." )
  endif ()
  if ( TARGET TwxFatalLib.cmake )
    get_target_property(
      twx_return_on_fatal.MESSAGE
      TwxFatalLib.cmake
      TWX_FATAL_MESSAGE
    )
    if ( NOT twx_return_on_fatal.MESSAGE STREQUAL "twx_return_on_fatal.MESSAGE-NOTFOUND$"
    AND NOT twx_return_on_fatal.MESSAGE STREQUAL "" )
      return ()
    endif ()
  endif ()
endmacro ()

twx_lib_did_load ()

#*/
