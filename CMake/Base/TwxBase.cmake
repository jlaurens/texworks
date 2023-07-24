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


# ANCHOR: twx_lib_will_load ()
#[=======[
*/
/** @brief Before a library starts loading.
  *
  * Display some message in VERBOSE mode.
  * @param name, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_will_load ([name]) {}
/*
#]=======]
function ( twx_lib_will_load )
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)\.cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)\.cmake" )
    set ( name_ "${CMAKE_MATCH_1}" )  
  elseif ( ARGC EQUAL 1 )
    set ( name_ "${ARGV0}" )  
  elseif ()
    set ( name_ "some library" )  
  endif ()
  message ( VERBOSE "Loading ${name_}..." )
endfunction ()

# ANCHOR: twx_lib_did_load ()
#[=======[
*/
/** @brief After a library has been loaded.
  *
  * Display some message in VERBOSE mode.
  * @param name, optional libray name used when
  *   not guessed from the current list file name.
  */
twx_lib_did_load ([name]) {}
/*
#]=======]
function ( twx_lib_did_load )
  if ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+Lib)\.cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )
  elseif ( CMAKE_CURRENT_LIST_FILE MATCHES "(Twx[^/]+)\.cmake" )
    message ( VERBOSE "Loading ${CMAKE_MATCH_1}... DONE" )  
  elseif ( ARGC EQUAL 1 )
    message ( VERBOSE "Loading ${ARGV0}... DONE" )  
  elseif ()
    message ( VERBOSE "Loading some library... DONE" )  
  endif ()
endfunction ()

twx_lib_will_load ()

string(ASCII 01 TWX_CHAR_SOH )
string(ASCII 02 TWX_CHAR_STX )
string(ASCII 03 TWX_CHAR_ETX )
string(ASCII 25 TWX_CHAR_EM )
string(ASCII 26 TWX_CHAR_SUB )
string(ASCII 28 TWX_CHAR_FS  )
string(ASCII 29 TWX_CHAR_GS  )
string(ASCII 30 TWX_CHAR_RS  )
string(ASCII 31 TWX_CHAR_US  )

# ANCHOR: twx_set_if_defined
#[=======[*/
/** @brief Set or unset.
  *
  * @param var is the variable to set
  * @param from_var is the variable holding the value.
  * If <from_var> is defined, var is set to the value,
  * otherwise var is unset. Assignments occur in the caller scope.
  */
twx_set_if_defined( var from_var ) {}
/*#]=======]
function ( twx_set_if_defined var_ from_ )
  set ( var_name_ ${var_} )
  set ( from_name_ ${from_} )
  twx_assert_variable_name ( ${var_name_} )
  twx_assert_variable_name ( ${from_name_} )
  if ( DEFINED ${from_name_} )
    set ( ${var_} "${${from_name_}}" PARENT_SCOPE )
  else ()
    unset ( ${var_} PARENT_SCOPE )
  endif ()
endfunction ( twx_set_if_defined )

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
      twx_assert_variable_name ( "${twx.R_IN_VAR}" )
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
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  twx_export ( "${twx.R_IN_VAR}=${value_}" )
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

# We load the policies as soon as possible
# Before using any higher level cmake command
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

set ( TWX_PROJECT_IS_ROOT ON )

# ANCHOR: TWX_BASE_VARIABLE_RE
#[=======[*/
/** @brief Regular expression for variables
  *
  * Quoted CMake documentation:
  *   > Literal variable references may consist of
  *   > alphanumeric characters,
  *   > the characters /_.+-,
  *   > and Escape Sequences.
  * where "An escape sequence is a \ followed by one character:"
  *   > escape_sequence  ::=  escape_identity | escape_encoded | escape_semicolon
  *   > escape_identity  ::=  '\' <match '[^A-Za-z0-9;]'>
  *   > escape_encoded   ::=  '\t' | '\r' | '\n'
  *   > escape_semicolon ::=  '\;'
  */
TWX_BASE_VARIABLE_RE;
/*#]=======]
set (
  TWX_BASE_VARIABLE_RE
  "^([a-zA-Z/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9/_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)*$"
)

# ANCHOR: twx_assert_variable_name
#[=======[*/
/** @brief Raise when not a literal variable name.
  *
  * @param ..., non empty list of variables names to test.
  * Support `$|` syntax (`$|<name>` is a shortcut to the more readable `"${<name>}"`)
  */
twx_assert_variable_name(...) {}
/*#]=======]
function ( twx_assert_variable_name .name )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_assert_variable_name )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => \"${v}\"" )
    if ( NOT v MATCHES "${TWX_BASE_VARIABLE_RE}" )
      twx_fatal ( "Not a variable name: \"${v}\"" )
      return ()
    endif ()
    math ( EXPR i "${i}+1" )
    if ( i GREATER_EQUAL ARGC )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_assert_variable_name )

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

# ANCHOR: twx_lib_require
#[=======[
*/
/** @brief Require a library
  *
  * Include the libraries with given names.
  * The behavior differs whether testing or not.
  *
  * `twx_lib_require()` is called from a library during its inclusion process.
  * A library can only require another library that stands next to it
  * or is available through `CMAKE_MODULE_PATH`.
  *
  * In normal mode, `twx_lib_require()` just executes `include()`
  * whereas in testing mode, it includes the test file associate to the library.
  * This test file will in turn include the library and then run tests.
  *
  */
twx_lib_require ( ... ) {}
/*
#]=======]
macro ( twx_lib_require )
  foreach ( twx_lib_require.lib ${ARGV} )
    # list ( APPEND twx_lib_require.stack "${twx_lib_require.lib}" )
    # message ( STATUS "twx_lib_require.lib => \"${twx_lib_require.lib}\"..." )
    if ( TWX_TEST )
      message ( TRACE "1) ${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
      if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        include ( "${CMAKE_CURRENT_LIST_DIR}/Test/Twx${twx_lib_require.lib}/Twx${twx_lib_require.lib}Test.cmake" )
        continue ()
      endif ()
    endif ()
    if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
      message ( TRACE "2) ${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
      include ( "${CMAKE_CURRENT_LIST_DIR}/Twx${twx_lib_require.lib}Lib.cmake" )
    else ()
      message ( TRACE "3) Twx${twx_lib_require.lib}Lib" )
      include ( "Twx${twx_lib_require.lib}Lib" )
    endif ()
    # list ( POP_BACK twx_lib_require.stack twx_lib_require.lib )
    # message ( STATUS "twx_lib_require.lib => \"${twx_lib_require.lib}\"... DONE" )
  endforeach ()
  set ( twx_lib_require.lib )
endmacro ()

# The order of the library names hereafter almost reflect dependencies
twx_lib_require (
  "Fatal"
  "Assert"
  "Expect"
  "Core"
  "Dir"
  "Math"
  "Increment"
  "Arg"
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

twx_message ( VERBOSE
  "ROOT   DIR => ${TWX_DIR}"
  "SOURCE DIR => ${CMAKE_SOURCE_DIR}"
  "BINARY DIR => ${CMAKE_BINARY_DIR}"
  NO_SHORT
)

twx_lib_did_load ()

#*/
