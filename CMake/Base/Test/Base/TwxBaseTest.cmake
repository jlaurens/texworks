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

twx_test_suite_push ()
block ()

twx_test_unit_push ( NAME "twx_set_if_defined" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "foo=>/bar=>baz")
  set ( foo )
  set ( bar "baz" )
  twx_set_if_defined ( foo bar )
  twx_expect ( foo "baz" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "foo=>/bar=>")
  set ( foo "baz" )
  set ( bar )
  twx_set_if_defined ( foo bar )
  twx_expect ( foo "baz" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_base_prettifier" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#/*
