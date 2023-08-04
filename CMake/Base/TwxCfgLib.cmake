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

include_guard ( GLOBAL )
twx_lib_will_load ()

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
function ( twx_cfg_path .ID .id .IN_VAR .var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_path" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "STAMPED" "ID;IN_VAR" ""
  )
  twx_arg_assert_parsed ()
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  if ( EXISTS "${twx.R_ID}" )
    twx_export ( "${twx.R_IN_VAR}=${twx.R_ID}" )
    return ()
  endif ()
  twx_assert_exists ( "${TWX_CFG_INI_DIR}" )
  twx_assert_non_void ( twx.R_ID )
  if ( twx.R_STAMPED )
    set ( extension "stamped" )
  else ()
    set ( extension "ini" )
  endif ()
  twx_export (
    "${twx.R_IN_VAR}=${TWX_CFG_INI_DIR}TwxCfg_${twx.R_ID}.${extension}"
  )
endfunction ( twx_cfg_path )

# ANCHOR: TWX_CFG_INI_REQUIRED_KEYS
#[=======[*/
/* UNEXPOSED *  @brief List of required keys
  *
  * Exposed for testing purposes only.
  */
TWX_CFG_INI_REQUIRED_KEYS;
/*#]=======]
set (
  TWX_CFG_INI_REQUIRED_KEYS
    # VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
    # COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
    # ORGANIZATION_DOMAIN ORGANIZATION_NAME ORGANIZATION_SHORT_NAME
    # POPPLER_DATA_URL POPPLER_DATA_SHA256 URW35_FONTS_URL
    # MANUAL_HTML_URL MANUAL_HTML_SHA256
    # URL_HOME URL_HOME_DEV URL_ISSUES URL_GPL MAIL_ADDRESS
)

# ANCHOR: twx_cfg_ini_required_key_add
#[=======[
*/
/** @brief Add required keys to INI files
  *
  * @param ... non empty list of keys.
  */
twx_cfg_ini_required_key_add (...) {}
/*
#]=======]
function ( twx_cfg_ini_required_key_add .k )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_ini_required_key_add" )
  twx_message ( DEBUG "ARGV => ``${ARGV}''" )
  list ( APPEND TWX_CFG_INI_REQUIRED_KEYS ${ARGV} )
  list ( REMOVE_DUPLICATES TWX_CFG_INI_REQUIRED_KEYS )
  twx_export ( TWX_CFG_INI_REQUIRED_KEYS )
endfunction ()

# ANCHOR: twx_cfg_ini_required_key_remove
#[=======[
*/
/** @brief Remove required keys to INI files
  *
  * @param ... non empty list of keys.
  */
twx_cfg_ini_required_key_remove (...) {}
/*
#]=======]
function ( twx_cfg_ini_required_key_remove .k )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_ini_required_key_remove" )
  twx_message ( DEBUG "ARGV => ``${ARGV}''" )
  list ( REMOVE_ITEM TWX_CFG_INI_REQUIRED_KEYS ${ARGV} )
  twx_export ( TWX_CFG_INI_REQUIRED_KEYS )
endfunction ()

# ANCHOR: twx_cfg_register_hooked
#[=======[
*/
/** @brief Register a function
  *
  * @param ... non empty list of command names.
  * Signature is empty.
  */
twx_cfg_register_hooked (...) {}
/*
#]=======]
function ( twx_cfg_register_hooked .k )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_register_hooked" )
  twx_hook_register ( ID TwxCfgLib ${ARGV} )
  twx_hook_export ()
endfunction ()

# ANCHOR: twx_cfg_update_factory
#[=======[
*/
/** @brief Update the factory Cfg data file
  *
  * Launch the `TwxCfgFactoryScript.cmake` command.
  */
twx_cfg_update_factory() {}
/*
#]=======]
macro ( twx_cfg_update_factory )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_update_factory" )
  twx_message ( VERBOSE
    "twx_cfg_update_factory: ${TWX_FACTORY_INI}"
  )
  twx_assert_exists ( "${TWX_CFG_INI_DIR}" )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_NAME=${TWX_NAME}"
      "-DTWX_FACTORY_INI=${TWX_FACTORY_INI}"
      "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
      "${-DTWX_STATE}"
      -P "${TWX_DIR}CMake/Script/TwxCfgFactoryScript.cmake"
    RESULT_VARIABLE twx_cfg_update_factory.result
    COMMAND_ERROR_IS_FATAL ANY
  )
  twx_assert_0 ( "${twx_cfg_update_factory.result}" )
  set ( twx_cfg_update_factory.result )
  twx_cfg_read ( "factory" )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

# ANCHOR: `twx_cfg_update_git`
#[=======[
*//** @brief Update the git Cfg data file
*/
twx_cfg_update_git ( ) {}
/*
#]=======]
macro ( twx_cfg_update_git )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_update_git" )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
      "${-DTWX_STATE}"
      -P "${TWX_DIR}CMake/Script/TwxCfgGitScript.cmake"
    COMMAND_ERROR_IS_FATAL ANY
  )
  twx_cfg_read ( "git" )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_target" )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "ID;IN_VAR" "" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twx.R_ID )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  set ( ${twx.R_IN_VAR} "TwxCfg_${twx.R_ID}_target" PARENT_SCOPE)
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_setup" )
  set ( TWX_CFG_INI_DIR "${TWX_PROJECT_BUILD_DATA_DIR}" )
  if ( "${TWX_FACTORY_INI}" STREQUAL "" )
    set (
      TWX_FACTORY_INI
      "${TWX_DIR}${TWX_NAME}.ini"
    )
    twx_assert_exists ( "${TWX_FACTORY_INI}" )
    set ( target_twx TwxCfg )
  else ()
    twx_assert_exists ( "${TWX_FACTORY_INI}" )
    set ( target_twx "TwxCfg_${PROJECT_NAME}" )
  endif ()
  twx_message ( VERBOSE
    "twx_cfg_setup target: ``${target_twx}''"
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
  twx_cfg_path ( ID "factory" IN_VAR path_factory_twx )
  twx_state_serialize ()
  add_custom_command (
    OUTPUT ${path_factory_twx}
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_NAME=${TWX_NAME}"
      "-DTWX_FACTORY_INI=${TWX_FACTORY_INI}"
      "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
      "${-DTWX_STATE}"
      -P "${TWX_DIR}CMake/Script/TwxCfgFactoryScript.cmake"
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
      "${-DTWX_STATE}"
      -P "${TWX_DIR}CMake/Script/TwxCfgGitScript.cmake"
    DEPENDS
      ${path_factory_twx}
    COMMENT
      "Update git Cfg information"
  )
  add_custom_target (
    "${target_twx}" ALL
    DEPENDS ${path_git_twx}
  )
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
  "static", "git", "paths"... It is stored in
  `TWX_CFG_ID_CURRENT` to be used by forthcoming `twx_cfg_set`
  and `twx_cfg_end`.

@note
  - These write environments can be nested as long as
    each time a different id is used.
  - If we use the same id in a subsequent write environment,
    the former will be overwritten.
  - Things happen in the current variable scope.
*/
twx_cfg_write_begin ( ID id ) {}
/** @brief Reserved variable*/ TwxCfg_kv.<id>;
/*
#]=======]
function ( twx_cfg_write_begin .ID twx.R_ID )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_arg_assert_keyword ( .ID )
  twx_assert_variable_name ( "${twx.R_ID}" )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_write_begin" )
  if ( DEFINED TwxCfg_kv.${twx.R_ID} )
    twx_fatal ( "Missing `twx_cfg_write_end( ID ${twx.R_ID} )`" )
    return ()
  endif ()

  twx_export (
    TwxCfg_kv.${twx.R_ID}
    "TWX_CFG_ID_CURRENT=${twx.R_ID}"
    UNSET
  )
endfunction ()

# ANCHOR: twx_cfg_set
#[=======[
*/
/** @brief Set a cfg <key>=<value> assignment
  *
  * @param id is the id of a `twx_cfg_write_begin` previous command.
  *   When not provided it defaults to the value of `TWX_CFG_ID_CURRENT`.
  * @param key a spaceless key, usually uppercase
  * @param ... a non empty list of `<key>=<value>` arguments
  */
twx_cfg_set ( [ID id] key, ... ) {}
/*
Feed `TwxCfg_kv.<id_>` with `<key>=<value>`.
#]=======]
set (
  TWX_CFG_SEMICOLON_PLACEHOLDER
  "${TWX_CHAR_STX}semicolon${TWX_CHAR_ETX}"
)
function ( twx_cfg_set ID_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_set" )
  if ( "${ID_}" STREQUAL "ID")
    twx_arg_assert_count ( ${ARGC} > 2 )
    set ( id_ "${ARGV1}" )
    set ( i 2 )
  else ()
    set ( i 0 )
    set ( id_ "${TWX_CFG_ID_CURRENT}" )
  endif ()
  while ( TRUE )
    set ( kv "${ARGV${i}}" )
    string ( REPLACE ";" "${TWX_CFG_SEMICOLON_PLACEHOLDER}" kv "${kv}" )
    list ( APPEND TwxCfg_kv.${id_} "${kv}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_export ( TwxCfg_kv.${id_} )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_write_end" )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "ID" "" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_ID}" STREQUAL "" )
    set ( twx.R_ID "${TWX_CFG_ID_CURRENT}" )
  endif ()
  twx_expect_unequal_string ( "${twx.R_ID}" "_private" )
  twx_cfg_path ( ID "${twx.R_ID}" IN_VAR path_ )
  if ( NOT "${path_}" IN_LIST ${PROJECT_NAME}_TWX_CFG_IDS )
    list ( APPEND ${PROJECT_NAME}_TWX_CFG_IDS ${path_})
  endif()
  set_property (
    DIRECTORY
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS
    ${path_}
  )
  set (
    contents_ "\
;READ ONLY
;This file was generated automatically by the TWX build system
[${PROJECT_NAME} ${twx.R_ID} informations]
"
  )
  # Expose the keys and the values separately.
  # and find the largest key for pretty printing
  set ( length_ 0 )
  set ( keys_ )
  message ( DEBUG "TwxCfg_kv.${twx.R_ID} => ``${TwxCfg_kv.${twx.R_ID}}''" )
  foreach ( kv ${TwxCfg_kv.${twx.R_ID}} )
    string ( REPLACE "${TWX_CFG_SEMICOLON_PLACEHOLDER}" ";" kv "${kv}" )
    twx_split_assign ( kv )
    twx_assert_defined ( kv.key )
    string ( LENGTH "${kv.key}" l )
    if ( "${l}" GREATER "${length_}" )
      set ( length_ "${l}" )
    endif ()
    list ( APPEND keys_ "${kv.key}" )
    set ( "${kv.key}_value" "${kv.value}" )
  endforeach ()
  # Set the contents
  block ( PROPAGATE contents_ )
  foreach ( key_ ${keys_} )
    string ( LENGTH "${key_}" l )
    if ( length_ GREATER l )
      math ( EXPR l "${length_}-${l}" )
      string ( REPEAT " " ${l} padding_ )
    else ()
      set ( padding_ )
    endif ()
    string ( APPEND contents_ "${key_}${padding_} = ${${key_}_value}\n" )
  endforeach ()
  endblock ()
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
    COMMAND_ERROR_IS_FATAL ANY
  )
  if ( NOT "${ans_twx}" EQUAL "0" )
    twx_message ( WARNING "copy_if_different: ans_twx => ${ans_twx}" )
  endif ()
  if ( NOT EXISTS "${path_}" )
    twx_fatal ( "Could not create ${path_}" )
    return ()
  endif ()
  execute_process (
    COMMAND ${CMAKE_COMMAND} -E remove
      "${path_}(busy)"
    RESULT_VARIABLE ans_twx
    COMMAND_ERROR_IS_FATAL ANY
  )
  unset ( TwxCfg_kv.${twx.R_ID} PARENT_SCOPE )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_read" )
  set ( TWX_CFG_READ_FAILED OFF )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "QUIET;ONLY_CONFIGURE;NO_PRIVATE" "" ""
  )
  # core ids or absolute paths: mixed
  set ( cfg_ini_mixed_ "${twx.R_UNPARSED_ARGUMENTS}" )
  if ( "${cfg_ini_mixed_}" STREQUAL "" )
    # No file path or name provided:
    # take it all, declared or not
    twx_assert_non_void ( TWX_CFG_INI_DIR )
    if ( NOT PROJECT_NAME STREQUAL "" )
      set ( cfg_ini_mixed_ "${${PROJECT_NAME}_TWX_CFG_IDS}" )
    endif ()
    if ( "${cfg_ini_mixed_}" STREQUAL "" )
      twx_cfg_path ( ID "*" IN_VAR glob_ )
      # TODO: what happens if it contains more than one '*'?
      file ( GLOB cfg_ini_mixed_ "${glob_}" )
      if ( "${cfg_ini_mixed_}" STREQUAL "" )
        twx_fatal ( "No id available\nARGV => ``${ARGV}''\nglob_ => ``${glob_}''" )
        return ()
      endif ()
    endif ()
  endif ()
# unmix
  set ( cfg_ini_unordered_ )
  foreach ( id_ ${cfg_ini_mixed_} )
    twx_cfg_path ( ID "${id_}" IN_VAR p_ )
    if ( NOT EXISTS "${p_}" )
      if ( twx.R_QUIET )
        set ( TWX_CFG_READ_FAILED ON PARENT_SCOPE )
        return ()
      else ()
        twx_fatal ( "No file at ${p_}")
        return ()
      endif ()
      # readability is not tested
    endif ()
    if ( twx.R_NO_PRIVATE )
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
        twx_message ( DEBUG "TWX_CFG_${CMAKE_MATCH_1} => ``${CMAKE_MATCH_2}''" )
        set (
          TWX_CFG_${CMAKE_MATCH_1}
          "${CMAKE_MATCH_2}"
          PARENT_SCOPE
        )
        if ( NOT name_ STREQUAL "" AND NOT twx.R_ONLY_CONFIGURE )
          set (
            TWX_${PROJECT_NAME}_CFG_${CMAKE_MATCH_1}
            "${CMAKE_MATCH_2}"
            PARENT_SCOPE
          )
        endif ()
        math ( EXPR count_ "${count_}+1" )
      endif ()
    endforeach ( l )
    if ( twx.R_ONLY_CONFIGURE )
      twx_util_timestamp (
        "${name_}"
        IN_VAR ${name_}_TWX_TIMESTAMP_CFG
      )
    endif ()
    twx_message ( DEBUG "Read: ${count_} records in ${name_}" )
    if ( twx.R_QUIET )
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
  *
  *   twx_cfg_target_dependent ( target_i ... [ID id_j ...])
  *
  * It makes each target given by its name dependent of each id given.
  * If no id is provided, the `TWX_<project name>_IDS_CFG` is used instead.
  * Of course "ID" is not allowed as target name.
  *
  * UNUSED.
  * 
  * @param ... is the list of the dependent target.
  * @param ... after the ID is the list of the dependency id.
  */
twx_cfg_target_dependent ( ... ID ... ) {}
/*
#]=======]
function (twx_cfg_target_dependent )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_cfg_target_dependent" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "" "ID"
  )
  set ( path_ )
  foreach ( id_ ${twx.R_ID} )
    twx_cfg_path ( ID ${id_} IN_VAR v )
    list ( APPEND path_ "${v}" )
  endforeach ()
  foreach ( target_ ${twx.R_UNPARSED_ARGUMENTS} )
    set_property (
      TARGET ${target_}
      APPEND
      PROPERTY SOURCES
      ${path_}
    )
  endforeach ()
endfunction ()

# ANCHOR: twx_cfg_return_if_exists
#[=======[
*/
/** @brief convenient macro
  *
  * Return if the Cfg data file with the given id already exists.
  *
  * @param id is the argument of `twx_cfg_path()`.
  */
twx_cfg_return_if_exists ( ID id ) {}
/*
#]=======]
macro ( twx_cfg_return_if_exists .ID id_ )
  twx_arg_assert_count ( ${ARGC} 2 )
  twx_cfg_path ( ${.ID} "${id_}" IN_VAR twx_cfg_return_if_exists.path )
  if ( EXISTS "${twx_cfg_return_if_exists.path}" )
    set ( twx_cfg_return_if_exists.path )
    return ()
  endif ()
  set ( twx_cfg_return_if_exists.path )
endmacro ()
set ( twx.lib )

twx_lib_require ( "Fatal" "Assert" "Expect" "Export" "Arg" "Increment" "State" )

twx_state_key_add ( TWX_CFG_INI_REQUIRED_KEYS )

twx_lib_did_load ()

#*/
