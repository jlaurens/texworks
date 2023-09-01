#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxGlobalLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

twx_tree_init ( expected.empty/ )
twx_tree_init ( expected.key/ )
twx_tree_set ( TREE expected.key/ key=value )
twx_tree_init ( expected.key.empty/ )
twx_tree_set ( TREE expected.key.empty/ key=${expected.empty/} )
twx_tree_init ( expected.key.key.key/ )
twx_tree_set ( TREE expected.key.key.key/ key/key/key=value )


twx_test_unit_push ( NAME "twx_global_save/restore" ID save/restore )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  unset ( TwxGlobalTest.tree/ )
  twx_global_restore ( IN_TREE TwxGlobalTest.tree/ )
  twx_tree_assert ( TwxGlobalTest.tree/ )
  twx_assert_true ( TWX_IS_TREE_TwxGlobalTest.tree/ )
  twx_expect ( TwxGlobalTest.tree/ "${expected.empty/}" )
  twx_global_save ( TREE expected.key/ )
  unset ( TwxGlobalTest.tree/ )
  unset ( TWX_IS_TREE_TwxGlobalTest.tree/ )
  twx_global_restore ( IN_TREE TwxGlobalTest.tree/ )
  twx_tree_assert ( TwxGlobalTest.tree/ )
  twx_assert_true ( "${TWX_IS_TREE_TwxGlobalTest.tree/}" )

  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/1" ID set/1 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  set ( tree/ "dummy" )
  twx_global_restore ( IN_TREE tree/ )
  twx_expect ( tree/ "${TWX_TREE_HEADER}" )
  twx_fatal_test ()
  twx_global_set ( key=value )
  twx_fatal_assert_pass ()
  twx_global_restore ( IN_TREE tree/ )
  twx_expect ( tree/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key${TWX_TREE_SEP}value" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_get/0" ID get/0 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  set ( A/k dummy )
  twx_assert_defined ( A/k )
  twx_global_get ( IN_TREE A KEY k )
  twx_assert_undefined ( A/k )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_get/1" ID set/1 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_restore ( IN_TREE tree/ )
  twx_expect ( tree/ "${TWX_TREE_HEADER}" )
  twx_global_set ( key=value )
  twx_fatal_assert_pass ()
  twx_global_restore ( IN_TREE tree/ )
  twx_expect ( tree/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key${TWX_TREE_SEP}value" )
  
  twx_global_get ( IN_TREE tree/ KEY key )
  twx_expect ( tree/key "value" )
  twx_global_get ( IN_TREE tree/ KEY key )
  twx_expect ( tree/key "value" )
  twx_global_get ( IN_TREE tree KEY key )
  twx_expect ( tree/key "value" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_remove/0" ID remove/0 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( k=v )
  twx_global_remove ( k )
  set ( A/k "dummy" )
  twx_assert_defined ( A/k )
  twx_global_get ( IN_TREE A KEY k )
  twx_assert_undefined ( A/k )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/remove/1" ID set/remove/1 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key=value )
  twx_regex_escape ( "key" IN_VAR scp_key_ )
  twx_expect ( scp_key_ "key" )
  twx_global_restore ( IN_TREE tree/ )
  twx_expect_matches ( "${tree/}" "${TWX_TREE_RECORD}(${scp_key_})${TWX_TREE_SEP}([^${TWX_TREE_RECORD}]*)$" )
  twx_global_remove ( key )
  twx_global_restore ( IN_TREE tree/ )
  twx_expect ( tree/ "${TWX_TREE_HEADER}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/2" ID set/2 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  block ( PROPAGATE actual/)
    twx_global_set ( key/key=value )
    twx_global_restore ( IN_TREE actual/ )
  endblock ()
  block ( PROPAGATE expected/)
    twx_global_set ( key/key=value )
    twx_tree_init ( A/ )
    twx_tree_set ( TREE A/ key=value )
    twx_global_set ( key=${A/} )
    twx_global_restore ( IN_TREE expected/ )
  endblock ()
  twx_expect ( actual/ "${expected/}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/3" ID set/2 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key=value )
  twx_global_set ( key=other_value )
  twx_global_restore ( IN_TREE A/ )
  twx_expect ( A/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key${TWX_TREE_SEP}other_value" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/get/0" ID TWX_TREE )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  set ( A/k "dummy" )
  twx_assert_defined ( A/k )
  twx_global_get ( IN_TREE A KEY k )
  twx_assert_undefined ( A/k )
  twx_global_set ( k=v )
  twx_global_get ( IN_TREE A KEY k )
  twx_expect ( A/k "v" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/get/1" ID set/get/1 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key=value )
  set ( tree/key "dummy" )
  twx_global_get ( IN_TREE tree KEY key )
  twx_expect ( tree/key "value" )
  twx_assert_undefined ( TWX_IS_TREE_tree/key )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_set/get/2" ID set/get/2 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( k/kk/kkk=value )
  set ( tree/k/kk/kkk dummy )
  set ( TWX_IS_TREE_tree/k/kk/kkk dummy )
  twx_global_get ( IN_TREE tree KEY k/kk/kkk )
  twx_expect ( tree/k/kk/kkk "value" )
  twx_assert_undefined ( TWX_IS_TREE_tree/k/kk/kkk )
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ kkk=value )
  set ( tree/k/kk/ dummy )
  twx_global_get ( IN_TREE tree KEY k/kk )
  unset ( tree/k/ )
  twx_global_get ( IN_TREE tree KEY k )
  # message ( TR@CE "tree/k => ``${tree/k}''" )
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ kk/kkk=value )
  # message ( TR@CE "expected/ => ``${expected/}''" )
  twx_expect ( tree/k "${expected/}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_remove/1" ID set/2 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_remove ( what ever )
  twx_global_restore ( IN_TREE tree/ )
  twx_tree_init ( expected/ )
  twx_expect ( tree/ "${expected/}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_remove/2" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key=value )
  twx_global_remove ( key what ever )
  twx_global_restore ( IN_TREE actual/ )
  twx_tree_init ( expected/ )
  twx_expect ( actual/ "${expected/}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_remove/3" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key/key/key=value )
  twx_global_remove ( what ever key )
  set ( actual/key dummy )
  twx_global_get ( IN_TREE actual/ KEY key )
  twx_assert_undefined ( actual/key )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_remove/4" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( key/key/key=value )
  twx_global_remove ( key/key )
  twx_global_restore ( IN_TREE A/ )
  twx_expect ( A/ "${expected.key.empty/}" )
  twx_global_get ( IN_TREE A KEY key/key )
  twx_assert_undefined ( A/key/key )
  twx_global_get ( IN_TREE A KEY key )
  twx_expect ( A/key "${expected.empty/}" )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_global_..." ID ... )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_global_clear ()
  twx_global_set ( k1/k1=v11 k1/k2=v12 k2/k1=v21 k2/k2=v22 k3=v3 k4=v4 )
  twx_global_log ( )
  # block ()
  #   twx_global_prettify ( IN_VAR pretty )
  #   # message ( TR@CE "GLOBAL => ${pretty}")
  # endblock ()
  unset ( A/k1 )
  unset ( TWX_IS_TREE_A/k1 )
  twx_global_get ( IN_TREE A/ KEY k1 )
  twx_assert_defined ( A/k1 )
  twx_assert_true ( "${TWX_IS_TREE_A/k1}" )
  twx_tree_assert ( A/k1 )
  unset ( A/k1/k1 )
  twx_tree_get ( TREE A/k1 KEY k1 )
  twx_expect ( A/k1/k1 "v11" )
  unset ( A/k1/k2 )
  twx_tree_get ( TREE A/k1 KEY k2 )
  twx_expect ( A/k1/k2 "v12" )
  unset ( A/k2 )
  unset ( TWX_IS_TREE_A/k2 )
  twx_global_get ( IN_TREE A/ KEY k2 )
  twx_assert_defined ( A/k2 )
  twx_assert_true ( "${TWX_IS_TREE_A/k2}" )
  twx_tree_assert ( A/k2 )
  unset ( A/k2/k1 )
  twx_tree_get ( TREE A/k2 KEY k1 )
  twx_expect ( A/k2/k1 "v21" )
  unset ( A/k2/k2 )
  twx_tree_get ( TREE A/k2 KEY k2 )
  twx_expect ( A/k2/k2 "v22" )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
