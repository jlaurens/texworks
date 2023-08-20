#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Base material everyone should include
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxBase.cmake"
  *     NO_POLICY_SCOPE
  *   )
  *
  * This is called from a `CMakeFiles.txt` which perfectly knows where it lives
  * and can replace `<...>` with the proper subpath.
  *
  * __Do not forget `NO_POLICY_SCOPE`!__
  *
  * After a new `project(...)` instruction is executed, issue
  *
  *   twx_base_after_project ()
  *
  * Output:
  * - `TWX_DIR`
  * - `twx_base_after_project()`
  * - `twx_dir_configure()`
  *
  * Implementation details:
  * This script may be called in various situations.
  * - from the main `CMakeLists.txt` at configuration time
  * - from another script in `-P` mode, at either time.
  *
  * In any cases, the global variables above are expected to point to
  * the same location. For `TWX_DIR` it is easy because its location
  * relative to the various `.cmake` script files is well known
  * at some early point.
  */
/*#]===============================================]

if ( TWX_TEST_DOMAIN.Core.RUN )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Core/Test/CMakeLists.txt"
    NO_POLICY_SCOPE
  )
else ()
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Core/TwxCore.cmake"
    NO_POLICY_SCOPE
  )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Core/TwxTestLib.cmake"
  )
  set ( TWX_TEST_DOMAIN.Core.SUITE_RE_NO ".*" )
endif ()

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Core/TwxCore.cmake"
  NO_POLICY_SCOPE
)

twx_lib_will_load ()

# ANCHOR: twx_set_if_defined
#[=======[*/
/** @brief Set or unset.
  *
  * @param var is the name of the variable to set
  * @param from_var is the name of the variable holding the value.
  * If <from_var> is defined, var is set to the value,
  * otherwise var is left unchanged. Assignments occur in the caller scope.
  */
twx_set_if_defined( var from_var ) {}
/*#]=======]
function ( twx_set_if_defined twx_set_if_defined.var twx_set_if_defined.from )
  twx_var_assert_name ( "${twx_set_if_defined.var}" )
  twx_var_assert_name ( "${twx_set_if_defined.from}" )
  if ( DEFINED ${twx_set_if_defined.from} )
    set ( ${twx_set_if_defined.var} "${${twx_set_if_defined.from}}" PARENT_SCOPE )
  endif ()
endfunction ()

# ANCHOR: twx_base_prettify
#[=======[
*/
/** @brief Turn a content into human readable
  *
  * @param ... a list of strings to manipulate.
  * Support the `$|` syntax.
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_base_prettify(... IN_VAR var) {}
/*
#]=======]
function ( twx_base_prettify )
  twx_arg_assert_count ( ${ARGC} > 2 )
  set ( i 0 )
  set ( v )
  unset ( twx.R_IN_VAR )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( "${v}" STREQUAL IN_VAR )
      twx_increment ( VAR i )
      set ( twx.R_IN_VAR "${ARGV${i}}" )
      twx_var_assert_name ( "${twx.R_IN_VAR}" )
      twx_increment_and_assert ( VAR i == ${ARGC} )
      break ()
    endif ()
    string ( REPLACE "${TWX_CHAR_SOH}"  "<SOH/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_STX}"  "<STX/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_ETX}"  "<ETX/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_EM}"   "<EM/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_SUB}"  "<SUB/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_FS}"   "<FS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_GS}"   "<GS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_RS}"   "<RS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_US}"   "<US/>"   v "${v}" )
    string ( APPEND value_ "${v}" )
    twx_increment_and_assert ( VAR i < ${ARGC} )
  endwhile ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  twx_export ( "${twx.R_IN_VAR}=${value_}" )
endfunction ()

# ANCHOR: twx_base_after_project
#[=======[*/
/** @brief Setup the state.
  *
  * Set various variables for the newly declareed project.
  *
  */
twx_base_after_project() {}
/*#]=======]
macro ( twx_base_after_project )
  twx_arg_assert_count ( ${ARGC} == 0 )
  twx_assert_non_void ( PROJECT_NAME )
  # This has already been included
  message ( DEBUG "twx_base_after_project: PROJECT_NAME => ${PROJECT_NAME}" )

	set ( CMAKE_CXX_STANDARD 11 )
  if ( APPLE )
    enable_language ( OBJCXX )
  endif ()

	# Tell CMake to run moc and friends when necessary:
	set ( CMAKE_AUTOMOC ON )
	set ( CMAKE_AUTOUIC ON )
	set ( CMAKE_AUTORCC ON )
	# As moc files are generated in the binary dir, tell CMake
	# to always look for includes there:
	set ( CMAKE_INCLUDE_CURRENT_DIR ON )

  set ( CMAKE_COLOR_MAKEFILE ON )

# Minor changes
  if ( NOT "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}" )
    set ( TWX_PROJECT_IS_ROOT OFF )
  endif ()
  foreach ( f ${TWX_BASE_AFTER_PROJECT} )
    cmake_language ( CALL "${f}" )
  endforeach ()
endmacro ( twx_base_after_project )

set ( TWX_IS_BASED ON )

# Next is meant to be run only once per cmake session.
# However, a different process can run this on its own.

set ( TWX_PROJECT_IS_ROOT ON )

#[=======[
TwxCoreLib.cmake
TwxAssertLib.cmake
TwxExpectLib.cmake
TwxMathLib.cmake
TwxIncrementLib.cmake
TwxArgLib.cmake
TwxSplitLib.cmake
TwxExportLib.cmake
TwxMessageLib.cmake
TwxTreeLib.cmake
TwxUtilLib.cmake

TwxCore.cmake

TwxAnsLib.cmake
TwxBasePolicy.cmake
TwxCfgLib.cmake
TwxTestLib.cmake
#]=======]

# The order of the library names hereafter almost reflects dependencies
twx_lib_require (
  "Split"
  "Export"
  "Message"
  "Tree"
  "Hook"
  "Util"
  "Global"
  "Ans"
  "State"
  "Cfg"
)

twx_assert_true ( TWX_IS_BASED )

if ( COMMAND twx_message_register_prettifier )
  twx_message_register_prettifier ( twx_base )
endif ()

set (
  TWX_EXECUTE_PROCESS_VARIABLE
    RESULT_VARIABLE twx.RESULT_VARIABLE
    ERROR_VARIABLE twx.ERROR_VARIABLE
    OUTPUT_VARIABLE twx.OUTPUT_VARIABLE
)
twx_lib_did_load ()

#*/
