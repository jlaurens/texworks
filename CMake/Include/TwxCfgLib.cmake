#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Cfg data writer and reader.

Low level controller to read, build and write Cfg data.
A Cfg data file is quite like an INI file, hence the file extension used.
It is saved in the `build_data` subfolder of the binary directory
of the project.

Usage:
```
include ( TwxCfgLib )
```
*/
/*
NB: We need high control and cannot benefit from
QSettings.
#]===============================================]

#[=======[
*//**
@brief Truthy c++ value

Expression used in `.in.cpp` files for a thuthy value.
*/
TWX_CFG_CPP_TRUTHY;
/*
#]=======]
set (
  TWX_CFG_CPP_TRUTHY 1
)

#[=======[
*//**
@brief Falsy c++ value

Expression used in `.in.cpp` files for a falsy value.
*/
TWX_CFG_CPP_FALSY;
/*
#]=======]
set (
  TWX_CFG_CPP_FALSY 0
)

# Guard
if ( COMMAND twx_cfg_setup )
  return ()
endif ()

# ANCHOR: twx_cfg_setup
#[=======[
*//**
@brief To automatically update dynamic Cfg data (git)

Add a target to allways rebuild dynamic data
for the current project.
Use at least once per project that needs `configuration_file`.
Essentially concerns `git`.
*/
twx_cfg_setup () {}
/*
#]=======]
function ( twx_cfg_setup )
  if ( TARGET TwxCfg_${PROJECT_NAME}_target )
    return ()
  endif ()
  twx_cfg_path ( _path "git" )
  add_custom_command(
    OUTPUT ${_path}
    COMMAND "${CMAKE_COMMAND}"
      "-DPROJECT_NAME=${PROJECT_NAME}"
      "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
      "-DTWX_TEST=${TWX_TEST}"
      -P "${TWX_DIR}/CMake/Include/TwxCfgTool.cmake"
    COMMENT
      "Update ${PROJECT_NAME} cfg information (git)"
  )
  add_custom_target (
    TwxCfg_${PROJECT_NAME}_target ALL
    DEPENDS ${_path}
  )
endfunction ()
# ANCHOR: twx_cfg_path
#[=======[
*//**
@brief Get the standard location for Cfg data files

@param variable name where the result is stored
@param id a spaceless string, the storage location is
  `<binary_dir>/build_data/<project_name>_<id>.ini` (or `.stamped`)
@param STAMPED optional key, when provided change the
  `ini` file extension for `stamped`.
*/
twx_cfg_path (variable id [STAMPED]) {}
/*
#]=======]
function ( twx_cfg_path ans_ id_ )
  if ( EXISTS "${id_}" )
    set (
      ${ans_}
      "${id_}"
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
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}_${id_}.${extension}"
    )
  endif ()
  twx_export ( ${ans_} )
  return ()
endfunction ()

# ANCHOR: Utility `twx_cfg_write_begin`
#[=======[
*//** @brief Start a cfg write sequence

Must be balanced by a `twx_cfg_write_end()` instruction.

Nesting of write sequences is not supported.

Usage:
```
twx_cfg_write_begin ()
twx_cfg_set ( ... )
...
twx_cfg_set ( ... )
twx_cfg_write_end ( ... )
```
*/
twx_cfg_write_begin () {}
/** @brief Reserved variable*/ cfg_keys_twx;
/** @brief Reserved variable*/ cfg_values_twx;
/*
#]=======]
function ( twx_cfg_write_begin )
  if ( DEFINED cfg_keys_twx )
    message ( FATAL_ERROR "Missing `twx_cfg_write_end(...)`" )
  endif ()
  set ( cfg_keys_twx )
  set ( cfg_values_twx )
endfunction ()

# ANCHOR: Utility `twx_cfg_set`
#[=======[
*//** @brief Set a cfg key/value pair
@param key a spaceless key, usually uppercase
@param value a possibly empty string, one line only
*/
twx_cfg_set ( key value ) {}
/*
Feed `cfg_keys_twx` with `<key>` and `cfg_values_twx` with `<value>`.
#]=======]
macro ( twx_cfg_set _key _value )
  list ( APPEND cfg_keys_twx "${_key}" )
  list ( APPEND cfg_values_twx "${_value}" )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "TWXCfg: ${_key} => <${_value}>" )
  endif ()
endmacro ()

#[=======[
twx_cfg_path ( path_ "${id_}" )
add_custom_command ( 
  OUTPUT "${path_}"
  COMMAND ${CMAKE_COMMAND} -P
  DEPENDS "${PROJECT_NAME}.ini"
)
add_custom_command(OUTPUT output1 [output2 ...]
                   COMMAND command1 [ARGS] [args1...]
                   [COMMAND command2 [ARGS] [args2...] ...]
                   [MAIN_DEPENDENCY depend]
                   [DEPENDS [depends...]]
                   [IMPLICIT_DEPENDS <lang1> depend1
                                    [<lang2> depend2] ...]
                   [WORKING_DIRECTORY dir]
                   [COMMENT comment] [VERBATIM] [APPEND])
#]=======]

# ANCHOR: Utility `twx_cfg_write_end`
#[=======[
*//** @brief balance previous `twx_cfg_write_begin()`

Do the writing...
@param id defines the storage location through `twx_cfg_path ()`.
*/
twx_cfg_write_end ( id ) {}
/*
#]=======]
function ( twx_cfg_write_end id_ )
  twx_cfg_path ( path_ "${id_}" )
  string ( TIMESTAMP t UTC )
  set (
    contents_ "\
;READ ONLY
;${t}
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${id_} informations]
"
  )
  # find the largest key for pretty printing
  set ( length 0 )
  foreach ( key IN LISTS cfg_keys_twx )
    string ( LENGTH "${key}" l )
    if ( l GREATER length )
      set ( length "${l}" )
    endif ()
  endforeach ()
  # Set the contents
  while ( NOT "${cfg_keys_twx}" STREQUAL "" )
    list ( GET cfg_keys_twx 0 key )
    list ( REMOVE_AT cfg_keys_twx 0 )
    if ( "${cfg_values_twx}" STREQUAL "" )
      set ( value "" )
      if ( NOT "${cfg_keys_twx}" STREQUAL "" )
        message ( FATAL_ERROR "Internal inconsistency")
      endif ()
    else ()
      list ( GET cfg_values_twx 0 value )
      list ( REMOVE_AT cfg_values_twx 0 )
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
  # write the file
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
    file ( RENAME "${path_}(new)" "${path_}" )
    message ( STATUS "Updated: ${path_}")
  else ()
    file ( REMOVE "${path_}(new)" )
  endif ()
  unset ( cfg_keys_twx PARENT_SCOPE)
  unset ( cfg_values_twx PARENT_SCOPE )
  # Now we cand start another write sequence
endfunction ()

# ANCHOR: Utility `twx_cfg_read`
#[=======[
*//** @brief Parse a Cfg data file

Parses the file lines matching `<key> = <value>`.
`<key>` contains no `=` nor space character, it is not empty whereas
`<value>` can be empty.
Set `twx_cfg_<key>` to `<value>`.

@param ... optional list of id or full path.
  When not provided all available Cfg data files are read.
  Each file is encoded in UTF-8
@param QUIET optional key, no error is raised when provided but `TWX_CFG_READ_FAILED` is set when the read failed and no more than one file is read.
@param ONLY_CONFIGURE optional key, no `TWX_<project_name>_<key>`
is set when provided
*/
twx_cfg_read ( ... [QUIET] [ONLY_CONFIGURE] ) {}
/*
#]=======]
function ( twx_cfg_read )
  set ( TWX_CFG_READ_FAILED OFF )
  cmake_parse_arguments (
    MY
    "QUIET;ONLY_CONFIGURE" "" ""
    ${ARGN}
  )
  if ( "${MY_UNPARSED_ARGUMENTS}" STREQUAL "" )
    # No file path or name provided: take it all
    twx_assert_non_void ( PROJECT_BINARY_DIR )
    twx_assert_non_void ( PROJECT_NAME )
    file (
      GLOB
      raw_list_
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}*.ini"
    )
    # older files first:
    set ( info_list_ )
    while ( NOT "${raw_list_}" STREQUAL "" )
      list ( GET raw_list_ 0 older_ )
      foreach ( item IN LISTS raw_list_ )
        if ( ${older_} IS_NEWER_THAN ${item} )
          set ( older_ ${item} )
        endif ()
      endforeach ()
      list ( REMOVE_ITEM raw_list_ ${older_} )
      list ( APPEND info_list_ ${older_} )
    endwhile ()
  else ()
    set ( info_list_ ${MY_UNPARSED_ARGUMENTS} )
  endif ()
  foreach ( name_ IN LISTS info_list_ )
    if ( NOT EXISTS "${name_}" )
      twx_cfg_path ( p_ "${name_}" )
      if ( EXISTS "${p_}" )
        set ( name_ "${p_}" ) 
      elseif ( MY_QUIET )
        set ( TWX_CFG_READ_FAILED ON PARENT_SCOPE )
        return ()
      else ()
        message ( FATAL_ERROR "No file at ${name_} (${p_})")
      endif ()#
        # readability is not tested
    endif ()
    if ( TWX_CONFIG_VERBOSE )
      message ( STATUS "twx_cfg_read: ${name_}" )
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
          message ( "TWX_CFG_${CMAKE_MATCH_1} => ${CMAKE_MATCH_2}" )
        endif ()
        if ( NOT name_ STREQUAL "" AND NOT MY_ONLY_CONFIGURE )
          set (
            TWX_${PROJECT_NAME}_CFG_${CMAKE_MATCH_1}
            "${CMAKE_MATCH_2}"
            PARENT_SCOPE
          )
        endif ()
      endif ()
    endforeach ()
    if ( MY_ONLY_CONFIGURE )
      include ( TwxCoreLib )
      twx_core_timestamp (
        "${name_}"
        TWX_CFG_TIMESTAMP_${name_}
      )
    endif ()
    if ( MY_QUIET )
      return ()
    endif ()
  endforeach ()
endfunction ()

# ANCHOR: twx_cfg_update
#[=======[
*//** @brief Updated Cfg data, mainly related to git.

Expected input state:

- `PROJECT_NAME`
- `PROJECT_BINARY_DIR`
- `TWX_DIR`
- `TWX_TEST` optional

Expected side effects:

- `<binary_dir>/build_data/<project name>-git.ini`
  is touched any time some data changes such that files must be reconfigured.
- `TWX_<project name>_CFG_<key>` when `<key>` is one of
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`
  - `GIT_OK`
*/
twx_cfg_update () {}
/*
#]=======]
function ( twx_cfg_update )
  twx_assert_non_void ( PROJECT_NAME )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "TwxCfgUpdate: ${PROJECT_NAME}" )
    message ( STATUS "TwxCfgUpdate: ${PROJECT_BINARY_DIR}" )
    message ( STATUS "TwxCfgUpdate: ${TWX_DIR}" )
  else ()
    message ( STATUS "TwxCfgUpdate..." )
  endif ()

  twx_cfg_read ( "factory" ONLY_CONFIGURE )
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

  if ( TWX_TEST )
    twx_cfg_write_begin ()
    foreach (key_ HASH BRANCH)
      twx_cfg_set ( GIT_${key_} "TEST(${key_}):${new_${key_}}" )
    endforeach ()
    twx_cfg_set ( GIT_DATE "1978-07-06T05:04:03+02:01" )
    twx_cfg_set ( GIT_OK ${TWX_CFG_CPP_TRUTHY} )
    twx_cfg_write_end ( "git" )
    message ( STATUS "Git commit info updated (TEST)" )
  else ()
    twx_cfg_write_begin ()
    foreach ( key_ HASH DATE BRANCH OK )
      twx_cfg_set ( GIT_${key_} "${new_${key_}}" )
    endforeach ()
    twx_cfg_write_end ( "git" )
    message ( STATUS "Git commit info updated" )
  endif ()
endfunction ( twx_cfg_update )

# ANCHOR: twx_cfg_return_if_exists
#[=======[
*//** @brief convenient macro

Return if the Cfg data file with the given id already exists.

@param id is the argument of `twx_cfg_path()`.
*/
twx_cfg_return_if_exists ( id ) {}
/*
#]=======]
macro (twx_cfg_return_if_exists _name )
  twx_cfg_path ( TWX_path ${_name} )
  if ( EXISTS "${TWX_path}" )
    unset ( TWX_path )
    return ()
  endif ()
  unset ( TWX_path )
endmacro ()
#*/
