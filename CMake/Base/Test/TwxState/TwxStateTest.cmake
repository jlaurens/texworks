#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing State.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

message ( STATUS "TwxStateLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxTestLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxStateLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxCore/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxTree/TwxTreeTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxHook/TwxHookTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxArg/TwxArgTest.cmake" )

block ()
twx_test_suite_will_begin ()

message ( "twx_state_*" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT * )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_state_key_add ( KEY k )
  twx_state_key_remove ( KEY k )
  twx_state_serialize ( IN_VAR saved )
  twx_state_deserialize ( saved )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

message ( "twx_state_(de)serialize" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "(de)serialize" )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( TWX_DEV   <TWX_DEV> )
  set ( TWX_TEST  <TWX_TEST> )
  # set ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # set ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # set ( CMAKE_MESSAGE_INDENT        .. )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # set ( CMAKE_MESSAGE_CONTEXT       "a;b;c" )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  twx_state_serialize ( IN_VAR saved )
  twx_tree_assert ( saved )
  # twx_tree_log ( TREE saved )
  set ( TWX_DEV   <> )
  set ( TWX_TEST  <> )
  # set ( CMAKE_BINARY_DIR <> )
  # set ( CMAKE_SOURCE_DIR <> )
  # set ( CMAKE_MESSAGE_INDENT        <> )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
  # set ( CMAKE_MESSAGE_CONTEXT       <> )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  ON )
  twx_state_deserialize ( saved )
  twx_expect ( TWX_DEV   <TWX_DEV> )
  twx_expect ( TWX_TEST  <TWX_TEST> )
  # twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # twx_expect ( CMAKE_MESSAGE_INDENT        .. )
  # twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT       "" )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

message ( "twx_state_key_add/remove" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "key_add/remove" )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( TWX_DEV   <TWX_DEV>   )
  set ( TWX_TEST  <TWX_TEST>  )
  twx_state_key_add ( TWX_OTHER )
  set ( TWX_OTHER <TWX_OTHER> )
  twx_state_serialize ( IN_VAR saved )
  twx_tree_log ( TREE saved )
  set ( TWX_DEV   <> )
  set ( TWX_TEST  <> )
  set ( TWX_OTHER <> )
  twx_state_deserialize ( saved )
  twx_expect ( TWX_DEV   <TWX_DEV>    )
  twx_expect ( TWX_TEST  <TWX_TEST>   )
  twx_expect ( TWX_OTHER <TWX_OTHER>  )
  twx_state_key_remove ( TWX_OTHER )
  twx_state_serialize ( IN_VAR saved )
  set ( TWX_DEV   <> )
  set ( TWX_TEST  <> )
  set ( TWX_OTHER <> )
  twx_state_deserialize ( saved )
  twx_expect ( TWX_DEV   <TWX_DEV>    )
  twx_expect ( TWX_TEST  <TWX_TEST>   )
  twx_expect ( TWX_OTHER <> )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

message ( "twx_state_will_serialize_register" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "preparation_register" )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_state_will_serialize_register ( TwxStateTest.preparation_register )
  set ( TWX_DEV   <> )
  set ( TWX_TEST  <> )
  macro ( TwxStateTest.preparation_register )
    message ( STATUS "TwxStateTest.preparation_register")
    set ( TWX_DEV   <TWX_DEV>   )
    set ( TWX_TEST  <TWX_TEST>  )
  endmacro ()
  twx_state_serialize ( IN_VAR saved )
  twx_state_deserialize ( saved )
  twx_expect ( TWX_DEV   <TWX_DEV>    )
  twx_expect ( TWX_TEST  <TWX_TEST>   )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxStateLib test... DONE")

#*/
