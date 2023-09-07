#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing facilities.
  *
  * Test are organized in collections
  *
  * - simple tests contain only few instructions
  * - test units are collections of simple tests
  * - test suites are collections of test units gathered in one file
  * - test domains are collections of test suites included from one file
  *
  * There is a global stack of file paths.
  * Test domains are tied to a `<root>/CMake/<domain>/Test/CMakeList.txt` file.
  * Test suites are tied to a `<root>/CMake/<domain>/Test/<suite>/Twx<suite>Test.cmake` file.
  * A file is pushed when entering a test domain or a test suite and poped when leaving.

  * A test file should start reading:
  *
  *   include_guard ( GLOBAL )
  *
  *   twx_test_suite_push ()
  *   if ( /TWX/TEST/SUITE.RUN )
  *   block ()
  *
  * followed by any number of units
  *
  *   # ANCHOR: <name>
  *   twx_test_unit_push ( NAME <name> NAME <id>)
  *   if ( /TWX/TEST/UNIT.RUN )
  *     block ()
  *     ...
  *     endblock ()
  *   endif ()
  *   twx_test_unit_pop ()
  *
  * with trailing
  *
  *   endblock ()
  *   endif ()
  *   twx_test_suite_pop ()
  *
  */
/*
#]===============================================]

include_guard ( GLOBAL )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxLib.cmake" )

set ( /TWX/TESTING ON )

# ANCHOR: twx_test_during
#[=======[
*/
/** @brief Whether some test is actually running.
  *
  * @param var_name for key IN_VAR, on return receives `TRUE` if a test
  *   matching the given with given id is actually running, false otherwise.
  * @param domain for key DOMAIN, a domain name.
  * @param suite for key SUITE, a core suite name.
  * @param unit for key UNIT, a core unit name.
  * @param RE, optional flag to switch to regular expressions.
  */
/*
#]=======]
function ( twx_test_during )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "RE" "DOMAIN;SUITE;UNIT;ID;IN_VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR " Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  twx_test_guess ( FILE "/FOO/BAR/" )
  get_property (
    /TWX/TEST/DOMAIN_CORE
    GLOBAL
    PROPERTY /TWX/TEST/DOMAIN_CORE
  )
  get_property (
    /TWX/TEST/SUITE_STACK
    GLOBAL
    PROPERTY /TWX/TEST/SUITE_STACK
  )
  get_property (
    /TWX/TEST/UNIT.NAME
    GLOBAL
    PROPERTY /TWX/TEST/UNIT.NAME
  )
  set ( "${twx.R_IN_VAR}" OFF PARENT_SCOPE )
  if ( twx.R_DOMAIN )
    if ( twx.R_RE )
      if ( /TWX/TEST/DOMAIN_CORE MATCHES "${twx.R_DOMAIN}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( /TWX/TEST/DOMAIN_CORE STREQUAL "${twx.R_DOMAIN}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( DEFINED twx.R_SUITE )
    if ( twx.R_RE )
      foreach ( s ${/TWX/TEST/SUITE_STACK} )
        if ( s MATCHES "${twx.R_SUITE}" )
          set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
          return ()
        endif ()
      endforeach ()
    else ()
      foreach ( s ${/TWX/TEST/SUITE_STACK} )
        if ( s STREQUAL "${twx.R_SUITE}" )
          set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
          return ()
        endif ()
      endforeach ()
    endif ()
  endif ()
  if ( twx.R_UNIT )
    if ( twx.R_RE )
      if ( /TWX/TEST/UNIT.NAME MATCHES "${twx.R_UNIT}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( /TWX/TEST/UNIT.NAME STREQUAL "${twx.R_UNIT}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( twx.R_FULL )
    list ( POP_BACK /TWX/TEST/SUITE_STACK full_ )
    string ( PREPEND full_ "${/TWX/TEST/DOMAIN_CORE}/" )
    string ( APPEND full_ "/${/TWX/TEST/UNIT.NAME}" )
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

set ( /TWX/FATAL/CATCH OFF )

# ANCHOR: twx_test_guess
#[=======[
*/
/** @brief Setup domain and suite test 
  *
  * @param BUILD .
  * @param domain for key `DOMAIN`, the core domain name.
  *   When explicitly undefined, undefines all the variables.
  * @param domain for key `IN_DOMAIN`, optional. On return,
  *   `<domain>.NAME` will hold the domain core name,
  *   `<domain>.PATH` will also hold the domain core name (ensure some consistency),
  *   `<domain>.ID` will hold the domain full path and
  *   `<domain>.RUN` will hold the domain running status.
  * @param suite for key `IN_SUITE`, optional. On return,
  *   `<suite>.NAME` will hold the suite core name,
  *   `<suite>.PATH` will hold the suite path (with domain and suite core names),
  *   `<suite>.NAME` will hold the suite name,
  *   `<suite>.ID` will hold the suite full path,
  *   `<suite>.RUN` will hold the suite running status and
  *   `<suite>.LIB` will hold the suite associate library.
  * @param UNSET optional flag to sunset all the variables.
  *   `UNSET` and `FILE` are mutually exclusive.
  */
twx_test_guess ([FILE file] [IN_DOMAIN|DOMAIN domain] [IN_SUITE suite] [UNSET]) {}
/*
#]=======]
macro ( twx_test_guess )
  cmake_parse_arguments (
    twx_test_guess.R
    "UNSET" "FILE;IN_DOMAIN;DOMAIN;IN_SUITE" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_guess.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_guess.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( twx_test_guess.R_UNSET )
    if ( DEFINED twx_test_guess.R_FILE )
      message ( FATAL_ERROR "Bad usage: FILE and UNSET are mutually exclusive" )
    endif ()
    twx_test_domain_setup (
      IN_DOMAIN ${twx_test_guess.R_IN_DOMAIN}
      BUILD
    )
    twx_test_suite_setup (
      IN_SUITE ${twx_test_guess.R_IN_SUITE}
    )
  else ()
    if ( NOT DEFINED twx_test_guess.R_FILE )
      if ( EXISTS "${CMAKE_CURRENT_LIST_FILE}" )
        set ( twx_test_guess.R_FILE "${CMAKE_CURRENT_LIST_FILE}" )
      else ()
        message ( FATAL_ERROR "Bad usage: CMAKE_CURRENT_LIST_FILE => ``${CMAKE_CURRENT_LIST_FILE}''" )
      endif ()
    endif ()
    if ( "${twx_test_guess.R_FILE}" MATCHES "^(.*/CMake/[^/]+/)Test/([^/]+)/" )
      set ( twx_test_guess.DOMAIN.DIR "${CMAKE_MATCH_1}" )
      set ( twx_test_guess.SUITE.NAME "${CMAKE_MATCH_2}" )
      if ( DEFINED twx_test_guess.R_IN_DOMAIN )
        twx_var_assert_name ( "${twx_test_guess.R_IN_DOMAIN}" )
      else ()
        set ( twx_test_guess.R_IN_DOMAIN twx_test_guess.DOMAIN )
      endif ()
      twx_test_domain_setup (
        DIR "${twx_test_guess.DOMAIN.DIR}"
        IN_DOMAIN ${twx_test_guess.R_IN_DOMAIN}
        BUILD
      )
      if ( DEFINED twx_test_guess.R_IN_SUITE )
        twx_test_suite_setup (
          DOMAIN ${twx_test_guess.R_IN_DOMAIN}
          NAME "${twx_test_guess.SUITE.NAME}"
          IN_SUITE ${twx_test_guess.R_IN_SUITE}
        )
      endif ()
    elseif ( "${twx_test_guess.R_FILE}" MATCHES "^(.*/CMake/[^/]+/)Test/" )
      set ( twx_test_guess.DOMAIN.DIR "${CMAKE_MATCH_1}" )
      if ( DEFINED twx_test_guess.R_IN_DOMAIN )
        twx_var_assert_name ( "${twx_test_guess.R_IN_DOMAIN}" )
        twx_test_domain_setup (
          DIR "${twx_test_guess.DOMAIN.DIR}"
          IN_DOMAIN ${twx_test_guess.R_IN_DOMAIN}
          BUILD
        )
      endif ()
      if ( DEFINED twx_test_guess.R_IN_SUITE )
        twx_test_suite_setup (
          IN_SUITE ${twx_test_guess.R_IN_SUITE}
        )
      endif ()      
    else ()
      message ( FATAL_ERROR "Bad usage: FILE -> ``${twx_test_guess.R_FILE}''" )
    endif ()
  endif ()
  twx_var_unset (
    UNSET FILE IN_DOMAIN DOMAIN IN_SUITE
    VAR_PREFIX twx_test_guess.R_
  )
  twx_var_unset (
    DOMAIN.DIR SUITE.NAME
    VAR_PREFIX twx_test_guess.
  )
endmacro ()

# ANCHOR: twx_test_count
#[=======[
*/
/** @brief Test count manager.
  *
  * @param domain for key `DOMAIN`, optional domain name.
  *   When `<domain>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/DOMAIN`.
  * @param suite for key `SUITE`, optional suite name.
  *   When the `SUITE` keyword is given, `<domain>` is ignored.
  *   When `<suite>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/SUITE`.
  * @param unit for key `UNIT`, optional unit name.
  *   When the `UNIT` keyword is given, <domain> and <suite> are ignored.
  *   When `<unit>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/UNIT`.
  * @param key for key `KEY`, required key identifier.
  * @param unit for key `UNIT`, optional unit name.
  *   Defaults to `/TWX/TEST/UNIT`.
  * @param step for key `STEP`, optional value.
  * @param value for key `SET`, optional value.
  * @param var for key `IN_VAR`, optional variable name.
  *   On return, contains the value of the counter with the given key,
  *   once all changes are performed.
  */
twx_test_count ( DOMAIN|SUITE|UNIT [name] KEY key [SET|STEP value] [IN_VAR var]) {}
/*
#]=======]
function ( twx_test_count )
  twx_function_begin ()
  block ( PROPAGATE ${TWX_CMD}.KEY ${TWX_CMD}.R_IN_VAR )
    set ( list_ DOMAIN SUITE UNIT )
    if ( NOT ARGV0 IN_LIST list_ )
      message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''")
    endif ()
    cmake_parse_arguments (
      PARSE_ARGV 1 ${TWX_CMD}.R
      "DOMAIN;SUITE;UNIT" "" ""
    )
    if ( ${TWX_CMD}.R_DOMAIN OR ${TWX_CMD}.R_SUITE OR ${TWX_CMD}.R_UNIT )
      message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''")  
    endif ()
    cmake_parse_arguments (
      PARSE_ARGV 0 twx.R
      "" "KEY;STEP;SET;IN_VAR;DOMAIN;SUITE;UNIT" ""
    )
    if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
      message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''")
    endif ()
    if ( NOT DEFINED twx.R_KEY )
      message ( FATAL_ERROR "Missing `KEY' keyword")
    endif ()
    set ( type_ ${ARGV0} )
    if ( NOT DEFINED twx.R_${type_} )
      set ( twx.R_${type_} "/TWX/TEST/${type_}" )
    endif ()
    if ( DEFINED twx.R_UNIT AND NOT DEFINED ${twx.R_UNIT}.ID )
      message ( FATAL_ERROR "Not a test unit: `${twx.R_UNIT}''" )
    elseif ( DEFINED twx.R_SUITE AND NOT DEFINED ${twx.R_SUITE}.ID )
      message ( FATAL_ERROR "Not a test suite: ``${twx.R_SUITE}''" )
    elseif ( DEFINED twx.R_DOMAIN AND NOT DEFINED ${twx.R_DOMAIN}.ID )
      message ( FATAL_ERROR "Not a test domain: ``${twx.R_DOMAIN}''" )
    endif ()
    set ( key_ "${${twx.R_${type_}}.ID}/${twx.R_KEY}.VALUE" )
    if ( DEFINED twx.R_SET )
      math ( EXPR twx.R_SET "${twx.R_SET}" )
      twx_global_set ( "${twx.R_SET}" KEY "${key_}" )
    elseif ( DEFINED twx.R_STEP )
      twx_global_get ( KEY "${key_}" IN_VAR twx.VALUE )
      math ( EXPR twx.VALUE "${twx.VALUE}+(${twx.R_STEP})" )
      twx_global_set ( "${twx.VALUE}" KEY "${key_}" )
    endif ()
    set ( ${TWX_CMD}.KEY ${key_} )
    set ( ${TWX_CMD}.R_IN_VAR ${twx.R_IN_VAR} )
  endblock ()
  # twx_var_log ( ${TWX_CMD}.KEY MSG ${CMAKE_CURRENT_FUNCTION} )
  # twx_var_log ( ${TWX_CMD}.R_IN_VAR MSG ${CMAKE_CURRENT_FUNCTION} )
  # twx_global_get ( KEY "${${TWX_CMD}.KEY}" IN_VAR X )
  # twx_var_log ( X MSG ${CMAKE_CURRENT_FUNCTION} )
  if ( DEFINED ${TWX_CMD}.R_IN_VAR )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
    twx_global_get ( KEY "${${TWX_CMD}.KEY}" IN_VAR ${${TWX_CMD}.R_IN_VAR} )
    if ( NOT DEFINED ${${TWX_CMD}.R_IN_VAR} )
      set ( ${${TWX_CMD}.R_IN_VAR} 0 )
    endif ()
    twx_var_log ( DEBUG ${${TWX_CMD}.R_IN_VAR} MSG "${${TWX_CMD}.KEY}" )
    return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
  else ()
    twx_global_get ( KEY "${${TWX_CMD}.KEY}" IN_VAR twx.VALUE )
    twx_var_log ( DEBUG twx.VALUE MSG "${${TWX_CMD}.KEY}" )
  endif ()
endfunction ( twx_test_count )

# ANCHOR: twx_test_on
#[=======[
*/
/** @brief Private callback
  *
  * @param event for key `EVENT`, one of `PASS` or `FAIL`.
  * @param domain for key `DOMAIN`, optional domain name.
  *   When `<domain>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/DOMAIN`.
  * @param suite for key `SUITE`, optional suite name.
  *   When `<suite>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/SUITE`.
  * @param unit for key `UNIT`, optional unit name.
  *   When `<unit>` is not explicitly provided after the keyword,
  *   it defaults to `/TWX/TEST/UNIT`.
  */
twx_test_on (EVENT event DOMAIN|SUITE|UNIT [name]) {}
/*
#]=======]
function ( twx_test_on .EVENT .twx.R_EVENT twx.R_TYPE )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "EVENT" ""
  )
  set ( list_ PASS FAIL )
  if ( NOT twx.R_EVENT IN_LIST list_ )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''")
  endif ()
  if ( twx.R_EVENT STREQUAL "FAIL" AND /TWX/TEST/STOP_ON_FAIL )
    twx_global_set__ ( ON KEY /TWX/TEST/EMERGENCY_STOP )
  endif ()
  set ( list_ DOMAIN SUITE UNIT )
  if ( NOT twx.R_TYPE IN_LIST list_ )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''")
  endif ()
  if ( ARGC GREATER 4 )
    message ( FATAL_ERROR "Bad usage: ARGV => ``${ARGV}''")  
  endif ()
  if ( ARGC EQUAL 4 )
    set ( name_ "${ARGV3}" )
  else ()
    set ( name_ /TWX/TEST/${twx.R_TYPE} )
  endif ()
  if ( NOT DEFINED ${name_}.ID )
    string ( TOLOWER "${twx.R_TYPE}" type_ )
    message ( FATAL_ERROR "Not a test ${type_}: ``${name_}''" )
  endif ()
  twx_test_count ( ${twx.R_TYPE} ${name_} KEY ALL  STEP 1 )
  twx_test_count ( ${twx.R_TYPE} ${name_} KEY ${twx.R_EVENT} STEP 1 )
endfunction ( twx_test_on )

# SECTION: File

# ANCHOR: twx_test_file_push
#[=======[
*/
/** @brief Push a file path on the global stack
  *
  * @param file for key FILE, push the given element on the stack.
  *   An element must not be pushed twice.
  *   The file must exist.
  * @param msg for key NO_DUPLICATE_MSG, required error message .
  */
twx_test_file_push (FILE file [NO_DUPLICATE_MSG msg]) {}
/*
#]=======]
function ( twx_test_file_push )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "FILE;NO_DUPLICATE_MSG" ""
  )
  # Not yet: twx_arg_assert_parsed ()
  twx_assert_undefined ( twx.R_UNPARSED_ARGUMENTS )
  twx_assert_exists ( "${twx.R_FILE}" )
  twx_assert_defined ( twx.R_NO_DUPLICATE_MSG )
  twx_global_append (
    "${twx.R_FILE}"
    KEY /TWX/TEST/CURRENT_LIST_FILE_STACK
    NO_DUPLICATE 
    ERROR_MSG "${twx.R_NO_DUPLICATE_MSG}"
  )
endfunction ()

# ANCHOR: twx_test_file_pop
#[=======[
*/
/** @brief Pop a file path from the global stack
  *
  * This must follow a `twx_test_file_pop` in the program flow.
  * LIFO stack.
  *
  * @param var for key IN_VAR, optional, holds the result on return.
  */
twx_test_file_pop (IN_VAR var) {}
/*
#]=======]
function ( twx_test_file_pop )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''")
  endif ()
  if ( DEFINED twx.R_IN_VAR )
    twx_var_assert_name ( "${twx.R_IN_VAR}" )
    twx_global_pop_back (
      IN_VAR ${twx.R_IN_VAR}
      KEY /TWX/TEST/CURRENT_LIST_FILE_STACK
      REQUIRED
    )
    return ( PROPAGATE ${twx.R_IN_VAR} )
  else ()
    twx_global_pop_back (
      KEY /TWX/TEST/CURRENT_LIST_FILE_STACK
      REQUIRED
    )
  endif ()
endfunction ()

# ANCHOR: twx_test_file_get
#[=======[
*/
/** @brief Get the last pushed file path from the global stack
  *
  * If it does not follow `twx_test_file_pop` in the program flow,
  * the resulting variable is undefined.
  *
  * @param var for key IN_VAR, holds the result on return or is undefined.
  */
twx_test_file_pop (IN_VAR var) {}
/*
#]=======]
function ( twx_test_file_get )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''")
  endif ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  twx_global_get_back (
    IN_VAR twx_test_domain_pop.FILE
    KEY /TWX/TEST/CURRENT_LIST_FILE_STACK
  )
  return ( PROPAGATE ${twx.R_IN_VAR} )
endfunction ()

# !SECTION

# SECTION: Domain
# ANCHOR: twx_test_domain_log
#[=======[
*/
/** @brief Log a domain fields
  *
  * @param mode, optional, one of `STATUS`, `VERBOSE`, `DEBUG`, `TRACE`.
  * @param domain for key `DOMAIN`.
  */
twx_test_domain_log ([mode] DOMAIN domain) {}
/*
#]=======]
function ( twx_test_domain_log )
  if ( "${ARGV0}" IN_LIST /TWX/CONST/MESSAGE/MODES )
    set ( i 1 )
    set ( mode_ "${ARGV0}" )
  else ()
    set ( i 0 )
    set ( mode_ )
  endif ()
  cmake_parse_arguments (
    PARSE_ARGV ${i} twx.R
    "" "DOMAIN" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx.R_DOMAIN}" )
  foreach ( X NAME PATH ID RUN SKIP DIR )
    twx_var_log (
      DEBUG
      ${twx.R_DOMAIN}.${X}
    )
  endforeach ()
endfunction ( twx_test_domain_log )

# ANCHOR: twx_test_domain_setup
#[=======[
*/
/** @brief Setup test domain
  *
  * @param name for key `NAME`, optional domain core name.
  *   When not provided, unset all the variables.
  * @param domain for key `IN_DOMAIN`. On return,
  *   `<domain>.NAME` will hold the domain core name `<name>`,
  *   `<domain>.PATH` will hold the domain path,
  *   `<domain>.ID` will hold the domain full path and
  *   `<domain>.RUN` will hold the domain running status.
  *   If relevant, `<domain>.DIR` should be set out of this command.
  * @param BUILD, optional flag to specify whether the test
  *   concerns the build system ot not: `<domain>.PATH` is `BUILD/<name>`
  *   for the build system and just `<name>` otherwise.
  *   Ignored when no `NAME` is provided.
  *   
  * @param PARENT_SCOPE, optional flag to specify whether the assignments
  *   are made in the caller scope or the caller's parent scope.
  */
twx_test_domain_setup ([NAME id] IN_DOMAIN domain [BUILD] [PARENT_SCOPE]) {}
/*
#]=======]
macro ( twx_test_domain_setup )
  cmake_parse_arguments (
    twx_test_domain_setup.R
    "BUILD;PARENT_SCOPE" "DIR;IN_DOMAIN" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_domain_setup.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_domain_setup.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx_test_domain_setup.R_IN_DOMAIN}" )
  if ( twx_test_domain_setup.R_DIR MATCHES "CMake/.*/CMake" )
    message ( FATAL_ERROR "*****" )
  endif ()
  if ( DEFINED twx_test_domain_setup.R_DIR )
    set ( twx_test_domain_setup.DOMAIN.DIR    "${twx_test_domain_setup.R_DIR}" )
    if ( twx_test_domain_setup.R_DIR MATCHES "/CMake/([^/]+)/" )
      set ( twx_test_domain_setup.DOMAIN.NAME "${CMAKE_MATCH_1}")
    else ()
      message ( FATAL_ERROR " Bad usage: DIR -> ``${twx_test_domain_setup.R_DIR}''")
    endif ()
    if ( twx_test_domain_setup.R_BUILD )
      set ( twx_test_domain_setup.BUILD BUILD/ )
    else ()
      set ( twx_test_domain_setup.BUILD )
    endif ()
    set (
      twx_test_domain_setup.DOMAIN.PATH
      "${twx_test_domain_setup.BUILD}${twx_test_domain_setup.DOMAIN.NAME}"
    )
    set (
      twx_test_domain_setup.DOMAIN.ID
      "/TWX/TEST/${twx_test_domain_setup.DOMAIN.PATH}"
    )
    twx_test_domain_skip ( INIT DOMAIN twx_test_domain_setup.DOMAIN )
    if ( DEFINED ${twx_test_domain_setup.DOMAIN.ID}.RUN )
      set (
        twx_test_domain_setup.DOMAIN.RUN
        "${${twx_test_domain_setup.DOMAIN.ID}.RUN}"
      )
    else ()
      set ( twx_test_domain_setup.DOMAIN.RUN ON )
      block ( PROPAGATE twx_test_domain_setup.DOMAIN.RUN )
        set ( filter_ /TWX/TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/NO )
        if ( DEFINED ${filter_} AND twx_test_domain_setup.DOMAIN.NAME MATCHES "${${filter_}}" )
          set ( twx_test_domain_setup.DOMAIN.RUN OFF )
        endif ()
        if ( NOT twx_test_domain_setup.DOMAIN.RUN )
          set ( filter_ /TWX/TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/YES )
          if ( DEFINED ${filter_} AND twx_test_domain_setup.DOMAIN.NAME MATCHES "${${filter_}}" )
            set ( twx_test_domain_setup.DOMAIN.RUN ON )
          endif ()
        endif ()
        if ( twx_test_domain_setup.DOMAIN.RUN )
          set ( filter_ ${twx_test_domain_setup.DOMAIN.ID}/FILTER/NO )
          if ( DEFINED ${filter_} AND twx_test_domain_setup.DOMAIN.NAME MATCHES "${${filter_}}" )
            set ( twx_test_domain_setup.DOMAIN.RUN OFF )
          endif ()
        endif ()
        if ( NOT twx_test_domain_setup.DOMAIN.RUN )
          set ( filter_ /TWX/TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/NO )
          if ( DEFINED ${filter_} AND twx_test_domain_setup.DOMAIN.NAME MATCHES "${${filter_}}" )
            set ( twx_test_domain_setup.DOMAIN.RUN OFF )
          endif ()
        endif ()
      endblock ()
    endif ()
  else ()
    foreach ( x NAME PATH ID RUN SKIP )
      set ( twx_test_domain_setup.DOMAIN.${x} )
    endforeach ()
  endif ()
  if ( twx_test_domain_setup.R_PARENT_SCOPE )
    set ( twx_test_domain_setup.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_domain_setup.SCOPE )
  endif ()
  foreach ( X NAME PATH ID RUN DIR SKIP )
    set (
      ${twx_test_domain_setup.R_IN_DOMAIN}.${X}
      "${twx_test_domain_setup.DOMAIN.${X}}"
      ${twx_test_domain_setup.SCOPE}
    )
    set (
      twx_test_domain_setup.DOMAIN.${X}
      ${twx_test_domain_setup.SCOPE}
    )
  endforeach ()
  foreach ( X R_BUILD R_PARENT_SCOPE R_NAME R_IN_DOMAIN SCOPE BUILD RUN )
    set ( twx_test_domain_setup.${X} )
  endforeach ()
endmacro ( twx_test_domain_setup )

# ANCHOR: twx_test_domain_skip
#[=======[
*/
/** @brief Mark the test domain as ignored
  *
  * In `INIT` mode 
  *   `<domain>.SKIP` is set to the boolean value of
  *   `/TWX/TEST/.SKIP/<<domain>.PATH>`.
  * When `ON` is set
  *   `<domain>.SKIP` is set to true as well as
  *   `/TWX/TEST/.SKIP/<<domain>.PATH>`.
  * When `ON` is not set
  *   `<domain>.SKIP` is set to false as well as
  *   `/TWX/TEST/.SKIP/<<domain>.PATH>`.
  *  
  * @param domain for key `DOMAIN`.
  * @param INIT, optional. ON is ignored.
  * @param ON, optional. Ignored when INIT is set.
  * @param PARENT_SCOPE, optional flag to specify whether the assignments
  *   are made in the caller scope or the caller's parent scope.
  */
twx_test_domain_skip (DOMAIN domain [PARENT_SCOPE]) {}
/*
#]=======]
macro ( twx_test_domain_skip )
  cmake_parse_arguments (
    twx_test_domain_skip.R
    "INIT;ON;PARENT_SCOPE" "DOMAIN" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_domain_skip.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_domain_skip.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx_test_domain_skip.R_DOMAIN}" )
  if ( twx_test_domain_skip.R_PARENT_SCOPE )
    set ( twx_test_domain_skip.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_domain_skip.SCOPE )
  endif ()
  if ( ${twx_test_domain_skip.R_INIT} )
    set (
      twx_test_domain_skip.R_ON
      "${/TWX/TEST/.SKIP/${${twx_test_domain_skip.R_DOMAIN}.PATH}}"
    )
  endif ()
  set (
    ${twx_test_domain_skip.R_DOMAIN}.SKIP
    ${twx_test_domain_skip.R_ON}
    ${twx_test_domain_skip.SCOPE}
  )
  set (
    /TWX/TEST/.SKIP/${${twx_test_domain_skip.R_DOMAIN}.PATH}
    ${twx_test_domain_skip.R_ON}
    ${twx_test_domain_skip.SCOPE}
  )
  twx_var_unset (
    SCOPE R_ON R_INIT R_DOMAIN R_PARENT_SCOPE
    VAR_PREFIX twx_test_domain_skip.
  )
endmacro ( twx_test_domain_skip )

# ANCHOR: twx_test_domain_push
#[=======[
*/
/** @brief Before the test domain runs
  *
  * Must be balanced by a `twx_test_domain_pop()`.
  * set `/TWX/TEST/DOMAIN`.
  *
  */
twx_test_domain_push () {}
/*
#]=======]
macro ( twx_test_domain_push )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_guess (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    IN_DOMAIN /TWX/TEST/DOMAIN
  )
  twx_test_file_push (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    NO_DUPLICATE_MSG "Circular domain: ``${/TWX/TEST/DOMAIN.PATH}''"
  )
  twx_test_domain_log ( DEBUG DOMAIN /TWX/TEST/DOMAIN )
  if ( ${/TWX/TEST/.SKIP/${/TWX/TEST/DOMAIN.PATH}} )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( DEBUG "Test domain ${/TWX/TEST/DOMAIN.PATH}... Ignored" ID Test/Domain )
    endblock ()
    # Do nothing
  elseif ( /TWX/TEST/DOMAIN.RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( CHECK_START "Test domain ${/TWX/TEST/DOMAIN.PATH}..." ID Test/Domain )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${/TWX/TEST/DOMAIN.NAME}" )
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( STATUS "Test domain ${/TWX/TEST/DOMAIN.PATH}... skipped" ID Test/Domain )
    endblock ()
  endif ()
endmacro ()

# ANCHOR: twx_test_domain_pop
#[=======[
*/
/** @brief After the test domain runs
  *
  * Must balance a `twx_test_domain_push()`.
  *
  */
twx_test_domain_pop () {}
/*
#]=======]
macro ( twx_test_domain_pop )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_file_pop ()
  if ( ${/TWX/TEST/.SKIP/${/TWX/TEST/DOMAIN.PATH}} )
    set ( /TWX/TEST/DOMAIN.SKIP ON )
  else ()
    set ( /TWX/TEST/.SKIP/${/TWX/TEST/DOMAIN.PATH} ON )
    set ( /TWX/TEST/DOMAIN.SKIP ON )
    if ( /TWX/TEST/DOMAIN.RUN )
      list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
      set (
        twx_test_domain_pop.BANNER
        "Test domain ${/TWX/TEST/DOMAIN.PATH}... "
      )
      if ( COMMAND twx_fatal_assert_pass )
        twx_fatal_assert_pass ()
      endif ()
      if ( COMMAND twx_fatal_catched )
        twx_fatal_catched ( IN_VAR v )
        if ( v AND NOT v STREQUAL "" )
          twx_test_count ( DOMAIN KEY ALL  STEP 1 )
          twx_test_count ( DOMAIN KEY FAIL STEP 1 )
          twx_fatal_clear ()
        endif ()
        block ( PROPAGATE twx_test_domain_pop.BANNER )
          twx_test_count ( DOMAIN KEY ALL  IN_VAR all_  )
          twx_test_count ( DOMAIN KEY PASS IN_VAR pass_ )
          twx_test_count ( DOMAIN KEY FAIL IN_VAR fail_ )
          if ( fail_ GREATER 0 )
            string ( APPEND twx_test_domain_pop.BANNER "FAIL: ${fail_} out of ${all_} test suites" )
            twx_test_count ( DOMAIN KEY FAIL STEP 1 )
          else ()
            string ( APPEND twx_test_domain_pop.BANNER "PASS: all ${all_} test suites" )
            twx_test_count ( DOMAIN KEY PASS STEP 1 )
          endif ()
        endblock ()
      endif ()
      block ()
        set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
        twx_format_message ( STATUS "${twx_test_domain_pop.BANNER}" ID Test/Domain )
      endblock ()
      twx_test_file_get ( IN_VAR twx_test_domain_pop.FILE )
      if ( DEFINED twx_test_domain_pop.FILE )
        twx_test_guess (
          FILE "${twx_test_domain_pop.FILE}"
          IN_DOMAIN /TWX/TEST/DOMAIN
        )
        block ()
          set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
          twx_format_message ( CHECK_START "... Test domain ${/TWX/TEST/DOMAIN.NAME}..." ID Test/Domain )
        endblock ()
        list ( APPEND CMAKE_MESSAGE_CONTEXT "${/TWX/TEST/DOMAIN.NAME}" )
      else ()
        twx_test_guess (
          IN_DOMAIN /TWX/TEST/DOMAIN
        )
      endif ()
      twx_var_unset (
        BANNER FILE
        VAR_PREFIX twx_test_domain_pop.
      )
    endif ()
  endif ()
  twx_var_log ( DEBUG /TWX/TEST/.SKIP/${/TWX/TEST/DOMAIN.PATH} )
endmacro ( twx_test_domain_pop )

# !SECTION
# SECTION: Suite
# ANCHOR: twx_test_suite_log
#[=======[
*/
/** @brief Log a suite fields
  *
  * @param mode, optional, one of `STATUS`, `VERBOSE`, `DEBUG`, `TRACE`.
  * @param suite for key `SUITE`.
  */
twx_test_suite_log ([mode] SUITE suite) {}
/*
#]=======]
function ( twx_test_suite_log )
  if ( "${ARGV0}" IN_LIST /TWX/CONST/MESSAGE/MODES )
    set ( i 1 )
    set ( mode_ "${ARGV0}" )
  else ()
    set ( i 0 )
    set ( mode_ )
  endif ()
  cmake_parse_arguments (
    PARSE_ARGV ${i} twx.R
    "" "SUITE" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx.R_SUITE}" )
  twx_var_log (
    ${mode_}
    ${${twx.R_SUITE}.DOMAIN}.NAME
  )
  foreach ( X NAME PATH ID RUN SKIP DIR LIB )
    twx_var_log (
      ${mode_}
      ${twx.R_SUITE}.${X}
    )
  endforeach ()
endfunction ( twx_test_suite_log )

# ANCHOR: twx_test_suite_setup
#[=======[
*/
/** @brief Setup test suite
  *
  * @param domain for key `DOMAIN`, optional domain.
  * @param name for key `NAME`, optional core suite name.
  * @param suite for key `IN_SUITE`. On return,
  *   `<suite>.NAME` will hold the suite core name `<suite>`,
  *   `<suite>.PATH` will hold the suite path ``<domain>.PATH`/<suite>`,
  *   `<suite>.ID` will hold the suite identifier ``<domain>.ID`/<suite>` and
  *   `<suite>.RUN` will hold the suite running status.
  *   If the domain run status is OFF, the suite run status is also OFF.
  * @param PARENT_SCOPE, optional flag to specify whether the assignments
  *   are made in the caller scope or the caller's parent scope.
  */
twx_test_suite_setup ([DOMAIN domain NAME name] IN_SUITE suite [PARENT_SCOPE]) {}
/*
#]=======]
macro ( twx_test_suite_setup )
  cmake_parse_arguments (
    twx_test_suite_setup.R
    "PARENT_SCOPE" "DOMAIN;NAME;IN_SUITE" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_suite_setup.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_suite_setup.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx_test_suite_setup.R_IN_SUITE}" )
  if ( DEFINED twx_test_suite_setup.R_NAME )
    if ( NOT DEFINED twx_test_suite_setup.R_DOMAIN )
      message ( FATAL_ERROR "Missing argument for key ``DOMAIN''" )
    endif ()
    if ( NOT DEFINED ${twx_test_suite_setup.R_DOMAIN}.NAME )
      message ( FATAL_ERROR "Not a domain: ``${twx_test_suite_setup.R_DOMAIN}''" )
    endif ()
    set ( twx_test_suite_setup.SUITE.DOMAIN "${twx_test_suite_setup.R_DOMAIN}" )
    set ( twx_test_suite_setup.SUITE.NAME   "${twx_test_suite_setup.R_NAME}" )
    set ( twx_test_suite_setup.SUITE.PATH   "${${twx_test_suite_setup.R_DOMAIN}.PATH}/${twx_test_suite_setup.SUITE.NAME}" )
    set ( twx_test_suite_setup.SUITE.ID     "${${twx_test_suite_setup.R_DOMAIN}.ID}/${twx_test_suite_setup.SUITE.NAME}" )
    set ( twx_test_suite_setup.SUITE.DIR    "${${twx_test_suite_setup.R_DOMAIN}.DIR}Test/${twx_test_suite_setup.SUITE.NAME}/Twx${twx_test_suite_setup.SUITE.NAME}Test.cmake" )
    twx_assert_exists ( "${twx_test_suite_setup.SUITE.DIR}" )
    twx_test_suite_skip ( INIT SUITE twx_test_suite_setup.SUITE )
    if ( ${twx_test_suite_setup.R_DOMAIN}.SKIP )
      set (twx_test_suite_setup.SUITE.RUN OFF )
    elseif ( NOT ${twx_test_suite_setup.R_DOMAIN}.RUN )
      set (twx_test_suite_setup.SUITE.RUN OFF )
    elseif ( DEFINED ${twx_test_suite_setup.ID}.RUN )
      set (
        twx_test_suite_setup.SUITE.RUN
        "${${twx_test_suite_setup.ID}.RUN}"
      )
    else ()
      block ( PROPAGATE twx_test_suite_setup.SUITE.RUN )
        if ( ${twx_test_suite_setup.R_DOMAIN}.ID MATCHES "/BUILD/" )
          set ( build_ BUILD/ )
        else ()
          set ( build_ )
        endif ()
        set ( run_ ON )
        set ( filter_ /TWX/TEST/${build_}SUITE/FILTER/NO )
        if ( DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
          set ( run_ OFF )
        endif ()
        set ( filter_ /TWX/TEST/${build_}SUITE/FILTER/YES )
        if ( NOT run_ AND DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
          set ( run_ ON )
        endif ()
        set ( filter_ ${twx_test_suite_setup.SUITE.ID}/FILTER/NO )
        if ( run_ AND DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
          set ( run_ OFF )
        endif ()
        set ( filter_ ${twx_test_suite_setup.SUITE.ID}/FILTER/YES )
        if ( NOT run_ AND DEFINED ${filter_} AND NOT twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
          set ( run_ ON )
        endif ()
        set ( twx_test_suite_setup.SUITE.RUN ${run_} )
      endblock ()
    endif ()
    if ( DEFINED ${twx_test_suite_setup.R_DOMAIN}.DIR AND NOT twx_test_suite_setup.SUITE.NAME STREQUAL "POC" )
      set (
        twx_test_suite_setup.SUITE.LIB
        "${${twx_test_suite_setup.R_DOMAIN}.DIR}Twx${twx_test_suite_setup.SUITE.NAME}.cmake"
      )
      cmake_path ( NORMAL_PATH twx_test_suite_setup.SUITE.LIB )
      if ( NOT EXISTS "${twx_test_suite_setup.SUITE.LIB}" )
        set (
          twx_test_suite_setup.SUITE.LIB
          "${${twx_test_suite_setup.R_DOMAIN}.DIR}Twx${twx_test_suite_setup.SUITE.NAME}Lib.cmake"
        )
        cmake_path ( NORMAL_PATH twx_test_suite_setup.SUITE.LIB )
        if ( NOT EXISTS "${twx_test_suite_setup.SUITE.LIB}" )
          message ( FATAL_ERROR "No library to test: ``${twx_test_suite_setup.SUITE.LIB}''" )
        endif ()
      endif ()
    else ()
      set ( twx_test_suite_setup.SUITE.LIB )
    endif ()
  else ()
    foreach ( x NAME PATH ID SKIP RUN DIR LIB )
      set ( twx_test_suite_setup.SUITE.${x} )
    endforeach ()
  endif ()
  if ( twx_test_suite_setup.R_PARENT_SCOPE )
    set ( twx_test_suite_setup.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_suite_setup.SCOPE )
  endif ()
  foreach ( twx_test_suite_setup.X DOMAIN NAME PATH ID SKIP RUN DIR LIB )
    set (
      ${twx_test_suite_setup.R_IN_SUITE}.${twx_test_suite_setup.X}
      ${twx_test_suite_setup.SUITE.${twx_test_suite_setup.X}}
      ${twx_test_suite_setup.SCOPE}
    )
    set ( twx_test_suite_setup.SUITE.${twx_test_suite_setup.X} )
  endforeach ()
  twx_var_unset (
    X SCOPE R_PARENT_SCOPE R_DOMAIN R_NAME R_IN_SUITE
    VAR_PREFIX twx_test_suite_setup.
  )
endmacro ( twx_test_suite_setup )

# ANCHOR: twx_test_suite_skip
#[=======[
*/
/** @brief Mark the test suite as ignored
  *
  * In `INIT` mode
  *   `<suite>.SKIP` is set to the boolean value of
  *   `/TWX/TEST/.SKIP/<<suite>.PATH>`.
  * When `ON` is set
  *   `<suite>.SKIP` is set to true as well as
  *   `/TWX/TEST/.SKIP/<<suite>.PATH>`.
  * When `ON` is not set
  *   `<suite>.SKIP` is set to false as well as
  *   `/TWX/TEST/.SKIP/<<suite>.PATH>`.
  *  
  * @param suite for key `SUITE`.
  * @param INIT, optional. ON is ignored.
  * @param ON, optional. Ignored when INIT is set.
  * @param PARENT_SCOPE, optional flag to specify whether the assignments
  *   are made in the caller scope or the caller's parent scope.
  */
twx_test_suite_skip (SUITE suite [PARENT_SCOPE]) {}
/*
#]=======]
macro ( twx_test_suite_skip )
  cmake_parse_arguments (
    twx_test_suite_skip.R
    "INIT;ON;PARENT_SCOPE" "SUITE" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_suite_skip.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_suite_skip.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx_test_suite_skip.R_SUITE}" )
  if ( twx_test_suite_skip.R_INIT )
    if ( /TWX/TEST/.SKIP/${${${twx_test_suite_skip.R_SUITE}.DOMAIN}.PATH} )
      set (
        twx_test_suite_skip.R_ON
        ON
      )
    else ()
      set (
        twx_test_suite_skip.R_ON
        ${/TWX/TEST/.SKIP/${${twx_test_suite_skip.R_SUITE}.PATH}}
      )
    endif ()
  endif ()
  if ( twx_test_suite_skip.R_PARENT_SCOPE )
    set ( twx_test_suite_skip.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_suite_skip.SCOPE )
  endif ()
  set (
    ${twx_test_suite_skip.R_SUITE}.SKIP
    ${twx_test_suite_skip.R_ON}
    ${twx_test_suite_skip.SCOPE}
  )
  set (
    /TWX/TEST/.SKIP/${${twx_test_suite_skip.R_SUITE}.PATH}
    ${${twx_test_suite_skip.R_SUITE}.SKIP}
    ${twx_test_suite_skip.SCOPE}
  )
  twx_var_unset (
    SCOPE R_ON R_SUITE R_PARENT_SCOPE
    VAR_PREFIX twx_test_suite_skip.
  )
endmacro ( twx_test_suite_skip )

# ANCHOR: twx_test_suite_push
#[=======[
*/
/** @brief Before the test suite runs
  *
  * Must be balanced by a `twx_test_suite_pop()`.
  * Loads the associate library retrieved from the path of the current list file.
  * A `block()` instruction should follow.
  *
  */
twx_test_suite_push () {}
/*
#]=======]
macro ( twx_test_suite_push )
  # API guards
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_guess (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    IN_DOMAIN /TWX/TEST/DOMAIN
    IN_SUITE  /TWX/TEST/SUITE
  )
  twx_test_file_push (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    NO_DUPLICATE_MSG "Circular suite: ``${/TWX/TEST/SUITE.NAME}''"
  )
  set ( /TWX/FATAL/CATCH ON )
  if ( ${/TWX/TEST/.SKIP/${/TWX/TEST/DOMAIN.PATH}} )
    set ( ${/TWX/TEST/.SKIP/${/TWX/TEST/SUITE.PATH}} ON )
  endif ()
  set ( twx_test_suite_push.BANNER "Test suite ${/TWX/TEST/SUITE.PATH}...")
  if ( ${/TWX/TEST/.SKIP/${/TWX/TEST/SUITE.PATH}} )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( DEBUG "${twx_test_suite_push.BANNER} ignored" ID Test/Suite )
    endblock ()
  else ()
    if ( /TWX/TEST/SUITE.RUN )
      block ()
        set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
        twx_format_message ( STATUS "${twx_test_suite_push.BANNER}" ID Test/Suite )
      endblock ()
      list ( APPEND CMAKE_MESSAGE_CONTEXT "${/TWX/TEST/SUITE.NAME}" )
    else ()
      block ()
        set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
        twx_format_message ( VERBOSE "${twx_test_suite_push.BANNER} skipped" ID Test/Suite )
      endblock ()
    endif ()
  endif ()
  if ( DEFINED /TWX/TEST/SUITE.LIB )
    include ( "${/TWX/TEST/SUITE.LIB}" )
    # twx_lib_require ( "${/TWX/TEST/SUITE.LIB}" )
  endif ()
  twx_var_unset (
    BANNER
    VAR_PREFIX twx_test_suite_push.
  )
endmacro ( twx_test_suite_push )

# ANCHOR: twx_test_suite_pop
#[=======[
*/
/** @brief After the test suite runs
  *
  * Must balance a `twx_test_suite_push()`.
  *
  */
twx_test_suite_pop () {}
/*
#]=======]
macro ( twx_test_suite_pop )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_file_pop ( IN_VAR twx_test_suite_pop.FILE )
  if ( "${twx_test_suite_pop.FILE}" MATCHES "/CMake/.*/CMake/" )
    twx_var_log ( twx_test_suite_pop.FILE )
    message ( FATAL_ERROR "*****" )
  endif ()
  twx_test_guess (
    FILE "${twx_test_suite_pop.FILE}"
    IN_DOMAIN /TWX/TEST/DOMAIN
    IN_SUITE /TWX/TEST/SUITE
  )
  if ( ${/TWX/TEST/.SKIP/${/TWX/TEST/SUITE.PATH}} )
  elseif ( /TWX/TEST/SUITE.RUN )
    list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
    twx_format_message (
      "Test suite ${/TWX/TEST/SUITE.PATH}..."
      ID Test/Suite
      IN_VAR twx_test_suite_pop.BANNER
    )
    string ( APPEND twx_test_suite_pop.BANNER " - " )
    set ( twx_test_suite_pop.MODE STATUS )
    if ( COMMAND twx_fatal_catched )
      twx_fatal_catched ( IN_VAR v )
      if ( v AND NOT v STREQUAL "" )
        twx_test_count ( SUITE KEY ALL  STEP 1 )
        twx_test_count ( SUITE KEY FAIL STEP 1 )
        twx_fatal_clear ()
      endif ()
      block ( PROPAGATE twx_test_suite_pop.BANNER )
        twx_test_count ( SUITE KEY ALL  IN_VAR all_  )
        twx_test_count ( SUITE KEY PASS IN_VAR pass_ )
        twx_test_count ( SUITE KEY FAIL IN_VAR fail_ )
        twx_test_count ( DOMAIN KEY ALL  STEP 1 )
        if ( fail_ GREATER 0 )
          twx_format_message (
            "FAIL: ${fail_} out of ${all_} test units"
            ID Test/FAIL
            APPEND_TO twx_test_suite_pop.BANNER
          )
          twx_test_count ( DOMAIN KEY FAIL STEP 1 )
        else ()
          twx_format_message (
            "PASS: all ${all_} test units"
            ID Test/PASS
            APPEND_TO twx_test_suite_pop.BANNER
          )
          twx_test_count ( DOMAIN KEY PASS STEP 1 )
        endif ()
      endblock ()
    endif ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      message (
        ${twx_test_suite_pop.MODE}
        "${twx_test_suite_pop.BANNER}"
      )
    endblock ()
  endif ()
  set (
    ${/TWX/TEST/.SKIP/${/TWX/TEST/SUITE.PATH}}
    ON
  )
  twx_test_file_get ( IN_VAR twx_test_suite_pop.FILE )
  if ( DEFINED twx_test_suite_pop.FILE )
    twx_test_guess (
      FILE "${twx_test_suite_pop.FILE}"
      IN_DOMAIN /TWX/TEST/DOMAIN
      IN_SUITE  /TWX/TEST/SUITE
    )
  else ()
    twx_test_guess (
      UNSET
      IN_DOMAIN /TWX/TEST/DOMAIN
      IN_SUITE  /TWX/TEST/SUITE
    )
  endif ()
  twx_var_unset (
    FILE BANNER MODE
    VAR_PREFIX twx_test_suite_pop.
  )
endmacro ( twx_test_suite_pop )

function ( TwxTestLib_state_prepare )
  get_property (
    /TWX/TEST/SUITE_STACK
    GLOBAL
    /TWX/TEST/SUITE_STACK
  )
  return ( PPROPAGATE /TWX/TEST/SUITE_STACK )
endfunction ()

macro ( twx_test_include )
  foreach ( n ${ARGV} )
    set (
      twx_include_test.p
      "${CMAKE_CURRENT_LIST_DIR}/Twx${n}/Twx${n}Test.cmake"
    )
    if ( EXISTS "${twx_include_test.p}" )
      include ( "${twx_include_test.p}" )
    else ()
      include (
        "${CMAKE_CURRENT_LIST_DIR}/../Twx${n}/Twx${n}Test.cmake"
      )
    endif ()
  endforeach ()
  set ( twx_include_test.p )
endmacro ( twx_test_include )

# !SECTION
# SECTION: Unit
# ANCHOR: twx_test_unit_log
#[=======[
*/
/** @brief Log a unit fields
  *
  * @param mode, optional, one of `STATUS`, `VERBOSE`, `DEBUG`, `TRACE`.
  * @param unit for key `UNIT`.
  */
twx_test_unit_log ([mode] UNIT unit) {}
/*
#]=======]
function ( twx_test_unit_log )
  if ( "${ARGV0}" IN_LIST /TWX/CONST/MESSAGE/MODES )
    set ( i 1 )
    set ( mode_ "${ARGV0}" )
  else ()
    set ( i 0 )
    set ( mode_ )
  endif ()
  cmake_parse_arguments (
    PARSE_ARGV ${i} twx.R
    "" "UNIT" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${twx.R_UNIT}" )
  foreach ( X DOMAIN SUITE NAME PATH ID SKIP RUN )
    twx_var_log ( DEBUG ${twx.R_UNIT}.${X} )
  endforeach ()
endfunction ( twx_test_unit_log )

# ANCHOR: twx_test_unit_push
#[=======[
*/
/** @brief Push a unit test
  *
  * Must be balanced by a `twx_test_unit_pop()`.
  * One of the two optional `ID` or `NAME` arguments must be provided.
  *
  * @param suite for key `SUITE`, optional suite.
  *   Defaults to `/TWX/TEST/SUITE`.
  * @param unit for key `IN_UNIT`, optional unit.
  *   Defaults to `/TWX/TEST/UNIT`.
  * @param id for key `ID`, short identifier for the message context.
  *   Must not evaluate to false in boolean context.
  *   When not provided, guessed from the requires <name>.
  * @param name for key `NAME`, short identifier for the message context.
  *   Must not evaluate to false in boolean context.
  *   When not provided, guessed from the requires <id>.
  */
twx_test_unit_push ([SUITE suite] [IN_UNIT unit] NAME name|CORE id) {}
/*
#]=======]
macro ( twx_test_unit_push )
  # API guards
  cmake_parse_arguments (
    twx_test_unit_push.R
    "PARENT_SCOPE" "NAME;CORE;SUITE;IN_UNIT" ""
    ${ARGV}
  )
  if ( DEFINED twx_test_unit_push.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx_test_unit_push.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  #
  if ( NOT DEFINED twx_test_unit_push.R_SUITE )
    set ( twx_test_unit_push.R_SUITE /TWX/TEST/SUITE )
  endif ()
  if ( DEFINED twx_test_unit_push.R_IN_UNIT )
    twx_var_assert_name ( "${twx_test_unit_push.R_IN_UNIT}" )
  else ()
    set ( twx_test_unit_push.R_IN_UNIT /TWX/TEST/UNIT )
  endif ()
  # Flow guard
  twx_global_get ( KEY twx_test_unit_push.UNIT.NAME )
  if ( DEFINED twx_test_unit_push.UNIT.NAME )
    message ( FATAL_ERROR "Unterminated test unit ``${twx_test_unit_push.UNIT.NAME}''" )
  endif ()
  if ( "${twx_test_unit_push.R_NAME}" STREQUAL "" )
    if ( "${twx_test_unit_push.R_CORE}" STREQUAL "" )
      message ( FATAL_ERROR "Missing CORE or NAME argument" )
    else ()
      set (
        twx_test_unit_push.R_NAME
        ${twx_test_unit_push.R_CORE}
      )
    endif ()
  elseif ( "${twx_test_unit_push.R_CORE}" STREQUAL "" )
    set ( twx_test_unit_push.R_CORE "${twx_test_unit_push.R_NAME}" )
  endif ()
  set ( twx_test_unit_push.UNIT.NAME "${twx_test_unit_push.R_NAME}" )
  twx_global_set (
    "${twx_test_unit_push.UNIT.NAME}"
    KEY twx_test_unit_push.UNIT.NAME
  )
  set (
    twx_test_unit_push.UNIT.PATH
    "${${twx_test_unit_push.R_SUITE}.PATH}/${twx_test_unit_push.R_CORE}"
  )
  set (
    twx_test_unit_push.UNIT.ID
    "${${twx_test_unit_push.R_SUITE}.ID}/${twx_test_unit_push.R_CORE}"
  )
  set (
    twx_test_unit_push.UNIT.SUITE
    "${${twx_test_unit_push.R_SUITE}.NAME}"
  )
  set (
    twx_test_unit_push.UNIT.DOMAIN
    "${${${twx_test_unit_push.R_SUITE}.DOMAIN}.NAME}"
  )
  if ( ${twx_test_unit_push.R_SUITE}.SKIP OR /TWX/TEST/.SKIP/${twx_test_unit_push.UNIT.PATH} )
    set ( twx_test_unit_push.UNIT.SKIP ON )
  else ()
    set ( twx_test_unit_push.UNIT.SKIP OFF )
  endif ()

  # Serious things start here
  block ( PROPAGATE twx_test_unit_push.UNIT.RUN )
    set ( run_ ON )
    if ( twx_test_unit_push.UNIT.SKIP )
      set ( run_ OFF )
    elseif ( ${twx_test_unit_push.R_SUITE}.RUN )
      set ( filter_ TWX/TEST/UNIT/FILTER/NO )
      if ( run_ AND DEFINED ${filter_} AND twx_test_unit_push.R_CORE MATCHES "${${filter_}}" )
        set ( twx_test_unit_push.UNIT.RUN OFF )
      endif ()
      set ( filter_ TWX/TEST/UNIT/FILTER/YES )
      if ( run_ AND DEFINED ${filter_} AND NOT twx_test_unit_push.R_CORE MATCHES "${${filter_}}" )
        set ( twx_test_unit_push.UNIT.RUN OFF )
      endif ()
      set ( filter_ TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/NO )
      if ( run_ AND DEFINED ${filter_} AND twx_test_unit_push.R_CORE MATCHES "${${filter_}}" )
        set ( run_ OFF )
      endif ()
      set ( filter_ TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/YES )
      if ( run_ AND DEFINED ${filter_} AND NOT twx_test_unit_push.R_CORE MATCHES "${${filter_}}" )
        set ( run_ OFF )
      endif ()
    else ()
      set ( run_ OFF )
    endif ()
    set ( twx_test_unit_push.UNIT.RUN ${run_} )
  endblock ()
  if ( twx_test_unit_push.UNIT.SKIP )
  elseif ( twx_test_unit_push.UNIT.RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( CHECK_START "Test unit  ${twx_test_unit_push.UNIT.PATH}" ID Test/Unit )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${twx_test_unit_push.UNIT.CORE}" )
    set ( twx_test_unit_push.CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}" )
    if ( NOT CMAKE_MESSAGE_CONTEXT_SHOW )
      string ( APPEND CMAKE_MESSAGE_INDENT "  " )
    endif ()
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( VERBOSE "Test unit  ${twx_test_unit_push.UNIT.PATH} skipped" ID Test/Unit )
    endblock()
  endif ()
  if ( twx_test_unit_push.R_PARENT_SCOPE )
    set ( twx_test_unit_push.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_unit_push.SCOPE )
  endif ()
  set (
    /TWX/TEST/.SKIP/${twx_test_unit_push.UNIT.PATH}
    ${twx_test_unit_push.UNIT.SKIP}
    ${twx_test_unit_push.SCOPE}
  )
  foreach ( X NAME PATH ID SKIP RUN )
    set (
      ${twx_test_unit_push.R_IN_UNIT}.${X}
      "${twx_test_unit_push.UNIT.${X}}"
      ${twx_test_unit_push.SCOPE}
    )
    set ( twx_test_unit_push.UNIT.${X} )
  endforeach ()
  twx_var_unset (
    UNIT.NAME SCOPE R_PARENT_SCOPE R_NAME R_CORE R_SUITE R_IN_UNIT R_UNPARSED_ARGUMENTS R_KEYWORDS_MISSING_VALUES
    VAR_PREFIX twx_test_unit_push.
  )
endmacro ( twx_test_unit_push )

# ANCHOR: twx_test_unit_pop
#[=======[
*/
/** @brief After the test unit runs
  *
  * Must balance a `twx_test_unit_push()`.
  *
  */
twx_test_unit_pop () {}
/*
#]=======]
macro ( twx_test_unit_pop )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( /TWX/TEST/UNIT.RUN )
    list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
    set ( CMAKE_MESSAGE_INDENT ${twx_test_unit_push.CMAKE_MESSAGE_INDENT} )
    if ( COMMAND twx_fatal_catched )
      twx_fatal_catched ( IN_VAR v )
      if ( v AND NOT v STREQUAL "" )
        twx_test_on ( EVENT FAIL UNIT )
      endif ()
      twx_fatal_clear ()
      twx_test_count ( UNIT  KEY ALL  IN_VAR twx.ALL.VALUE  )
      twx_test_count ( UNIT  KEY PASS IN_VAR twx.PASS.VALUE )
      twx_test_count ( UNIT  KEY FAIL IN_VAR twx.FAIL.VALUE )
      twx_test_count ( SUITE KEY ALL  STEP 1 )
      if ( twx.FAIL.VALUE GREATER 0 )
        twx_test_count ( SUITE KEY FAIL STEP 1 )
        if ( /TWX/TEST/STOP_ON_FAIL )
          message ( FATAL_ERROR "FAILURE" )
        else ()
          twx_fatal ( "FAILURE" )
        endif ()
      else ()
        twx_test_count ( SUITE KEY PASS STEP 1 )
      endif ()
      twx_fatal_assert_pass (
        CHECK MESSAGE_CONTEXT_HIDE
        MSG_PASS "PASS: all ${twx.ALL.VALUE} tests"
        MSG_FAIL "FAIL: ${twx.FAIL.VALUE} out of ${twx.COUNT.VALUE} tests"
      )
    endif ()
  endif ()
  twx_global_set (
    KEY twx_test_unit_push.UNIT.NAME
  )
  set ( /TWX/TEST/UNIT.RUN )
endmacro ( twx_test_unit_pop )

# !SECTION
# SECTION: Simple
# ANCHOR: twx_test_simple_check
#[=======[
*/
/** @brief Start a simple test
  *
  * @param start, the `CHECK_START` like message, in VERBOSE mode only.
  *
  */
twx_test_simple_check () {}
/*
#]=======]
macro ( twx_test_simple_check twx.R_SIMPLE_CHECK )
  if ( NOT ${ARGC} EQUAL 1 )
    message ( FATAL_ERROR " Bad usage: ARGN => ``${ARGN}''" )
  endif ()
  if ( DEFINED /TWX/TEST/SIMPLE_CHECK )
    message ( FATAL_ERROR "No nested simple tests" )
  endif ()
  twx_fatal_clear ()
  set ( /TWX/TEST/SIMPLE_CHECK "${twx.R_SIMPLE_CHECK}" )
endmacro ()

# ANCHOR: twx_test_simple_pass
#[=======[
*/
/** @brief Simple test pass assertion
  *
  */
twx_test_simple_pass () {}
/*
#]=======]
macro ( twx_test_simple_pass )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  block ()
  if ( NOT /TWX/TEST/SIMPLE_MESSAGE_CONTEXT_SHOW )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  twx_fatal_assert_pass (
    VERBOSE "${/TWX/TEST/SIMPLE_CHECK}"
    ON_PASS twx_test_on EVENT PASS UNIT
    ON_FAIL twx_test_on EVENT FAIL UNIT
  )
  twx_global_get__ ( KEY /TWX/TEST/EMERGENCY_STOP )
  if ( /TWX/TEST/EMERGENCY_STOP )
    message ( FATAL_ERROR "EMERGENCY" )
  endif ()
  endblock ()
  set ( /TWX/TEST/SIMPLE_CHECK )
endmacro ()

# ANCHOR: twx_test_simple_fail
#[=======[
*/
/** @brief Simple test fail assertion
  *
  */
twx_test_simple_fail () {}
/*
#]=======]
macro ( twx_test_simple_fail )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  block ()
  if ( NOT /TWX/TEST/SIMPLE_MESSAGE_CONTEXT_SHOW )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  endif ()
  twx_fatal_assert_fail (
    VERBOSE "${/TWX/TEST/SIMPLE_CHECK}"
    ON_PASS twx_test_on EVENT PASS UNIT
    ON_FAIL twx_test_on EVENT FAIL UNIT
  )
  twx_global_get__ ( KEY /TWX/TEST/EMERGENCY_STOP )
  if ( /TWX/TEST/EMERGENCY_STOP )
    message ( FATAL_ERROR "EMERGENCY STOP" )
  endif ()
  endblock ()
  set ( /TWX/TEST/SIMPLE_CHECK )
endmacro ()

# ANCHOR: twx_test_stop
#[=======[
*/
/** @brief Stop the flow.
  *
  * Convenient method for debugging. Raises.
  */
twx_test_stop() {}
/*
#]=======]
macro ( twx_test_stop )
  foreach ( V ${ARGV} )
    twx_var_log ( ${V} )
  endforeach ()
  message ( FATAL_ERROR "*****" )
endmacro ()


twx_lib_require ( Format Global NO_TEST )

if ( /TWX/FORMAT/NIGHT_SHIFT )
  twx_format_define ( ID Test/Domain UNDERLINE BOLD BACK_COLOR 94 )
  twx_format_define ( ID Test/Suite UNDERLINE BOLD BACK_COLOR 22 )
  twx_format_define ( ID Test/Unit UNDERLINE BOLD BACK_COLOR 19 )
  twx_format_define ( ID Test/PASS BOLD TEXT_COLOR 118 )
  twx_format_define ( ID Test/FAIL BOLD TEXT_COLOR 208 )
else ()
  twx_format_define ( ID Test/Domain UNDERLINE BOLD BACK_COLOR 229 )
  twx_format_define ( ID Test/Suite UNDERLINE BOLD BACK_COLOR 193 )
  twx_format_define ( ID Test/Unit UNDERLINE BOLD BACK_COLOR 195 )
  twx_format_define ( ID Test/PASS BOLD TEXT_COLOR 28 )
  twx_format_define ( ID Test/FAIL BOLD TEXT_COLOR 160 )
endif ()

twx_lib_did_load ()

#*/
