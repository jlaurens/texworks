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

twx_test_suite_push ()
block ()

# ANCHOR: twx_state_*
twx_test_unit_push ( CORE "..." )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "..." )
  twx_state_key_add ( KEY k )
  twx_state_key_remove ( KEY k )
  twx_state_serialize ( IN_VAR saved )
  twx_state_deserialize ( saved )
  twx_test_simple_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: (de)serialize
twx_test_unit_push ( CORE "de/serialize" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( /TWX/DEV   </TWX/DEV> )
  set ( /TWX/TESTING  </TWX/TESTING> )
  # set ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # set ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # set ( CMAKE_MESSAGE_INDENT        .. )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # set ( CMAKE_MESSAGE_CONTEXT       "a;b;c" )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  twx_test_simple_check ( "serialize" )
  twx_state_serialize ( IN_VAR saved )
  twx_tree_assert ( TREE saved )
  twx_test_simple_pass ()

  twx_tree_log ( TRACE TREE saved )

  twx_test_simple_check ( "deserialize" )
  set ( /TWX/DEV   <> )
  set ( /TWX/TESTING  <> )
  # set ( CMAKE_BINARY_DIR <> )
  # set ( CMAKE_SOURCE_DIR <> )
  # set ( CMAKE_MESSAGE_INDENT        <> )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
  # set ( CMAKE_MESSAGE_CONTEXT       <> )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  ON )
  twx_tree_assert ( TREE saved )
  twx_state_deserialize ( saved )  
  twx_expect ( /TWX/DEV   </TWX/DEV> )
  twx_expect ( /TWX/TESTING  </TWX/TESTING> )
  twx_test_simple_pass ()
  # twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # twx_expect ( CMAKE_MESSAGE_INDENT        .. )
  # twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT       "" )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: (de)serialize(2)
# with `;'
twx_test_unit_push ( CORE "(de)serialize(2)" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( /TWX/DEV   "</TWX/DEV>" )
  set ( /TWX/TESTING  "</TWX/TEST/1;/TWX/TEST/2>" )
  # set ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # set ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # set ( CMAKE_MESSAGE_INDENT        .. )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # set ( CMAKE_MESSAGE_CONTEXT       "a;b;c" )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  twx_state_serialize ( IN_VAR saved )
  twx_tree_assert ( TREE saved )
  # twx_tree_log ( TREE saved )
  set ( /TWX/DEV   "<>" )
  set ( /TWX/TESTING  "<>" )
  # set ( CMAKE_BINARY_DIR <> )
  # set ( CMAKE_SOURCE_DIR <> )
  # set ( CMAKE_MESSAGE_INDENT        <> )
  # set ( CMAKE_MESSAGE_LOG_LEVEL     <> )
  # set ( CMAKE_MESSAGE_CONTEXT       <> )
  # set ( CMAKE_MESSAGE_CONTEXT_SHOW  ON )
  twx_state_deserialize ( saved )
  twx_expect ( /TWX/DEV   "</TWX/DEV>" )
  twx_expect ( /TWX/TESTING  "</TWX/TEST/1;/TWX/TEST/2>" )
  # twx_expect ( CMAKE_BINARY_DIR <CMAKE_BINARY_DIR> )
  # twx_expect ( CMAKE_SOURCE_DIR <CMAKE_SOURCE_DIR> )
  # twx_expect ( CMAKE_MESSAGE_INDENT        .. )
  # twx_expect ( CMAKE_MESSAGE_LOG_LEVEL     TRACE )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT       "" )
  # twx_expect ( CMAKE_MESSAGE_CONTEXT_SHOW  Y )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: key_add/remove
twx_test_unit_push ( CORE "key_add/remove" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( /TWX/DEV   </TWX/DEV>   )
  set ( /TWX/TESTING  </TWX/TESTING>  )
  twx_state_key_add ( TWX_OTHER )
  set ( TWX_OTHER <TWX_OTHER> )
  twx_state_serialize ( IN_VAR saved )
  # twx_tree_log ( TREE saved )
  set ( /TWX/DEV   <> )
  set ( /TWX/TESTING  <> )
  set ( TWX_OTHER <> )
  twx_state_deserialize ( saved )
  twx_expect ( /TWX/DEV   </TWX/DEV>   )
  twx_expect ( /TWX/TESTING  </TWX/TESTING>  )
  twx_expect ( TWX_OTHER <TWX_OTHER> )
  twx_state_key_remove ( TWX_OTHER )
  twx_state_serialize ( IN_VAR saved )
  set ( /TWX/DEV   <> )
  set ( /TWX/TESTING  <> )
  set ( TWX_OTHER <> )
  twx_state_deserialize ( saved )
  twx_expect ( /TWX/DEV   </TWX/DEV>  )
  twx_expect ( /TWX/TESTING  </TWX/TESTING> )
  twx_expect ( TWX_OTHER <> )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: preparation_register
twx_test_unit_push ( NAME "twx_state_will_serialize_register" CORE "preparation_register" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_state_will_serialize_register ( TwxStateTest.preparation_register )
  set ( /TWX/DEV   <> )
  set ( /TWX/TESTING  <> )
  macro ( TwxStateTest.preparation_register )
    message ( STATUS "TwxStateTest.preparation_register")
    set ( /TWX/DEV   </TWX/DEV>  )
    set ( /TWX/TESTING  </TWX/TESTING> )
  endmacro ()
  twx_state_serialize ( IN_VAR saved )
  twx_state_deserialize ( saved )
  twx_expect ( /TWX/DEV   </TWX/DEV>  )
  twx_expect ( /TWX/TESTING  </TWX/TESTING> )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Script
twx_test_unit_push ( NAME "Script" )
# Communicate with the script
if ( /TWX/TEST/UNIT.RUN )
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
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
