#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxTreeLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

twx_tree_assert ( TWX_TREE )
twx_assert_true ( "${TWX_IS_TREE_TWX_TREE}" )

message ( STATUS "twx_tree_prettify" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_ )
twx_fatal_assert_passed ()
if ( TRUE )
  unset ( m)
  twx_tree_prettify ( "${TWX_TREE_MARK}${TWX_TREE_START}${TWX_TREE_RECORD}${TWX_TREE_SEP}" IN_VAR m )
  twx_expect ( m "<SOH><STX><GS/><RS/>" )
  twx_tree_prettify ( "${TWX_TREE_HEADER}" IN_VAR m )
  twx_expect ( m "<SOH>TwxTree<STX>" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "TWX_TREE_KEY_RE" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT KEY_RE )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_fatal_test ()
  # set (
  #   TWX_TREE_KEY_RE
  #   "([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9_.+-]|\\[^a-zA-Z0-9;]|\\[trn]|\\;)*"
  # )
  twx_expect_matches ( a "${TWX_TREE_KEY_RE}" )
  twx_expect_matches ( abc "${TWX_TREE_KEY_RE}" )
  twx_expect_unmatches ( 0abc "^${TWX_TREE_KEY_RE}$" )
  twx_expect_unmatches ( / "^${TWX_TREE_KEY_RE}$" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_tree_assert_key" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT assert_key )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_fatal_test ()
  twx_tree_assert_key ( a )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  twx_tree_assert_key ( / )
  twx_fatal_assert_failed ()
  twx_tree_assert_key ( a )
  twx_fatal_assert_passed ()
  twx_fatal_test ()
  twx_tree_assert_key ( a/ )
  twx_fatal_assert_failed ()
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_tree_init/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT init/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  unset ( A/ )
  twx_tree_init ( A/ )
  twx_tree_assert ( A/ )
  twx_assert_true ( "${TWX_IS_TREE_A/}" )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
endif ()
twx_fatal_assert_passed ()
twx_fatal_test ()
endblock ()

message ( STATUS "twx_tree_init(1-2)" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT init/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  set ( A/ dummy )
  twx_tree_init ( A/ )
  twx_tree_assert ( A/ )
  twx_assert_true ( "${TWX_IS_TREE_A/}" )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_get_keys/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get_keys/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  set ( A/ "${TWX_TREE_HEADER}\
${TWX_TREE_RECORD}a1${TWX_TREE_SEP}\
${TWX_TREE_RECORD}a2${TWX_TREE_SEP}\
${TWX_TREE_RECORD}b1${TWX_TREE_SEP}\
${TWX_TREE_RECORD}b2${TWX_TREE_SEP}\
" )
  set ( keys )
  twx_tree_get_keys ( TREE A/ IN_VAR keys )
  twx_expect_list ( keys "a1" "a2" "b1" "b2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX a )
  twx_expect_list ( keys "a1" "a2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX a RELATIVE )
  twx_expect_list ( keys "1" "2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX b )
  twx_expect_list ( keys "b1" "b2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX b RELATIVE )
  twx_expect_list ( keys "1" "2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys MATCHES 1$ )
  twx_expect_list ( keys "a1" "b1" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys MATCHES 2$ )
  twx_expect_list ( keys "a2" "b2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX a MATCHES 1$ )
  twx_expect_list ( keys "a1" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX b MATCHES 2$ )
  twx_expect_list ( keys "b2" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX a RELATIVE MATCHES 1$ )
  twx_expect_list ( keys "1" )
  twx_tree_get_keys ( TREE A/ IN_VAR keys PREFIX b RELATIVE MATCHES 2$ )
  twx_expect_list ( keys "2" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_get/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_fatal_test ()
  twx_tree_assert ( A/ )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_tree_get ( TREE A/ KEY key )  
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_tree_init ( A/ )
  twx_tree_get ( STREE A/ KEY key )  
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_tree_get ( TREE A/ XKEY key )  
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  twx_tree_get ( TREE A/ KEY "k e y" )  
  twx_fatal_assert_failed ()
  twx_fatal_test ()
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_get/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  unset ( A/ )
  twx_tree_init ( A/ )
  set ( A.whatever dummy )
  set ( TWX_IS_TREE_A.whatever dummy )
  twx_tree_get ( TREE A/ IN_VAR A.whatever KEY whatever )
  twx_fatal_assert_passed ()
  message ( TR@CE "twx_tree_get DONE" )
  twx_assert_undefined ( A.whatever )
  twx_assert_undefined ( TWX_IS_TREE_A.whatever )
  set ( A.whenever dummy )
  set ( TWX_IS_TREE_A/whenever dummy )
  twx_tree_get ( TREE A/ KEY whenever )
  twx_assert_undefined ( A/whenever )
  twx_assert_undefined ( TWX_IS_TREE_A.whenever )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  unset ( A/ )
  twx_tree_init ( A/ )
  twx_tree_assert ( A/ )
  twx_tree_set ( TREE A/ key=value )
  twx_expect ( A/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key${TWX_TREE_SEP}value" )
  set ( A/key dummy )
  twx_tree_get ( TREE A/ IN_VAR A/key KEY key )
  twx_expect ( A/key value )
  set ( A/key dummy )
  twx_tree_get ( TREE A/ KEY key )
  twx_expect ( A/key value )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/2" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  unset ( A/ )
  twx_tree_init ( A/ )
  twx_tree_assert ( A/ )
  twx_tree_set ( TREE A/ key=${A/} )
  twx_expect ( A/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key/${TWX_TREE_SEP}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/remove/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/remove/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  twx_regex_escape ( "key" IN_VAR scp_key_ )
  twx_expect ( scp_key_ "key" )
  twx_expect_matches ( "${A/}" "${TWX_TREE_RECORD}${scp_key_}${TWX_TREE_SEP}" )
  twx_expect_matches ( "${A/}" "${TWX_TREE_RECORD}(${scp_key_})${TWX_TREE_SEP}([^${TWX_TREE_RECORD}]*)" )
  twx_tree_remove ( TREE A/ KEY key )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/2" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ key/key=value )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  twx_tree_init ( actual/ )
  twx_tree_set ( TREE actual/ key=${A/} )
  # twx_tree_prettify ( "${expected/}" IN_VAR pretty )
  # message ( TR@CE "expected/ => \"${pretty}\"" )
  # twx_tree_prettify ( "${actual/}" IN_VAR pretty )
  # message ( TR@CE "actual/ => \"${pretty}\"" )
  twx_expect ( actual/ "${expected/}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  twx_tree_set ( TREE A/ key=other_value )
  twx_expect ( A/ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}key${TWX_TREE_SEP}other_value" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/get/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  set ( A.key dummy )
  twx_tree_get ( TREE A/ KEY key )
  twx_expect ( A/key "value" )
  twx_assert_undefined ( TWX_IS_TREE_A.key )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/get/1'" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/1' )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  set ( A/key/ dummy )
  twx_tree_get ( TREE A/ KEY key )
  twx_expect ( A/key "value" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/get/2" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ k/kk/kkk=value )
  set ( A.k/kk/kkk dummy )
  set ( TWX_IS_TREE_A.k/kk/kkk dummy )
  twx_tree_get ( TREE A/ KEY k/kk/kkk )
  twx_expect ( A/k/kk/kkk "value" )
  twx_assert_undefined ( TWX_IS_TREE_A/k/kk/kkk )
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ kkk=value )
  set ( A.k/kk/ dummy )
  twx_tree_get ( TREE A/ IN_VAR A.k/kk/ KEY k/kk )
  unset ( A.k/ )
  twx_tree_get ( TREE A/ IN_VAR A.k/ KEY k )
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ kk/kkk=value )
  twx_expect ( A.k/ "${expected/}" )
  endif ()
  twx_fatal_assert_passed ()
  endblock ()
  
  message ( STATUS "Test twx_tree_remove/1" )
  block ()
  list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
  twx_fatal_assert_passed ()
  if ( TRUE )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_set/get/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/2 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ k/kk/kkk=value )
  set ( A.k/kk/kkk dummy )
  set ( TWX_IS_TREE_A.k/kk/kkk dummy )
  twx_tree_get ( TREE A/ KEY k/kk/kkk )
  twx_expect ( A/k/kk/kkk "value" )
  twx_assert_undefined ( TWX_IS_TREE_A/k/kk/kkk )
  
  twx_tree_get ( TREE A/ KEY k/kk )
  twx_tree_assert ( A/k/kk )
  twx_assert_true ( TWX_IS_TREE_A/k/kk )
  
  twx_tree_init ( B/ )
  twx_tree_set ( TREE B/ kkk=value )
  twx_expect ( A/k/kk "${B/}" )

  endif ()
  twx_fatal_assert_passed ()
  endblock ()
  
  message ( STATUS "Test twx_tree_remove/1" )
  block ()
  list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
  twx_fatal_assert_passed ()
  if ( TRUE )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_get_keys/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get_keys/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key1=value1 )
  twx_tree_get_keys ( TREE A/ IN_VAR keys )
  twx_expect_list ( keys "key1" )
  twx_tree_set ( TREE A/ key2=value2 )
  twx_tree_get_keys ( TREE A/ IN_VAR keys )
  twx_expect_list ( keys "key1" "key2" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
twx_fatal_assert_passed ()
if ( TRUE )
    # Remove unexisting key
  twx_tree_init ( A/ )
  twx_tree_remove ( TREE A/ KEY what ever )
  twx_tree_init ( B/ )
  twx_expect ( A/ "${B/}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/2" )
block ()
twx_fatal_assert_passed ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/2 )
if ( TRUE )
  # Remove value
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key=value )
  twx_tree_remove ( TREE A/ KEY key what ever )
  twx_tree_init ( B/ )
  twx_expect ( A/ "${B/}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/3 )
twx_fatal_assert_passed ()
if ( TRUE )
  # Remove whole subtree
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key/key/key=value )
  twx_tree_remove ( TREE A/ KEY what ever key )
  twx_tree_init ( expected/ )
  twx_message ( STATUS "${A/}" )
  twx_tree_get ( TREE A/ IN_VAR A.key KEY key )
  twx_assert_undefined ( A.key )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/3" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/3 )
twx_fatal_assert_passed ()
if ( TRUE )
  # Remove subtree but remember
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key/key/key=value )
  twx_tree_remove ( TREE A/ KEY what ever key )
  twx_tree_get ( TREE A/ IN_VAR A.key KEY key )
  twx_assert_undefined ( A/key )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/3'" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/3' )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key/key/key=value )
  set ( A/key "dummy" )
  twx_tree_get ( TREE A/ IN_VAR A/key KEY key )
  twx_tree_init ( B/ )
  twx_tree_set ( TREE B/ key/key=value )
  twx_expect ( A/key "${B/}" )

  twx_tree_remove ( TREE A/ KEY what ever key )
  set ( A/key "dummy" )
  twx_tree_get ( TREE A/ IN_VAR A/key KEY key )
  twx_assert_undefined ( A/key )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/4" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/4 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key/key/key=value )
  twx_tree_remove ( TREE A/ KEY key/key )
  twx_tree_get ( TREE A/ IN_VAR A.key/key KEY key/key )
  twx_assert_undefined ( A.key/key )
  twx_tree_get ( TREE A/ IN_VAR A.key/ KEY key )
  twx_tree_assert ( A.key/ )
  twx_tree_get ( TREE A.key/ IN_VAR A.key.key KEY key )
  twx_assert_undefined ( A.key.key/ )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_remove/5" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove/5 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ key/key/key=value )
  twx_tree_get ( TREE A/ IN_VAR A/key KEY key )
  twx_tree_assert ( A/key )
  twx_tree_get ( TREE A/key IN_VAR A/key/key KEY key )
  twx_tree_assert ( A/key/key )
  twx_tree_prettify ( "${A/key/key}" IN_VAR pretty )
  # message ( TR@CE "AFTER REMOVE:  A/key/key => ${pretty}")
  twx_tree_init ( expected/ )
  twx_tree_set ( TREE expected/ key=value )
  twx_expect ( A/key/key "${expected/}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Test twx_tree_..." )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_expect ( A/ "${TWX_TREE_HEADER}" )
  twx_tree_set ( TREE A/ k1/k1=v11 k1/k2=v12 k2/k1=v21 k2/k2=v22 k3=v3 k4=v4 )
  twx_tree_log ( TREE A/ )
  # twx_tree_prettify ( "${A/}" IN_VAR pretty )
  # message ( TR@CE "A/ => ${pretty}")
  unset ( A.k1/ )
  twx_tree_get ( TREE A/ IN_VAR A.k1/ KEY k1 )
  twx_assert_defined ( A.k1/ )
  twx_assert_true ( "${TWX_IS_TREE_A.k1/}" )
  # TODO: twx_tree_assert -> twx_assert_tree
  twx_tree_assert ( A.k1/ )
  unset ( A.k1.k1/ )
  twx_tree_get ( TREE A.k1/ IN_VAR A.k1.k1/ KEY k1 )
  twx_expect ( A.k1.k1/ v11 )
  unset ( A.k1.k2/ )
  twx_tree_get ( TREE A.k1/ IN_VAR A.k1.k2/ KEY k2 )
  twx_expect ( A.k1.k2/ v12 )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "Trees inside trees" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT subtrees )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ( A/ )
  twx_tree_init ( AA/ )
  twx_tree_init ( AAA/ )
  twx_tree_set ( TREE AAA/ "kkk=vvv" )
  twx_tree_set ( TREE AA/  "kk=${AAA/}" )
  set ( AA.kk/ dummy )
  twx_tree_get ( TREE AA/ IN_VAR AA.kk/ KEY kk )
  twx_tree_assert ( AA.kk/ )
  twx_expect ( AA.kk/ "${AAA/}" )
  set ( v dummy )
  twx_tree_get ( TREE AA/ IN_VAR v KEY kk/kkk )
  twx_expect ( v "vvv" )
  twx_tree_set ( TREE A/  "k=${AA/}" )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k )
  twx_expect ( v "${AA/}" )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k/kk )
  twx_expect ( v "${AAA/}" )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k/kk/kkk )
  twx_expect ( v "vvv" )
  # Direct definition
  twx_tree_init ( A/ )
  twx_tree_set ( TREE A/ k/kk/kkk=vvv )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k )
  twx_expect ( v "${AA/}" )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k/kk )
  twx_expect ( v "${AAA/}" )
  set ( v dummy )
  twx_tree_get ( TREE A/ IN_VAR v KEY k/kk/kkk )
  twx_expect ( v "vvv" )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test Tree with default Tree" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT TWX_TREE )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
  twx_tree_set ( k=v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_expect ( v "v" )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_get" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  set ( v dummy )
  twx_assert_defined ( v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_set" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k=v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_expect ( v v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove_one" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k=v )
  twx_tree_remove ( KEY k )
  set ( v dummy )
  twx_assert_defined ( v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k=v k2=v2 )
  twx_tree_remove ( KEY k k2 )
  set ( v dummy )
  twx_assert_defined ( v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
  set ( v2 dummy2 )
  twx_assert_defined ( v2 )
  twx_tree_get ( IN_VAR v2 KEY k2 )
  twx_assert_undefined ( v2 )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove(2)" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k/kk=v )
  twx_tree_remove ( KEY k/kk )
  set ( v dummy )
  twx_assert_defined ( v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_tree_assert ( v )
  twx_tree_remove ( KEY k )
  set ( v dummy )
  twx_assert_defined ( v )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove(3)" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k/kk=v )
  twx_tree_remove ( KEY m|k/.*| )
  set ( v dummy )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove(4)" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k/kk/kkk=v )
  twx_tree_remove ( KEY k/kk )
  set ( v dummy )
  twx_tree_get ( IN_VAR v KEY k )
  twx_expect ( v "${TWX_TREE_HEADER}" )
  twx_tree_remove ( KEY k )
  set ( v dummy )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_remove(5)" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k=v )
  set ( v "dummy" )
  twx_tree_get ( IN_VAR v KEY k )
  twx_expect ( v "v" )
  twx_tree_set ( k )
  set ( v "dummy" )
  twx_tree_get ( IN_VAR v KEY k )
  twx_assert_undefined ( v )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_expose/0" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT expose/0 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k=v )
  set ( k "dummy" )
  twx_tree_expose ()
  twx_expect ( k "v" )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test twx_tree_expose/1" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT expose/1 )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_tree_init ()
  twx_tree_set ( k/kk=v )
  set ( v "dummy" )
  twx_tree_get ( IN_VAR v KEY k/kk )
  twx_expect ( v "v" )
  set ( k "dummy" )
  twx_tree_expose ()
  twx_tree_assert ( k )
  set ( k/kk "dummy" )
  twx_tree_get ( TREE k KEY kk )
  twx_expect ( k/kk "v" )
endif ()
twx_fatal_assert_passed ()
endblock()

message ( STATUS "Test list support" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT list )
twx_fatal_assert_passed ()
if ( TRUE )
  message ( STATUS "1)************************************" )
  twx_tree_set ( "k=a;b" )
  message ( STATUS "2)************************************" )
  twx_tree_prettify ( "${TWX_TREE}" IN_VAR pretty )
  message ( DEBUG ( "pretty => \"${pretty}\""))
  message ( STATUS "3)************************************" )
  set ( v "dummy" )
  twx_tree_get ( IN_VAR v KEY k )
  twx_expect ( v "a;b" )
endif ()
twx_fatal_assert_passed ()
endblock()

endblock ()
twx_test_suite_did_end ()

#*/
