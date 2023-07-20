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

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../../Base/Test/CMakeLists.txt"
  NO_POLICY_SCOPE
)
project ( TwxCMakeIncludeTest )

message ( STATUS "Testing /CMake/Include..." )

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
list ( APPEND CMAKE_MESSAGE_CONTEXT Test.Include )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxCfg/TwxCfgTest.cmake" )

message ( FATAL_ERROR "**********" )

file ( GLOB tests */Include/Test/*Test.cmake )
foreach ( t ${tests} )
  include ( ${t} )
endforeach ()

#*/
