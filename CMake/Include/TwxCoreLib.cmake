#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Collection of core utilities

Usage:
```
include (
  "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxCoreLib.cmake"
)
```
or simply
```
include ( TwxCoreLib )
```
when `TwxBase` is loaded.

Also includes module `CMakeParseArguments` until this is built in.

Output state:
- `TWX_DIR`

*/
/*#]===============================================]

# Full include only once
if ( DEFINED TWX_DIR )
  return ()
endif ()
# This has already been included

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same location, in particular when called from a module
or a sub code unit. The same holds for `CMAKE_SOURCE_DIR`.
`TWX_DIR` is always "at the top" because it is defined
relative to this included file.
#]=======]
get_filename_component (
  TWX_DIR
  "${CMAKE_CURRENT_LIST_DIR}/../.."
  REALPATH
)

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Include` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
]=======]
list (
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR}/CMake/Include"
  "${TWX_DIR}/CMake/Modules"
)
list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )

# ANCHOR: twx_message_verbose
#[=======[*/
/** @brief Log status message in verbose mode
  *
  * @param ... are text messages
  */
twx_message_verbose(...) {}
/*#]=======]
function ( twx_message_verbose mode_ )
  if ( NOT "${mode_}" STREQUAL "STATUS" )
    list ( INSERT ARGN 0 "${mode_}" )
    set ( mode_ )
  endif ()
  if ( TWX_VERBOSE )
    foreach ( msg_ ${ARGN} )
      message ( ${mode_} "${msg_}" )
    endforeach ()
  endif ()
endfunction ()

# ANCHOR: TWX_DEV
#[=======[*/
/** @brief Whether in developer mode
  *
  * Initially unset.
  * See @ref TWX_NAME.
  */
TWX_DEV;
/*#]=======]

option ( TWX_DEV "To activate developer mode" )

# ANCHOR: TWX_NAME
#[=======[*/
/** @brief The main project name
  *
  * One level of indirection is used for two reasons:
  *
  * * the word `TeXworks` is used so many times while refering to
  *   different meanings,
  * * One may need to change that name. In particular, this name
  *   is reflected in different parts of the file system. We want to
  *   allow a developper to have both a release version and  a developer
  *   version and let them live side by side with nothing in common.
  *   In particular, the developer version is not allowed to break
  *   an existing release version.
  *
  * Set to `TeXworks` in normal mode but to `TeXworks-dev`
  * when `TWX_DEV` is set.
  * In developer mode, use for example
  * 
  *   cmake ... -DTWX_DEV=ON ...
  * 
  * Shared by Twx modules and main code.
  * In particular, main configuration files for metadata
  * like version and names are <TWX_NAME>.ini.
  *
  * See also the `TeXworks.ini` and `TeXworks-dev.ini`
  * configuration files at the top level.
  *
  * When testing, this value can be set beforehand, in that case,
  * it will not be overwritten.
  */
TWX_NAME;
/** @brief The main project command
  *
  * This is the main project name in lowercase.
  */
TWX_COMMAND;
/*#]=======]
if ( "${TWX_NAME}" STREQUAL "" )
  if ( TWX_DEV )
    set ( TWX_NAME TeXworks-dev )
    set ( TWX_COMMAND texworks-dev )
  else ()
    set ( TWX_NAME TeXworks )
    set ( TWX_COMMAND texworks )
  endif ()
endif ()

message ( STATUS "TwxCoreLib: TWX_NAME => ${TWX_NAME}" )

# ANCHOR: twx_fatal
#[=======[
*//** @brief Terminate with a FATAL_ERROR message. */
twx_fatal(...){}
/*
#]=======]
macro ( twx_fatal )
  message ( FATAL_ERROR ${ARGN} )
endmacro ()

# ANCHOR: twx_assert_non_void
#[=======[*/
/** @brief Raises when the variable is empty.

@param variable_name a variable name
@param ... another variable name
*/
twx_assert_non_void(variable_name ... ) {}
/*#]=======]
function ( twx_assert_non_void _variable )
  if ( "${${_variable}}" STREQUAL "" )
    if ( "${ARGN}" STREQUAL "" )
      twx_fatal ( "Missing ${_variable}")
    elseif ( "${_variable}" MATCHES "^MY_(.*)$" )
      twx_fatal ( "Missing ${CMAKE_MATCH_1} ... argument")
    else ()
      twx_fatal ( "Missing ${ARGN}")
    endif ()
  endif ()
endfunction ()

# ANCHOR: twx_assert_0
#[=======[*/
/** @brief Raise when the argument is not 0
  * 
  * The argument is in general the return value of a command.
  * @param returned 
  */
twx_assert_0( returned ) {}
/*#]=======]
function ( twx_assert_0 returned_ )
  if ( NOT ${${returned_}} EQUAL 0 )
    twx_fatal ( "Unexpected ${${returned_}} instead of 0")
  endif ()
endfunction ()

# ANCHOR: twx_assert_equal
#[=======[*/
/** @brief Raise when arguments are not equal
  * 
  * @param actual is the actual text
  * @param expected is the expected text
  */
twx_assert_equal( actual expected ) {}
/*#]=======]
function ( twx_assert_equal actual_ expected_ )
  if ( NOT "${actual_}" STREQUAL "${expected_}" )
    twx_fatal ( "Unexpected ${actual_} instead of ${expected_}" )
  endif ()
endfunction ()

# ANCHOR: twx_assert_exists
#[=======[*/
/** @brief Raises when a file or directory is missing.
  *
  * @param expected is the location to test. When the path is relative,
    the current default resolution applies. Syntactic sugar: expected can be a variable.
  */
twx_assert_exists(expected) {}
/*#]=======]
function ( twx_assert_exists _path )
  if ( DEFINED "${_path}" )
    if ( NOT EXISTS "${${_path}}")
      twx_fatal ( "Missing file/directory at ${${_path}}")
    endif ()
  elseif ( NOT EXISTS "${_path}" )
    twx_fatal ( "Missing file/directory at ${_path}")
  endif ()
endfunction ()

# ANCHOR: twx_assert_target
#[=======[*/
/** @brief Raise when a target does not exist.
  *
  * @param target_ is the name of the target to test
  */
twx_assert_parsed() {}
/*#]=======]
macro ( twx_assert_target target_ )
  if ( NOT TARGET "${target_}" )
    if ( NOT TARGET "${${target_}}" )
      twx_fatal ( "Unknwon target ${target_} (${${target_}})" )
    endif ()
  endif ()
endmacro ()

include ( CMakeParseArguments )

# ANCHOR: twx_parse_arguments
#[=======[*/
/** @brief Covers `cmake_parse_arguments` with name `my_twx`.
  *
  * @param ..., forwards to `cmake_parse_arguments(my_twx ...)`.
  */
twx_parse_arguments(...) {}
/*#]=======]
macro ( twx_parse_arguments OPTIONALS ONES MANIES )
  cmake_parse_arguments ( my_twx "${OPTIONALS}" "${ONES}" "${MANIES}" ${ARGN} )
endmacro ()

# ANCHOR: twx_assert_parsed
#[=======[*/
/** @brief Raise if there are unparsed arguments. */
twx_assert_parsed() {}
/*#]=======]
macro ( twx_assert_parsed )
  # NB remember that arguments in functions and macros are not the same
  if ( NOT "${my_twx_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_fatal ( "Unparsed arguments ${my_twx_UNPARSED_ARGUMENTS}" )
  endif ()
endmacro ()

# ANCHOR: twx_pass_option
#[=======[*/
/** @brief Forward a flag in the arguments.
  *
  * Used in conjunction with `twx_parse_arguments()`.
  * When an option FOO is parsed, we retrieve either `TRUE` or `FALSE`
  * in `my_twx_FOO`. This transforms the contents in `FOO` or an empty string
  * to allow the usage of `my_twx_FOO` as argument of a command that accepts
  * the same FOO flag.
  * 
  * @param option is the flag name
  */
twx_pass_option( option ) {}
/*#]=======]
macro ( twx_pass_option OPTION_ )
  if ( my_twx_${OPTION_} )
    set ( my_twx_${OPTION_} ${OPTION_} )
  else ()
    set ( my_twx_${OPTION_} )
  endif ()
endmacro ()

# ANCHOR: Utility `twx_core_timestamp`
#[=======[
Usage:
```
twx_core_timestamp ( <file_path> <variable> )
```
Records the file timestamp.
The precision is 1s.
Correct up to 2036-02-27.
#]=======]
function ( twx_core_timestamp file_path ans )
  file (
    TIMESTAMP "${file_path}" ts "%S:%M:%H:%j:%Y" UTC
  )
  if ( ts MATCHES "^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$" )
    math(
      EXPR
      ts "
      ${CMAKE_MATCH_1} + 60 * (
        ${CMAKE_MATCH_2} + 60 * (
          ${CMAKE_MATCH_3} + 24 * (
            ${CMAKE_MATCH_4} + 365 * (
              ${CMAKE_MATCH_5}-2023
            )
          )
        )
      )"
    )
    if ( CMAKE_MATCH_5 GREATER 2024 )
      math(
        EXPR
        ts
        "${ts} + 86400" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2028 )
      math(
        EXPR
        ts
        "${ts} + 172800" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2032 )
      math(
        EXPR
        ts
        "${ts} + 259200" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2036 )
      math(
        EXPR
        ts
        "${ts} + 345600" 
      )
    endif ()
  else ()
    set ( ts 0 )
  endif ()
  set ( ${ans} "${ts}" PARENT_SCOPE )
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

# ANCHOR: twx_export
#[=======[
*//**
Convenient shortcut to export variables to the parent scope.
@param ... the names of the variable to be exported.
*/
twx_export(...){}
/*
#]=======]
macro ( twx_export )
  foreach ( var_twx ${ARGN} )
    set ( ${var_twx} ${${var_twx}} PARENT_SCOPE )
  endforeach ()
endmacro ()

message ( STATUS "TwxCoreLib loaded: ${TWX_DIR}" )

#*/
