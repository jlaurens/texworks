#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Fatal utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxFatalLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_fatal()`, a shortcut to `message(FATAL_ERROR ...)``
  *   with some testing facilities.
  *
  * Testing utilities:
  * - `twx_fatal_catched()`
  */
/*#]===============================================]

include_guard ( GLOBAL )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxVarLib.cmake" )

twx_lib_will_load ()

# ANCHOR: twx_fatal
#[=======[
*/
/** @brief Terminate with a FATAL_ERROR message.
  *
  * @param ..., non empty list of text messages.
  *   In normal mode, all parameters are forwarded as is to `message(FATAL_ERROR ...)`.
  *   In test mode, the parameters are recorded for later use,
  *   nothing is displayed and the program does not stop.
  *   As there is no `try-catch` mechanism in `CMake`,
  *   a `return()` or `break()` statement may follow a `twx_fatal()` instruction.
  * @param RETURN, optional flag to execute `return()` in test mode
  * @param BREAK, optional flag to execute `break()` in test mode.
  *   RETURN takes precedence over BREAK.
  *
  */
twx_fatal(...){}
/*
#]=======]
macro ( twx_fatal )
  # list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  set ( twx_fatal.FILE "${CMAKE_CURRENT_LIST_FILE}" )
  set ( twx_fatal.LINE "${CMAKE_CURRENT_LIST_LINE}" )
  if ( TWX_FATAL_CATCH )
    twx_fatal_get ( IN_VAR twx_fatal.MSG )
    message ( STATUS "twx_fatal.MSG => ``${twx_fatal.MSG}''" )
    if ( DEFINED twx_fatal.MSG )
      string ( APPEND twx_fatal.MSG "\n " )
    else ()
      set ( twx_fatal.MSG " " )
    endif ()
  else ()
    set ( twx_fatal.MSG )
  endif ()
  cmake_parse_arguments (
    twx_fatal.R "RETURN;BREAK" "VAR" "" ${ARGV}
  )
  message ( STATUS "twx_fatal.MSG => ``${twx_fatal.MSG}''" )
  foreach ( twx_fatal.m twx_fatal.R_UNPARSED_ARGUMENTS )
    if ( "${twx_fatal.m}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND twx_fatal.MSG "${twx_fatal.m}\\" )
    else ()
      list ( APPEND twx_fatal.MSG "${twx_fatal.m}" )
    endif ()
  endforeach ()
  message ( STATUS "twx_fatal.MSG => ``${twx_fatal.MSG}''" )
  if ( DEFINED twx_fatal.R_VAR )
    if ( v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      string ( APPEND twx_fatal.MSG ": ${twx_fatal.R_VAR} => ``${${twx_fatal.R_VAR}}''" )
    else ()
      set ( twx_fatal.MSG "Not a variable name: ``${twx_fatal.R_VAR}''" )
      set ( twx_fatal.FILE "${CMAKE_CURRENT_FUNCTION_FILE}" )
      set ( twx_fatal.LINE "${CMAKE_CURRENT_FUNCTION_LINE}" )
    endif ()
  endif ()
  message ( STATUS "twx_fatal.MSG => ``${twx_fatal.MSG}''" )
  if ( TWX_FATAL_CATCH )
    set_property (
      GLOBAL
      PROPERTY TWX_FATAL_MESSAGE "${twx_fatal.MSG}"
    )
    # Store the location of the error
    string ( REPLACE ";" "${TWX_CHAR_STX}PLACEHOLDER:SEMICOLON${TWX_CHAR_ETX}" twx_fatal.FILE "${CMAKE_CURRENT_FUNCTION_LIST_FILE}" )
    if ( NOT TWX_DIR STREQUAL "" )
      string ( REPLACE "${TWX_DIR}" ";" twx_fatal.FILE "${twx_fatal.FILE}" )
      if ( "${twx_fatal.FILE}" MATCHES "^;" )
        list ( POP_BACK twx_fatal.FILE twx_fatal.LAST )
        set ( twx_fatal.FILE "<source>/${twx_fatal.LAST}" )
      endif ()
    endif ()
    if ( NOT CMAKE_BINARY_DIR STREQUAL "" )
      string ( REPLACE "${CMAKE_BINARY_DIR}/" ";" twx_fatal.FILE "${twx_fatal.FILE}" )
      if ( "${twx_fatal.FILE}" MATCHES "^;" )
        list ( POP_BACK twx_fatal.FILE twx_fatal.LAST )
        set ( twx_fatal.FILE "<binary>/${twx_fatal.LAST}" )
      endif ()
    endif ()
    string ( REPLACE "${TWX_CHAR_STX}PLACEHOLDER:SEMICOLON${TWX_CHAR_ETX}" ";" twx_fatal.FILE "${twx_fatal.FILE}" )
    # string ( APPEND twx_fatal.MSG "${twx_fatal.CONTEXT}:${twx_fatal.FILE}:${CMAKE_CURRENT_LIST_LINE}:\n ${m}" )
    # twx_global_set ( "TWX_FATAL_MESSAGE=${twx_fatal.MSG}" )
    set ( twx_fatal.WHERE "${CMAKE_CURRENT_FUNCTION_LIST_FILE}:${CMAKE_CURRENT_FUNCTION_LIST_LINE}:" )
    set_property (
      GLOBAL
      PROPERTY TWX_FATAL_WHERE "${twx_fatal.WHERE}"
    )
    string ( REPLACE ";" "->" twx_fatal.CONTEXT "${CMAKE_MESSAGE_CONTEXT}" )
    twx_var_log ( twx_fatal.CONTEXT )
    set_property (
      GLOBAL
      PROPERTY TWX_FATAL_CONTEXT "${twx_fatal.CONTEXT}"
    )
    if ( TWX_TEST )
      twx_var_log ( twx_fatal.MSG MSG "TWX_TEST" )
      message ( CHECK_START "${CMAKE_MESSAGE_CONTEXT}/TWX_FATAL_MESSAGE" )
      get_property (
        twx_fatal.MSG_saved
        GLOBAL
        PROPERTY TWX_FATAL_MESSAGE
      )
      if ( NOT twx_fatal.MSG_saved STREQUAL twx_fatal.MSG )
        message ( CHECK_FAIL "Internal inconsistency 1" )
      endif ()
      message ( CHECK_START "${CMAKE_MESSAGE_CONTEXT}/TWX_FATAL_WHERE" )
      get_property (
        twx_fatal.WHERE_saved
        GLOBAL
        PROPERTY TWX_FATAL_WHERE
      )
      if ( twx_fatal.WHERE_saved STREQUAL twx_fatal.WHERE )
        message ( CHECK_PASS "OK" )
      else ()
        twx_var_log ( twx_fatal.WHERE_saved )
        message ( CHECK_FAIL "Internal inconsistency 2" )
      endif ()
      message ( CHECK_START "${CMAKE_MESSAGE_CONTEXT}/TWX_FATAL_CONTEXT" )
      get_property (
        twx_fatal.CONTEXT_saved
        GLOBAL
        PROPERTY TWX_FATAL_MESSAGE
      )
      if ( twx_fatal.CONTEXT_saved STREQUAL twx_fatal.CONTEXT )
        message ( CHECK_PASS "OK" )
      else ()
        twx_var_log ( twx_fatal.CONTEXT_saved )
        message ( CHECK_FAIL "Internal inconsistency 3" )
      endif ()
    endif ()
    if ( twx_fatal.R_RETURN )
      return ()
    elseif ( twx_fatal.R_BREAK )
      break ()
    endif ()
  elseif ( DEFINED twx_fatal.R_VAR )
    if ( NOT v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      message ( FATAL_ERROR "Not a variable name: ``${twx_fatal.R_VAR}''" )
    endif ()
    message ( FATAL_ERROR ${twx_fatal.MSG} ": ${twx_fatal.R_VAR} => ``${${twx_fatal.R_VAR}}''" )
  else ()
    message ( FATAL_ERROR ${twx_fatal.MSG} )
  endif ()
endmacro ()

# ANCHOR: twx_fatal_get
#[=======[
*/
/** @brief Get the current fatal error message.
  *
  * For testing purposes mainly.
  *
  * @param var for key `IN_VAR`, contains the message on return
  */
twx_fatal_get(IN_VAR var){}
/*
#]=======]
function ( twx_fatal_get )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_get" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( NOT "${twx.R_IN_VAR}" MATCHES "${TWX_CORE_VARIABLE_RE}" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  get_property (
    ${twx.R_IN_VAR}
    GLOBAL
    PROPERTY TWX_FATAL_MESSAGE
  )
  return ( PROPAGATE ${twx.R_IN_VAR} )
endfunction ()

# ANCHOR: twx_fatal_set
#[=======[
*/
/** @brief set the current fatal error message.
  *
  * For testing purposes mainly.
  *
  * @param var for key `VAR`, contains the message on input
  */
twx_fatal_get(VAR var){}
/*
#]=======]
function ( twx_fatal_set )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_set" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( NOT "${twx.R_VAR}" MATCHES "${TWX_CORE_VARIABLE_RE}" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  set_property (
    ${twx.R_IN_VAR}
    GLOBAL
    PROPERTY TWX_FATAL_MESSAGE "${twx.R_VAR}"
  )
endfunction ()

# ANCHOR: twx_fatal_clear
#[=======[
*/
/** @brief Clear catched fatal messages.
  *
  * For testing purposes only.
  *
  */
twx_fatal_clear (){}
/*
#]=======]
function ( twx_fatal_clear )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_clear" )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Too many arguments: ${ARGC} instead of 0." )
  endif ()
  set_property (
    GLOBAL
    PROPERTY TWX_FATAL_MESSAGE
  )
endfunction ()

# ANCHOR: twx_fatal_test
#[=======[
*/
/** @brief After the test suite runs
  *
  * Catch the fatal status and calls `twx_fatal_clear()`.
  * Called at the start of a scope.
  *
  */
twx_fatal_test () {}
/*
#]=======]
function ( twx_fatal_test )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_test" )
  if ( NOT DEFINED twx_fatal_test.CATCH_SAVED )
    set ( twx_fatal_test.CATCH_SAVED "${TWX_FATAL_CATCH}" PARENT_SCOPE )
  endif ()
  set ( TWX_FATAL_CATCH ON PARENT_SCOPE )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_clear ()
endfunction ()

# ANCHOR: twx_fatal_assert_passed
#[=======[
*/
/** @brief Raise when a test unexpectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_fatal_assert_passed () {}
/*
#]=======]
function ( twx_fatal_assert_passed )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_assert_passed" )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_fatal_assert_passed.v )
  if ( twx_fatal_assert_passed.v AND NOT twx_fatal_assert_passed.v STREQUAL "" )
    message ( FATAL_ERROR "${twx_fatal_assert_passed.v}" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_fatal_test.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_assert_failed
#[=======[
*/
/** @brief Raise when a test did not expectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  */
twx_fatal_assert_failed () {}
/*
#]=======]
function ( twx_fatal_assert_failed )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_assert_failed" )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_catched ( IN_VAR twx_fatal_assert_failed.v )
  if ( NOT twx_fatal_assert_failed.v OR twx_fatal_assert_failed.v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_fatal_test.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_catched
#[=======[
*/
/** @brief Catch fatal messages.
  *
  * For testing purposes only.
  * If the `twx_fatal()` call has no really bad consequences,
  * we can catch the message.
  *
  * @param var for key `IN_VAR`, contains the list of messages on return.
  * @param context for key `IN_CONTEXT`, optional, contains the list of corresponding contexts on return.
  */
twx_fatal_catched (IN_VAR var [IN_CONTEXT context]){}
/*
#]=======]
function ( twx_fatal_catched )
  list (  APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_catched" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_fatal_catched.R
    "" "IN_VAR;IN_CONTEXT" ""
  )
  twx_var_log ( twx_fatal_catched.R_IN_VAR )
  twx_var_log ( twx_fatal_catched.R_IN_CONTEXT )
  twx_var_assert_name ( "${twx_fatal_catched.R_IN_VAR}" )
  if ( NOT twx.R_UNPARSED_ARGUMENTS STREQUAL "" )
    set ( ${twx.R_IN_VAR} " Bad usage: ``${twx_fatal_catched.R_UNPARSED_ARGUMENTS}''." )
    return ( PROPAGATE ${twx_fatal_catched.R_IN_VAR} ${twx_fatal_catched.R_IN_CONTEXT} )
  endif ()
  twx_fatal_get ( IN_VAR ${twx_fatal_catched.R_IN_VAR} )
  message ( " ${twx_fatal_catched.R_IN_VAR} => ``${${twx_fatal_catched.R_IN_VAR}}''" )
  if ( twx_fatal_catched.R_IN_CONTEXT )
    twx_var_assert_name ( "${twx_fatal_catched.R_IN_CONTEXT}" )
    get_property (
      ${twx_fatal_catched.R_IN_CONTEXT}
      GLOBAL
      PROPERTY TWX_FATAL_CONTEXT
    )
    message ( " ${twx_fatal_catched.R_IN_CONTEXT} => ``${${twx_fatal_catched.R_IN_CONTEXT}}''" )
  endif ()
  return ( PROPAGATE ${twx_fatal_catched.R_IN_VAR} ${twx_fatal_catched.R_IN_CONTEXT} )
endfunction ( twx_fatal_catched )

# ANCHOR: twx_return_on_fatal
#[=======[
*/
/** @brief Return on fatal messages.
  *
  * For testing purposes only.
  */
twx_return_on_fatal () {}
/*
#]=======]
macro ( twx_return_on_fatal )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ``${ARGV}''." )
  endif ()
  twx_fatal_get ( IN_VAR twx_return_on_fatal.MESSAGE )
  if ( NOT "${twx_return_on_fatal.MESSAGE}" STREQUAL "" )
    return ()
  endif ()
endmacro ()

twx_lib_did_load ()

#*/
