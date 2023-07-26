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

twx_test_unit_will_begin ( NAME "twx_regex_escape" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  unset ( actual )
  twx_regex_escape ( "" IN_VAR actual )
  if ( NOT "${actual}" STREQUAL "" )
    message ( FATAL_ERROR "FAILED: ")
  endif ()
  twx_regex_escape ( "^" IN_VAR actual )
  # message ( "DEBUG: twx_regex_escape: actual => ${actual}" )
  foreach ( c_ "^" "$"
  "." 
  "\\"
  "["
  "]"
  "-"
  "*"
  "+"
  "?"
  "|"
  "(" ")"
  )
    # message ( "DEBUG: c_ => ``${c_}''")
    twx_regex_escape ( "${c_}" IN_VAR actual )
    # message ( "DEBUG: actual => ``${actual}''")
    if ( NOT "${actual}" STREQUAL "\\${c_}" )
      message ( FATAL_ERROR "FAILED (``${actual}'' instead of ``\\${c_}'')")
    endif ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_did_end ()

twx_test_unit_will_begin ( NAME "assert_variable" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( TWX_FATAL_CATCH ON )
  twx_fatal_clear ()
  twx_assert_variable_name ( "Ç" )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_assert_variable_name ( "a_1" )
  twx_fatal_clear ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
