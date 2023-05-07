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

NB: This does not load the base.

#]===============================================]

# guard

if ( TwxInfoLib_ALREADY )
  return ()
endif ()

# ANCHOR: Shared preamble
#[=======[
Reads and manage the `MODE` argument.
Set `_path` for reading or writing.
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
  # return
  set ( info_keys_twx   "${info_keys_twx}"   PARENT_SCOPE )
  set ( info_values_twx "${info_values_twx}" PARENT_SCOPE )
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
