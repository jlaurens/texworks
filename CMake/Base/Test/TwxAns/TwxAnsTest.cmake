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

twx_test_suite_will_begin ()
block ()

twx_tree_init ( empty/ )

message ( STATUS "twx_ans_*" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT * )
twx_fatal_assert_passed ()
if ( TRUE )
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
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_ans_clear" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT clear )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_ans_clear ()
  twx_tree_assert ( TWX_ANS )
  twx_expect ( TWX_ANS "${empty/}" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_ans_get_keys" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT get_keys )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_ans_clear ()
  set ( keys "dummy" )
  twx_assert_defined ( keys )
  twx_ans_get_keys ( IN_VAR keys )
  twx_assert_undefined ( keys )
  twx_tree_set ( TREE TWX_ANS k=v )
  twx_ans_get_keys ( IN_VAR keys )
  twx_expect_list ( keys "k" )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_ans_set/get/remove" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT set/get/remove )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_ans_clear ()
  set ( TWX_ANS/k "dummy" )
  twx_ans_get ( KEY k )
  twx_assert_undefined ( TWX_ANS/k )
  twx_ans_set ( k=v )
  twx_ans_get ( KEY k )
  twx_expect ( TWX_ANS/k "v" )
  twx_ans_remove ( KEY k )
  twx_ans_get ( KEY k )
  twx_assert_undefined ( TWX_ANS/k )
endif ()
twx_fatal_assert_passed ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#*/
