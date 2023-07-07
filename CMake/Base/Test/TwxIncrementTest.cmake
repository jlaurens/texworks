#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxIncrementLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxIncrementTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxIncrementTest.cmake ON )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxIncrementLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgTest.cmake" )

message ( STATUS "TwxIncrementLib test...")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Increment )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_increment" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT increment )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( i 123 )
  twx_assert_compare ( ${i} == 123 )
  twx_increment ( VAR i )
  twx_assert_compare ( ${i} == 124 )
  twx_increment ( VAR i STEP 2 )
  twx_assert_compare ( ${i} == 126 )
  twx_increment ( VAR i STEP -1 )
  twx_assert_compare ( ${i} == 125 )
  set ( TWX_FATAL_CATCH ON )
  twx_fatal_clear ()
  twx_increment ( )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR i STEP )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR i STEP 2 3 )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
endif ()
twx_test_fatal ()
endblock ()

message ( STATUS "twx_break_if" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT break_if )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( i 100 )
  while (true )
    twx_break_if ( ${i} < 1000 )
    set ( i 1000 )
    break ()
  endwhile ()
  message ( TRACE "X" )
  twx_assert_compare ( ${i} == 100 )
  set ( i 100 )
  while (true )
    twx_break_if ( ${i} > 1000 )
    set ( i 1000 )
    break ()
  endwhile ()
  message ( TRACE "XX ${i} " )
  twx_assert_compare ( ${i} == 1000 )
  message ( TRACE "XXX" )
  twx_test_fatal ()
  message ( TRACE "XXX" )
  while (true )
    twx_break_if ( ${i} == 1000 EXTRA )
    break ()
  endwhile ()
  message ( TRACE "XXX" )
  twx_test_fatal_assert_failed ()
  while (true )
    twx_break_if ( ${i} <> 1000 )
    break ()
  endwhile ()
  twx_test_fatal_assert_failed ()
endif ()
twx_test_fatal ()
endblock ()
message ( TRACE "XXXX" )

endblock ()

message ( STATUS "TwxIncrementLib test... DONE")

#/*
