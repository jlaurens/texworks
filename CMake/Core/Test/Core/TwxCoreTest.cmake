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

twx_test_suite_push ()
block ()

twx_test_unit_push ( NAME "twx_regex_escape" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "void string" )
  unset ( actual )
  twx_regex_escape ( "" IN_VAR actual )
  twx_expect_equal_string ( "${actual}" "" )
  twx_test_simple_pass ()

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
    twx_test_simple_check ( "\\${c_}" )
    unset ( actual )
    twx_regex_escape ( "${c_}" IN_VAR actual )
    twx_expect_equal_string ( "${actual}" "\\${c_}" )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
