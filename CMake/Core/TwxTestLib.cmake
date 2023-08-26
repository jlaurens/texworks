#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing facilities.
  *
  * A test file should start reading:
  *
  *   include_guard ( GLOBAL )
  *
  *   twx_test_suite_will_begin ()
  *   if ( TWX_TEST_SUITE_RUN )
  *   block ()
  *
  * followed by any number of units
  *
  *   # ANCHOR: <name>
  *   twx_test_unit_will_begin ( NAME <name> ID <id>)
  *   if ( TWX_TEST_UNIT_RUN )
  *     block ()
  *     ...
  *     endblock ()
  *   endif ()
  *   twx_test_unit_did_end ()
  *
  * with trailing
  *
  *   endblock ()
  *   endif ()
  *   twx_test_suite_did_end ()
  *
  */
/*
#]===============================================]

include_guard ( GLOBAL )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxLib.cmake" )

set ( TWX_TEST ON )

# ANCHOR: twx_test_during
#[=======[
*/
/** @brief Whether some test is actually running.
  *
  * @param test_id for key ID, a variable name like identifier to uniquely
  *   identify a test suite.
  * @param var_name for key IN_VAR, on return receives `TRUE` if a test
  *   matching the given with given id is actually running, false otherwise.
  * @param RE, optional flag to switch to regular expressions.
  */
/*
#]=======]
function ( twx_test_during )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "RE" "DOMAIN;SUITE;UNIT;FULL;IN_VAR" ""
  )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR " Bad usage ( twx.R_UNPARSED_ARGUMENTS => ``${twx.R_UNPARSED_ARGUMENTS}'')" )
  endif ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  get_property (
    TWX_TEST_DOMAIN_NAME
    GLOBAL
    PROPERTY TWX_TEST_DOMAIN_NAME
  )
  get_property (
    TWX_TEST_SUITE_STACK
    GLOBAL
    PROPERTY TWX_TEST_SUITE_STACK
  )
  get_property (
    TWX_TEST_UNIT_NAME
    GLOBAL
    PROPERTY TWX_TEST_UNIT_NAME
  )
  set ( "${twx.R_IN_VAR}" OFF PARENT_SCOPE )
  if ( twx.R_DOMAIN )
    if ( twx.R_RE )
      if ( TWX_TEST_DOMAIN_NAME MATCHES "${twx.R_DOMAIN}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( TWX_TEST_DOMAIN_NAME STREQUAL "${twx.R_DOMAIN}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( twx.R_SUITE )
    if ( twx.R_RE )
      foreach ( s ${TWX_TEST_SUITE_STACK} )
        if ( s MATCHES "${twx.R_SUITE}" )
          set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
          return ()
        endif ()
      endforeach ()
    else ()
      foreach ( s ${TWX_TEST_SUITE_STACK} )
        if ( s STREQUAL "${twx.R_SUITE}" )
          set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
          return ()
        endif ()
      endforeach ()
    endif ()
  endif ()
  if ( twx.R_UNIT )
    if ( twx.R_RE )
      if ( TWX_TEST_UNIT_NAME MATCHES "${twx.R_UNIT}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( TWX_TEST_UNIT_NAME STREQUAL "${twx.R_UNIT}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( twx.R_FULL )
    list ( POP_BACK TWX_TEST_SUITE_STACK full_ )
    string ( PREPEND full_ "${TWX_TEST_DOMAIN_NAME}/" )
    string ( APPEND full_ "/${TWX_TEST_UNIT_NAME}" )
    if ( twx.R_RE )
      if ( full_ MATCHES "${twx.R_FULL}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( full_ STREQUAL "${twx.R_FULL}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
endfunction ( twx_test_during )

twx_lib_will_load ( NO_SCRIPT )

# define_property (
#   TARGET PROPERTY TWX_TEST_DOMAIN_STACK
# )
# define_property (
#   TARGET PROPERTY TWX_TEST_SUITE_STACK
# )
set_property (
  GLOBAL
  PROPERTY TWX_TEST_DOMAIN_STACK
)
set_property (
  GLOBAL
  PROPERTY TWX_TEST_SUITE_STACK
)
set_property (
  GLOBAL
  PROPERTY TWX_TEST_UNIT_NAME
)

set ( TWX_FATAL_CATCH OFF )

# ANCHOR: twx_test_guess
#[=======[
*/
/** @brief Guess the domain, suite and tested library
  *
  * When this function is called from a file location matching
  * `<source>/CMake/<domain>/Test/Twx<core>.cmake` file,
  * return the `<domain>` path component as domain name,
  * `<core>`  as core suite name and `Twx<core>` as suite name.
  * The tested library name is `Twx<suite>` if
  *
  *   <source>/CMake/<domain>/Twx<suite>.cmake
  *
  * exists and it is `Twx<suite>Lib` if
  *
  *   <source>/Cmake/<domain>/Twx<suite>Lib.cmake`
  *
  * exists.
  *
  * When this function is not called from a proper file, raises.
  *
  * @param domain for key `IN_DOMAIN`, optional, will hold the domain name on return.
  * @param core for key `IN_CORE_SUITE`, optional, will hold the core suite name on return.
  * @param suite for key `IN_SUITE`, optional, will hold the suite name on return.
  * @param lib for key `IN_LIB`, optional, will hold the tested library name on return.
  *
  */
twx_test_guess ([IN_DOMAIN domain] [IN_CORE_SUITE core] [IN_SUITE suite] [IN_LIB lib]) {}
/*
#]=======]
function ( twx_test_guess )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_test_guess.R
    "" "IN_DOMAIN;IN_SUITE;IN_LIB" ""
  )
  if ( DEFINED twx_test_guess.R_UNPARSED_ARGUMENTS )
    twx_fatal ( "Bad usage: unexpected ``${twx_test_guess.R_UNPARSED_ARGUMENTS}''" RETURN )
  endif ()
  if ( "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/CMake/([^/]+)/Test/(Twx([^/]+))/" )
    set ( twx_test_guess.DOMAIN     "${CMAKE_MATCH_1}" )
    set ( twx_test_guess.SUITE      "${CMAKE_MATCH_2}" )
    set ( twx_test_guess.CORE_SUITE "${CMAKE_MATCH_3}" )
  elseif ( "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/CMake/([^/]+)/Test/" )
    set ( twx_test_guess.DOMAIN "${CMAKE_MATCH_1}" )
    set ( twx_test_guess.SUITE )
    set ( twx_test_guess.CORE_SUITE )
  else ()
    twx_fatal ( "Bad usage" VAR CMAKE_CURRENT_LIST_FILE RETURN )
  endif ()
  if ( DEFINED twx_test_guess.SUITE )
    set (
      twx_test_guess.LIB
      "${CMAKE_CURRENT_LIST_DIR}/../../${twx_test_guess.SUITE}.cmake"
    )
    if ( NOT EXISTS "${twx_test_guess.LIB}" )
      string ( APPEND twx_test_guess.SUITE Lib )
      set (
        twx_test_guess.LIB
        "${CMAKE_CURRENT_LIST_DIR}/../../${twx_test_guess.SUITE}.cmake"
      )
      if ( NOT EXISTS "${twx_test_guess.LIB}" )
        message ( FATAL_ERROR "No library to test" )
      endif ()
    endif ()
  else ()
    set ( twx_test_guess.LIB )
  endif ()
  if (DEFINED twx_test_guess.R_IN_DOMAIN )
    twx_var_assert_name ( "${twx_test_guess.R_IN_DOMAIN}" )
    set ( "${twx_test_guess.R_IN_DOMAIN}" ${twx_test_guess.DOMAIN} )
  endif ()
  if ( DEFINED twx_test_guess.R_IN_SUITE )
    twx_var_assert_name ( "${twx_test_guess.R_IN_SUITE}" )
    set ( "${twx_test_guess.R_IN_SUITE}" ${twx_test_guess.SUITE} )
  endif ()
  if ( DEFINED twx_test_guess.R_IN_CORE_SUITE )
    twx_var_assert_name ( "${twx_test_guess.R_IN_CORE_SUITE}" )
    set ( "${twx_test_guess.R_IN_CORE_SUITE}" ${twx_test_guess.CORE_SUITE} )
  endif ()
  if ( DEFINED twx_test_guess.R_IN_LIB )
    twx_var_assert_name ( "${twx_test_guess.R_IN_LIB}" )
    set ( "${twx_test_guess.R_IN_LIB}" ${twx_test_guess.LIB} )
  endif ()
  return (
    PROPAGATE
    ${twx_test_guess.R_IN_DOMAIN}
    ${twx_test_guess.R_IN_SUITE}
    ${twx_test_guess.R_IN_LIB}
  )
endfunction ()

# ANCHOR: twx_test_domain_will_begin
#[=======[
*/
/** @brief Before the test domain runs
  *
  * Must be balanced by a `twx_test_domain_did_end()`.
  *
  */
twx_test_domain_will_begin (NAME name) {}
/*
#]=======]
macro ( twx_test_domain_will_begin )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage (ARGV => ``${ARGV}'')" )
  endif ()
  twx_test_guess ( IN_DOMAIN TWX_TEST_DOMAIN_NAME )
  if ( NOT DEFINED TWX_TEST_DOMAIN_NAME )
    set ( TWX_TEST_DOMAIN_NAME "None" )
  endif ()
  twx_global_append (
    "${TWX_TEST_DOMAIN_NAME}"
    ID TWX_TEST_DOMAIN_STACK
    DUPLICATE "Circular domain: ``${TWX_TEST_DOMAIN_NAME}''"
  )
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message ( CHECK_START "Test domain ${TWX_TEST_DOMAIN_NAME}..." ID Test/Domain )
  endblock ()
  list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_DOMAIN_NAME}" )
  if ( DEFINED TWX_TEST_DOMAIN.${TWX_TEST_DOMAIN_NAME}.RUN )
    set ( TWX_TEST_DOMAIN_RUN "${TWX_TEST_DOMAIN.${TWX_TEST_DOMAIN_NAME}.RUN}" )
  else ()
    set ( TWX_TEST_DOMAIN_RUN ON )
    if ( TWX_TEST_DOMAIN_RE_YES AND NOT TWX_TEST_DOMAIN_NAME MATCHES "${TWX_TEST_DOMAIN_RE_YES}" )
      set ( TWX_TEST_DOMAIN_RUN OFF )
    elseif ( TWX_TEST_DOMAIN_RE_NO AND TWX_TEST_DOMAIN_NAME MATCHES "${TWX_TEST_UNIT_RE_NO}")
      set ( TWX_TEST_DOMAIN_RUN OFF )
    endif ()
    set ( TWX_TEST_DOMAIN.${TWX_TEST_DOMAIN_NAME}.RUN ${TWX_TEST_DOMAIN_RUN} )
  endif ()
endmacro ()

# ANCHOR: twx_test_domain_did_end
#[=======[
*/
/** @brief After the test domain runs
  *
  * Must balance a `twx_test_domain_will_begin()`.
  *
  */
twx_test_domain_did_end () {}
/*
#]=======]
function ( twx_test_domain_did_end )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage (ARGV => ``${ARGV}'')" )
  endif ()
  if ( COMMAND twx_fatal_assert_pass )
    twx_fatal_assert_pass ()
  endif ()
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  if ( TWX_TEST_DOMAIN.${TWX_TEST_DOMAIN_NAME}.RUN )
    set ( status_ "DONE" )
  else ()
    set ( status_ "SKIPPED" )
  endif ()
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message ( STATUS "Test domain ${TWX_TEST_DOMAIN_NAME}... ${status_}" ID Test/Domain )
  endblock ()
  twx_global_pop_back (
    REQUIRED
    ID TWX_TEST_DOMAIN_STACK
    IN_VAR TWX_TEST_DOMAIN_STACK
  )
  return ( PROPAGATE CMAKE_MESSAGE_CONTEXT )
endfunction ( twx_test_domain_did_end )

# ANCHOR: twx_test_suite_will_begin
#[=======[
*/
/** @brief Before the test suite runs
  *
  * Must be balanced by a `twx_test_suite_did_end()`.
  * Loads the associate library retrieved from the path of the current list file.
  * A `block()` instruction should follow.
  *
  * @param level for key LOG_LEVEL, optional log level.
  */
twx_test_suite_will_begin ([LOG_LEVEL level]) {}
/*
#]=======]
macro ( twx_test_suite_will_begin )
  list ( APPEND twx_test_suite_will_begin.CMAKE_MESSAGE_LOG_LEVEL "${CMAKE_MESSAGE_LOG_LEVEL}" )
  # API guards
  if ( ${ARGC} EQUAL 2 )
    if ( NOT ARGV0 STREQUAL "LOG_LEVEL" )
      message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
    endif ()
    set ( CMAKE_MESSAGE_LOG_LEVEL ${ARGV1} )
  elseif ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  get_property (
    twx_test_suite_will_begin.SUITE_CORE_LIST
    GLOBAL
    PROPERTY TWX_TEST_SUITE_CORE_LIST
  )
  list ( APPEND twx_test_suite_will_begin.SUITE_CORE_LIST "${TWX_TEST_SUITE_CORE_NAME}" )
  set_property (
    GLOBAL
    PROPERTY TWX_TEST_SUITE_CORE_LIST "${twx_test_suite_will_begin.SUITE_CORE_LIST}"
  )
  get_property (
    twx_test_suite_will_begin.DOMAIN_LIST
    GLOBAL
    PROPERTY TWX_TEST_DOMAIN_STACK
  )
  list ( APPEND twx_test_suite_will_begin.DOMAIN_LIST "${TWX_TEST_DOMAIN_NAME}" )
  set_property (
    GLOBAL
    PROPERTY TWX_TEST_DOMAIN_STACK "${twx_test_suite_will_begin.DOMAIN_LIST}"
  )
  list ( APPEND TwxTestLib.SUITE_CORE_NAME "${TWX_TEST_SUITE_CORE_NAME}" )
  # Get the name of the test suite
  twx_test_guess (
    IN_DOMAIN TWX_TEST_DOMAIN_NAME
    IN_SUITE TWX_TEST_SUITE_NAME
    IN_CORE_SUITE TWX_TEST_SUITE_CORE_NAME
    IN_LIB twx_test_suite_will_begin.LIB
  )
  set (
    twx_test_suite_will_begin.LIB
    "${CMAKE_CURRENT_LIST_DIR}/../../${TWX_TEST_SUITE_NAME}.cmake"
  )
  # At this point, we are OK to run
  # Store the name of the test suite
  twx_global_append (
    "${TWX_TEST_SUITE_CORE_NAME}"
    ID TWX_TEST_SUITE_STACK
  )
  # Whether the suite should run
  if ( DEFINED TWX_TEST/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_CORE_NAME}.RUN )
    set ( TWX_TEST_SUITE_RUN "${TWX_TEST/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_CORE_NAME}.RUN}" )
  else ()
    set ( TWX_TEST_SUITE_RUN ON )
    if ( TWX_TEST_SUITE_RE_YES AND NOT TWX_TEST_SUITE_NAME MATCHES "${TWX_TEST_SUITE_RE_YES}" )
      set ( TWX_TEST_SUITE_RUN OFF )
    elseif ( TWX_TEST/${TWX_TEST_DOMAIN_NAME}/SUITE_RE_YES AND NOT TWX_TEST_SUITE_NAME MATCHES "${TWX_TEST/${TWX_TEST_DOMAIN_NAME}/SUITE_RE_YES}" )
      set ( TWX_TEST_SUITE_RUN OFF )
    elseif ( TWX_TEST_SUITE_RE_NO AND TWX_TEST_SUITE_NAME MATCHES "${TWX_TEST_SUITE_RE_NO}")
      set ( TWX_TEST_SUITE_RUN OFF )
    elseif ( TWX_TEST/${TWX_TEST_DOMAIN_NAME}/SUITE_RE_NO AND TWX_TEST_SUITE_NAME MATCHES "${TWX_TEST/${TWX_TEST_DOMAIN_NAME}/SUITE_RE_YES}" )
      set ( TWX_TEST_SUITE_RUN OFF )
    endif ()
    set ( TWX_TEST/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_CORE_NAME}.RUN "${TWX_TEST_SUITE_RUN}" )
  endif ()
  set ( TWX_FATAL_CATCH ON )
  set ( twx_test_suite_will_begin.banner "Test suite ${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_NAME}...")
  if ( TWX_TEST_SUITE_RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( STATUS "${twx_test_suite_will_begin.banner}" ID Test/Suite )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_SUITE_CORE_NAME}" )
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( VERBOSE "${twx_test_suite_will_begin.banner} skipped" ID Test/Suite )
    endblock ()
  endif ()
  include ( "${twx_test_suite_will_begin.LIB}" )
  set ( twx_test_suite_will_begin.length )
  set ( twx_test_suite_will_begin.banner )
  set ( twx_test_suite_will_begin.underline )
endmacro ( twx_test_suite_will_begin )

# ANCHOR: twx_test_suite_did_end
#[=======[
*/
/** @brief After the test suite runs
  *
  * Must balance a `twx_test_suite_will_begin()`.
  *
  */
twx_test_suite_did_end (ID id) {}
/*
#]=======]
function ( twx_test_suite_did_end )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage (ARGV => ``${ARGV}'')" )
  endif ()
  get_property (
    list_
    GLOBAL
    PROPERTY TWX_TEST_SUITE_STACK
  )
  if ( NOT DEFINED list_ )
    message ( FATAL_ERROR "Internal inconsistency, please report." )
  endif ()
  list ( POP_BACK list_ TWX_TEST_SUITE_CORE_NAME )
  set_property (
    GLOBAL
    PROPERTY TWX_TEST_SUITE_STACK "${list_}"
  )
  # Get the tested library
  set ( TWX_TEST_SUITE_NAME "Twx${TWX_TEST_SUITE_CORE_NAME}" )
  set (
    lib_
    "${CMAKE_CURRENT_LIST_DIR}/../../${TWX_TEST_SUITE_NAME}.cmake"
  )
  if ( NOT EXISTS "${lib_}" )
    set ( TWX_TEST_SUITE_NAME "Twx${TWX_TEST_SUITE_CORE_NAME}Lib" )
    set (
      lib_
      "${CMAKE_CURRENT_LIST_DIR}/../../${TWX_TEST_SUITE_NAME}.cmake"
    )
    if ( NOT EXISTS "${twx_test_suite_will_begin.lib}" )
      message ( FATAL_ERROR "No library to test" )
    endif ()
  endif ()
  if ()
    set ( TWX_TEST_SUITE_NAME )
  else ()
  endif ()
  list ( POP_BACK TwxTestLib.DOMAIN_NAME TWX_TEST_DOMAIN_NAME )
  list ( POP_BACK TwxTestLib.SUITE_CORE_NAME TWX_TEST_SUITE_CORE_NAME )
  set ( TWX_TEST_SUITE_RUN ${${TWX_TEST/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_CORE_NAME}.RUN}} )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  list ( POP_BACK twx_test_suite_will_begin.CMAKE_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )

  set ( banner_ "Test suite ${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_NAME}... ")
  if ( TWX_TEST/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_CORE_NAME}.RUN )
    set ( mode_ STATUS )
    string ( APPEND banner_ "DONE")
  else ()
    set ( mode_ VERBOSE )
    string ( APPEND banner_ "SKIPPED")
  endif ()
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message ( ${mode_} "${banner_}" ID Test/Suite )
  endblock ()
  return ( PROPAGATE
    TWX_TEST_DOMAIN_NAME
    TWX_TEST_SUITE_CORE_NAME
    TWX_TEST_SUITE_RUN
    TWX_TEST_SUITE_CORE_NAME
    CMAKE_MESSAGE_CONTEXT
    CMAKE_MESSAGE_LOG_LEVEL
    CMAKE_MESSAGE_INDENT
  )
endfunction ( twx_test_suite_did_end )

function ( TwxTestLib_state_prepare )
  get_property (
    TWX_TEST_SUITE_STACK
    GLOBAL
    TWX_TEST_SUITE_STACK
  )
  return ( PPROPAGATE TWX_TEST_SUITE_STACK )
endfunction ()

macro ( twx_test_include )
  foreach ( twx_include_test.n ${ARGV} )
    set (
      twx_include_test.p
      "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_include_test.n}/Twx${twx_include_test.n}Test.cmake"
    )
    if ( EXISTS "${twx_include_test.p}" )
      include ( "${twx_include_test.p}" )
    else ()
      include (
        "${CMAKE_CURRENT_LIST_DIR}/../Twx${twx_include_test.n}/Twx${twx_include_test.n}Test.cmake"
      )
    endif ()
  endforeach ()
  set ( twx_include_test.n )
  set ( twx_include_test.p )
endmacro ( twx_test_include )

# ANCHOR: twx_test_unit_will_begin
#[=======[
*/
/** @brief Before the test unit runs
  *
  * Must be balanced by a `twx_test_unit_did_end()`.
  * One of the two optional parameters must be provided.
  *
  * @param name for key `NAME`, unique unit identifier within a test suite.
  *   Must not evaluate to false in boolean context.
  *   When not provided, the <id> must be provided and the name is therefore
  *   `twx_<TWX_TEST_SUITE_CORE_NAME:lower>_<id>`.
  *   Goodies: TWX_TEST_SUITE_CORE_NAME is possibly splitted into 2 words
  *   separated by a `_` character.
  * @param id for key `ID`, short identifier for the message context.
  *   Must not evaluate to false in boolean context.
  *   When not provided, guessed form the requires <name>.
  */
twx_test_unit_will_begin ([NAME name] [ID id]) {}
/*
#]=======]
macro ( twx_test_unit_will_begin )
  # API guards
  cmake_parse_arguments (
    twx_test_unit_will_begin.R
    "" "NAME;ID" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_unit_will_begin.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: ``${twx_test_unit_will_begin.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  #
  string ( REGEX REPLACE "([^A-Z])([A-Z])" "\\1_\\2" twx_test_unit_will_begin.CORE "${TWX_TEST_SUITE_CORE_NAME}" )
  string ( TOLOWER "${twx_test_unit_will_begin.CORE}" twx_test_unit_will_begin.CORE )
  if ( "${twx_test_unit_will_begin.R_NAME}" STREQUAL "" )
    if ( "${twx_test_unit_will_begin.R_ID}" STREQUAL "" )
      set (
        twx_test_unit_will_begin.R_NAME
        twx_${twx_test_unit_will_begin.CORE}
      )
      set (
        twx_test_unit_will_begin.R_ID
        twx_${twx_test_unit_will_begin.CORE}
      )
    else ()
      set (
        twx_test_unit_will_begin.R_NAME
        twx_${twx_test_unit_will_begin.CORE}_${twx_test_unit_will_begin.R_ID}
      )
    endif ()
  elseif ( "${twx_test_unit_will_begin.R_ID}" STREQUAL "" )
    if ( "${twx_test_unit_will_begin.R_NAME}" MATCHES "^twx_${twx_test_unit_will_begin.CORE}_(.*)$" )
      set ( twx_test_unit_will_begin.R_ID "${CMAKE_MATCH_1}" )
    else ()
      set ( twx_test_unit_will_begin.R_ID "${twx_test_unit_will_begin.R_NAME}" )
    endif ()
  endif ()
  # Flow guard
  get_property (
    twx_test_unit_will_begin.NAME
    GLOBAL
    PROPERTY TWX_TEST_UNIT_NAME
  )
  if ( DEFINED twx_test_unit_will_begin.NAME )
    message ( FATAL_ERROR "Test units must not be nested" )
  endif ()
  set ( TWX_TEST_UNIT_NAME "${twx_test_unit_will_begin.R_NAME}" )
  set_property (
    GLOBAL
    PROPERTY TWX_TEST_UNIT_NAME "${TWX_TEST_UNIT_NAME}"
  )
  # Serious things start here
  if ( TWX_TEST_SUITE_RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( CHECK_START "Test unit ${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_NAME}/${TWX_TEST_UNIT_NAME}" ID Test/Unit )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${twx_test_unit_will_begin.R_ID}" )
    set ( twx_test_unit_will_begin.CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}" )
    if ( NOT CMAKE_MESSAGE_CONTEXT_SHOW )
      string ( APPEND CMAKE_MESSAGE_INDENT "  " )
    endif ()
    set ( TWX_TEST_UNIT_RUN "${TWX_TEST_SUITE_RUN}" )
    if ( TWX_TEST_UNIT_RUN AND TWX_TEST_UNIT_RE_YES AND NOT TWX_TEST_UNIT_NAME MATCHES "${TWX_TEST_UNIT_RE_YES}" )
      set ( TWX_TEST_UNIT_RUN OFF )
    endif ()
    if ( TWX_TEST_UNIT_RUN AND TWX_TEST_UNIT_RE_NO AND TWX_TEST_UNIT_NAME MATCHES "${TWX_TEST_UNIT_RE_NO}")
      set ( TWX_TEST_UNIT_RUN OFF )
    endif ()
    if ( TWX_TEST_UNIT_RUN )
      set ( twx_test_unit_will_begin.FULL "${TWX_TEST_SUITE_NAME}/${TWX_TEST_UNIT_NAME}" )
      if ( TWX_TEST_SUITE_UNIT_RE_YES AND NOT twx_test_unit_will_begin.FULL MATCHES "${TWX_TEST_SUITE_UNIT_RE_YES}" )
        set ( TWX_TEST_UNIT_RUN OFF )
      endif ()
      if ( TWX_TEST_UNIT_RUN AND TWX_TEST_SUITE_UNIT_RE_NO AND twx_test_unit_will_begin.FULL MATCHES "${TWX_TEST_SUITE_UNIT_RE_NO}" )
        set ( TWX_TEST_UNIT_RUN OFF )
      endif ()
    endif ()
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( VERBOSE "Test unit ${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_NAME}/${TWX_TEST_UNIT_NAME} skipped" ID Test/Unit )
    endblock()
    set ( TWX_TEST_UNIT_RUN OFF )
  endif ()
  set ( twx_test_unit_will_begin.R_NAME )
  set ( twx_test_unit_will_begin.R_ID )
  set ( twx_test_unit_will_begin.CORE )
  set ( twx_test_unit_will_begin.NAME )
  set ( twx_test_unit_will_begin.FULL )
endmacro ( twx_test_unit_will_begin )

# ANCHOR: twx_test_unit_did_end
#[=======[
*/
/** @brief After the test unit runs
  *
  * Must balance a `twx_test_unit_will_begin()`.
  *
  */
twx_test_unit_did_end () {}
/*
#]=======]
function ( twx_test_unit_did_end )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage (ARGV => ``${ARGV}'')" )
  endif ()
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  set ( CMAKE_MESSAGE_INDENT ${twx_test_unit_will_begin.CMAKE_MESSAGE_INDENT} )
  if ( COMMAND twx_fatal_assert_pass )
    twx_fatal_assert_pass ( CHECK MESSAGE_CONTEXT_HIDE )
  endif ()
  set_property (
    GLOBAL
    PROPERTY TWX_TEST_UNIT_NAME
  )
  set ( TWX_TEST_UNIT_RUN )
  return ( PROPAGATE
    CMAKE_MESSAGE_CONTEXT
    TWX_TEST_SUITE_RUN
  )
endfunction ( twx_test_unit_did_end )

# ANCHOR: twx_test_simple_start
#[=======[
*/
/** @brief Start a simple test
  *
  * @param start, the `CHECK_START` like message, in VERBOSE mode only.
  *
  */
twx_test_simple_start () {}
/*
#]=======]
macro ( twx_test_simple_start twx.R_SIMPLE_CHECK )
  if ( NOT ${ARGC} EQUAL 1 )
    message ( FATAL_ERROR " Bad usage: ARGN => ``${ARGN}''" )
  endif ()
  if ( DEFINED TWX_TEST_SIMPLE_CHECK )
    message ( FATAL_ERROR "No nested simple tests" )
  endif ()
  twx_fatal_clear ()
  set ( TWX_TEST_SIMPLE_CHECK "${twx.R_SIMPLE_CHECK}" )
endmacro ()

# ANCHOR: twx_test_simple_pass
#[=======[
*/
/** @brief Simple test pass assertion
  *
  */
twx_test_simple_assert_pass () {}
/*
#]=======]
macro ( twx_test_simple_assert_pass )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  block ()
  if ( NOT TWX_TEST_SIMPLE_MESSAGE_CONTEXT_SHOW )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  twx_fatal_assert_pass ( VERBOSE "${TWX_TEST_SIMPLE_CHECK}" )
  endblock ()
  set ( TWX_TEST_SIMPLE_CHECK )
endmacro ()

# ANCHOR: twx_test_simple_assert_fail
#[=======[
*/
/** @brief Simple test fail assertion
  *
  */
twx_test_simple_fail () {}
/*
#]=======]
macro ( twx_test_simple_assert_fail )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  block ()
  if ( NOT TWX_TEST_SIMPLE_MESSAGE_CONTEXT_SHOW )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  twx_fatal_assert_fail ( VERBOSE "${TWX_TEST_SIMPLE_CHECK}" )
  endblock ()
  set ( TWX_TEST_SIMPLE_CHECK )
endmacro ()

twx_lib_require ( Format Global TEST OFF )

if ( TWX_FORMAT_NIGHT_SHIFT )
  twx_format_define ( ID Test/Domain UNDERLINE BOLD BACK_COLOR 94 )
  twx_format_define ( ID Test/Suite UNDERLINE BOLD BACK_COLOR 22 )
  twx_format_define ( ID Test/Unit UNDERLINE BOLD BACK_COLOR 19 )
  twx_format_define ( ID Test/PASS BOLD TEXT_COLOR 28 )
  twx_format_define ( ID Test/FAIL BOLD TEXT_COLOR 160 )
else ()
  twx_format_define ( ID Test/Domain UNDERLINE BOLD BACK_COLOR 229 )
  twx_format_define ( ID Test/Suite UNDERLINE BOLD BACK_COLOR 193 )
  twx_format_define ( ID Test/Unit UNDERLINE BOLD BACK_COLOR 195 )
  twx_format_define ( ID Test/PASS BOLD TEXT_COLOR 82 )
  twx_format_define ( ID Test/FAIL BOLD TEXT_COLOR 208 )
endif ()

twx_lib_did_load ()

#*/
