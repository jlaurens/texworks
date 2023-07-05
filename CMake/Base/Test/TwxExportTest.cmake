#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxExportLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxExportTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxExportTest.cmake ON )

message ( "TwxExportLib testing")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExportLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxSplitTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Export )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_export" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_export )
twx_test_fatal ()
function ( TwxExportTest_1 key value )
  twx_export ()
endfunction ()
twx_test_fatal_assert_failed ()
twx_test_fatal_assert_passed ()
endblock ()

endblock ()