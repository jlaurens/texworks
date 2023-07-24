#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*/
/** @file
  * @brief CMake/Include/Test Cmake file
  * 
  * Test the various cmake libraries more related to TeXworks and projects.
  * 
  */
/*
#]===============================================]

cmake_minimum_required ( VERSION 3.25 )

include_guard ( GLOBAL )

if ( TWX_TEST_DOMAIN.Base.RUN )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../../Base/Test/CMakeLists.txt"
    NO_POLICY_SCOPE
  )
else ()
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../../Base/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../../Base/TwxTestLib.cmake"
  )
  set ( TWX_TEST_DOMAIN.Base.SUITE_RE_NO ".*" )
endif ()

project ( TwxCMakeIncludeTest )

twx_test_domain_will_begin ()

if ( TWX_TEST_DOMAIN_RUN )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxInclude.cmake" )


# All the test that we did not list in `TwxBase.cmake`.
file ( GLOB_RECURSE tests "${CMAKE_CURRENT_LIST_DIR}/*Test.cmake" )
foreach ( t ${tests} )
  include ( ${t} )
endforeach ()

endif ()
twx_test_domain_did_end ()

#*/
