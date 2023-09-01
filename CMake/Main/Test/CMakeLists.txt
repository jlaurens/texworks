#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*/
/** @file
  * @brief CMake/Main/Test Cmake file
  * 
  * Test the various cmake libraries more related to TeXworks and projects.
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

project ( TwxCMakeMainTest )

set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

twx_test_domain_push ()
if ( TWX_TEST_DOMAIN.RUN )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxMain.cmake" )

# All the test that we did not list in `TwxBase.cmake`.
file ( GLOB_RECURSE tests "${CMAKE_CURRENT_LIST_DIR}/*Test.cmake" )
foreach ( t ${tests} )
  include ( ${t} )
endforeach ()
endif ()
twx_test_domain_pop ()

#*/
