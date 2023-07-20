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

include_guard ( GLOBAL )

message ( "TwxBaseLib test...")

block ()
twx_test_suite_will_begin ()

message ( "twx_compare_log_level" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_compare_log_level )
twx_test_fatal_assert_passed ()
if ( TRUE )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxBaseLib test... DONE")

#/*
