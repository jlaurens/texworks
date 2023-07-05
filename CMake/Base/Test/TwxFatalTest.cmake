#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Fatal.
  *
  * First test.
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxFatalTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxFatalTest.cmake ON )

message ( STATUS "TwxFatalLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxFatalLib.cmake")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL DEBUG )
list ( APPEND CMAKE_MESSAGE_CONTEXT Fatal )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "assert_variable" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT assert_variable )
set ( TWX_FATAL_CATCH ON )
twx_fatal_clear ()
twx_assert_variable ( "Ç" )
twx_fatal_catched ( IN_VAR v )
if ( v STREQUAL "" )
  message ( FATAL_ERROR "FAILURE" )
endif ()
twx_fatal_clear ()
twx_assert_variable ( "a_1" )
endblock ()

message ( STATUS "fatal_catch" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT fatal_catch )
set ( TWX_FATAL_CATCH ON )
twx_fatal ( "ABCDE" )
return ()
twx_fatal_catched ( IN_VAR v )
if ( NOT v STREQUAL "ABCDE" )
  message ( FATAL_ERROR "FAILURE" )
endif ()
twx_fatal_clear ()
twx_fatal_catched ( IN_VAR v )
if ( NOT v STREQUAL "" )
  message ( FATAL_ERROR "FAILURE" )
endif ()
endblock ()

endblock ()

message ( STATUS "TwxFatalLib test... DONE")

#*/
