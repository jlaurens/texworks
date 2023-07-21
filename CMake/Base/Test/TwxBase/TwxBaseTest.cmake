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

twx_test_suite_will_begin ()
block ()

message ( "twx_compare_log_level" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_compare_log_level )
twx_fatal_assert_passed ()
if ( TRUE )
endif ()
twx_fatal_assert_passed ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#/*
