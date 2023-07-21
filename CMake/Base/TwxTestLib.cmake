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

set ( TWX_TEST ON )

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
  * Loads the associate library retrieved from the path of the current list file.
  * A `block()` instruction should follow.
  *
  * @param level for key LOG_LEVEL, optional log level.
  */
twx_test_suite_will_begin ([LOG_LEVEL level]) {}
/*
#]=======]
macro ( twx_test_suite_will_begin )
  block ()
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  message ( "" )
  endblock()
  list ( APPEND twx_test_suite_will_begin.CMAKE_MESSAGE_LOG_LEVEL "${CMAKE_MESSAGE_LOG_LEVEL}" )
  if ( ${ARGC} EQUAL 2 )
    if ( NOT ARGV0 STREQUAL "LOG_LEVEL" )
      message ( FATAL_ERROR "Bad usage (ARGV => \"${ARGV}\")" )
    endif ()
    set ( CMAKE_MESSAGE_LOG_LEVEL ${ARGV1} )
  elseif ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Bad usage (ARGV => \"${ARGV}\")" )
  endif ()
  get_target_property (
    twx_test_suite_will_begin.list
    TwxTestLib.cmake
    TWX_TEST_SUITE_LIST
  )
  if ( "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/Twx([^/]+)/Twx[^/]+Test.cmake$" )
    set ( TWX_TEST_SUITE_CORE_NAME "${CMAKE_MATCH_1}" )
  else ()
    set ( TWX_TEST_SUITE_CORE_NAME "Dummy" )
  endif ()
  list ( APPEND twx_test_suite_will_begin.list "${TWX_TEST_SUITE_CORE_NAME}" )
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
    TWX_TEST_SUITE_LIST "${twx_test_suite_will_begin.list}"
  )
  set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
  set ( TWX_FATAL_CATCH ON )
  set ( twx_test_suite_will_begin.banner "Test suite ${TWX_TEST_SUITE_NAME}...")
  string ( LENGTH "${twx_test_suite_will_begin.banner}" twx_test_suite_will_begin.length )
  string( REPEAT "=" "${twx_test_suite_will_begin.length}" twx_test_suite_will_begin.underline )
  message ( STATUS "${twx_test_suite_will_begin.banner}" )
  message ( STATUS "${twx_test_suite_will_begin.underline}" )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_SUITE_CORE_NAME}" )
  if ( "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/Twx([^/]+)Test.cmake$" )
    if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/../../Twx${CMAKE_MATCH_1}.cmake" )
      include ( "${CMAKE_CURRENT_LIST_DIR}/../../Twx${CMAKE_MATCH_1}.cmake" )
    else ()
      include ( "${CMAKE_CURRENT_LIST_DIR}/../../Twx${CMAKE_MATCH_1}Lib.cmake" )
    endif ()
  else ()
    message ( FATAL_ERROR "No library to test" )
  endif ()
  set ( twx_test_suite_will_begin.length )
  set ( twx_test_suite_will_begin.banner )
  set ( twx_test_suite_will_begin.underline )
endmacro ()

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
  list ( POP_BACK twx_test_suite_will_begin.CMAKE_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  return ( PROPAGATE CMAKE_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_CONTEXT )
endfunction ()

function ( TwxTestLib_state_prepare )
  get_target_property (
    TWX_TEST_SUITE_LIST
    TwxTestLib.cmake
    TWX_TEST_SUITE_LIST
  )
  twx_export ( TWX_TEST_SUITE_LIST )
endfunction ()

macro ( twx_test_include )
  foreach ( twx_include_test.n ${ARGV} )
    set (
      twx_include_test.p
      "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_include_test.n}/Twx${twx_include_test.n}Test.cmake"
    )
    if ( EXISTS "${twx_include_test.p}" )
      include ( "${twx_include_test.p}" )
    else ()
      include (
        "${CMAKE_CURRENT_LIST_DIR}/../Twx${twx_include_test.n}/Twx${twx_include_test.n}Test.cmake"
      )
    endif ()
  endforeach ()
  set ( twx_include_test.n )
  set ( twx_include_test.p )
endmacro ()

message ( VERBOSE "Loaded: TwxTestLib" )

#*/
