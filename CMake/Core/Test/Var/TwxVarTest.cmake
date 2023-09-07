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

# ANCHOR: assert_name
twx_test_unit_push ( CORE "assert_name" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( /TWX/FATAL/CATCH ON )
  function ( twx_test_unit_push_1 twx.R_name twx.R_event )
    twx_test_simple_check ( "${twx.R_name}" )
    twx_var_assert_name ( "${twx.R_name}" )
    cmake_language ( CALL "twx_test_simple_${twx.R_event}" )
  endfunction ()
  twx_test_unit_push_1 ( "" fail )
  twx_test_unit_push_1 ( "Ç" fail )
  twx_test_unit_push_1 ( "a_1" pass )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
