#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxCoreLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxCoreTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxCoreTest.cmake ON )

message ( "TwxCoreLib testing")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExportLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Expect )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_split" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split )
twx_test_fatal ()

twx_test_fatal_assert_failed ()
twx_test_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_export" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_export )

endblock ()

endblock ()