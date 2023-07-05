#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Collection of core utilities

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxCoreLib.cmake"
  )

Output state:
- `TWX_DIR`

*/
/*#]===============================================]

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
  */
twx_complete_dir_var(...) {}
/*#]=======]
function ( twx_complete_dir_var var_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_complete_dir_var )
  set ( i 0 )
  while ( true )
    set ( v "${ARGV${i}}" )
    message ( TRACE "v => \"${v}\"")
    twx_assert_variable ( "${v}" )
    set ( w "${${v}}" )
    if ( NOT w STREQUAL "" AND NOT w MATCHES "/$" )
      set ( ${v} "${w}/" PARENT_SCOPE)
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
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

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Include` and `CMake/Modules` available.
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

if ( "${TWX_COMMAND}" STREQUAL "" )
  string ( TOLOWER "${TWX_NAME}" TWX_COMMAND)
endif ()

# ANCHOR: Utility `twx_core_timestamp`
#[=======[
Usage:
```
twx_core_timestamp ( <filepath_> <variable> )
```
Records the file timestamp.
The precision is 1s.
Correct up to 2036-02-27.
#]=======]
function ( twx_core_timestamp filepath_ ans )
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
  set ( ${ans} "${ts}" PARENT_SCOPE )
endfunction ()

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

function ( twx_regex_escape text_ IN_VAR_ var_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_regex_escape )
  cmake_parse_arguments ( PARSE_ARGV 1 twxR "" "IN_VAR" "" )
  if ( NOT DEFINED twxR_IN_VAR )
    twx_fatal ( "Missing IN_VAR argument.")
    return ()
  endif ()
  twx_assert_variable ( twxR_IN_VAR )
  set ( i 0 )
  unset ( ARGV${ARGC} )
  while ( true )
    if ( ARGV${i} STREQUAL "IN_VAR" )
      twx_increment ( VAR i STEP 2 )
      if ( DEFINED ARGV${i} )
        twx_fatal ( "Unexpected argument: ${ARGV${i}}")
        return ()
      endif ()
      break ()
    endif ()
    string (
      REGEX REPLACE "([]()|?+*[\\\\.$^-])" "\\\\\\1"
      out_
      "${twxR_UNPARSED_ARGUMENTS}"
    )
    if ( out_ MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${out_}\\" )
    else ()
      list ( APPEND m "${out_}" )
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  set ( ${twxR_IN_VAR} "${m}" PARENT_SCOPE )
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMessageLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxStateLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrementLib.cmake" )

twx_complete_dir_var ( TWX_DIR )

message ( DEBUG "TwxCoreLib loaded ${TWX_DIR}" )

#*/
