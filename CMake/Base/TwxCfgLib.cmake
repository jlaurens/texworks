#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Cfg data writer and reader.
  * 
  * Low level controller to read, build and write Cfg data.
  * A Cfg data file is quite like an INI file, hence the file extension used.
  * It is saved in the `TwxBuildData` subfolder of the main binary directory
  * of the project. It will be used to define the replacement macros
  * embedded in `configure_file` input.
  * 
  * There are at least 2 cfg ini data files for names "factory" and "git".
  * The later needs to be updated each time. It is associate to a target.
  * This target is the very first one created by a call to `twx_cfg_setup`.
  * Its name is `twx_cfg_target`. It also holds the shared location of all the
  * cfg ini data files as property `TWX_CFG_INI_DIR`.
  * 
  * Usage:
  * ```
  * include ( TwxCfgLib )
  * ```
  * 
  * The cache is not always suitable to store values because
  * the CMake scoping rules do not allow any kind of logical scope.
  */
/*
NB: We need high control and cannot benefit from
QSettings.
#]===============================================]

#[=======[
*/
/**
  * @brief Truthy c++ value
  * 
  * Expression used inside `.in.cpp` files for a thuthy value.
  */
TWX_CPP_TRUTHY_CFG;
/*
#]=======]
set (
  TWX_CPP_TRUTHY_CFG 1
)

#[=======[
*/
/**
  * @brief Falsy c++ value
  * 
  * Expression used inside `.in.cpp` files for a falsy value.
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
*/
/**
  * @brief Get the standard location for Cfg data files
  * 
  * @param id for key `ID`, a required spaceless string, the storage location is
  *   `<cfg_ini_dir>/<project_name>_<id>.ini` (or `.stamped`)
  *   If a file at `<id>` exists, it is the returned location.
  * @param var for key `IN_VAR`, name of the variable that contains the result on return.
  * @param `STAMPED` optional flag, when provided change the
  *   `ini` file extension for `stamped`.
  */
twx_cfg_path ( ID id IN_VAR var [STAMPED] ) {}
/*
#]=======]
function ( twx_cfg_path )
  cmake_parse_arguments ( PARSE_ARGV 4 twxR "STAMPED" "ID;IN_VAR" "" )
  twx_arg_assert_parsed ()
  twx_assert_variable ( "${twxR_IN_VAR}")
  if ( EXISTS "${twxR_ID}" )
    twx_export ( "${twxR_IN_VAR}=${twxR_ID}" )
    return ()
  endif ()
  twx_assert_non_void ( TWX_CFG_INI_DIR )
  twx_assert_non_void ( twxR_ID )
  if ( twxR_STAMPED )
    set ( extension "stamped" )
  else ()
    set ( extension "ini" )
  endif ()
  twx_export (
    "${twxR_IN_VAR}=${TWX_CFG_INI_DIR}TwxCfg_${twxR_ID}.${extension}"
  )
endfunction ( twx_cfg_path )

# ANCHOR: `twx_cfg_update_factory`
#[=======[
*/
/** @brief Update the factory Cfg data file
  *
  * Launch the `TwxCfg_factory.cmake` command.
  */
twx_cfg_update_factory ( ) {}
/*
#]=======]
macro ( twx_cfg_update_factory )
  twx_message ( VERBOSE
    "twx_cfg_update_factory: ${TWX_FACTORY_INI}"
  )
  twx_assert_non_void ( TWX_CFG_INI_DIR )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_NAME=${TWX_NAME}"
      "-DTWX_FACTORY_INI=${TWX_FACTORY_INI}"
      "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
      "${TWX-D_STATE}"
      -P "${TWX_DIR}CMake/Command/TwxCfg_factory.cmake"
    RESULT_VARIABLE twx_cfg_update_factory.result
  )
  twx_assert_0 ( "${twx_cfg_update_factory.result}" )
  unset ( twx_cfg_update_factory.result )
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
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
      "${TWX-D_STATE}"
      -P "${TWX_DIR}CMake/Command/TwxCfg_git.cmake"
  )
  twx_cfg_read ( "git" )
endmacro ()

# ANCHOR: Utility `twx_cfg_target`
#[=======[
*/
/** @brief The cfg target name
  *
  * Unused.
  * @param var for key `IN_VAR`, required name of the variable that holds the result on return.
  * @param id for key `ID`, required identifier, unique per cmake session.
  */
twx_cfg_target ( ID id IN_VAR var ) {}
/*
#]=======]
function ( twx_cfg_target )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "ID;IN_VAR" "" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twxR_ID )
  twx_assert_variable ( "${twxR_IN_VAR}" )
  set ( ${twxR_IN_VAR} "TwxCfg_${twxR_ID}_target" PARENT_SCOPE)
endfunction ()

# ANCHOR: twx_cfg_setup
#[=======[
*/
/** @brief Setup the current project to use Cfg
  *
  * Find the proper `<project name>.ini` file, usually in the
  * `PROJECT_SOURCE_DIR`, and put the path in `TWX_FACTORY_INI`.
  * Bypass this behavior by providing a path to an existing file in the
  * `TWX_FACTORY_INI` variable prior to calling `twx_cfg_setup`.
  *
  * When not in script mode and on the first call,
  * creates 2 commands to build the shared "factory" and "git" Cfg data files.
  * Add a target to allways rebuild git related Cfg data.
  * 
  * Then "factory" and "git" Cfg metadata files are always updated
  * with `twx_cfg_update_factory ()` and `twx_cfg_update_git ()`
  * such that their contents is available in the current variable scope.
  * Finally `TWX_FACTORY_INI` and `TWX_CFG_INI_DIR`
  * are exported just before the function returns.
  * 
  * Used at least once per project that needs `configuration_file`.
  * 
  * See twx_cfg_read().
  * 
  * The `TWX_TEST`, `CMAKE_MESSAGE_LOG_LEVEL` and `TWX_DEV` variables are propagated
  * to the command.
  */
twx_cfg_setup () {}
/** @brief Location of the factory ini file
  *
  * By default it is `<root>/TeXworks.ini` or `<root>/TeXworks-dev.ini`,
  * whether we are in development mode or not.
  * It is set lazily by the `twx_cfg_setup()` instruction.
  *
  * When testing, this variable must eventually be set before
  * `twx_cfg_setup()` is called. In practice, it is set before
  * `twx_module_setup()` is called by the `/modules/TwxCore/Test/`
  * subdirectory. The value is then the absolute location of
  * a `TeXworks-test.ini` file.
  *
  * See `ref(TWX_CFG_INI_DIR)`.
  */
TWX_FACTORY_INI;
/*
#]=======]
function ( twx_cfg_setup )
  twx_assert_non_void ( PROJECT_NAME TWX_PROJECT_BUILD_DATA_DIR )
  set ( TWX_CFG_INI_DIR "${TWX_PROJECT_BUILD_DATA_DIR}" )
  if ( "${TWX_FACTORY_INI}" STREQUAL "" )
    set (
      TWX_FACTORY_INI
      "${TWX_DIR}${TWX_NAME}.ini"
    )
    twx_assert_exists ( TWX_FACTORY_INI )
    set ( target_twx TwxCfg )
  else ()
    twx_assert_exists ( TWX_FACTORY_INI )
    set ( target_twx "TwxCfg_${PROJECT_NAME}" )
  endif ()
  twx_message ( VERBOSE
    "twx_cfg_setup target: ${target_twx}"
    DEEPER
  )
  twx_message ( VERBOSE
    "TWX_FACTORY_INI => ${TWX_FACTORY_INI}"
    "TWX_CFG_INI_DIR => ${TWX_CFG_INI_DIR}"
  )
  if ( TARGET "${target_twx}" OR NOT "${CMAKE_SCRIPT_MODE_FILE}" STREQUAL "" )
    twx_cfg_update_factory ()
    twx_cfg_update_git ()
    twx_export ( TWX_FACTORY_INI TWX_CFG_INI_DIR )
    return ()
  endif ()
  set_property (
    DIRECTORY
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${TWX_FACTORY_INI}
  )
  if ( COMMAND add_custom_command )
    twx_cfg_path ( ID "factory" IN_VAR path_factory_twx )
    twx_state_serialize ()
    add_custom_command (
      OUTPUT ${path_factory_twx}
      COMMAND "${CMAKE_COMMAND}"
        "-DTWX_NAME=${TWX_NAME}"
        "-DTWX_FACTORY_INI=${TWX_FACTORY_INI}"
        "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
        "${TWX-D_STATE}"
        -P "${TWX_DIR}CMake/Command/TwxCfg_factory.cmake"
      DEPENDS
        ${TWX_FACTORY_INI}
      COMMENT
        "Update factory Cfg information"
    )
    twx_cfg_path ( ID "git" IN_VAR path_git_twx )
    twx_state_serialize ()
    add_custom_command (
      OUTPUT ${path_git_twx}
      COMMAND "${CMAKE_COMMAND}"
        "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
        "${TWX-D_STATE}"
        -P "${TWX_DIR}CMake/Command/TwxCfg_git.cmake"
      DEPENDS
        ${path_factory_twx}
      COMMENT
        "Update git Cfg information"
    )
    add_custom_target (
      "${target_twx}" ALL
      DEPENDS ${path_git_twx}
    )
  endif ()
  twx_cfg_update_factory ()
  twx_cfg_update_git ()
  twx_export ( TWX_FACTORY_INI TWX_CFG_INI_DIR )
endfunction ( twx_cfg_setup )

# SECTION: Cfg ini file
# ANCHOR: twx_cfg_write_begin
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
macro ( twx_cfg_write_begin ID. twxR_ID )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_arg_assert_keyword ( ID )
  if ( DEFINED cfg_kv_${twxR_ID}_twx )
    twx_fatal ( "Missing `twx_cfg_write_end( ID ${twxR_ID} )`" )
    return ()
  endif ()
  set ( cfg_kv_${twxR_ID}_twx )
  set ( TWX_CURRENT_ID_CFG "${twxR_ID}" )
endmacro ()

# ANCHOR: twx_cfg_set
#[=======[
*/
/** @brief Set a cfg <key>=<value> assignment
  *
  * @param id is the id of a `twx_cfg_write_begin` previous command.
  *   When not provided it defaults to the value of `TWX_CURRENT_ID_CFG`.
  * @param key a spaceless key, usually uppercase
  * @param ... a non empty list of `<key>=<value>` arguments
  */
twx_cfg_set ( [ID id] key, ... ) {}
/*
Feed `cfg_kv_<id_>_twx` with `<key>` with `<key>=<value>`.
#]=======]
set (
  TWX_CFG_SEMICOLON_PLACEHOLDER
  "${TWX_CHAR_STX}semicolon${TWX_CHAR_ETX}"
)
function ( twx_cfg_set ID_ )
  if ( "${ID}" STREQUAL "ID")
    twx_arg_assert_count ( ${ARGC} > 2 )
    set ( id_ "${ARGV1}" )
    set ( i 2 )
  else ()
    set ( i 0 )
    set ( id_ "${TWX_CURRENT_ID_CFG}" )
  endif ()
  while ( TRUE )
    set ( kv "${ARGV${i}}" )
    twx_assert_kv ( "${kv}" )
    string ( REPLACE ";" "${TWX_CFG_SEMICOLON_PLACEHOLDER}" kv "${kv}" )
    list ( APPEND cfg_kv_${id_}_twx "${kv}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_export ( cfg_kv_${id_}_twx )
endfunction ()

# ANCHOR: twx_cfg_write_end
#[=======[
*//** @brief balance previous `twx_cfg_write_begin()`

Write the data recorded so far with the give id.

@param id for key `ID`, optional, defines the storage location through `twx_cfg_path ()`.
*/
twx_cfg_write_end ( [ID id] ) {}
/*
#]=======]
function ( twx_cfg_write_end )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "ID" "" )
  twx_arg_assert_parsed ()
  if ( "${twxR_ID}" STREQUAL "" )
    set ( twxR_ID "${TWX_CURRENT_ID_CFG}" )
  endif ()
  if ( "${twxR_ID}" STREQUAL "_private" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()  
  twx_cfg_path ( ID "${twxR_ID}" IN_VAR path_ )
  if ( NOT ";${${PROJECT_NAME}_TWX_CFG_IDS};" MATCHES ";${path_};" )
    list ( APPEND ${PROJECT_NAME}_TWX_CFG_IDS ${path_})
  endif()
  set_property(
    DIRECTORY
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${path_}
  )
  set (
    contents_ "\
;READ ONLY
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${twxR_ID} informations]
"
  )
  # Expose the keys and the values separately.
  # and find the largest key for pretty printing
  set ( length_ 0 )
  set ( keys_ )
  foreach ( kv ${cfg_keys_${twxR_ID}_twx} )
    string ( REPLACE "${TWX_CFG_SEMICOLON_PLACEHOLDER}" ";" kv "${kv}" )
    twx_split ( "${kv}" IN_KEY k IN_VALUE v )
    twx_assert_defined ( k )
    string ( LENGTH "${k}" l )
    if ( "${l}" GREATER "${length_}" )
      set ( length_ "${l}" )
    endif ()
    list ( APPEND keys "${k}" )
    set ( "${k}_value" "${v}" )
  endforeach ()
  # Set the contents
  foreach ( key_ ${keys_} )
    string ( LENGTH "${key_}" l )
    math ( EXPR l "${length_}-${l}" )
    if ( "${l}" GREATER "0" )
      foreach (i RANGE 1 ${l} )
        string ( APPEND key_ " " )
      endforeach ()
    endif ()
    string ( APPEND contents_ "${key_} = ${${key_}_value}\n" )
  endwhile ()
  # write the file
  twx_message ( VERBOSE "twx_cfg_write_end:" DEEPER )
  twx_message ( VERBOSE "Writing ${path_}" )
  file ( WRITE "${path_}(busy)" "${contents_}" )
  if ( NOT EXISTS "${path_}(busy)" )
    twx_fatal ( "Could not create ${path_}(busy)" )
    return ()
  endif ()
  set ( ans_twx )
  execute_process (
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${path_}(busy)"
      "${path_}"
    RESULT_VARIABLE ans_twx
  )
  if ( NOT "${ans_twx}" EQUAL "0" )
    twx_message ( VERBOSE WARNING "copy_if_different: ans_twx => ${ans_twx}" )
  endif ()
  if ( NOT EXISTS "${path_}" )
    twx_fatal ( "Could not create ${path_}" )
    return ()
  endif ()
  execute_process (
    COMMAND ${CMAKE_COMMAND} -E remove
      "${path_}(busy)"
    RESULT_VARIABLE ans_twx
  )
  unset ( cfg_kv_${twxR_ID}_twx PARENT_SCOPE )
  # Now we can start another write sequence in the parent scope
endfunction ()

# ANCHOR: twx_cfg_read
#[=======[
*/
/** @brief Parse Cfg data files
  *
  * Central function.
  * Parses the file lines matching `<key> = <value>`.
  * `<key>` contains no `=` nor space character, it is not empty whereas
  * `<value>` can be empty.
  * Set `twx_cfg_<key>` to `<value>`.
  * 
  * @param ... optional list of id or full path.
  *   When not provided, the `<PROJECT_NAME>_TWX_CFG_IDS` is used instead.
  *   When this list is empty, all available Cfg data files are read,
  *   from the older to the newer. Each file is encoded in UTF-8
  * @param `QUIET` optional key, no error is raised when provided but `TWX_CFG_READ_FAILED` is set when the read failed and no more than one file is read.
  * @param `ONLY_CONFIGURE` optional key, no `TWX_<project_name>_<key>`
  * is set when provided
  * @param `NO_PRIVATE` optional key, private `...cfg.ini` files are ignored.
  */
twx_cfg_read ( ... [QUIET] [ONLY_CONFIGURE]) {}
/*
#]=======]
function ( twx_cfg_read )
  set ( TWX_CFG_READ_FAILED OFF )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_R
    "QUIET;ONLY_CONFIGURE;NO_PRIVATE" "" ""
  )
  # core ids or absolute paths: mixed
  set ( cfg_ini_mixed_ "${twxR_UNPARSED_ARGUMENTS}" )
  if ( "${cfg_ini_mixed_}" STREQUAL "" )
    # No file path or name provided:
    # take it all, declared or not
    twx_assert_non_void ( TWX_CFG_INI_DIR )
    if ( NOT PROJECT_NAME STREQUAL "" )
      set ( cfg_ini_mixed_ "${${PROJECT_NAME}_TWX_CFG_IDS}" )
    endif ()
    if ( "${cfg_ini_mixed_}" STREQUAL "" )
      twx_cfg_path ( ID "*" IN_VAR glob_ )
      # TODO: what happend if it contains more than one '*'?
      file ( GLOB cfg_ini_mixed_ "${glob_}" )
      if ( "${cfg_ini_mixed_}" STREQUAL "" )
        twx_fatal ( "No known id in ${cfg_ini_mixed_}\nARGV:${ARGV}" )
        return ()
      endif ()
    endif ()
  endif ()
# unmix
  set ( cfg_ini_unordered_ )
  foreach ( id_ ${cfg_ini_mixed_} )
    twx_cfg_path ( ID "${id_}" IN_VAR p_ )
    if ( NOT EXISTS "${p_}" )
      if ( twxR_QUIET )
        set ( TWX_CFG_READ_FAILED ON PARENT_SCOPE )
        return ()
      else ()
        twx_fatal ( "No file at ${p_}")
        return ()
      endif ()
      # readability is not tested
    endif ()
    if ( twxR_NO_PRIVATE )
      get_filename_component ( n_ "${p_}" NAME )
      if ("${n_}" MATCHES "private" )
        continue ()
      endif ()
    endif ()
    list ( APPEND cfg_ini_unordered_ "${p_}" )
  endforeach ()
  # older files first:
  set ( cfg_ini_ordered_ )
  while ( NOT cfg_ini_unordered_ STREQUAL "" )
    list ( GET cfg_ini_unordered_ 0 older_ )
    foreach ( item ${cfg_ini_unordered_} )
      if ( ${older_} IS_NEWER_THAN ${item} )
        set ( older_ ${item} )
      endif ()
    endforeach ()
    list ( REMOVE_ITEM cfg_ini_unordered_ ${older_} )
    # filter out the `private` cfg.ini files if requested
    list ( APPEND cfg_ini_ordered_ ${older_} )
  endwhile ()
  # Parse the files
  twx_message ( DEBUG "twx_cfg_read:" DEEPER )
  foreach ( name_ ${cfg_ini_ordered_} )
    twx_message ( DEBUG "Reading: ${name_}" )
    file (
      STRINGS "${name_}"
      lines
      REGEX "="
      ENCODING UTF-8
    )
    set ( count_ 0 )
    foreach ( l ${lines} )
      if ( l MATCHES "^[ ]*([^ =]+)[ ]*=(.*)$" )
        string ( STRIP "${CMAKE_MATCH_2}" CMAKE_MATCH_2 )
        twx_message ( DEBUG "TWX_CFG_${CMAKE_MATCH_1} => ${CMAKE_MATCH_2}" )
        set (
          TWX_CFG_${CMAKE_MATCH_1}
          "${CMAKE_MATCH_2}"
          PARENT_SCOPE
        )
        if ( NOT name_ STREQUAL "" AND NOT twxR_ONLY_CONFIGURE )
          set (
            TWX_${PROJECT_NAME}_CFG_${CMAKE_MATCH_1}
            "${CMAKE_MATCH_2}"
            PARENT_SCOPE
          )
        endif ()
        math ( EXPR count_ "${count_}+1" )
      endif ()
    endforeach ( l )
    if ( twxR_ONLY_CONFIGURE )
      twx_core_timestamp (
        "${name_}"
        ${name_}_TWX_TIMESTAMP_CFG
      )
    endif ()
    twx_message ( DEBUG "Read: ${count_} records in ${name_}" )
    if ( twxR_QUIET )
      return ()
    endif ()
  endforeach ( name_ )
endfunction ( twx_cfg_read )
# !SECTION

# ANCHOR: twx_cfg_target_dependent
#[=======[
*/
/** @brief Make targets dependent of cfg data files
  *
  * All the targets that rely on the cfg technology should be dependent.
  * This allows to rebuild the target each time the cfg data files are modified.
  *
  * Usage:
  * ```
  * twx_cfg_target_dependent ( target_i ... [ID id_j ...])
  * ```
  * It makes each target given by its name dependent of each id given.
  * If no id is provided, the `TWX_<project name>_IDS_CFG` is used instead.
  * Of course "ID" is not allowed as target name.
  *
  * UNUSED AND FALSE.
  * 
  * @param ... is the list of the dependent target.
  * @param ... after the ID is the list of the dependency id.
  */
twx_cfg_target_dependent ( ... ) {}
/*
#]=======]
function (twx_cfg_target_dependent )
  set ( targets_ )
  set ( ids_ )
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    if ( v STREQUAL ID )
      while ( TRUE )
        twx_increment_and_break_if ( VAR i >= ${ARGC} )
        list ( APPEND ids_ "${v}" )
      endwhile ()
      break ()
    endif ()
    list ( APPEND targets_ "${v}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
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
macro ( twx_cfg_return_if_exists _name )
  twx_cfg_path ( ID "${_name}" IN_VAR twx_cfg_return_if_exists.path )
  if ( EXISTS "${twx_cfg_return_if_exists.path}" )
    unset ( twx_cfg_return_if_exists.path )
    return ()
  endif ()
  unset ( twx_cfg_return_if_exists.path )
endmacro ()

#[=======[
External functions and constants
twx_arg_assert_parsed
twx_assert_variable
twx_export
twx_assert_non_void
twx_message
twx_state_serialize
twx_assert_0
twx_assert_exists
twx_expect_equal
twx_fatal
twx_increment_and_break_if
#]=======]

include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxAssertlib.cmake"
)
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxExpectlib.cmake"
)
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxStatelib.cmake"
)
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxMessagelib.cmake"
)
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxCorelib.cmake"
)

#*/
