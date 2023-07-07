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

if ( DEFINED //CMake/Include/Test/TwxGlobalTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxGlobalTest.cmake ON )

message ( STATUS "TwxGlobalLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxGlobalLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTreeTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Global )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_global_restore" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT init/1 )
twx_test_fatal_assert_passed()
if ( TRUE )
  unset ( TwxGlobalTest.tree/ )
  twx_global_restore ( TREE TwxGlobalTest.tree/ )
  twx_tree_assert ( TwxGlobalTest.tree/ )
  twx_assert_true ( "${TWX_IS_TREE_TwxGlobalTest.tree/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/1 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_set ( key=value )
  twx_global_restore ()
  twx_expect ( TWX_GLOBAL_TREE/ "${TWX_TREE_HEADER}${TWX_TREE_GROUP_SEP}key${TWX_TREE_RECORD_SEP}value" )
  twx_global_get ( KEY key )
  twx_expect ( TWX_GLOBAL_TREE/key "value" )
  twx_global_get ( KEY key )
  twx_expect ( TWX_GLOBAL_TREE/key "value" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/remove/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/remove/1 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key=value )
  twx_regex_escape ( "key" IN_VAR scp_key_ )
  twx_expect ( scp_key_ "key" )
  twx_expect_matches ( "${A/}" "${TWX_TREE_GROUP_SEP}${scp_key_}${TWX_TREE_RECORD_SEP}" )
  twx_expect_matches ("${A/}" "${TWX_TREE_GROUP_SEP}(${scp_key_})${TWX_TREE_RECORD_SEP}([^${TWX_TREE_GROUP_SEP}]*)" )
  twx_global_remove ( KEYS key )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/2" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( actual/ )
  twx_global_set ( TREE actual/ key/key=value )
  twx_global_init ( A/ )
  twx_global_set ( key=value )
  twx_global_init ( expected/ )
  twx_global_set ( TREE expected/ key=${A/} )
  twx_expect ( actual/ "${expected/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key=value )
  twx_global_set ( key=other_value )
  twx_expect ( A/ "${TWX_TREE_HEADER}${TWX_TREE_GROUP_SEP}key${TWX_TREE_RECORD_SEP}other_value" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/get/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/1 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key=value )
  set ( A.key dummy )
  twx_global_get ( KEY key )
  twx_expect ( A.key "value" )
  twx_assert_undefined ( TWX_IS_TREE_A.key )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_set/get/2" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/2 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( k/kk/kkk=value )
  set ( A.k/kk/kkk dummy )
  set ( TWX_IS_TREE_A.k/kk/kkk dummy )
  twx_global_get ( KEY k/kk/kkk )
  twx_expect ( A.k/kk/kkk "value" )
  twx_assert_undefined ( TWX_IS_TREE_A.k/kk/kkk )
  twx_global_init ( expected/ )
  twx_global_set ( TREE expected/ kkk=value )
  set ( A.k/kk/ dummy )
  twx_global_get ( IN_VAR A.k/kk/ KEY k/kk )
  unset ( A.k/ )
  twx_global_get ( IN_VAR A.k/ KEY k )
  twx_global_init ( expected/ )
  twx_global_set ( TREE expected/ kk/kkk=value )
  twx_expect ( A.k/ "${expected/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_remove/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_remove ( KEYS what ever )
  twx_global_init ( B/ )
  twx_expect ( A/ "${B/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_remove/2" )
block ()
twx_test_fatal_assert_passed()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key=value )
  twx_global_remove ( KEYS key what ever )
  twx_global_init ( B/ )
  twx_expect ( A/ "${B/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_remove/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/3 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key/key/key=value )
  twx_global_remove ( KEYS what ever key )
  twx_global_init ( expected/ )
  twx_message ( STATUS "${A/}" )
  twx_global_get ( IN_VAR A.key/ KEY key )
  twx_global_assert ( A.key/ )
  twx_expect ( A.key/ "${expected/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_remove/4" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/4 )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_set ( key/key/key=value )
  twx_global_remove ( KEYS key/key )
  twx_global_get ( IN_VAR A.key/key/ KEY key/key )
  twx_global_assert ( A.key/key/ )
  twx_global_get ( IN_VAR A.key/ KEY key )
  twx_global_assert ( A.key/ )
  twx_global_get ( TREE A.key/ IN_VAR A.key.key/ KEY key )
  twx_global_assert ( A.key.key/ )
  twx_global_init ( expected/ )
  twx_expect ( A.key.key/ "${expected/}" )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "Test twx_global_..." )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
  twx_global_set ( k1/k1=v11 k1/k2=v12 k2/k1=v21 k2/k2=v22 k3=v3 k4=v4 )
  twx_global_log ( )
  twx_global_prettify ( IN_VAR pretty )
  message ( STATUS "A/ => ${pretty}")
  unset ( A.k1/ )
  twx_global_get ( IN_VAR A.k1/ KEY k1 )
  twx_assert_defined ( A.k1/ )
  twx_assert_true ( "${TWX_IS_TREE_A.k1/}" )
  # TODO: twx_global_assert -> twx_assert_global
  twx_global_assert ( A.k1/ )
  unset ( A.k1.k1/ )
  twx_global_get ( TREE A.k1/ IN_VAR A.k1.k1/ KEY k1 )
  twx_expect ( A.k1.k1/ v11 )
  unset ( A.k1.k2/ )
  twx_global_get ( TREE A.k1/ IN_VAR A.k1.k2/ KEY k2 )
  twx_expect ( A.k1.k2/ v12 )
endif ()
twx_test_fatal_assert_passed()
endblock ()

message ( STATUS "" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_ )
endblock ()



message ( STATUS "Globals inside trees" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT subtrees )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ( A/ )
  twx_global_init ( AA/ )
  twx_global_init ( AAA/ )
  twx_global_set ( TREE AAA/ "kkk=vvv" )
  twx_global_set ( TREE AA/  "kk=${AAA/}" )
  set ( AA.kk/ dummy )
  twx_global_get ( TREE AA/ IN_VAR AA.kk/ KEY kk )
  twx_global_assert ( AA.kk/ )
  twx_expect ( AA.kk/ "${AAA/}" )
  set ( v dummy )
  twx_global_get ( TREE AA/ IN_VAR v KEY kk/kkk )
  twx_expect ( v "vvv" )
  twx_global_set (  "k=${AA/}" )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k )
  twx_expect ( v "${AA/}" )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k/kk )
  twx_expect ( v "${AAA/}" )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k/kk/kkk )
  twx_expect ( v "vvv" )
  # Direct definition
  twx_global_init ( A/ )
  twx_global_set ( k/kk/kkk=vvv )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k )
  twx_expect ( v "${AA/}" )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k/kk )
  twx_expect ( v "${AAA/}" )
  set ( v dummy )
  twx_global_get ( IN_VAR v KEY k/kk/kkk )
  twx_expect ( v "vvv" )
endif ()
twx_test_fatal_assert_passed()
endblock()

message ( STATUS "Test Global with default Global" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT TWX_TREE )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ()
  twx_global_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
  twx_global_set ( k=v )
  twx_global_get ( IN_VAR v KEY k )
  twx_expect ( v "${v}" )
endif ()
twx_test_fatal_assert_passed()
endblock()

message ( STATUS "Test twx_global_get" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ()
  set ( v dummy )
  twx_assert_defined ( v )
  twx_global_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_test_fatal_assert_passed()
endblock()
message ( STATUS "Test twx_global_set" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ()
  twx_global_set ( k=v )
  twx_global_get ( IN_VAR v KEY k )
  twx_expect ( v v )
endif ()
twx_test_fatal_assert_passed()
endblock()
message ( STATUS "Test twx_global_remove" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_test_fatal_assert_passed()
if ( FALSE )
  twx_global_init ()
  twx_global_set ( k=v )
  twx_global_remove ( KEYS k )
  set ( v dummy )
  twx_assert_defined ( v )
  twx_global_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_test_fatal_assert_passed()
endblock()

endblock ()

message ( STATUS "TwxGlobalLib test...")

#*/
