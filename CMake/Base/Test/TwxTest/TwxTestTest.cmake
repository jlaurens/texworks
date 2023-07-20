#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxTreeLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )


message ( STATUS "TwxTestLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxTestLib.cmake" )

block ()

twx_test_suite_will_begin ()

message ( STATUS "Test Test..." )

twx_test_suite_did_end ()

endblock ()

message ( STATUS "TwxTestLib test...")

#*/
