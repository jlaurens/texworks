#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Core.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

message ( STATUS "fatal_catch" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT fatal_catch )
if ( TRUE )
  set ( TWX_FATAL_CATCH ON )
  twx_fatal ( "ABCDE" )
  twx_fatal_catched ( IN_VAR v )
  if ( NOT v STREQUAL "ABCDE" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_fatal_catched ( IN_VAR v )
  if ( NOT v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
endif ()
twx_fatal_clear ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#*/
