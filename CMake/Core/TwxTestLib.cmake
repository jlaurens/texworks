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
  *   twx_test_suite_push ()
  *   if ( TWX_TEST_SUITE.RUN )
  *   block ()
  *
  * followed by any number of units
  *
  *   # ANCHOR: <name>
  *   twx_test_unit_push ( NAME <name> NAME <id>)
  *   if ( TWX_TEST_UNIT.RUN )
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

set ( TWX_TEST ON )

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
    TWX_TEST_DOMAIN_CORE
    GLOBAL
    PROPERTY TWX_TEST_DOMAIN_CORE
  )
  get_property (
    TWX_TEST_SUITE_STACK
    GLOBAL
    PROPERTY TWX_TEST_SUITE_STACK
  )
  get_property (
    TWX_TEST_UNIT.NAME
    GLOBAL
    PROPERTY TWX_TEST_UNIT.NAME
  )
  set ( "${twx.R_IN_VAR}" OFF PARENT_SCOPE )
  if ( twx.R_DOMAIN )
    if ( twx.R_RE )
      if ( TWX_TEST_DOMAIN_CORE MATCHES "${twx.R_DOMAIN}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( TWX_TEST_DOMAIN_CORE STREQUAL "${twx.R_DOMAIN}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( DEFINED twx.R_SUITE )
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
      if ( TWX_TEST_UNIT.NAME MATCHES "${twx.R_UNIT}" )
        set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
        return ()
      endif ()
    elseif ( TWX_TEST_UNIT.NAME STREQUAL "${twx.R_UNIT}" )
      set ( "${twx.R_IN_VAR}" ON PARENT_SCOPE )
      return ()
    endif ()
  endif ()
  if ( twx.R_FULL )
    list ( POP_BACK TWX_TEST_SUITE_STACK full_ )
    string ( PREPEND full_ "${TWX_TEST_DOMAIN_CORE}/" )
    string ( APPEND full_ "/${TWX_TEST_UNIT.NAME}" )
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

set ( TWX_FATAL_CATCH OFF )

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
      twx_test_domain_setup (
        IN_DOMAIN twx_test_guess.DOMAIN
        BUILD
      )
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
    else ()
      message ( FATAL_ERROR "Bad usage: FILE -> ``${twx_test_guess.R_FILE}''" )
    endif ()
  endif ()
endmacro ()

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
  set ( l "STATUS;VERBOSE;DEBUG;TRACE" )
  if ( "${ARGV0}" IN_LIST l )
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
  foreach ( X NAME PATH ID RUN DIR )
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
  *   When not provided, unset all tyhe variables.
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
if ( DEFINED twx_test_domain_setup.R_DIR )
  set ( twx_test_domain_setup.DIR    "${twx_test_domain_setup.R_DIR}" )
  if ( twx_test_domain_setup.R_DIR MATCHES "/CMake/([^/]+)/" )
    set ( twx_test_domain_setup.NAME "${CMAKE_MATCH_1}")
  else ()
    message ( FATAL_ERROR " Bad usage: DIR -> ``${twx_test_domain_setup.R_DIR}''")
  endif ()
  if ( twx_test_domain_setup.R_BUILD )
    set ( twx_test_domain_setup.BUILD BUILD/ )
  else ()
    set ( twx_test_domain_setup.BUILD )
  endif ()
  set ( twx_test_domain_setup.PATH  "${twx_test_domain_setup.BUILD}${twx_test_domain_setup.NAME}" )
  set (
    twx_test_domain_setup.ID
    "TWX_TEST/${twx_test_domain_setup.PATH}"
  )
  if ( DEFINED ${twx_test_domain_setup.ID}.RUN )
    set (
      twx_test_domain_setup.RUN
      "${${twx_test_domain_setup.ID}.RUN}"
    )
  else ()
    set ( twx_test_domain_setup.RUN ON )
    block ( PROPAGATE twx_test_domain_setup.RUN )
      set ( filter_ TWX_TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/NO )
      if ( DEFINED ${filter_} AND twx_test_domain_setup.NAME MATCHES "${${filter_}}" )
        set ( twx_test_domain_setup.RUN OFF )
      endif ()
      if ( NOT twx_test_domain_setup.RUN )
        set ( filter_ TWX_TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/YES )
        if ( DEFINED ${filter_} AND twx_test_domain_setup.NAME MATCHES "${${filter_}}" )
          set ( twx_test_domain_setup.RUN ON )
        endif ()
      endif ()
      if ( twx_test_domain_setup.RUN )
        set ( filter_ ${twx_test_domain_setup.ID}/FILTER/NO )
        if ( DEFINED ${filter_} AND twx_test_domain_setup.NAME MATCHES "${${filter_}}" )
          set ( twx_test_domain_setup.RUN OFF )
        endif ()
      endif ()
      if ( NOT twx_test_domain_setup.RUN )
        set ( filter_ TWX_TEST/${twx_test_domain_setup.BUILD}DOMAIN/FILTER/NO )
        if ( DEFINED ${filter_} AND twx_test_domain_setup.NAME MATCHES "${${filter_}}" )
          set ( twx_test_domain_setup.RUN OFF )
        endif ()
      endif ()
    endblock ()
  endif ()
else ()
  foreach ( x NAME PATH ID RUN )
    set ( twx_test_domain_setup.${x} )
  endforeach ()
endif ()
if ( twx_test_domain_setup.R_PARENT_SCOPE )
  set ( twx_test_domain_setup.SCOPE PARENT_SCOPE )
else ()
  set ( twx_test_domain_setup.SCOPE )
endif ()
foreach ( twx_test_domain_setup.X NAME PATH ID RUN DIR )
  set (
    ${twx_test_domain_setup.R_IN_DOMAIN}.${twx_test_domain_setup.X}
    "${twx_test_domain_setup.${twx_test_domain_setup.X}}"
    ${twx_test_domain_setup.SCOPE}
  )
endforeach ()
foreach ( twx_test_domain_setup.X BUILD PARENT_SCOPE NAME IN_DOMAIN )
  set (
    twx_test_domain_setup.R_${twx_test_domain_setup.X}
  )
endforeach ()
foreach ( twx_test_domain_setup.X SCOPE BUILD RUN )
  set (
    twx_test_domain_setup.${twx_test_domain_setup.X}
  )
endforeach ()
set ( twx_test_domain_setup.X )
endmacro ( twx_test_domain_setup )

# ANCHOR: twx_test_domain_push
#[=======[
*/
/** @brief Before the test domain runs
  *
  * Must be balanced by a `twx_test_domain_pop()`.
  * set `TWX_TEST_DOMAIN`.
  *
  */
twx_test_domain_push () {}
/*
#]=======]
macro ( twx_test_domain_push )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_global_append (
    "${CMAKE_CURRENT_LIST_FILE}"
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
    DUPLICATE "Circular domain: ``${TWX_TEST_DOMAIN.NAME}''"
  )
  twx_test_guess (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    IN_DOMAIN TWX_TEST_DOMAIN
  )
  twx_test_domain_log ( DEBUG DOMAIN TWX_TEST_DOMAIN )
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message ( CHECK_START "Test domain ${TWX_TEST_DOMAIN.NAME}..." ID Test/Domain )
  endblock ()
  list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_DOMAIN.NAME}" )
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
  if ( COMMAND twx_fatal_assert_pass )
    twx_fatal_assert_pass ()
  endif ()
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  if ( TWX_TEST_DOMAIN.RUN )
    set ( status_ "DONE" )
  else ()
    set ( status_ "SKIPPED" )
  endif ()
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message ( STATUS "Test domain ${TWX_TEST_DOMAIN.NAME}... ${status_}" ID Test/Domain )
  endblock ()
  twx_global_get (
    IN_VAR twx_test_domain_pop.FILE
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
  )
  twx_global_pop_back (
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
    REQUIRED
  )
  twx_global_get (
    IN_VAR twx_test_domain_pop.FILE
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
  )
  twx_global_get (
    IN_VAR twx_test_domain_pop.FILE
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
  )
  twx_global_get_back (
    IN_VAR twx_test_domain_pop.FILE
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
  )
  if ( DEFINED twx_test_domain_pop.FILE )
    twx_test_guess (
      FILE "${twx_test_domain_pop.FILE}"
      IN_DOMAIN TWX_TEST_DOMAIN
    )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( CHECK_START "... Test domain ${TWX_TEST_DOMAIN.NAME}..." ID Test/Domain )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_DOMAIN.NAME}" )
  else ()
    twx_test_guess (
      IN_DOMAIN TWX_TEST_DOMAIN
    )
  endif ()
  foreach ( twx_test_domain_pop.x FILE )
    set ( twx_test_domain_pop.${twx_test_domain_pop.x} )
  endforeach ()
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
  set ( l "STATUS;VERBOSE;DEBUG;TRACE" )
  if ( "${ARGV0}" IN_LIST l )
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
  foreach ( X DOMAIN NAME PATH ID RUN LIB )
    twx_var_log (
      DEBUG
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
    set ( twx_test_suite_setup.SUITE.NAME  "${twx_test_suite_setup.R_NAME}" )
    set ( twx_test_suite_setup.SUITE.PATH  "${${twx_test_suite_setup.R_DOMAIN}.PATH}/${twx_test_suite_setup.SUITE.NAME}" )
    set ( twx_test_suite_setup.SUITE.ID    "${${twx_test_suite_setup.R_DOMAIN}.ID}/${twx_test_suite_setup.SUITE.NAME}" )
    if ( NOT ${twx_test_suite_setup.R_DOMAIN}.RUN )
      set (twx_test_suite_setup.SUITE.RUN OFF )
    elseif ( DEFINED ${twx_test_suite_setup.ID}.RUN )
      set (
        twx_test_suite_setup.SUITE.RUN
        "${${twx_test_suite_setup.ID}.RUN}"
      )
    else ()
      set ( twx_test_suite_setup.SUITE.RUN ON )
      block ( PROPAGATE twx_test_suite_setup.SUITE.RUN )
        if ( ${twx_test_suite_setup.R_DOMAIN}.ID MATCHES "/BUILD/" )
          set ( build_ BUILD/ )
        else ()
          set ( build_ )
        endif ()
        set ( filter_ TWX_TEST/${build_}SUITE/FILTER/NO )
        if ( DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
          set ( twx_test_suite_setup.SUITE.RUN OFF )
        endif ()
        if ( NOT twx_test_suite_setup.SUITE.RUN )
          set ( filter_ TWX_TEST/${build_}SUITE/FILTER/YES )
          if ( DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
            set ( twx_test_suite_setup.SUITE.RUN ON )
          endif ()
        endif ()
        if ( twx_test_suite_setup.SUITE.RUN )
          set ( filter_ ${twx_test_suite_setup.SUITE.ID}/FILTER/NO )
          if ( DEFINED ${filter_} AND twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
            set ( twx_test_suite_setup.SUITE.RUN OFF )
          endif ()
        endif ()
        if ( NOT twx_test_suite_setup.SUITE.RUN )
          set ( filter_ ${twx_test_suite_setup.SUITE.ID}/FILTER/YES )
          if ( DEFINED ${filter_} AND NOT twx_test_suite_setup.SUITE.NAME MATCHES "${${filter_}}" )
            set ( twx_test_suite_setup.SUITE.RUN ON )
          endif ()
        endif ()
      endblock ()
    endif ()
    if ( DEFINED ${twx_test_suite_setup.R_DOMAIN}.DIR AND NOT twx_test_suite_setup.SUITE.NAME STREQUAL "POC" )
      set (
        twx_test_suite_setup.SUITE.LIB
        "${${twx_test_suite_setup.R_DOMAIN}.DIR}Twx${twx_test_suite_setup.SUITE.NAME}.cmake"
      )
      cmake_path ( NORMAL_PATH twx_test_suite_setup.SUITE.LIB )
      if ( NOT EXISTS "${twx_test_suite_setup.SUITE.LIB}" )
        string ( APPEND twx_test_suite_setup.SUITE.NAME Lib )
        set (
          twx_test_suite_setup.SUITE.LIB
          "${${twx_test_suite_setup.R_DOMAIN}.DIR}Twx${twx_test_suite_setup.SUITE.NAME}.cmake"
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
    foreach ( x NAME PATH ID RUN LIB )
      set ( twx_test_suite_setup.SUITE.${x} )
    endforeach ()
  endif ()
  if ( twx_test_suite_setup.R_PARENT_SCOPE )
    set ( twx_test_suite_setup.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_suite_setup.SCOPE )
  endif ()
  foreach ( twx_test_suite_setup.X DOMAIN NAME PATH ID RUN LIB )
    set (
      ${twx_test_suite_setup.R_IN_SUITE}.${twx_test_suite_setup.X}
      "${twx_test_suite_setup.SUITE.${twx_test_suite_setup.X}}"
      ${twx_test_suite_setup.SCOPE}
    )
    set ( twx_test_suite_setup.SUITE.${twx_test_suite_setup.X} )
  endforeach ()
  foreach ( twx_test_suite_setup.X PARENT_SCOPE DOMAIN NAME IN_SUITE )
    set (
      twx_test_suite_setup.R_${twx_test_suite_setup.X}
    )
  endforeach ()
  foreach ( twx_test_suite_setup.X SCOPE )
    set (
      twx_test_suite_setup.${twx_test_suite_setup.X}
    )
  endforeach ()
  set ( twx_test_suite_setup.X )
endmacro ( twx_test_suite_setup )

# ANCHOR: twx_test_suite_push
#[=======[
*/
/** @brief Before the test suite runs
  *
  * Must be balanced by a `twx_test_suite_pop()`.
  * Loads the associate library retrieved from the path of the current list file.
  * A `block()` instruction should follow.
  *
  * @param level for key LOG_LEVEL, optional log level.
  */
twx_test_suite_push ([LOG_LEVEL level]) {}
/*
#]=======]
macro ( twx_test_suite_push )
  list ( APPEND twx_test_suite_push.CMAKE_MESSAGE_LOG_LEVEL "${CMAKE_MESSAGE_LOG_LEVEL}" )
  # API guards
  if ( ${ARGC} EQUAL 2 )
    if ( NOT ARGV0 STREQUAL "LOG_LEVEL" )
      message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
    endif ()
    set ( CMAKE_MESSAGE_LOG_LEVEL ${ARGV1} )
  elseif ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_global_append (
    "${CMAKE_CURRENT_LIST_FILE}"
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
    DUPLICATE "Circular suite: ``${TWX_TEST_SUITE.NAME}''"
  )
  twx_test_guess (
    FILE "${CMAKE_CURRENT_LIST_FILE}"
    IN_DOMAIN TWX_TEST_DOMAIN
    IN_SUITE  TWX_TEST_SUITE
  )
  twx_test_suite_log ( DEBUG SUITE TWX_TEST_SUITE )
  set ( TWX_FATAL_CATCH ON )
  set ( twx_test_suite_push.BANNER "Test suite ${TWX_TEST_SUITE.PATH}...")
  if ( TWX_TEST_SUITE.RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( STATUS "${twx_test_suite_push.BANNER}" ID Test/Suite )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${TWX_TEST_SUITE.NAME}" )
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( VERBOSE "${twx_test_suite_push.BANNER} skipped" ID Test/Suite )
    endblock ()
  endif ()
  if ( DEFINED TWX_TEST_SUITE.LIB )
    include ( "${TWX_TEST_SUITE.LIB}" )
  endif ()
  foreach ( twx_test_suite_push.X BANNER )
    set ( twx_test_suite_push.${twx_test_suite_push.X} )
  endforeach ()
endmacro ( twx_test_suite_push TWX_TEST_SUITE )

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
  twx_global_pop_back (
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
    IN_VAR twx_test_suite_pop.FILE
    REQUIRED
  )
  twx_test_guess (
    FILE "${twx_test_suite_pop.FILE}"
    IN_DOMAIN TWX_TEST_DOMAIN
    IN_SUITE TWX_TEST_SUITE
  )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  list ( POP_BACK twx_test_suite_push.CMAKE_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  set (
    twx_test_suite_pop.BANNER
    "Test suite ${TWX_TEST_DOMAIN.NAME}/${TWX_TEST_SUITE.NAME}... "
  )
  if ( TWX_TEST_SUITE.RUN )
    set ( twx_test_suite_pop.MODE STATUS )
    string ( APPEND twx_test_suite_pop.BANNER "DONE")
  else ()
    set ( twx_test_suite_pop.MODE VERBOSE )
    string ( APPEND twx_test_suite_pop.BANNER "SKIPPED")
  endif ()
  block ()
    set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
    twx_format_message (
      ${twx_test_suite_pop.MODE}
      "${twx_test_suite_pop.BANNER}"
      NAME Test/Suite
    )
  endblock ()
  twx_global_get_back (
    KEY TWX_TEST_CURRENT_LIST_FILE_STACK
    IN_VAR twx_test_suite_pop.FILE
  )
  if ( DEFINED twx_test_suite_pop.FILE )
    twx_test_guess (
      FILE "${twx_test_suite_pop.FILE}"
      IN_DOMAIN TWX_TEST_DOMAIN
      IN_SUITE  TWX_TEST_SUITE
    )
  else ()
    twx_test_guess (
      UNSET
      IN_DOMAIN TWX_TEST_DOMAIN
      IN_SUITE  TWX_TEST_SUITE
    )
  endif ()
  set ( twx_test_suite_pop.FILE )
  set ( twx_test_suite_pop.BANNER )
  set ( twx_test_suite_pop.MODE )
endmacro ( twx_test_suite_pop )

# ANCHOR: twx_test_suite_increment
#[=======[
*/
/** @brief Private callback
  */
twx_test_suite_increment ( key ) {}
/*
#]=======]
function ( twx_test_suite_increment key_ )
  if ( NOT ${ARGC} EQUAL 1 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  if ( DEFINED TWX_TEST_UNIT.NAME )
    set ( id_
      "TWX_TEST/${TWX_TEST_DOMAIN_CORE}/${key_}.VALUE"
    )
    twx_global_increment ( NAME ${id_} )

  endif ()
endfunction ()

# ANCHOR: twx_test_suite_on_pass
#[=======[
*/
/** @brief Private callback
  */
twx_test_suite_on_pass () {}
/*
#]=======]
function ( twx_test_suite_on_pass )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_suite_increment ( COUNT )
  twx_test_suite_increment ( PASS )
endfunction ()

# ANCHOR: twx_test_suite_on_fail
#[=======[
*/
/** @brief Private callback
  */
twx_test_suite_on_fail () {}
/*
#]=======]
function ( twx_test_suite_on_fail )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_suite_increment ( COUNT )
  twx_test_suite_increment ( FAIL )
endfunction ()

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
  set ( l "STATUS;VERBOSE;DEBUG;TRACE" )
  if ( "${ARGV0}" IN_LIST l )
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
  foreach ( X SUITE NAME PATH ID RUN )
    twx_var_log (
      DEBUG
      ${twx.R_UNIT}.${X}
    )
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
  *   Defaults to `TWX_TEST_SUITE`.
  * @param unit for key `IN_UNIT`, optional unit.
  *   Defaults to `TWX_TEST_UNIT`.
  * @param id for key `ID`, short identifier for the message context.
  *   Must not evaluate to false in boolean context.
  *   When not provided, guessed from the requires <name>.
  * @param name for key `NAME`, short identifier for the message context.
  *   Must not evaluate to false in boolean context.
  *   When not provided, guessed from the requires <id>.
  */
twx_test_unit_push ([SUITE suite] [IN_UNIT unit] NAME name|ID id) {}
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
    set ( twx_test_unit_push.R_SUITE TWX_TEST_SUITE )
  endif ()
  if ( DEFINED twx_test_unit_push.R_IN_UNIT )
    twx_var_assert_name ( "${twx_test_unit_push.R_IN_UNIT}" )
  else ()
    set ( twx_test_unit_push.R_IN_UNIT TWX_TEST_UNIT )
  endif ()
  # Flow guard
  twx_global_get ( KEY twx_test_unit_push.NAME )
  if ( DEFINED twx_test_unit_push.NAME )
    message ( FATAL_ERROR "Test units must not be nested" )
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
  set ( twx_test_unit_push.NAME "${twx_test_unit_push.R_NAME}" )
  twx_global_set (
    "${twx_test_unit_push.NAME}"
    KEY twx_test_unit_push.NAME
  )
  set ( twx_test_unit_push.PATH "${${twx_test_unit_push.R_SUITE}.PATH}/${twx_test_unit_push.R_NAME}" )
  set ( twx_test_unit_push.ID "${${twx_test_unit_push.R_SUITE}.ID}/${twx_test_unit_push.R_NAME}" )
  # Serious things start here
  if ( ${twx_test_unit_push.R_SUITE}.RUN )
    set ( twx_test_unit_push.RUN ON )
    if ( twx_test_unit_push.RUN AND DEFINED TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/YES AND NOT twx_test_unit_push.CORE MATCHES "${TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/YES}" )
      set ( twx_test_unit_push.RUN OFF )
    endif ()
    if ( twx_test_unit_push.RUN AND DEFINED TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/NO AND twx_test_unit_push.CORE MATCHES "${TWX/TEST/UNIT/${twx_test_unit_push.R_IN_UNIT}/FILTER/NO}")
      set ( twx_test_unit_push.RUN OFF )
    endif ()
    if ( twx_test_unit_push.RUN AND DEFINED TWX/TEST/UNIT/FILTER/YES AND NOT twx_test_unit_push.CORE MATCHES "${TWX/TEST/UNIT/FILTER/YES}" )
      set ( twx_test_unit_push.RUN OFF )
    endif ()
    if ( twx_test_unit_push.RUN AND DEFINED TWX_TEST_SUITE_UNIT/FILTER/NO AND twx_test_unit_push.CORE MATCHES "${TWX/TEST/UNIT/FILTER/NO}" )
      set ( twx_test_unit_push.RUN OFF )
    endif ()
  else ()
    set ( twx_test_unit_push.RUN OFF )
  endif ()
  if ( twx_test_unit_push.RUN )
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( CHECK_START "Test unit  ${twx_test_unit_push.PATH}" ID Test/Unit )
    endblock ()
    list ( APPEND CMAKE_MESSAGE_CONTEXT "${twx_test_unit_push.CORE}" )
    set ( twx_test_unit_push.CMAKE_MESSAGE_INDENT "${CMAKE_MESSAGE_INDENT}" )
    if ( NOT CMAKE_MESSAGE_CONTEXT_SHOW )
      string ( APPEND CMAKE_MESSAGE_INDENT "  " )
    endif ()
  else ()
    block ()
      set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
      twx_format_message ( VERBOSE "Test unit  ${twx_test_unit_push.PATH} skipped" ID Test/Unit )
    endblock()
  endif ()
  if ( twx_test_unit_push.R_PARENT_SCOPE )
    set ( twx_test_unit_push.SCOPE PARENT_SCOPE )
  else ()
    set ( twx_test_unit_push.SCOPE )
  endif ()
  foreach ( twx_test_unit_push.X NAME PATH ID RUN )
    set (
      ${twx_test_unit_push.R_IN_UNIT}.${twx_test_unit_push.X}
      "${twx_test_unit_push.${twx_test_unit_push.X}}"
      ${twx_test_unit_push.SCOPE}
    )
    set ( twx_test_unit_push.${twx_test_unit_push.X} )
  endforeach ()
  set ( twx_test_unit_push.SCOPE )
  foreach ( twx_test_unit_push.X
    NAME CORE SUITE IN_UNIT UNPARSED_ARGUMENTS KEYWORDS_MISSING_VALUES
  )
    set ( twx_test_unit_push.R_${twx_test_unit_push.X} )
  endforeach ()
  set ( twx_test_unit_push.X )
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
function ( twx_test_unit_pop )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  set ( CMAKE_MESSAGE_INDENT ${twx_test_unit_push.CMAKE_MESSAGE_INDENT} )
  if ( COMMAND twx_fatal_catched )
    twx_fatal_catched ( IN_VAR v )
    if ( v AND NOT v STREQUAL "" )
      twx_test_simple_on_fail ()
    endif ()
    twx_fatal_clear ()
    twx_test_unit_count ( KEY ALL  IN_VAR twx.ALL.VALUE  )
    twx_test_unit_count ( KEY PASS IN_VAR twx.PASS.VALUE )
    twx_test_unit_count ( KEY FAIL IN_VAR twx.FAIL.VALUE )
    twx_fatal_assert_pass (
      CHECK MESSAGE_CONTEXT_HIDE
      MSG_PASS "PASS: all ${twx.ALL.VALUE} tests"
      MSG_FAIL "FAIL: ${twx.FAIL.VALUE} out of ${twx.COUNT.VALUE} tests"
    )
  endif ()
  twx_global_set (
    KEY twx_test_unit_push.NAME
  )
  set ( TWX_TEST_UNIT.RUN )
  return ( PROPAGATE
    CMAKE_MESSAGE_CONTEXT
  )
endfunction ( twx_test_unit_pop )

# ANCHOR: twx_test_unit_count
#[=======[
*/
/** @brief Private unit count manager.
  *
  * @param key for key `KEY`, required key identifier.
  * @param unit for key `UNIT`, optional unit name.
  *   Defaults to `TWX_TEST_UNIT`.
  * @param step for key `STEP`, optional value.
  * @param value for key `SET`, optional value.
  * @param var for key `IN_VAR`, optional variable name.
  *   On return, contains the value of the counter with the given key,
  *   once all changes are performed.
  */
twx_test_unit_count ( KEY key [SET|STEP value] [IN_VAR var] [UNIT unit]) {}
/*
#]=======]
function ( twx_test_unit_count )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;STEP;SET;IN_VAR;UNIT" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''")
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_KEY )
    message ( FATAL_ERROR "Missing `KEY' keyword")
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_UNIT )
    set ( ${TWX_CMD}.R_UNIT TWX_TEST_UNIT )
  endif ()
  if ( NOT DEFINED ${${TWX_CMD}.R_UNIT}.ID )
    message ( FATAL_ERROR "Not a test unit: ${TWX_CMD}.R_UNIT => ``${${TWX_CMD}.R_UNIT}''" )
  endif ()
  set ( ${TWX_CMD}.KEY "${${${TWX_CMD}.R_UNIT}.ID}/${${TWX_CMD}.R_KEY}.VALUE" )
  if ( DEFINED ${TWX_CMD}.R_SET )
    math ( EXPR ${TWX_CMD}.R_SET "${${TWX_CMD}.R_SET}" )
    twx_global_set ( "${${TWX_CMD}.R_SET}" KEY "${${TWX_CMD}.KEY}" )
  elseif ( DEFINED ${TWX_CMD}.R_STEP )
    twx_global_get ( KEY "${${TWX_CMD}.KEY}" IN_VAR ${TWX_CMD}.VALUE )
    math ( EXPR ${TWX_CMD}.VALUE "${${TWX_CMD}.VALUE}+(${${TWX_CMD}.R_STEP})" )
    twx_global_set ( "${${TWX_CMD}.VALUE}" KEY "${${TWX_CMD}.KEY}" )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_IN_VAR )
    twx_global_get ( KEY "${${TWX_CMD}.KEY}" IN_VAR ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
endfunction ()

# ANCHOR: twx_test_unit_on_pass
#[=======[
*/
/** @brief Private callback
  */
twx_test_unit_on_pass () {}
/*
#]=======]
function ( twx_test_unit_on_pass )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_unit_count ( KEY ALL  STEP 1 )
  twx_test_unit_count ( KEY PASS STEP 1 )
endfunction ()

# ANCHOR: twx_test_unit_on_fail
#[=======[
*/
/** @brief Private callback
  */
twx_test_unit_on_fail () {}
/*
#]=======]
function ( twx_test_unit_on_fail )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_unit_count ( KEY ALL  STEP 1 )
  twx_test_unit_count ( KEY FAIL STEP 1 )
endfunction ()

# !SECTION
# SECTION: Simple
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

# ANCHOR: twx_test_simple_assert_pass
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
  twx_fatal_assert_pass (
    VERBOSE "${TWX_TEST_SIMPLE_CHECK}"
    ON_PASS twx_test_simple_on_pass
    ON_FAIL twx_test_simple_on_fail
  )
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
  twx_fatal_assert_fail (
    VERBOSE "${TWX_TEST_SIMPLE_CHECK}"
    ON_PASS twx_test_simple_on_pass
    ON_FAIL twx_test_simple_on_fail
  )
  endblock ()
  set ( TWX_TEST_SIMPLE_CHECK )
endmacro ()

# ANCHOR: twx_test_simple_on_pass
#[=======[
*/
/** @brief Private callback
  */
twx_test_unit_on_pass () {}
/*
#]=======]
function ( twx_test_simple_on_pass )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_unit_count ( KEY ALL  STEP 1 )
  twx_test_unit_count ( KEY PASS STEP 1 )
endfunction ()

# ANCHOR: twx_test_simple_on_fail
#[=======[
*/
/** @brief Private callback
  */
twx_test_simple_on_fail () {}
/*
#]=======]
function ( twx_test_simple_on_fail )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR " Bad usage: ARGV => ``${ARGV}''" )
  endif ()
  twx_test_unit_count ( KEY ALL  STEP 1 )
  twx_test_unit_count ( KEY FAIL STEP 1 )
endfunction ()

twx_lib_require ( Format Global TEST OFF )

if ( TWX_FORMAT_NIGHT_SHIFT )
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
