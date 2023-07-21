#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*/
/** @file
  * @brief CMake/Base/Test Cmake file
  * 
  * Test the various cmake libraries.
  * 
  */
/*
#]===============================================]

cmake_minimum_required ( VERSION 3.25 )

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

project ( TwxCMakeBaseTest )

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
list ( APPEND CMAKE_MESSAGE_CONTEXT Test.Base )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxPOC/TwxPOCTest.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxTestLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxBase.cmake" )

file ( GLOB_RECURSE tests "${CMAKE_CURRENT_LIST_DIR}/*Test.cmake" )
foreach ( t ${tests} )
  include ( ${t} )
endforeach ()

list ( POP_BACK CMAKE_MESSAGE_CONTEXT )

message ( STATUS "CMake/Base test suites... DONE" )

#*/
