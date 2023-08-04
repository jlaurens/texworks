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

twx_test_suite_will_begin ()
block ()

# ANCHOR: twx_state_*
twx_test_unit_will_begin ( ID "*" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_state_key_add ( KEY k )
  twx_state_key_remove ( KEY k )
  twx_state_serialize ( IN_VAR saved )
  twx_state_deserialize ( saved )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: (de)serialize
twx_test_unit_will_begin ( ID "(de)serialize" )
if ( TWX_TEST_UNIT_RUN )
  block ()
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
  twx_fatal_assert_passed ()
  twx_tree_log ( TREE saved )
  set ( TWX_DEV   <> )
  set ( TWX_TEST  <> )
  # set ( CMAKE_BINARY_DIR <> )
  # set ( CMAKE_SOURCE_DIR <> )
  # set ( CMAKE_MESSAGE_INDENT        <> )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
  # set ( CMAKE_MESSAGE_CONTEXT       <> )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  ON )
  twx_tree_assert ( saved )
  twx_state_deserialize ( saved )
  twx_fatal_assert_passed ()
  twx_expect ( TWX_DEV   <TWX_DEV> )
  twx_fatal_assert_passed ()
  twx_expect ( TWX_TEST  <TWX_TEST> )
  twx_fatal_assert_passed ()
  # twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # twx_expect ( CMAKE_MESSAGE_INDENT        .. )
  # twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT       "" )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: (de)serialize(2)
# with `;'
twx_test_unit_will_begin ( ID "(de)serialize(2)" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( TWX_DEV   "<TWX_DEV>" )
  set ( TWX_TEST  "<TWX_TEST_1;TWX_TEST_2>" )
  # set ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # set ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # set ( CMAKE_MESSAGE_INDENT        .. )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # set ( CMAKE_MESSAGE_CONTEXT       "a;b;c" )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  twx_state_serialize ( IN_VAR saved )
  twx_tree_assert ( saved )
  # twx_tree_log ( TREE saved )
  set ( TWX_DEV   "<>" )
  set ( TWX_TEST  "<>" )
  # set ( CMAKE_BINARY_DIR <> )
  # set ( CMAKE_SOURCE_DIR <> )
  # set ( CMAKE_MESSAGE_INDENT        <> )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
  # set ( CMAKE_MESSAGE_CONTEXT       <> )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  ON )
  twx_state_deserialize ( saved )
  twx_expect ( TWX_DEV   "<TWX_DEV>" )
  twx_expect ( TWX_TEST  "<TWX_TEST_1;TWX_TEST_2>" )
  # twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # twx_expect ( CMAKE_MESSAGE_INDENT        .. )
  # twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT       "" )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: key_add/remove
twx_test_unit_will_begin ( ID "key_add/remove" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( TWX_DEV   <TWX_DEV>   )
  set ( TWX_TEST  <TWX_TEST>  )
  twx_state_key_add ( TWX_OTHER )
  set ( TWX_OTHER <TWX_OTHER> )
  twx_state_serialize ( IN_VAR saved )
  # twx_tree_log ( TREE saved )
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
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: preparation_register
twx_test_unit_will_begin ( NAME "twx_state_will_serialize_register" ID "preparation_register" )
if ( TWX_TEST_UNIT_RUN )
  block ()
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
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: Script
twx_test_unit_will_begin ( NAME "Script" )
# Communicate with the script
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_state_key_add ( TWX_FOUR )
  set ( TWX_FOUR "F O;U\nR" )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "${-DTWX_STATE}"
    -P "${CMAKE_CURRENT_LIST_DIR}/TwxStateScript.cmake"
    RESULT_VARIABLE twx.RESULT_VARIABLE
    ERROR_VARIABLE twx.ERROR_VARIABLE
    OUTPUT_VARIABLE twx.OUTPUT_VARIABLE
    ERROR_STRIP_TRAILING_WHITESPACE
    # COMMAND_ERROR_IS_FATAL ANY
  )
  message ( "twx.RESULT_VARIABLE => ``${twx.RESULT_VARIABLE}''" )
  message ( "twx.ERROR_VARIABLE  => ``${twx.ERROR_VARIABLE}''"  )
  message ( "twx.OUTPUT_VARIABLE => ``${twx.OUTPUT_VARIABLE}''" )
  twx_assert_no_error ()
  twx_fatal_assert_passed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/
