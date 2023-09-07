#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxAnsLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

twx_tree_init ( TREE empty/ )

# ANCHOR: ...
twx_test_unit_push ( CORE "..." )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "abc" )
  twx_ans_clear ()
  twx_ans_assert_key ( "abc" )
  twx_ans_get_keys ( IN_VAR keys )
  twx_ans_get ( KEY k)
  twx_ans_set ( k )
  twx_ans_remove ( KEY k )
  twx_ans_expose ()
  twx_ans_export ()
  twx_ans_log ()
  twx_ans_prettify ( IN_VAR pretty )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: clear
twx_test_unit_push ( CORE clear )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  
  twx_test_simple_check ( "abc" )
  twx_ans_clear ()
  twx_tree_assert ( TREE /TWX/ANS )
  twx_expect ( /TWX/ANS "${empty/}" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: get_keys
twx_test_unit_push ( CORE get_keys )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Undefined keys" )
  twx_ans_clear ()
  set ( keys "dummy" )
  twx_assert_defined ( keys )
  twx_ans_get_keys ( IN_VAR keys )
  twx_assert_undefined ( keys )
  twx_test_simple_pass ()

  twx_test_simple_check ( "/TWX/ANS/k=v" )
  twx_ans_clear ()
  set ( keys "dummy" )
  twx_tree_set ( TREE /TWX/ANS k=v )
  twx_ans_get_keys ( IN_VAR keys )
  twx_expect_list ( keys "k" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: set/get/remove
twx_test_unit_push ( CORE set/get/remove )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Undefined k" )
  twx_ans_clear ()
  set ( /TWX/ANS/k "dummy" )
  twx_ans_get ( KEY k )
  twx_assert_undefined ( /TWX/ANS/k )
  twx_test_simple_pass ()

  twx_test_simple_check ( "k=v" )
  twx_ans_clear ()
  set ( k "dummy" )
  set ( /TWX/ANS/k "dummy" )
  twx_ans_set ( k=v )
  twx_ans_get ( KEY k IN_VAR k )
  twx_ans_get ( KEY k )
  twx_expect ( k "v" )
  twx_expect ( /TWX/ANS/k "v" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "k=v removed" )
  twx_ans_clear ()
  set ( /TWX/ANS/k "dummy" )
  twx_ans_set ( k=v )
  twx_ans_remove ( KEY k )
  twx_ans_get ( KEY k )
  twx_assert_undefined ( /TWX/ANS/k )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: expose
twx_test_unit_push ( CORE expose )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "k=v" )
  twx_ans_clear ()
  twx_ans_set ( k=v )
  # twx_tree_log ( TREE /TWX/ANS )
  set ( /TWX/ANS/k )
  twx_tree_expose ( TREE /TWX/ANS )
  twx_expect ( /TWX/ANS/k "v" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "[/TWX/ANS/]k=v" )
  twx_ans_clear ()
  twx_ans_set ( k=v )
  set ( /TWX/ANS/k )
  twx_ans_expose ()
  twx_expect ( /TWX/ANS/k "v" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()
  
#*/
