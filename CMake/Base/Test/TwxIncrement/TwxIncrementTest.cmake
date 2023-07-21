#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxIncrementLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

message ( STATUS "twx_increment" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT increment )
twx_fatal_assert_passed ()
if ( TRUE )
  set ( i 123 )
  twx_assert_compare ( ${i} == 123 )
  twx_increment ( VAR i )
  twx_assert_compare ( ${i} == 124 )
  twx_increment ( VAR i STEP 2 )
  twx_assert_compare ( ${i} == 126 )
  twx_increment ( VAR i STEP -1 )
  twx_assert_compare ( ${i} == 125 )
  set ( TWX_FATAL_CATCH ON )
  twx_fatal_clear ()
  twx_increment ( )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR i STEP )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_increment ( VAR i STEP 2 3 )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_break_if" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT break_if )
twx_fatal_assert_passed ()
if ( TRUE )
  set ( i 100 )
  while (true )
    twx_break_if ( ${i} < 1000 )
    set ( i 1000 )
    break ()
  endwhile ()
  # message ( TR@CE "X" )
  twx_assert_compare ( ${i} == 100 )
  set ( i 100 )
  while (true )
    twx_break_if ( ${i} > 1000 )
    set ( i 1000 )
    break ()
  endwhile ()
  # message ( TR@CE "XX ${i} " )
  twx_assert_compare ( ${i} == 1000 )
  # message ( TR@CE "XXX" )
  twx_fatal_test ()
  # message ( TR@CE "XXX" )
  while (true )
    twx_break_if ( ${i} == 1000 FORBIDDEN_EXTRA_ARGUMENT )
    break ()
  endwhile ()
  # message ( TR@CE "XXX" )
  twx_fatal_assert_failed ()
  while (true )
    twx_break_if ( ${i} <> 1000 )
    set ( i 2000 )
    break ()
  endwhile ()
  twx_assert_compare ( ${i} == 2000 )
  while (true )
    twx_break_if ( ${i} <> 1000 )
    set ( i 3000 )
    break ()
  endwhile ()
  twx_assert_compare ( ${i} == 2000 )
endif ()
twx_fatal_assert_passed ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#/*
