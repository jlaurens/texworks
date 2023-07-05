#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*/
/** @file
  * @brief CMake/Include/Test Cmake file
  * 
  * Test the various cmake libraries.
  * 
  */
/*
#]===============================================]

cmake_minimum_required ( VERSION 3.25 )
include (
  "${CMAKE_CURRENT_LIST_DIR}/../TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)
project ( TwxCMakeIncludeTest )

message ( STATUS "Testing Twx Cmake Libraries" )

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
list ( APPEND CMAKE_MESSAGE_CONTEXT Test )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxPOCTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMathTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalTest.cmake" )

set ( TWX_FATAL_CATCH ON )
function ( twx_test_fatal )
  if ( "${ARGC}" GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_clear ()
endfunction ()

function ( twx_test_fatal_assert_passed )
  if ( "${ARGC}" GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_test_fatal_assert_passed.v )
  if ( NOT twx_test_fatal_assert_passed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE: \"${twx_test_fatal_assert_passed.v}\"" )
  endif ()
  twx_fatal_clear ()
endfunction ()

function ( twx_test_fatal_assert_failed )
  if ( "${ARGC}" GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_test_fatal_assert_failed.v )
  if ( twx_test_fatal_assert_failed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxSplitTest.cmake" )
message ( FATAL_ERROR "**********" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMessageTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTreeTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxBaseTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cmake" )
message ( FATAL_ERROR "**********" )
file ( GLOB tests *Test.cmake )

foreach ( t ${tests} )
  message ( STATUS ${t} )
  include ( ${t} )
endforeach ()

#*/
