#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Utilities
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxUtilLib.cmake"
  *   )
  *
  * Output state:
  * - `TWX_DIR`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

# Full include only once
if ( DEFINED TWX_DIR )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_complete_dir_var
#[=======[*/
/** @brief Complete dir variables contents.
  *
  * When the variable is not empty, ensures that it ends with a `/`.
  * The resulting path may not exists though.
  *
  * @param ..., non empty list of string variables containing locations of directories.
  *
  */
twx_complete_dir_var(...) {}
/*
Implementation details:
The argument are IO variable names, such that we must name local variables with great care,
otherwise there might be a conflict.
#]=======]
function ( twx_complete_dir_var twx_complete_dir_var.var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_complete_dir_var )
  set ( twx_complete_dir_var.i 0 )
  while ( TRUE )
    set ( twx_complete_dir_var.v "${ARGV${twx_complete_dir_var.i}}" )
    # message ( TR@CE "v => \"${twx_complete_dir_var.v}\"")
    twx_assert_variable_name ( "${twx_complete_dir_var.v}" )
    twx_assert_defined ( "${twx_complete_dir_var.v}" )
    set ( twx_complete_dir_var.w "${${twx_complete_dir_var.v}}" )
    if ( NOT "${twx_complete_dir_var.w}" STREQUAL "" AND NOT "${twx_complete_dir_var.w}" MATCHES "/$" )
      twx_export ( "${twx_complete_dir_var.v}=${twx_complete_dir_var.w}/" )
    endif ()
    twx_increment_and_break_if ( VAR twx_complete_dir_var.i >= ${ARGC} )
  endwhile ()
endfunction ( twx_complete_dir_var )

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
  "${CMAKE_CURRENT_LIST_DIR}/../../"
  REALPATH
)

# ANCHOR: Utility `twx_util_timestamp`
#[=======[
Usage:
```
twx_util_timestamp ( <filepath_> <variable> )
```
Records the file timestamp.
The precision is 1s.
Correct up to 2036-02-27.
#]=======]
function ( twx_util_timestamp filepath_ .IN_VAR twx.R_IN_VAR )
  twx_arg_assert_count ( ${ARGC} == 3 )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  file (
    TIMESTAMP "${filepath_}" ts "%S:%M:%H:%j:%Y" UTC
  )
  if ( ts MATCHES "^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$" )
    math (
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
    if ( "${CMAKE_MATCH_5}" GREATER "2024" )
      math (
        EXPR
        ts
        "${ts} + 86400"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2028" )
      math (
        EXPR
        ts
        "${ts} + 172800"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2032" )
      math (
        EXPR
        ts
        "${ts} + 259200"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2036" )
      math (
        EXPR
        ts
        "${ts} + 345600"
      )
    endif ()
  else ()
    set ( ts 0 )
  endif ()
  twx_export ( "${twx.R_IN_VAR}=${ts}" )
endfunction ()

# TODO: MOVE THIS TO THE INCLUDE FOLDER

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
  else ()
    set ( TWX_NAME TeXworks )
  endif ()
endif ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExportLib.cmake" )

if ( "${TWX_COMMAND}" STREQUAL "" )
  string ( TOLOWER "${TWX_NAME}" TWX_COMMAND)
endif ()

twx_complete_dir_var ( TWX_DIR )

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Base` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
]=======]
list (
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR}CMake/Base"
  "${TWX_DIR}CMake/Include"
  "${TWX_DIR}CMake/Modules"
)
list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )

message ( DEBUG "TwxUtilLib loaded ${TWX_DIR}" )

#*/
