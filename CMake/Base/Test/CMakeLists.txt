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
There are different possible designs for testing purposes.
We started with a simple organization with great usage of `include()`
instructions over `add_subdirectory()`.
#]===============================================]

cmake_minimum_required ( VERSION 3.25 )

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

project ( TwxCMakeBaseTest )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxTestLib.cmake" )

set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

twx_test_domain_will_begin ( NAME Base )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxPOC/TwxPOCTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxBase.cmake" )

# All the test that we did not list in `TwxBase.cmake`.
file ( GLOB_RECURSE tests "${CMAKE_CURRENT_LIST_DIR}/*Test.cmake" )
foreach ( t ${tests} )
  include ( ${t} )
endforeach ()

twx_test_domain_did_end ()

#*/
