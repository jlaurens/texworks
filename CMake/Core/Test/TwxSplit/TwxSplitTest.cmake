#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxSplitLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

# message ( STATUS "ARGC" )
# block ()
# list ( APPEND CMAKE_MESSAGE_CONTEXT ARGC )
# function ( TwxSplitTest_ARGC a )
#   set ( b 4 )
#   if ( ${ARGC} GREATER a )
#     message ( STATUS "1) ARGC > ${a}")
#   else ()
#     message ( STATUS "1) ARGC <= ${a}")
#   endif ()
#   if ( ARGC GREATER a )
#     message ( STATUS "2) ARGC > ${a}")
#   else ()
#     message ( STATUS "2) ARGC <= ${a}")
#   endif ()
# endfunction ()
# set ( a b )
# set ( b 1 )
# TwxSplitTest_ARGC ( 1 2 3 )
# endblock()

# ANCHOR: assign(0)
twx_test_unit_will_begin ( ID "assign(0)" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Too many arguments" )
  twx_split_assign ( a b c d e f ) # `twx_split_assign ( 1 2 3 4 5 6 )` has side effects
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad keyword 1" )
  twx_split_assign ( kv IN_KEYx k IN_VALUE v )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad keyword 2" )
  twx_split_assign ( kv IN_KEY k IN_VALUEx v )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad variable names" )
  twx_var_assert_name ( "<k>" )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad variable names(2)" )
  twx_var_assert_name ( " " )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad key" )
  twx_split_assign ( kv IN_KEY <k> IN_VALUE v )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "bad value" )
  twx_split_assign ( kv IN_KEY k IN_VALUE <v> )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "not the same variable names" )
  twx_split_assign ( kv IN_KEY w IN_VALUE w )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Context" )
  set ( k )
  twx_assert_undefined ( k )
  set ( v )
  twx_assert_undefined ( k v )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "Normal call" )
  twx_split_assign ( key=value IN_KEY k IN_VALUE v )
  twx_expect ( k key )
  twx_expect ( v value )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "Normal call, value with ``=''" )
  set ( k )
  set ( v )
  twx_assert_undefined ( k v )
  twx_split_assign ( key=va=ue IN_KEY k IN_VALUE v )
  twx_expect ( k key )
  twx_expect ( v va=ue )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "No key" )
  set ( k )
  set ( v )
  twx_assert_undefined ( k v )
  twx_split_assign ( =value IN_KEY k IN_VALUE v )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Only key" )
  set ( k )
  set ( v )
  twx_assert_undefined ( k v )
  twx_split_assign ( key IN_KEY k IN_VALUE v )
  twx_expect ( k key )
  twx_assert_undefined ( v )
  twx_test_simple_assert_pass ()

  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: assign(1)
twx_test_unit_will_begin ( ID "assign(1)" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Too many arguments" )
  twx_split_assign ( a b c d e f ) # `twx_split_assign ( 1 2 3 4 5 6 )` has side effects
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad keyword 1" )
  twx_split_assign ( kv IN_VARx )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Normal call" )
  set ( kv.key )
  set ( kv.value )
  twx_assert_undefined ( kv.key kv.value )
  twx_split_assign ( key=value IN_VAR kv )
  twx_expect ( kv.key key )
  twx_expect ( kv.value value )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "Normal call, value with ``=''" )
  set ( kv.key )
  set ( kv.value )
  twx_assert_undefined ( kv.key kv.value )
  twx_split_assign ( key=va=ue IN_VAR kv )
  twx_expect ( kv.key key )
  twx_expect ( kv.value va=ue )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "No key'" )
  twx_split_assign ( =value IN_VAR kv )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Only key" )
  set ( kv.key )
  set ( kv.value )
  twx_assert_undefined ( kv.key kv.value )
  twx_split_assign ( key IN_VAR kv )
  twx_expect ( kv.key key )
  twx_assert_undefined ( kv.value )
  twx_test_simple_assert_pass ()

  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: assign(2)
twx_test_unit_will_begin ( ID "assign(2)" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "key1=value1" )
  set ( kv.key )
  set ( kv.value )
  twx_assert_undefined ( kv.key kv.value )
  set ( kv "key1=value1" )
  twx_split_assign ( kv )
  twx_expect ( kv.key key1 )
  twx_expect ( kv.value value1 )
  twx_test_simple_assert_pass ()

  twx_expect ( kv.value value1 )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: compare
twx_test_unit_will_begin ( ID compare )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Too few arguments" )
  twx_split_compare ( a b c d e f g h )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Too many arguments" )
  twx_split_compare ( a b c d e f g h i j )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad keyword 1" )
  twx_split_compare ( a IN_LEFTx b IN_OP c IN_RIGHT d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad keyword 2" )
  twx_split_compare ( a IN_LEFT b IN_OPs c IN_RIGHT d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad keyword 3" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHTd d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad keyword 4" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d IN_NEGATEq e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad variable name 1" )
  twx_split_compare ( a IN_LEFT b! IN_OP c IN_RIGHT d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad variable name 2" )
  twx_split_compare ( a IN_LEFT b IN_OP c! IN_RIGHT d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad variable name 3" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d! IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Bad variable name 4" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d IN_NEGATE e! )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 1-2" )
  twx_split_compare ( a IN_LEFT b IN_OP b IN_RIGHT d IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 1-3" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT b IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 1-4" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d IN_NEGATE b )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 2-3" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT c IN_NEGATE e )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 2-4" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d IN_NEGATE c )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Not the same variable name 3-4" )
  twx_split_compare ( a IN_LEFT b IN_OP c IN_RIGHT d IN_NEGATE d )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Normal call" )
  set ( l )
  set ( o )
  set ( r )
  set ( n )
  twx_assert_undefined ( l o r n )
  set ( argn_ IN_LEFT l IN_OP o IN_RIGHT r IN_NEGATE n )
  twx_split_compare ( ll=rr ${argn_} )
  twx_expect ( l ll )
  twx_expect ( o EQUAL )
  twx_expect ( r rr )
  twx_assert_false ( n )
  twx_test_simple_assert_pass ()

  function ( twx_split_compare_test comparison l_ o_ r_ n_ )
    twx_test_simple_start ( "${comparison}" )
    twx_split_compare ( "${comparison}" IN_LEFT l IN_OP o IN_RIGHT r IN_NEGATE n )
    twx_expect ( l "${l_}" )
    twx_expect ( o "${o_}" )
    twx_expect ( r "${r_}" )
    cmake_language ( CALL "${n_}" "${n}" )
    twx_test_simple_assert_pass ()
  endfunction ()
  twx_split_compare_test ( ll=rr ll EQUAL rr twx_assert_false )
  twx_split_compare_test ( ll==rr ll EQUAL rr twx_assert_false )
  twx_split_compare_test ( ll<rr ll LESS rr twx_assert_false )
  twx_split_compare_test ( ll<=rr ll LESS_EQUAL rr twx_assert_false )
  twx_split_compare_test ( ll>rr ll GREATER rr twx_assert_false )
  twx_split_compare_test ( ll>=rr ll GREATER_EQUAL rr twx_assert_false )
  twx_split_compare_test ( ll!=rr ll EQUAL rr twx_assert_true )
  twx_split_compare_test ( ll<>rr ll EQUAL rr twx_assert_true )
  twx_split_compare_test ( !ll=rr ll EQUAL rr twx_assert_true )
  twx_split_compare_test ( !ll==rr ll EQUAL rr twx_assert_true )
  twx_split_compare_test ( !ll<rr ll LESS rr twx_assert_true )
  twx_split_compare_test ( !ll<=rr ll LESS_EQUAL rr twx_assert_true )
  twx_split_compare_test ( !ll>rr ll GREATER rr twx_assert_true )
  twx_split_compare_test ( !ll>=rr ll GREATER_EQUAL rr twx_assert_true )
  twx_split_compare_test ( !ll!=rr ll EQUAL rr twx_assert_false )
  twx_split_compare_test ( !ll<>rr ll EQUAL rr twx_assert_false )

  twx_test_simple_start ( "Bad comparison" )
  twx_split_compare ( kk===ll IN_LEFT l IN_OP o IN_RIGHT r IN_NEGATE n )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "No comparison" )
  twx_split_compare ( kkll IN_LEFT l IN_OP o IN_RIGHT r IN_NEGATE n )
  twx_test_simple_assert_fail ()

  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: append
twx_test_unit_will_begin ( ID append )
if ( TWX_TEST_UNIT_RUN )
  block ()

  twx_test_simple_start ( "Void string" )
  twx_split_append ( "" )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Multi" )
  set ( list1 )
  set ( list2 )
  twx_split_append (
    list1=<<1.1
    list1=<<1.2
    "list2=<<2.1;2.2"
    list1=<<1.3
    list2=<<2.3
  )
  twx_expect ( list1 "1.1;1.2;1.3" )
  twx_expect ( list2 "2.1;2.2;2.3" )
  twx_test_simple_assert_pass ()

  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: prepend
twx_test_unit_will_begin ( ID prepend )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Void string" )
  twx_split_prepend ( "" )
  twx_test_simple_assert_fail ()

  twx_test_simple_start ( "Multi" )
  set ( list1 )
  set ( list2 )
  twx_split_prepend (
    list1=>>1.1
    list1=>>1.2
    "list2=>>2.1;2.2"
    list1=>>1.3
    list2=>>2.3
  )
  twx_expect ( list1 "1.3;1.2;1.1" )
  twx_expect ( list2 "2.3;2.1;2.2" )
  twx_test_simple_assert_pass ()

  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
