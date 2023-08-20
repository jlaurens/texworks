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

include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxCorePolicy.cmake"
  NO_POLICY_SCOPE
)
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxLib.cmake" )

twx_lib_will_load ()

string ( ASCII 01 TWX_CHAR_SOH )
string ( ASCII 02 TWX_CHAR_STX )
string ( ASCII 03 TWX_CHAR_ETX )
string ( ASCII 25 TWX_CHAR_EM  )
string ( ASCII 26 TWX_CHAR_SUB )
string ( ASCII 28 TWX_CHAR_FS  )
string ( ASCII 29 TWX_CHAR_GS  )
string ( ASCII 30 TWX_CHAR_RS  )
string ( ASCII 31 TWX_CHAR_US  )

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

# ANCHOR: TWX_PATH_LIST_SEPARATOR
#[=======[
*/
/** @brief The system dependent path list separator.
  *
  * `;` on windows and friends, `:` otherwise.
  */
TWX_PATH_LIST_SEPARATOR;
/*#]=======]
if (WIN32)
	set ( TWX_PATH_LIST_SEPARATOR ";" )
else ()
	set ( TWX_PATH_LIST_SEPARATOR ":" )
endif ()

# ANCHOR: SWITCHER
#[=======[
*//**
The system dependent switcher is used as path component.
Possible values are
- `os_windows`,
- `os_darwin`,
- `os_other`,
*/
TWX_OS_SWITCHER;
/*#]=======]
if (WIN32)
  set ( TWX_OS_SWITCHER "os_windows" )
elseif (APPLE)
  set ( TWX_OS_SWITCHER "os_darwin" )
else ()
  set ( TWX_OS_SWITCHER "os_other" )
endif ()

# ANCHOR: twx_regex_escape ()
#[=======[
/** @brief Escape strings to be used in regular expression
  *
  * @param ... non empty list of strings
  * @param var for key `IN_VAR`, the variable named <var> will hold the result on return
  */
twx_regex_escape(... IN_VAR var ) {}
/*#]=======]

set ( twx_regex_escape_RE [=[[]()|?+*[\\.$^-]]=] )

function ( twx_regex_escape .text .IN_VAR .var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "IN_VAR" "" )
  if ( NOT DEFINED twx.R_IN_VAR )
    twx_fatal ( "Missing IN_VAR argument.")
    return ()
  endif ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  set ( m )
  set ( i 0 )
  while ( TRUE )
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      math ( EXPR i "${i}+2" )
      if ( "${i}" LESS ${ARGC} )
        twx_fatal ( "Unexpected argument: ${ARGV${i}}")
        return ()
      endif ()
      break ()
    endif ()
    # message ( TR@CE "IN => ``${ARGV${i}}''" )
    string (
      REGEX REPLACE "([]()|?+*[\\\\.$^-])" "\\\\\\1"
      out_
      "${ARGV${i}}"
    )
    # message ( TR@CE "OUT => ``${out_}''" )
    list ( APPEND m "${out_}" )
    math ( EXPR i "${i}+1" )
    if ( "${i}" GREATER_EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ()
  set ( "${twx.R_IN_VAR}" "${m}" PARENT_SCOPE )
endfunction ()

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

TwxBase.cmake

TwxAnsLib.cmake
TwxBasePolicy.cmake
TwxCfgLib.cmake
TwxTestLib.cmake
#]=======]

# The order of the library names hereafter almost reflects dependencies
twx_lib_require (
  "Var"
  "Fatal"
  "Assert"
  "Expect"
  "Dir"
  "Format"
  "Log"
  "Increment"
  "Arg"
  "Math"
  "Split"
  "Export"
)

message ( VERBOSE "ROOT   DIR => ${TWX_DIR}" )
message ( VERBOSE "SOURCE DIR => ${CMAKE_SOURCE_DIR}" )
message ( VERBOSE "BINARY DIR => ${CMAKE_BINARY_DIR}" )

twx_lib_did_load ()

#*/
