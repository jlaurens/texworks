#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Cfg data writer and reader.

Low level controller to read, build and write Cfg data.
A Cfg data file is quite like an INI file, hence the file extension used.
It is saved in the `TwxBuildData` subfolder of the binary directory
of the project. It will be used to define the replacement macros
embedded in `configure_file` input.

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
TWX_CPP_TRUTHY_CFG;
/*
#]=======]
set (
  TWX_CPP_TRUTHY_CFG 1
)

#[=======[
*//**
@brief Falsy c++ value

Expression used in `.in.cpp` files for a falsy value.
*/
TWX_CPP_FALSY_CFG;
/*
#]=======]
set (
  TWX_CPP_FALSY_CFG 0
)

# Guard
if ( COMMAND twx_cfg_setup )
  return ()
endif ()

# ANCHOR: twx_cfg_path
#[=======[
*//**
@brief Get the standard location for Cfg data files

@param variable name where the result is stored
@param id for key ID, a spaceless string, the storage location is
  `.../TwxBuildData/<project_name>_<id>.ini` (or `.stamped`)
@param STAMPED optional key, when provided change the
  `ini` file extension for `stamped`.
*/
twx_cfg_path ( variable ID id [STAMPED] ) {}
/*
#]=======]
function ( twx_cfg_path ans_ )
  twx_parse_arguments ( "STAMPED" "ID" "" ${ARGN} )
  twx_assert_parsed ()
  if ( EXISTS "${my_twx_ID}" )
    set ( ${ans_} "${my_twx_ID}" )
    twx_export ( ${ans_} )
    return ()
  endif ()
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  twx_assert_non_void ( PROJECT_NAME )
  if ( my_twx_STAMPED )
    set ( extension "stamped" )
  else ()
    set ( extension "ini" )
  endif ()
  set (
    ${ans_}
    "${TWX_PROJECT_BUILD_DATA_DIR}/${PROJECT_NAME}_${my_twx_ID}_cfg.${extension}"
  )
  twx_export ( ${ans_} )
endfunction ()

# ANCHOR: `twx_cfg_update_factory`
#[=======[
*//** @brief Update the factory Cfg data file */
twx_cfg_update_factory ( ) {}
/*
#]=======]
macro ( twx_cfg_update_factory )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DPROJECT_NAME=${PROJECT_NAME}"
      "-DTWX_PROJECT_INI=${TWX_PROJECT_INI}"
      "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
      "-DTWX_PROJECT_BUILD_DATA_DIR=${TWX_PROJECT_BUILD_DATA_DIR}"
      "-DTWX_${PROJECT_NAME}_INI=${TWX_${PROJECT_NAME}_INI}"
      "-DTWX_VERBOSE=${TWX_VERBOSE}"
      "-DTWX_TEST=${TWX_TEST}"
      "-DTWX_DEV=${TWX_DEV}"
      -P "${TWX_DIR}/CMake/Command/TwxCfg_factory.cmake"
  )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  twx_cfg_read ( "factory" )
endmacro ()

# ANCHOR: `twx_cfg_update_git`
#[=======[
*//** @brief Update the git Cfg data file
*/
twx_cfg_update_git ( ) {}
/*
#]=======]
macro ( twx_cfg_update_git )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DPROJECT_NAME=${PROJECT_NAME}"
      "-DTWX_PROJECT_INI=${TWX_PROJECT_INI}"
      "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
      "-DTWX_PROJECT_BUILD_DATA_DIR=${TWX_PROJECT_BUILD_DATA_DIR}"
      "-DTWX_VERBOSE=${TWX_VERBOSE}"
      "-DTWX_TEST=${TWX_TEST}"
      "-DTWX_DEV=${TWX_DEV}"
      -P "${TWX_DIR}/CMake/Command/TwxCfg_git.cmake"
  )
  twx_cfg_read ( "git" )
endmacro ()

# ANCHOR: twx_cfg_setup
#[=======[
*//**
@brief Setup the current project to use Cfg

Find the proper `<project name>.ini` file, usually in the
`PROJECT_SOURCE_DIR`, and put the path in `TWX_<project name>_INI`.
Bypass this by providing a path to an existing file in the
`TWX_<project name>_INI` variable prior to calling `twx_cfg_setup`.
Or provide an `ini` argument.

Creates 2 commands to build the "factory" and "git" Cfg data files
for the current project.

Add a target to allways rebuild git related Cfg data.

The "factory" and "git" Cfg data files are read such that
their contents is available in the current variable scope.

Use at least once per project that needs `configuration_file`.

See twx_cfg_read().

The `TWX_TEST` variable is propagated to the command.

@param ini the optional metadata configuration file. 
*/
twx_cfg_setup (ini) {}
/** @brief Overwrite the default <project name>.ini lookup */
TWX_PROJECT_INI;
/*
#]=======]
macro ( twx_cfg_setup )
  twx_assert_non_void ( PROJECT_NAME )
  if ( TARGET TwxCfg_${PROJECT_NAME}_target )
    twx_cfg_read ( "factory" "git" )
  else ()
    if ( "${TWX_${PROJECT_NAME}_INI}" STREQUAL "" OR NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
      set (
        TWX_${PROJECT_NAME}_INI
        "${ARGN}"
      )
      if ( "${ARGN}" STREQUAL "" OR NOT EXISTS "${ARGN}" )
        if ( "${TWX_PROJECT_INI}" STREQUAL "" )
          set (
            TWX_PROJECT_INI
            "${PROJECT_NAME}.ini"
          )
        endif ()
        set (
          TWX_${PROJECT_NAME}_INI
          "${TWX_PROJECT_INI}"
        )
        if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
          set (
            TWX_${PROJECT_NAME}_INI
            "${PROJECT_SOURCE_DIR}/${TWX_PROJECT_INI}"
          )
          if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
            set (
              TWX_${PROJECT_NAME}_INI
              "${CMAKE_CURRENT_SOURCE_DIR}/${TWX_PROJECT_INI}"
            )
            if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
              set (
                TWX_${PROJECT_NAME}_INI
                "${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.ini"
              )
              if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
                set (
                  TWX_${PROJECT_NAME}_INI
                  "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.ini"
                )
                if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
                  set (
                    TWX_${PROJECT_NAME}_INI
                    "${TWX_DIR}/${TWX_PROJECT_NAME}.ini"
                  )
                  if ( NOT EXISTS "${TWX_${PROJECT_NAME}_INI}" )
                    message ( FATAL_ERROR "No TWX_${PROJECT_NAME}_INI" )
                  endif ()
                endif ()
              endif ()
            endif ()
          endif ()
        endif ()
      endif ()
    endif ()
    twx_message_verbose ( STATUS "TWX_${PROJECT_NAME}_INI => ${TWX_${PROJECT_NAME}_INI}" )
    twx_assert_non_void ( TWX_${PROJECT_NAME}_INI )
    set_property (
      DIRECTORY 
      APPEND 
      PROPERTY CMAKE_CONFIGURE_DEPENDS
      ${TWX_${PROJECT_NAME}_INI}
    )
    twx_cfg_path ( path_factory_twx ID "factory" )
    add_custom_command (
      OUTPUT ${path_factory_twx}
      COMMAND "${CMAKE_COMMAND}"
        "-DPROJECT_NAME=${PROJECT_NAME}"
        "-DTWX_PROJECT_INI=${TWX_PROJECT_INI}"
        "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
        "-DTWX_PROJECT_BUILD_DATA_DIR=${TWX_PROJECT_BUILD_DATA_DIR}"
        "-DTWX_${PROJECT_NAME}_INI=${TWX_${PROJECT_NAME}_INI}"
        "-DTWX_VERBOSE=${TWX_VERBOSE}"
        "-DTWX_TEST=${TWX_TEST}"
        "-DTWX_DEV=${TWX_DEV}"
        -P "${TWX_DIR}/CMake/Command/TwxCfg_factory.cmake"
      DEPENDS
        ${TWX_${PROJECT_NAME}_INI}
      COMMENT
        "Update ${PROJECT_NAME} factory Cfg information"
    )
    # We need the contents before the first build
    twx_cfg_update_factory ()

    twx_cfg_path ( path_git_twx ID "git" )
    add_custom_command(
      OUTPUT ${path_git_twx}
      COMMAND "${CMAKE_COMMAND}"
        "-DPROJECT_NAME=${PROJECT_NAME}"
        "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
        "-DTWX_PROJECT_BUILD_DATA_DIR=${TWX_PROJECT_BUILD_DATA_DIR}"
        "-DTWX_VERBOSE=${TWX_VERBOSE}"
        "-DTWX_TEST=${TWX_TEST}"
        "-DTWX_DEV=${TWX_DEV}"
        -P "${TWX_DIR}/CMake/Command/TwxCfg_git.cmake"
      DEPENDS
        ${path_factory_twx}
      COMMENT
        "Update ${PROJECT_NAME} git Cfg information"
    )
    # We also need the contents before the first build
    twx_cfg_update_git ()

    add_custom_target (
      TwxCfg_${PROJECT_NAME}_target ALL
      DEPENDS ${path_git_twx}
    )
  endif ()
endmacro ()

# ANCHOR: Utility `twx_cfg_write_begin`
#[=======[
*//** @brief Start a cfg write sequence

Must be balanced by a `twx_cfg_write_end()` instruction
with the same <id>. This will write the cfg data file.
Usage:
```
twx_cfg_write_begin ( ID foo )
twx_cfg_set ( ID foo <key_1> <value_1> )
...
twx_cfg_set ( ID foo <key_n> <value_n> )
twx_cfg_write_end ( ID foo )
```

@param id is a unique identifier. In practice, one of
  "static", "git", "paths"... Is is stored in
  `TWX_CURRENT_ID_CFG` to be used by forthcoming `twx_cfg_set` 
  and `twx_cfg_end`.

@note
  - These write environments can be nested as long as
    each time a different id is used.
  - If we use the same id in a subsequent write environment,
    the former will be overwritten.
  - Things happen in the current variable scope.
*/
twx_cfg_write_begin ( ID id ) {}
/** @brief Reserved variable*/ cfg_keys_<id>_twx;
/** @brief Reserved variable*/ cfg_values_<id>_twx;
/*
#]=======]
macro ( twx_cfg_write_begin ID my_twx_ID )
  twx_assert_equal ( ID ${ID} )
  if ( DEFINED cfg_keys_${my_twx_ID}_twx )
    message ( FATAL_ERROR "Missing `twx_cfg_write_end( ID ${my_twx_ID} )`" )
  endif ()
  set ( cfg_keys_${my_twx_ID}_twx )
  set ( cfg_values_${my_twx_ID}_twx )
  set ( TWX_CURRENT_ID_CFG "${my_twx_ID}" )
endmacro ()

# ANCHOR: Utility `twx_cfg_set`
#[=======[
*//** @brief Set a cfg key/value pair
@param id is the id of a `twx_cfg_write_begin` previous command.
  When not provided it defaults to the value of `TWX_CURRENT_ID_CFG`.
@param key a spaceless key, usually uppercase
@param ... a possibly empty list of stringsstring, one line only
*/
twx_cfg_set ( [ID id] key, ... ) {}
/*
Feed `cfg_keys_<id_>_twx` with `<key>` and `cfg_values_<id_>_twx` with `<value>`.
#]=======]
function ( twx_cfg_set ID id_ )
  if ( "${ID}" STREQUAL "ID")
    if ( "${ARGN}" STREQUAL "" )
      message ( FATAL_ERROR "Internal error in twx_cfg_set: missing key" )
    endif ()
    list ( GET ARGN 0 key_ )
    list ( REMOVE_AT ARGN 0 )
    set ( value_ "${ARGN}" )
  else ()
    set ( key_ "${ID}" )
    list ( INSERT ARGN 0 "${id_}" )
    set ( value_ "${ARGN}" )
    set ( id_ "${TWX_CURRENT_ID_CFG}" )
  endif ()
  list ( APPEND cfg_keys_${id_}_twx "${key_}" )
  string ( REPLACE ";" "{{{semicolon}}}" value_ "${value_}" )
  list ( APPEND cfg_values_${id_}_twx "<${value_}>" )
  twx_message_verbose ( STATUS "TWXCfg(${id_}): ${key_} => <${value_}>" )
  twx_export ( cfg_keys_${id_}_twx )
  twx_export ( cfg_values_${id_}_twx )
endfunction ()

# ANCHOR: Utility `twx_cfg_write_end`
#[=======[
*//** @brief balance previous `twx_cfg_write_begin()`

Write the data recorded so far with the give id.

@param id for key ID, optional, defines the storage location through `twx_cfg_path ()`.
*/
twx_cfg_write_end ( [ID id] ) {}
/*
#]=======]
function ( twx_cfg_write_end )
  twx_parse_arguments ( "" "ID" "" ${ARGN} )
  twx_assert_parsed ()
  if ( "${my_twx_ID}" STREQUAL "" )
    set ( my_twx_ID "${TWX_CURRENT_ID_CFG}" )
  endif ()
  twx_cfg_path ( path_ ID "${my_twx_ID}" )
  if ( NOT ";${${PROJECT_NAME}_TWX_CFG_IDS};" MATCHES ";${path_};" )
    list ( APPEND ${PROJECT_NAME}_TWX_CFG_IDS ${path_})
  endif()
  set_property(
    DIRECTORY 
    APPEND 
    PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${path_}
  )
  string ( TIMESTAMP t UTC )
  set (
    contents_ "\
;READ ONLY
;${t}
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${my_twx_ID} informations]
"
  )
  # find the largest key for pretty printing
  set ( length 0 )
  foreach ( key_ IN LISTS cfg_keys_${my_twx_ID}_twx )
    string ( LENGTH "${key_}" l )
    if ( l GREATER length )
      set ( length "${l}" )
    endif ()
  endforeach ()
  # Set the contents
  while ( NOT "${cfg_keys_${my_twx_ID}_twx}" STREQUAL "" )
    list ( GET cfg_keys_${my_twx_ID}_twx 0 key_ )
    list ( REMOVE_AT cfg_keys_${my_twx_ID}_twx 0 )
    if ( "${cfg_values_${my_twx_ID}_twx}" STREQUAL "" )
      message ( FATAL_ERROR "Internal inconsistency: <${key_}>")
    endif ()
    string ( LENGTH "${key_}" l )
    math ( EXPR l "${length}-${l}" )
    if ( l GREATER 0 )
      foreach (i RANGE 1 ${l} )
        string ( APPEND key_ " " )
      endforeach ()
    endif ()
    list ( GET cfg_values_${my_twx_ID}_twx 0 value_ )
    list ( REMOVE_AT cfg_values_${my_twx_ID}_twx 0 )
    string ( REPLACE "{{{semicolon}}}" ";" value_ "${value_}" )
    if ( "${value_}" MATCHES "^<(.*)>$" )
      set ( value_ "${CMAKE_MATCH_1}" )
    endif ()
    set (
      contents_
      "${contents_}${key_} = ${value_}\n"
    )
  endwhile ()
  # write the file
  twx_message_verbose ( STATUS "Writing ${path_}" )
  file (
    WRITE
    "${path_}(busy)"
    "${contents_}"
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E compare_files
    "${path_}(busy)"
    "${path_}"
    RESULT_VARIABLE ans
  )
  if ( ans GREATER 0 )
    file ( RENAME "${path_}(busy)" "${path_}" )
    message ( STATUS "Updated: ${path_}" )
  else ()
    file ( REMOVE "${path_}(busy)" )
  endif ()
  unset ( cfg_keys_${my_twx_ID}_twx   PARENT_SCOPE )
  unset ( cfg_values_${my_twx_ID}_twx PARENT_SCOPE )
  # Now we cand start another write sequence
endfunction ()

# ANCHOR: Utility `twx_cfg_read`
#[=======[
*//** @brief Parse Cfg data files

Parses the file lines matching `<key> = <value>`.
`<key>` contains no `=` nor space character, it is not empty whereas
`<value>` can be empty.
Set `twx_cfg_<key>` to `<value>`.

@param ... optional list of id or full path.
  When not provided, the `<PROJECT_NAME>_TWX_CFG_IDS` is used instead.
  When this list is empty, all available Cfg data files are read,
  from the older to the newer. Each file is encoded in UTF-8
@param LISTS optional key followed by variables containing lists of ids
@param QUIET optional key, no error is raised when provided but `TWX_CFG_READ_FAILED` is set when the read failed and no more than one file is read.
@param ONLY_CONFIGURE optional key, no `TWX_<project_name>_<key>`
is set when provided
@param NO_PRIVATE optional key, private `...cfg.ini` files are ignored.
*/
twx_cfg_read ( ... [LISTS lists] [QUIET] [ONLY_CONFIGURE]) {}
/*
#]=======]
function ( twx_cfg_read )
  set ( TWX_CFG_READ_FAILED OFF )
  twx_parse_arguments (
    "QUIET;ONLY_CONFIGURE;NO_PRIVATE" "" "LISTS"
    ${ARGN}
  )
  # core ids or absolute paths: mixed
  set ( cfg_ini_mixed_ "${my_twx_UNPARSED_ARGUMENTS}" )
  foreach ( l IN LISTS my_twx_LISTS )
    list ( APPEND cfg_ini_mixed_ "${l_}" )
  endforeach ()
  if ( "${cfg_ini_mixed_}" STREQUAL "" )
    # No file path or name provided:
    # take it all, declared or not
    twx_assert_non_void ( PROJECT_BINARY_DIR )
    twx_assert_non_void ( PROJECT_NAME )
    list ( APPEND cfg_ini_mixed_ "${${PROJECT_NAME}_TWX_CFG_IDS}" )
    if ( "${cfg_ini_mixed_}" STREQUAL "" )
      twx_cfg_path ( glob_ ID "*" )
      # TODO: what happend if it contains more than one '*'?
      file ( GLOB cfg_ini_mixed_ "${glob_}" )
      if ( "${cfg_ini_mixed_}" STREQUAL "" )
        message ( FATAL_ERROR "No known id in ${cfg_ini_mixed_}\nARGN:${ARGN}" )
      endif ()
    endif ()
  endif ()
# unmix
  set ( cfg_ini_unordered_ )
  foreach ( id_ IN LISTS cfg_ini_mixed_ )
    twx_cfg_path ( p_ ID "${id_}" )
    if ( NOT EXISTS "${p_}" )
      if ( my_twx_QUIET )
        set ( TWX_CFG_READ_FAILED ON PARENT_SCOPE )
        return ()
      else ()
        message ( FATAL_ERROR "No file at ${p_}")
      endif ()
      # readability is not tested
    endif ()
    if ( my_twx_NO_PRIVATE )
      get_filename_component ( n_ "${p_}" NAME )
      if ("${n_}" MATCHES "private" )
        continue ()
      endif ()
    endif ()
    list ( APPEND cfg_ini_unordered_ "${p_}" )
  endforeach ()
  # older files first:
  set ( cfg_ini_ordered_ )
  while ( NOT "${cfg_ini_unordered_}" STREQUAL "" )
    list ( GET cfg_ini_unordered_ 0 older_ )
    foreach ( item IN LISTS cfg_ini_unordered_ )
      if ( ${older_} IS_NEWER_THAN ${item} )
        set ( older_ ${item} )
      endif ()
    endforeach ()
    list ( REMOVE_ITEM cfg_ini_unordered_ ${older_} )
    # filter out the `private` cfg.ini files if requested
    list ( APPEND cfg_ini_ordered_ ${older_} )
  endwhile ()
  # Parse the files
  foreach ( name_ IN LISTS cfg_ini_ordered_ )
    twx_message_verbose ( STATUS "twx_cfg_read: ${name_}" )
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
        if ( TWX_VERBOSE )
          message ( "TWX_CFG_${CMAKE_MATCH_1} => ${CMAKE_MATCH_2}" )
        endif ()
        if ( NOT name_ STREQUAL "" AND NOT my_twx_ONLY_CONFIGURE )
          set (
            TWX_${PROJECT_NAME}_CFG_${CMAKE_MATCH_1}
            "${CMAKE_MATCH_2}"
            PARENT_SCOPE
          )
        endif ()
      endif ()
    endforeach ( line IN LISTS lines )
    if ( my_twx_ONLY_CONFIGURE )
      twx_core_timestamp (
        "${name_}"
        ${name_}_TWX_TIMESTAMP_CFG
      )
    endif ()
    if ( my_twx_QUIET )
      return ()
    endif ()
  endforeach ( name_ IN LISTS cfg_ini_ordered_ )
endfunction ( twx_cfg_read )

# ANCHOR: twx_cfg_target_dependent
#[=======[
*//** @brief Make targets dependent of cfg data files

All the targets that rely on the cfg technology should be dependent.
This allows to rebuild the target each time the cfg data files are modified.

Usage:
```
twx_cfg_target_dependent ( target_i ... [ID id_j ...])
```
It makes each target given by its name dependent of each id given.
If no id is provided, the `TWX_<project name>_IDS_CFG` is used instead.
Of course "ID" is not allowed as target name.

UNUSED.

@param ... is the list of the dependent target.
@param ... after the ID is the list of the dependency id.
*/
twx_cfg_target_dependent ( ... ) {}
/*
#]=======]
function (twx_cfg_target_dependent )
  set ( targets_ )
  set ( ids_ )
  while ( NOT "${ARGN}" STREQUAL "" )
    list ( GET ARGN 0 item_ )
    list ( REMOVE_AT ARGN 0 )
    if ( ${item_} STREQUAL "ID" )
      while ( NOT "${ARGN}" STREQUAL "" )
        list ( GET ARGN 0 item_ )
        list ( REMOVE_AT ARGN 0 )
        list ( APPEND ids_ "${item_}" )
      endwhile ()
    else ()
      list ( APPEND targets_ "${item_}" )
    endif ()
  endwhile ()
  set_property(
    TARGET ${ARGN} 
    APPEND 
    PROPERTY SOURCES
    ${path_}
  )
endfunction ()

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
  twx_cfg_path ( TWX_path ID "${_name}" )
  if ( EXISTS "${TWX_path}" )
    unset ( TWX_path )
    return ()
  endif ()
  unset ( TWX_path )
endmacro ()
#*/
