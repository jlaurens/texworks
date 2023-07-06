#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxBaseLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxBaseTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxBaseTest.cmake ON )

message ( "TwxBaseLib test...")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Base )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( "twx_compare_log_level" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_compare_log_level )
unset ( actual )

endblock ()

endblock ()

message ( STATUS "TwxBseLib test...")

#/*
