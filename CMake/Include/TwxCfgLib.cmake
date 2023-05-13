#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

Info file writer and reader.

Usage:
```
include ( TwxCfgLib )
```
Output:
* `twx_cfg_write_begin` function
* `twx_cfg_set` function
* `twx_cfg_write_end` function
* `twx_cfg_read` function

#]===============================================]

# guard

if ( TwxCfgLib_ALREADY )
  return ()
endif ()

set ( TwxCfgLib_ALREADY ON )

set (
  TWX_CFG_CPP_TRUTHY 1
)

# ANCHOR: twx_cfg_setup
#[=======[
Add a target to allways rebuild dynamic information
for the current project.

Usage:
```
twx_cfg_setup ()
```
#]=======]
function ( twx_cfg_setup )
  if ( NOT TARGET TwxInfo_${PROJECT_NAME}_target )
    twx_cfg_path ( _path "git" )
    add_custom_command(
      OUTPUT ${_path}
      COMMAND "${CMAKE_COMMAND}"
        "-DPROJECT_NAME=${PROJECT_NAME}"
        "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
        -P "${TWX_DIR}/CMake/Include/TwxInfoTool.cmake"
      COMMENT
        "Update ${PROJECT_NAME} Git information"
    )
    add_custom_target (
      TwxInfo_${PROJECT_NAME}_target ALL
      DEPENDS ${_path}
    )
  endif ()
endfunction ()
# ANCHOR: twx_cfg_path
#[=======[
Get the standard locations for static and git info
```
twx_cfg_path ( <variable> <name> [STAMPED])
```
Set the `<variable>` to the path for the given `<name>`

Input arguments:
* `<variable>` will contain the output
* `<name>` shortcut or full path.

The `STAMPED` optional argument changes the `ini` extension
for `stamped`.
#]=======]
function ( twx_cfg_path ans_ name_ )
  if ( EXISTS "${name_}" )
    set (
      ${ans_}
      "${name_}"
    )
  else ()
    twx_assert_non_void ( PROJECT_BINARY_DIR )
    twx_assert_non_void ( PROJECT_NAME )
    cmake_parse_arguments ( MY "STAMPED" "" "" ${ARGN} )
    if ( MY_STAMPED )
      set ( extension "stamped" )
    else ()
      set ( extension "ini" )
    endif ()
    set (
      ${ans_}
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}_${name_}.${extension}"
    )
  endif ()
  twx_export ( ${ans_} )
  return ()
endfunction ()

# ANCHOR: Utility `twx_cfg_write_begin`
#[=======[
Usage:
```
twx_cfg_write_begin ()
twx_cfg_set ( ... )
...
twx_cfg_set ( ... )
twx_cfg_write_end ( ... )
```

#]=======]
function ( twx_cfg_write_begin )
  set ( info_keys_twx )
  set ( info_values_twx )
endfunction ()

# ANCHOR: Utility `twx_cfg_set`
#[=======[
Usage:
```
twx_cfg_set ( key value )
```
Feed `info_keys_twx` with `<key>` and `info_values_twx` with `<value>`.
#]=======]
function ( twx_cfg_set _key _value )
  list ( APPEND info_keys_twx "${_key}" )
  list ( APPEND info_values_twx "${_value}" )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "TWXInfo: ${_key} => <${_value}>" )
  endif ()
  return (
    PROPAGATE
    info_keys_twx
    info_values_twx
  )
endfunction ()

# ANCHOR: Utility `twx_cfg_write_end`
#[=======[
Usage:
```
twx_cfg_write_end ( <info_name> )
```
Do the writing...
#]=======]
function ( twx_cfg_write_end name_ )
  twx_cfg_path ( path_ "${name_}" )
  set (
    contents_ "\
;READ ONLY
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${name_} informations]
"
  )
  # find the largest key
  set ( length 0 )
  foreach ( key IN LISTS info_keys_twx )
    string ( LENGTH "${key}" l )
    if ( l GREATER length )
      set ( length "${l}" )
    endif ()
  endforeach ()
  while ( NOT "${info_keys_twx}" STREQUAL "" )
    list ( GET info_keys_twx 0 key )
    list ( REMOVE_AT info_keys_twx 0 )
    if ( "${info_values_twx}" STREQUAL "" )
      set ( value "" )
      if ( NOT "${info_keys_twx}" STREQUAL "" )
        message ( FATAL_ERROR "Internal inconsistency")
      endif ()
    else ()
      list ( GET info_values_twx 0 value )
      list ( REMOVE_AT info_values_twx 0 )
    endif ()
    string ( LENGTH "${key}" l )
    math ( EXPR l "${length}-${l}" )
    if ( l GREATER 0 )
      foreach (i RANGE 1 ${l} )
        string ( APPEND key " " )
      endforeach ()
    endif ()
    set (
      contents_
      "${contents_}${key} = ${value}\n"
    )
  endwhile ()
  file (
    WRITE
    "${path_}(new)"
    "${contents_}"
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E compare_files
    "${path_}(new)"
    "${path_}"
    RESULT_VARIABLE ans
  )
  if ( ans GREATER 0 )
    message ( STATUS "Updated: ${path_}")
    file ( RENAME "${path_}(new)" "${path_}" )
  else ()
    file ( REMOVE "${path_}(new)" )
  endif ()
  unset ( info_keys_twx )
  unset ( info_values_twx )
endfunction ()

# ANCHOR: Utility `twx_cfg_read`
#[=======[
Usage:
```
twx_cfg_read ( [ <info_name> | <file_path> ...] [QUIET] [ONLY_CONFIGURE] )
```
Argument: one of
* `info_name`: one info name
* `file_path`: parse the file at `<file_path>` which is encoded in UTF-8
  and must be readable.

When no arguments are provided, read all the available files.

Output:
* With `QUIET`, `TWX_CFG_READ_FAILED` is true when the read failed.
  In all other situations, it is false. Also, only one file is read,
  if any.

Parses the file lines matching `<key> = <value>`.
`<key>` contains no `=` nor space character, it is not empty whereas
`<value>` can be empty.
Set `twx_cfg_<key>` to `<value>`.
When `QUIET` is provided, no error is raised.
When `ONLY_CONFIGURE` is not provided, and in `GIT` or `STATIC` mode, 
also set `TWX_<project_name>_<key>` to `<value>`.

#]=======]
function ( twx_cfg_read )
  set ( TWX_CFG_READ_FAILED OFF )
  cmake_parse_arguments (
    twx
    "QUIET;ONLY_CONFIGURE" "" ""
    ${ARGN}
  )
  if ( "${twx_UNPARSED_ARGUMENTS}" STREQUAL "" )
    # No file path or name provided: take it all
    twx_assert_non_void ( PROJECT_BINARY_DIR )
    twx_assert_non_void ( PROJECT_NAME )
    file (
      GLOB
      info_list_
      "${PROJECT_BINARY_DIR}/build_data/*.ini"
    )
  else ()
    set ( info_list_ ${twx_UNPARSED_ARGUMENTS} )
  endif ()
  foreach ( name_ IN LISTS info_list_ )
    if ( NOT EXISTS "${name_}" )
      twx_cfg_path ( p_ "${name_}" )
      if ( EXISTS "${p_}" )
        set ( name_ "${p_}" ) 
      elseif ( twx_QUIET )
        set ( TWX_CFG_READ_FAILED ON )
        return ()
      else ()
        message ( FATAL_ERROR "No file at ${name_} (${p_})")
      endif ()#
        # readability is not tested
    endif ()
    file (
      STRINGS "${name_}"
      lines
      REGEX "="
      ENCODING UTF-8
    )
    foreach ( line IN LISTS lines )
      if ( line MATCHES "^[ ]*([^ =]+)[ ]*=(.*)$" )
        string ( STRIP "${CMAKE_MATCH_2}" CMAKE_MATCH_2 )
        set (
          TWX_CFG_${CMAKE_MATCH_1}
          "${CMAKE_MATCH_2}"
          PARENT_SCOPE
        )
        if ( TWX_CONFIG_VERBOSE )
          message ( "twx_cfg_${CMAKE_MATCH_1} => ${CMAKE_MATCH_2}" )
        endif ()
        if ( NOT name_ STREQUAL "" AND NOT twx_ONLY_CONFIGURE )
          set (
            TWX_${PROJECT_NAME}_INFO_${CMAKE_MATCH_1}
            "${CMAKE_MATCH_2}"
            PARENT_SCOPE
          )
        endif ()
      endif ()
    endforeach ()
    if ( twx_ONLY_CONFIGURE )
      include ( TwxCoreLib )
      twx_core_timestamp (
        "${name_}"
        TWX_CFG_TIMESTAMP_${name_}
      )
    endif ()
    if ( twx_QUIET )
      return ()
    endif ()
  endforeach ()
endfunction ()

#[===============================================[
Updated information, mainly related to git.

Usage:
from a target at build time only
```
twx_cfg_update ()
```
Input:
* `PROJECT_NAME`
* `PROJECT_BINARY_DIR`

Output:
* `<binary_dir>/build_data/<project name>Git.ini`
  is touched any time some info changes such that files must be reconfigured.
* `TWX_<project name>_INFO_<key>` when `<key>` is one of
  - `GIT_HASH`
  - `Git_DATE`
  - `GIT_BRANCH`
  - `GIT_OK`

#]===============================================]

# ANCHOR: twx_cfg_update
function ( twx_cfg_update )
  twx_assert_non_void ( PROJECT_NAME )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "TwxInfoUpdate: ${PROJECT_NAME}" )
    message ( STATUS "TwxInfoUpdate: ${PROJECT_BINARY_DIR}" )
    message ( STATUS "TwxInfoUpdate: ${TWX_DIR}" )
  else ()
    message ( STATUS "TwxInfoUpdate..." )
  endif ()

  include ( TwxCfgLib )
  twx_cfg_read ( "static" ONLY_CONFIGURE )
  twx_cfg_read ( "git" QUIET ONLY_CONFIGURE )

  foreach ( key HASH DATE BRANCH OK )
    set ( new_${key} "${TWX_CFG_GIT_${key}}" )    
  endforeach ()

  set ( Unavailable "<Unavailable>" )
  set ( new_BRANCH "${Unavailable}" )

  # Try to run git to obtain the last commit hash, date and branch
  find_package ( Git QUIET )
  if ( GIT_FOUND )
    execute_process (
      COMMAND "${GIT_EXECUTABLE}"
      "--git-dir=.git" "show" "--no-patch" "--pretty=%h"
      WORKING_DIRECTORY "${TWX_DIR}"
      RESULT_VARIABLE result_HASH
      OUTPUT_VARIABLE new_HASH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
#[=======[
In theory, `set( ENV{TZ} UTC0 )` followed by
```
git show --quiet --date='format-local:%Y-%m-%dT%H:%M:%SZ' --format="%cd" --no-patch
```
Would show the date and time UTC.
#]=======]
    execute_process (
      COMMAND "${GIT_EXECUTABLE}"
      "--git-dir=.git" "show" "--no-patch" "--pretty=%cI"
      WORKING_DIRECTORY "${TWX_DIR}"
      RESULT_VARIABLE result_DATE
      OUTPUT_VARIABLE new_DATE
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process (
      COMMAND "${GIT_EXECUTABLE}"
      "--git-dir=.git" "branch" "--show-current"
      WORKING_DIRECTORY "${TWX_DIR}"
      RESULT_VARIABLE result_BRANCH
      OUTPUT_VARIABLE new_BRANCH
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if ( result_HASH EQUAL 0 AND
        result_DATE EQUAL 0 AND
        result_BRANCH EQUAL 0 AND
        NOT "${new_HASH}" STREQUAL "" AND
        NOT "${new_DATE}" STREQUAL "" AND
        NOT "${new_BRANCH}" STREQUAL "" )
        set ( new_OK ${TWX_CFG_CPP_TRUTHY} )
      execute_process (
        COMMAND "${GIT_EXECUTABLE}"
        "--git-dir=.git" "diff" "--ignore-cr-at-eol" "--quiet" "HEAD"
        WORKING_DIRECTORY "${TWX_DIR}"
        RESULT_VARIABLE MODIFIED_RESULT_twx
      )
      if ( MODIFIED_RESULT_twx EQUAL 1)
        set( new_HASH "${new_HASH}*")
      endif ()
    endif ()
  endif ( GIT_FOUND )

  twx_cfg_write_begin ()
  twx_cfg_set ( GIT_HASH   "${new_HASH}"   )
  twx_cfg_set ( GIT_DATE   "${new_DATE}"   )
  twx_cfg_set ( GIT_BRANCH "${new_BRANCH}" )
  twx_cfg_set ( GIT_OK     "${new_OK}"     )
  twx_cfg_write_end ( "git" )
  message ( STATUS "Git commit info updated" )

endfunction ( twx_cfg_update )

# ANCHOR: twx_cfg_return_if_exists
#[=======[
Usage:
```
twx_cfg_return_if_exists ( name )
```
`name` is the argument of `twx_cfg_path`.
#]=======]
macro (twx_cfg_return_if_exists _name )
  twx_cfg_path ( TWX_path ${_name} )
  if ( EXISTS "${TWX_path}" )
    unset ( TWX_path )
    return ()
  endif ()
  unset ( TWX_path )
endmacro ()