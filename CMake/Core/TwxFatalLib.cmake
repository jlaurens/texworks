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
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  set ( twx_fatal.FILE "${CMAKE_CURRENT_LIST_FILE}" )
  set ( twx_fatal.LINE "${CMAKE_CURRENT_LIST_LINE}" )
  if ( TWX_FATAL_CATCH )
    twx_fatal_get ( IN_VAR twx_fatal.MSG )
    if ( DEFINED twx_fatal.MSG )
      string ( APPEND twx_fatal.MSG "\n" )
    endif ()
  else ()
    set ( twx_fatal.MSG )
  endif ()
  cmake_parse_arguments (
    twx_fatal.R "RETURN;BREAK" "VAR" "" ${ARGV}
  )
  foreach ( twx_fatal.m ${twx_fatal.R_UNPARSED_ARGUMENTS} )
    if ( "${twx_fatal.m}" MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND twx_fatal.MSG " ${twx_fatal.m}\\" )
    else ()
      list ( APPEND twx_fatal.MSG " ${twx_fatal.m}" )
    endif ()
  endforeach ()
  if ( DEFINED twx_fatal.R_VAR )
    if ( v MATCHES "${TWX_CORE_VARIABLE_RE}" )
      string ( APPEND twx_fatal.MSG ": ${twx_fatal.R_VAR} => ``${${twx_fatal.R_VAR}}''" )
    else ()
      set ( twx_fatal.MSG " Not a variable name: ``${twx_fatal.R_VAR}''" )
      set ( twx_fatal.FILE "${CMAKE_CURRENT_FUNCTION_FILE}" )
      set ( twx_fatal.LINE "${CMAKE_CURRENT_FUNCTION_LINE}" )
    endif ()
  endif ()
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
    set_property (
      GLOBAL
      PROPERTY TWX_FATAL_CONTEXT "${twx_fatal.CONTEXT}"
    )
    if ( TWX_TEST )
      block ()
      get_property (
        test_done_
        GLOBAL
        PROPERTY TWX_FATAL_TEST_DONE
      )
      if ( NOT test_done_ )
        set_property (
          GLOBAL
          PROPERTY TWX_FATAL_TEST_DONE ON
        )
        set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
        get_property (
          twx_fatal.MSG_saved
          GLOBAL
          PROPERTY TWX_FATAL_MESSAGE
        )
        if ( twx_fatal.MSG_saved STREQUAL twx_fatal.MSG )
          message ( VERBOSE "TWX_FATAL_MSG: ${TWX_FORMAT/Test/PASS}PASSED${TWX_FORMAT_RESET}" )
        else ()
          twx_var_log ( DEBUG twx_fatal.MSG_saved MSG "Actual" )
          twx_var_log ( DEBUG twx_fatal.MSG       MSG "Expected" )
          message ( FATAL_ERROR "TWX_FATAL_MSG: ${TWX_FORMAT/Test/FAIL}Internal inconsistency 1${TWX_FORMAT_RESET}" )
        endif ()
        get_property (
          twx_fatal.WHERE_saved
          GLOBAL
          PROPERTY TWX_FATAL_WHERE
        )
        if ( twx_fatal.WHERE_saved STREQUAL twx_fatal.WHERE )
          message ( VERBOSE "TWX_FATAL_WHERE - ${TWX_FORMAT/Test/PASS}PASS${TWX_FORMAT_RESET}" )
        else ()
          twx_var_log ( DEBUG twx_fatal.WHERE_saved MSG "Actual" )
          twx_var_log ( DEBUG twx_fatal.WHERE       MSG "Expected" )
          message ( FATAL_ERROR "${TWX_FORMAT/Test/FAIL}Internal inconsistency 2${TWX_FORMAT_RESET}" )
        endif ()
        get_property (
          twx_fatal.CONTEXT_saved
          GLOBAL
          PROPERTY TWX_FATAL_CONTEXT
        )
        if ( twx_fatal.CONTEXT_saved STREQUAL twx_fatal.CONTEXT )
          message ( VERBOSE "TWX_FATAL_CONTEXT - ${TWX_FORMAT/Test/PASS}PASSED${TWX_FORMAT_RESET}" )
        else ()
          twx_var_log ( DEBUG twx_fatal.CONTEXT_saved MSG "Actual" )
          twx_var_log ( DEBUG twx_fatal.CONTEXT       MSG "Expected" )
          message ( FATAL_ERROR "TWX_FATAL_CONTEXT - ${TWX_FORMAT/Test/FAIL}Internal inconsistency 3${TWX_FORMAT_RESET}" )
        endif ()
      endif ()
      endblock ()
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
  # Avoid name conflicts
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( NOT "${${TWX_CMD}.R_IN_VAR}" MATCHES "${TWX_CORE_VARIABLE_RE}" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  get_property (
    ${${TWX_CMD}.R_IN_VAR}
    GLOBAL
    PROPERTY TWX_FATAL_MESSAGE
  )
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
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
  twx_cmd_begin ( "${CMAKE_CURRENT_FUNCTION}" )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( NOT "${${TWX_CMD}.R_VAR}" MATCHES "${TWX_CORE_VARIABLE_RE}" )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  set_property (
    GLOBAL
    PROPERTY TWX_FATAL_MESSAGE "${${TWX_CMD}.R_VAR}"
  )
endfunction ( twx_fatal_set )

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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_clear" )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal_test" )
  if ( NOT DEFINED twx_fatal_test.CATCH_SAVED )
    set ( twx_fatal_test.CATCH_SAVED "${TWX_FATAL_CATCH}" PARENT_SCOPE )
  endif ()
  set ( TWX_FATAL_CATCH ON PARENT_SCOPE )
  if ( ${ARGC} GREATER "0" )
    message ( FATAL_ERROR "Too many arguments" )
  endif ()
  twx_fatal_clear ()
endfunction ()

# ANCHOR: twx_fatal_assert_pass
#[=======[
*/
/** @brief Raise when a test unexpectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  *
  * @param CHECK, optional flag to indicate that it closes a `CHECK_START`.
  * @param MESSAGE_CONTEXT_HIDE, optional flag to not show the message context.
  *   When not provided, the current state applies.
  * @param pass_cmd for key ON_PASS, optional name of a command executed on pass.
  *   This command is called with no argument.
  * @param fail_cmd for key ON_FAIL, optional name of a command executed on pass.
  *   This command is called with no argument.
  * @param pass_msg for key MSG_PASS, optional message used on pass.
  *   Defaults to `PASS`.
  * @param fail_msg for key MSG_FAIL, optional message used on fail.
  *   Defaults to `FAIL`.
  */
twx_fatal_assert_pass ([CHECK] [MESSAGE_CONTEXT_HIDE]) {}
/*
#]=======]
function ( twx_fatal_assert_pass )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "CHECK;MESSAGE_CONTEXT_HIDE" "ON_PASS;ON_FAIL;MSG_PASS;MSG_FAIL" ""
  )
  if ( ${TWX_CMD}.R_MESSAGE_CONTEXT_HIDE )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_MSG_PASS )
    set ( ${TWX_CMD}.R_MSG_PASS PASS )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_MSG_FAIL )
    set ( ${TWX_CMD}.R_MSG_FAIL FAIL )
  endif ()
  twx_fatal_catched ( IN_VAR ${TWX_CMD}.v )
  if ( ${TWX_CMD}.v AND NOT ${TWX_CMD}.v STREQUAL "" )
    set ( ${TWX_CMD}.CHECK FAIL )
    set ( ${TWX_CMD}.MSG_CHECK ${${TWX_CMD}.R_MSG_FAIL} )
    set ( ${TWX_CMD}.BANNER "${${TWX_CMD}.v}" )
  else ()
    set ( ${TWX_CMD}.CHECK PASS )
    set ( ${TWX_CMD}.MSG_CHECK ${${TWX_CMD}.R_MSG_PASS} )
    set ( ${TWX_CMD}.BANNER "${${TWX_CMD}.MSG_CHECK}" )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_ON_${${TWX_CMD}.CHECK} )
    cmake_language ( CALL "${${TWX_CMD}.R_ON_${${TWX_CMD}.CHECK}}" )
  endif ()
  string ( PREPEND ${TWX_CMD}.BANNER "${TWX_FORMAT/Test/${${TWX_CMD}.CHECK}}" )
  if ( ${TWX_CMD}.R_CHECK )
    set ( ${TWX_CMD}.MODE "CHECK_${${TWX_CMD}.CHECK}" )
  else ()
    set ( ${TWX_CMD}.MODE STATUS )
    if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
      list ( POP_FRONT ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${TWX_CMD}.MODE )
      set ( ${TWX_CMD}.MODES STATUS VERBOSE DEBUG TRACE ) 
      if ( NOT ${TWX_CMD}.MODE IN_LIST ${TWX_CMD}.MODES )
        list ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${TWX_CMD}.MODE )
        set ( ${TWX_CMD}.MODE STATUS )
      endif ()
      string ( PREPEND ${TWX_CMD}.BANNER "${${TWX_CMD}.R_UNPARSED_ARGUMENTS} - " )
    endif ()
  endif ()
  message ( ${${TWX_CMD}.MODE} "${${TWX_CMD}.BANNER}${TWX_FORMAT_RESET}" )
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH "${twx_fatal_test.CATCH_SAVED}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_fatal_assert_fail
#[=======[
*/
/** @brief Raise when a test did not expectedly raised.
  *
  * This is not extremely strong but does the job in most situations.
  *
  * @param CHECK, optional flag to indicate that it closes a `CHECK_START`.
  * @param MESSAGE_CONTEXT_HIDE, optional flag to not show the message context.
  *   When not provided, the current state applies.
  * @param pass_cmd for key ON_PASS, optional name of a command executed on pass.
  *   This command is called with no argument.
  * @param fail_cmd for key ON_FAIL, optional name of a command executed on pass.
  *   This command is called with no argument.
  * @param pass_msg for key MSG_PASS, optional message used on pass.
  *   Defaults to `PASS`.
  * @param fail_msg for key MSG_FAIL, optional message used on fail.
  *   Defaults to `FAIL`.
  *
  */
twx_fatal_assert_fail ([CHECK] [MESSAGE_CONTEXT_HIDE]) {}
/*
#]=======]
function ( twx_fatal_assert_fail )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "CHECK;MESSAGE_CONTEXT_HIDE" "ON_PASS;ON_FAIL;MSG_PASS;MSG_FAIL" ""
  )
  if ( ${TWX_CMD}.R_MESSAGE_CONTEXT_HIDE )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_MSG_PASS )
    set ( ${TWX_CMD}.R_MSG_PASS PASS )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_MSG_FAIL )
    set ( ${TWX_CMD}.R_MSG_FAIL FAIL )
  endif ()
  twx_fatal_catched ( IN_VAR ${TWX_CMD}.v )
  if ( DEFINED ${TWX_CMD}.v AND NOT ${TWX_CMD}.v STREQUAL "" )
    set ( ${TWX_CMD}.CHECK PASS )
    set ( ${TWX_CMD}.MSG_CHECK ${${TWX_CMD}.R_MSG_PASS} )
  else ()
    set ( ${TWX_CMD}.CHECK FAIL )
    set ( ${TWX_CMD}.MSG_CHECK ${${TWX_CMD}.R_MSG_FAIL} )
  endif ()
  set ( ${TWX_CMD}.BANNER "${${TWX_CMD}.MSG_CHECK}" )
  if ( DEFINED ${TWX_CMD}.R_ON_${${TWX_CMD}.CHECK} )
    cmake_language ( CALL "${${TWX_CMD}.R_ON_${${TWX_CMD}.CHECK}}" )
  endif ()
  string ( PREPEND ${TWX_CMD}.BANNER "${TWX_FORMAT/Test/${${TWX_CMD}.CHECK}}" )
  if ( ${TWX_CMD}.R_CHECK )
    set ( ${TWX_CMD}.MODE "CHECK_${${TWX_CMD}.CHECK}" )
  else ()
    set ( ${TWX_CMD}.MODE STATUS )
    if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
      list ( POP_FRONT ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${TWX_CMD}.MODE )
      set ( ${TWX_CMD}.MODES STATUS VERBOSE DEBUG TRACE ) 
      if ( NOT ${TWX_CMD}.MODE IN_LIST ${TWX_CMD}.MODES )
        list ( PREPEND ${TWX_CMD}.R_UNPARSED_ARGUMENTS ${TWX_CMD}.MODE )
        set ( ${TWX_CMD}.MODE STATUS )
      endif ()
      string ( PREPEND ${TWX_CMD}.BANNER "${${TWX_CMD}.R_UNPARSED_ARGUMENTS} - " )
    endif ()
  endif ()
  message ( ${${TWX_CMD}.MODE} "${${TWX_CMD}.BANNER}${TWX_FORMAT_RESET}" )
  twx_fatal_clear ()
  if ( DEFINED twx_fatal_test.CATCH_SAVED )
    set ( TWX_FATAL_CATCH ${twx_fatal_test.CATCH_SAVED} PARENT_SCOPE )
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
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "IN_VAR;IN_CONTEXT" ""
  )
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    set ( ${${TWX_CMD}.R_IN_VAR} " Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''." )
    return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_IN_CONTEXT} )
  endif ()
  twx_fatal_get ( IN_VAR ${${TWX_CMD}.R_IN_VAR} )
  # message ( TRACE " ${${TWX_CMD}.R_IN_VAR} => ``${${${TWX_CMD}.R_IN_VAR}}''" )
  if ( ${TWX_CMD}.R_IN_CONTEXT )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_CONTEXT}" )
    get_property (
      ${${TWX_CMD}.R_IN_CONTEXT}
      GLOBAL
      PROPERTY TWX_FATAL_CONTEXT
    )
    # message ( TRACE " ${${TWX_CMD}.R_IN_CONTEXT} => ``${${${TWX_CMD}.R_IN_CONTEXT}}''" )
  endif ()
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_IN_CONTEXT} )
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
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''." )
  endif ()
  twx_fatal_get ( IN_VAR twx_return_on_fatal.MESSAGE )
  if ( NOT "${twx_return_on_fatal.MESSAGE}" STREQUAL "" )
    return ()
  endif ()
endmacro ()

twx_lib_did_load ()

#*/
