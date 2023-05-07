#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

Info file writer and reader.

Usage:
```
include ( TwxInfoLib )
```
Output:
* `twx_info_write_begin` function
* `twx_info_set` function
* `twx_info_write_end` function
* `twx_info_read` function

#]===============================================]

# guard

if ( TwxInfoLib_ALREADY )
  return ()
endif ()

set ( TwxInfoLib_ALREADY ON )

set (
  TWX_INFO_CPP_TRUTHY 1
)

# ANCHOR: twx_info_setup
#[=======[
Add a target to allways rebuild dynamic information
for the current project.

Usage:
```
twx_info_setup ()
```
#]=======]
function ( twx_info_setup )
  if ( NOT TARGET TwxInfo_${PROJECT_NAME}_target )
    twx_info_path ( GIT _path )
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
# ANCHOR: Path
#[=======[
Get the standard locations for static and git info
```
twx_info_path ( <mode> <variable> )
```
Set the `<variable>` to thge path for the given `<mode>`

Input arguments:
* `<mode>` one of `GIT`, `STATIC` or a full mode.
* `<variable>` will contain the output

#]=======]
function ( twx_info_path MODE _path )
  if ( MODE STREQUAL "GIT" )
    if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_BINARY_DIR" )
    elseif ( "${PROJECT_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_NAME" )
    endif ()
    set (
      ${_path}
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Git.ini"
    )
  elseif ( MODE STREQUAL "STATIC" )
    if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_BINARY_DIR" )
    elseif ( "${PROJECT_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_NAME" )
    endif ()
    set (
      ${_path}
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Static.ini"
    )
  else ()
    set ( ${_path} "${MODE}" )
  endif ()
  return ( PROPAGATE ${_path} )
endfunction ()

# ANCHOR: Shared preamble
#[=======[
Reads and manage the `MODE` argument.
Set `_path` for reading or writing.
Set `MODE` appropriately.
#]=======]
macro ( twx__info_manage_MODE )
  if ( MODE STREQUAL "GIT" )
    if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_BINARY_DIR" )
    elseif ( "${PROJECT_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_NAME" )
    endif ()
    set (
      _path
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Git.ini"
    )
  elseif ( MODE STREQUAL "STATIC" )
    if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_BINARY_DIR" )
    elseif ( "${PROJECT_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "Missing PROJECT_NAME" )
    endif ()
    set (
      _path
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Static.ini"
    )
  else ()
    set ( _path "${MODE}" )
    set ( MODE )
  endif ()
endmacro ()

# ANCHOR: Utility `twx_info_write_begin`
#[=======[
Usage:
```
twx_info_write_begin ( ( GIT | STATIC | <file_path> ) )
```
Required argument: one of
* `GIT`: write the git info file
* `STATIC`: write the static info file
* `<file_path>`: write the file at `<file_path>` which is a writable location.

#]=======]
function ( twx_info_write_begin )
  set ( info_keys_twx )
  set ( info_values_twx )
endfunction ()

# ANCHOR: Utility `twx_info_set`
#[=======[
Usage:
```
twx_info_set ( key value )
```
Feed `info_keys_twx` with `<key>` and `info_values_twx` with `<value>`.
#]=======]
function ( twx_info_set _key _value )
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

# ANCHOR: Utility `twx_info_write_end`
#[=======[
Usage:
```
twx_info_write_end ( GIT | STATIC | <file_path> )
```
Do the writing...
#]=======]
function ( twx_info_write_end MODE )
  twx__info_manage_MODE ()
  string ( TOLOWER "${MODE}" mode)
  set (
    contents "\
;READ ONLY
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${mode} informations]
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
    list ( GET info_values_twx 0 value )
    list ( REMOVE_AT info_values_twx 0 )
    string ( LENGTH "${key}" l )
    math ( EXPR l "${length}-${l}" )
    if ( l GREATER 0 )
      foreach (i RANGE 1 ${l} )
        string ( APPEND key " " )
      endforeach ()
    endif ()
    set (
      contents
      "${contents}${key} = ${value}\n"
    )
  endwhile ()
  file (
    WRITE
    "${_path}(new)"
    "${contents}"
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E compare_files
    "${_path}(new)"
    "${_path}"
    RESULT_VARIABLE ans
  )
  if ( ans GREATER 0 )
    message ( STATUS "Updated: ${_path}")
    file ( RENAME "${_path}(new)" "${_path}" )
  else ()
    file ( REMOVE "${_path}(new)" )
  endif ()
  unset ( info_keys_twx )
  unset ( info_values_twx )
endfunction ()

# ANCHOR: Utility `twx_info_read`
#[=======[
Usage:
```
twx_info_read ( ( GIT | STATIC | <file_path> ) [QUIET] [ONLY_CONFIGURE] )
```
Required argument: one of
* `GIT`: parse the git info file
* `STATIC`: parse the static info file
* `file_path`: parse the file at `<file_path>` which is encoded in UTF-8
  and must be readable.

Output:
* With `QUIET`, `TWX_INFO_READ_FAILED` is true when the read failed.
  In all other situations, it is false.

Parses the file lines matching `<key> = <value>`.
`<key>` contains no `=` nor space character, it is not empty whereas
`<value>` can be empty.
Set `TWX_INFO_<key>` to `<value>`.
When `QUIET` is provided, no error is raised.
When `ONLY_CONFIGURE` is not provided, and in `GIT` or `STATIC` mode, 
also set `TWX_<project_name>_<key>` to `<value>`.

#]=======]
function ( twx_info_read MODE )
  set ( TWX_INFO_READ_FAILED OFF )
  if ( NOT "${ARGN}" STREQUAL "" )
    list ( GET ARGN 0 arg )
    list ( REMOVE_AT ARGN 0 )
    if ( arg STREQUAL "QUIET" )
      set ( _quiet ON )
      if ( NOT "${ARGN}" STREQUAL "" )
        list ( GET ARGN 0 arg )
        list ( REMOVE_AT ARGN 0 )
        if ( arg STREQUAL "ONLY_CONFIGURE" )
          set ( _only_configure ON )
        endif ()
      endif ()  
    elseif ( arg STREQUAL "ONLY_CONFIGURE" )
      set ( _only_configure ON )
    endif ()
  endif ()
  twx__info_manage_MODE ()
  if ( NOT EXISTS "${_path}" )
    if ( _quiet )
      set ( TWX_INFO_READ_FAILED ON )
      return ()
    else ()
      message ( FATAL_ERROR "No file at ${_path}")
    endif ()#
    # readability is not tested
  endif ()
  file (
    STRINGS "${_path}"
    lines
    REGEX "="
    ENCODING UTF-8
  )
  foreach ( line IN LISTS lines )
    if ( line MATCHES "^[ ]*([^ =]+)[ ]*=(.*)$" )
      string ( STRIP "${CMAKE_MATCH_2}" CMAKE_MATCH_2 )
      set (
        TWX_INFO_${CMAKE_MATCH_1}
        "${CMAKE_MATCH_2}"
        PARENT_SCOPE
      )
      message ( "TWX_INFO_${CMAKE_MATCH_1} => ${CMAKE_MATCH_2}" )
      if ( NOT MODE STREQUAL "" AND NOT _only_configure )
        set (
          TWX_${PROJECT_NAME}_INFO_${CMAKE_MATCH_1}
          "${CMAKE_MATCH_2}"
          PARENT_SCOPE
        )
      endif ()
    endif ()
  endforeach ()
  if ( _only_configure )
    include ( TwxCoreLib )
    twx_core_timestamp (
      "${_path}"
      TWX_INFO_TIMESTAMP_${MODE}
    )
  endif ()
endfunction ()

#[===============================================[
Updated information, mainly related to git.

Usage:
from a target at build time only
```
twx_info_update ()
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

# ANCHOR: GIT

function ( twx_info_update )
  if ( "${PROJECT_NAME}" STREQUAL "" )
    message ( FATAL_ERROR "Undefined PROJECT_NAME" )
  endif ()
  if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
    message ( FATAL_ERROR "Undefined PROJECT_BINARY_DIR" )
  endif ()

  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "TwxInfoUpdate: ${PROJECT_NAME}" )
    message ( STATUS "TwxInfoUpdate: ${PROJECT_BINARY_DIR}" )
    message ( STATUS "TwxInfoUpdate: ${TWX_DIR}" )
  else ()
    message ( STATUS "TwxInfoUpdate" )
  endif ()

  include ( TwxInfoLib )
  twx_info_read ( STATIC    ONLY_CONFIGURE )
  twx_info_read ( GIT QUIET ONLY_CONFIGURE )

  foreach ( key HASH DATE BRANCH OK )
    set ( new_${key} "${TWX_INFO_GIT_${key}}" )    
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
````
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
        set ( new_OK ${TWX_INFO_CPP_TRUTHY} )
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

  include ( TwxInfoLib )
  twx_info_write_begin ()
  twx_info_set ( GIT_HASH   "${new_HASH}"   )
  twx_info_set ( GIT_DATE   "${new_DATE}"   )
  twx_info_set ( GIT_BRANCH "${new_BRANCH}" )
  twx_info_set ( GIT_OK     "${new_OK}"     )
  twx_info_write_end ( GIT )
  message ( STATUS "Git commit info updated" )

endfunction ( twx_info_update )
