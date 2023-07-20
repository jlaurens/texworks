#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing facilities.
  *
  */
/*
#]===============================================]

include_guard ( GLOBAL )

# ANCHOR: twx_test_during
#[=======[
*/
/** @brief Whether some test is actually running.
  *
  * @param test_id for key ID, a variable name like identifier to uniquely
  *   identify a test suite.
  * @param var_name for key IN_VAR, on return receives `TRUE` if the test
  *   with given id is actually running, false otherwise.
  */
/*
#]=======]
function ( twx_test_during .ID twx.R_ID .IN_VAR twx.R_IN_VAR )
  if ( NOT ${ARGC} EQUAL 4 )
    message ( FATAL_ERROR "Bad usage ( ARGV => \"${ARGV}\")" )
  endif ()
  if ( NOT "${.ID}" STREQUAL "ID" OR NOT "${.IN_VAR}" STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Bad usage ( ARGV => \"${ARGV}\")" )
  endif ()
  twx_assert_variable_name ( "${twx.R_ID}" "${twx.R_IN_VAR}" )
  if ( TARGET TwxTestLib.cmake )
    get_target_property (
      TWX_TEST_SUITE_LIST
      TwxTestLib.cmake
      TWX_TEST_SUITE_LIST
    )
  endif ()
  if ( "${twx.R_ID}" IN_LIST TWX_TEST_SUITE_LIST )
    set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
  else ()
    set ( "${twx.R_IN_VAR}" OFF PARENT_SCOPE )
  endif ()
endfunction ()

if ( CMAKE_SCRIPT_MODE_FILE )
  message ( DEBUG "No testing library in script mode" )
  return ()
endif ()

add_custom_target (
  TwxTestLib.cmake
)
define_property (
  TARGET PROPERTY TWX_TEST_SUITE_LIST
)
set_target_properties (
  TwxTestLib.cmake
  PROPERTIES
  TWX_TEST_SUITE_LIST ""
)

set ( TWX_FATAL_CATCH OFF )

# ANCHOR: twx_test_suite_will_begin
#[=======[
*/
/** @brief Before the test suite runs
  *
  * Must be balanced by a `twx_test_suite_did_end()`.
  * Best run with a scope, for example a block scope.
  *
  * @param test_id for key ID, a variable name like identifier to uniquely
  *   identify a test suite.
  * @param level for key LOG_LEVEL, optional log level.
  */
twx_test_suite_will_begin ([LOG_LEVEL level]) {}
/*
#]=======]
function ( twx_test_suite_will_begin )
  if ( ${ARGC} EQUAL 2 )
    if ( NOT ARGV0 STREQUAL "LOG_LEVEL" )
      message ( FATAL_ERROR "Bad usage (ARGV => \"${ARGV}\")" )
    endif ()
    set ( CMAKE_MESSAGE_LOG_LEVEL ${ARGV1} PARENT_SCOPE )
  elseif ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Bad usage (ARGV => \"${ARGV}\")" )
  endif ()
  get_target_property (
    list_
    TwxTestLib.cmake
    TWX_TEST_SUITE_LIST
  )
  if ( "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/Twx([^/]+)/Twx[^/]+Test.cmake$" )
    set ( TWX_TEST_SUITE_CORE_NAME "${CMAKE_MATCH_1}" )
  else ()
    set ( TWX_TEST_SUITE_CORE_NAME "Dummy" )
  endif ()
  list ( APPEND list_ "${TWX_TEST_SUITE_CORE_NAME}" )
  if ( "${TWX_TEST_SUITE_CORE_NAME}" STREQUAL "Base" )
    set ( TWX_TEST_SUITE_NAME "Twx${TWX_TEST_SUITE_CORE_NAME}" )
  elseif ( "${TWX_TEST_SUITE_CORE_NAME}" STREQUAL "Include" )
    set ( TWX_TEST_SUITE_NAME "Twx${TWX_TEST_SUITE_CORE_NAME}" )
  else ()
    set ( TWX_TEST_SUITE_NAME "Twx${TWX_TEST_SUITE_CORE_NAME}Lib" )
  endif ()
  set_target_properties (
    TwxTestLib.cmake
    PROPERTIES
    TWX_TEST_SUITE_LIST "${list_}"
  )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW ON PARENT_SCOPE )
  set ( TWX_FATAL_CATCH ON PARENT_SCOPE )
  set ( banner_ "Test suite ${TWX_TEST_SUITE_NAME}...")
  string ( LENGTH "${banner_}" length_ )
  string( REPEAT "=" "${length_}" underline_ )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  message ( "" )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
  message ( STATUS "${banner_}" )
  message ( STATUS "${underline_}" )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_SUITE_CORE_NAME}" )
  return ( PROPAGATE CMAKE_MESSAGE_CONTEXT TWX_TEST_SUITE_CORE_NAME TWX_TEST_SUITE_NAME )
endfunction ()

set ( TWX_FATAL_CATCH OFF )

# ANCHOR: twx_test_suite_did_end
#[=======[
*/
/** @brief After the test suite runs
  *
  * Must balance a `twx_test_suite_will_begin()`.
  *
  */
twx_test_suite_did_end (ID id) {}
/*
#]=======]
function ( twx_test_suite_did_end )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Bad usage (ARGV => \"${ARGV}\")" )
  endif ()
  get_target_property (
    list_
    TwxTestLib.cmake
    TWX_TEST_SUITE_LIST
  )
  if ( "${list_}" STREQUAL "" )
    message ( FATAL_ERROR "Internal inconsistency, please report." )
  endif ()
  list ( POP_BACK list_ )
  set_target_properties (
    TwxTestLib.cmake
    PROPERTIES
    TWX_TEST_SUITE_LIST "${list_}"
  )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  set ( banner_ "Test suite ${TWX_TEST_SUITE_NAME}... DONE")
  string ( LENGTH "${banner_}" length_ )
  string( REPEAT "=" "${length_}" underline_ )
  message ( STATUS "${banner_}" )
  message ( STATUS "${underline_}" )
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
  if ( TARGET TwxCoreLib.cmake )
    set_target_properties (
      TwxCoreLib.cmake
      PROPERTIES
        TWX_FATAL_MESSAGE ""
    )
  endif ()
endfunction ()

# ANCHOR: twx_test_fatal
#[=======[
*/
/** @brief After the test suite runs
  *
  * Must balance a `twx_test_suite_will_begin()`.
  *
  */
twx_test_fatal (ID id) {}
/*
#]=======]
function ( twx_test_fatal )
  if ( NOT DEFINED twx_test_fatal.CATCH_SAVED )
    set ( twx_test_fatal.CATCH_SAVED "${TWX_FATAL_CATCH}" PARENT_SCOPE )
  endif ()
  set ( TWX_FATAL_CATCH ON PARENT_SCOPE )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_clear ()
endfunction ()

# ANCHOR: twx_test_fatal_assert_passed
#[=======[
*/
/** @brief Raise when a test unexpectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_test_fatal_assert_passed () {}
/*
#]=======]
function ( twx_test_fatal_assert_passed )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_test_fatal_assert_passed.v )
  if ( NOT twx_test_fatal_assert_passed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE: \"${twx_test_fatal_assert_passed.v}\"" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_test_fatal.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_test_fatal.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_test_fatal_assert_failed
#[=======[
*/
/** @brief Raise when a test did not expectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_test_fatal_assert_failed () {}
/*
#]=======]
function ( twx_test_fatal_assert_failed )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_test_fatal_assert_failed.v )
  if ( twx_test_fatal_assert_failed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_test_fatal.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_test_fatal.CATCH_SAVED}" PARENT_SCOPE )
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
    message ( FATAL_ERROR "Missing IN_VAR key: got \"${.IN_VAR}\" instead." )
  endif ()
  twx_assert_variable_name ( "${twx.R_VAR}" )
  
  if ( TARGET TwxCoreLib.cmake )
    get_target_property(
      ${twx.R_VAR}
      TwxCoreLib.cmake
      TWX_FATAL_MESSAGE
    )
  endif ()
  if ( ${twx.R_VAR} STREQUAL "fatal_-NOTFOUND")
    set ( ${twx.R_VAR} "" )
  endif ()
  set ( ${twx.R_VAR} "${${twx.R_VAR}}" PARENT_SCOPE )
endfunction ()

function ( TwxTestLib_state_prepare )
  get_target_property (
    TWX_TEST_SUITE_LIST
    TwxTestLib.cmake
    TWX_TEST_SUITE_LIST
  )
  twx_export ( TWX_TEST_SUITE_LIST )
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

message ( VERBOSE "Loaded: TwxTestLib" )

#*/
