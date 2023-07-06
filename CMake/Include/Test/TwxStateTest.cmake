#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing State.
  *
  * First test.
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxStateTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxStateTest.cmake ON )

message ( STATUS "TwxTestLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxStateLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL DEBUG )
list ( APPEND CMAKE_MESSAGE_CONTEXT State )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( "JSON" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT equal_string )
endblock ()

message ( "twx_state" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT equal_string )
# set ( TWX_DEV   <TWX_DEV> )
# set ( TWX_TEST  <TWX_TEST> )
# set ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
# set ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
# set ( CMAKE_MESSAGE_INDENT        <CMAKE_MESSAGE_INDENT> )
# set ( CMAKE_MESSAGE_LOG_LEVEL     <CMAKE_MESSAGE_LOG_LEVEL> )
# set ( CMAKE_MESSAGE_CONTEXT       <CMAKE_MESSAGE_CONTEXT> )
# set ( CMAKE_MESSAGE_CONTEXT_SHOW  <CMAKE_MESSAGE_CONTEXT_SHOW> )
# twx_state_serialize ( IN_VAR saved )
# set ( TWX_DEV   <> )
# set ( TWX_TEST  <> )
# set ( CMAKE_BINARY_DIR <> )
# set ( CMAKE_SOURCE_DIR <> )
# set ( CMAKE_MESSAGE_INDENT        <> )
# set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
# set ( CMAKE_MESSAGE_CONTEXT       <> )
# set ( CMAKE_MESSAGE_CONTEXT_SHOW  <> )
# twx_state_deserialize ( saved )
# twx_expect ( TWX_DEV   <TWX_DEV> )
# twx_expect ( TWX_TEST  <TWX_TEST> )
# twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
# twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
# twx_expect ( CMAKE_MESSAGE_INDENT        <CMAKE_MESSAGE_INDENT> )
# twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     <CMAKE_MESSAGE_LOG_LEVEL> )
# twx_expect ( CMAKE_MESSAGE_CONTEXT       <CMAKE_MESSAGE_CONTEXT> )
# twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  <CMAKE_MESSAGE_CONTEXT_SHOW> )
endblock ()

endblock ()

message ( STATUS "TwxTestLib test... DONE")

#*/
