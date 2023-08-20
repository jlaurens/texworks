#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief `cfg_file` helpers.
  *
  * Each folder containing files that will be processed by `cfg_file`
  * must be a cmake directory.

  * Usage:
  * at configuration time only
  *
  *   include ( TwxCfgFileLib )
  *
  *   twx_cfg_file_begin ( ID id )
  *   ...
  *   twx_cfg_file_add ( ... )
  *   ...
  *   twx_cfg_file_add ( ... )
  *   ...
  *   twx_cfg_file_add ( ... )
  *   ...
  *   twx_cfg_file_end ( ID id )
  *
  * All this is in the same variable scope.
  *
  * This process will transform `foo.in.bar` from the source
  * directory into `foo.bar` of the binary directory
  * through various Cfg `...ini` files.
  *
  * Headers will contain a private part suitable for testing purposes.
  * For static libraries built with modules, these private part are not
  * part of the publicly available headers. As a consequence,
  * some Cfg `...ini` maybe excluded from the build process.
  *
  * By convention, if a file name contains "private", it is considered private.
  * If the `NO_PRIVATE` flag is active, any private file is ignored.
  * This holds for both source files and Cfg `...ini` files.
  *
  */
/*
Implementation detail:
- one key is not a substring of another.
#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_cfg_file_name_out
#[=======[
*/
/** @brief Parse a name for configuration.
  *
  * This is where is implemented the logic of automatic file configuration
  * about file naming.
  * If the given `file_name` and output values are the same,
  * no configuration is requested. The converse is also true.
  * @param file_name is a file name,
  * @param var_out is the name of a variable where the output file name is recorded
  */
twx_cfg_file_name_out ( file_name IN_VAR var_out ) {}
/*
Beware of regular expression syntax.
#]=======]
function ( twx_cfg_file_name_out twx.R_FILE .IN_VAR twx.R_VAR )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_var_assert_name ( "${twx.R_VAR}" )
  if ( twx.R_FILE MATCHES "^(.*)[.]in$" )
    set ( ${twx.R_VAR} "${CMAKE_MATCH_1}" )
  elseif ( twx.R_FILE MATCHES "^(.*)[.]in([.][^/]+)$" )
    set ( ${twx.R_VAR} "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
  else ()
    set ( ${twx.R_VAR} "${twx.R_FILE}" )
  endif ()
  twx_export ( ${twx.R_VAR} )
endfunction ()

# ANCHOR: twx_cfg_file_begin
#[=======[
*/
/**
  * @brief Prepare file configuration
  *
  * Ensure that all the macros are properly defined.
  *
  * Usage
  *   
  *   <start of scope>
  *   twx_cfg_file_begin ( ID id )
  *   ...
  *   twx_cfg_file_add ( ... )
  *   ...
  *   twx_cfg_file_end ( )
  *   ...
  *   <end of scope>
  *
  * Input state:
  * - `PROJECT_NAME`, required
  *
  * Output state:
  * - `TWX_CFG_FILE__ID_CURRENT`, private
  *
  * @param id for key `ID`, a unique required identifier
  */
twx_cfg_file_begin ( ID id ) {}
/*
#]=======]
function ( twx_cfg_file_begin )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "ID" "" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( PROJECT_NAME twx.R_ID )
  set ( busy_ TWX_CFG_FILE__${PROJECT_NAME}_${twx.R_ID}_BUSY )
  if ( ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_end ( ID ${twx.R_ID} )" )
    return ()
  endif ()
  set ( ${busy_} ON PARENT_SCOPE )
  set ( TWX_CFG_FILE__ID_CURRENT "${twx.R_ID}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_cfg_file_add
#[=======[
*/
/**
  * @brief Configure some files.
  *
  * See `twx_cfg_file_begin()`.
  *
  * @param id for key `ID`, an optional identifier, it defaults to the one
  *   most recently given to `twx_cfg_file_begin()`
  * @param ... for key FILES, non empty list of absolute file paths.
  */
twx_cfg_file_add ( [ID id] FILES ... ) {}
/*
#]=======]
function ( twx_cfg_file_add )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "ID" "FILES" )
  twx_arg_assert_parsed ()
  if ( NOT twx.R_ID )
    twx_assert_non_void ( TWX_CFG_FILE__ID_CURRENT )
    set ( twx.R_ID "${TWX_CFG_FILE__ID_CURRENT}" )
  endif ()
  twx_assert_non_void ( twx.R_ID )
  twx_assert_non_void ( twx.R_FILES )
  set ( busy_ TWX_CFG_FILE__${PROJECT_NAME}_${twx.R_ID}_BUSY )
  if ( NOT ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_begin ( ID ${twx.R_ID} )" )
    return ()
  endif ()
  set ( list_ TWX_CFG_FILE__${PROJECT_NAME}_${twx.R_ID}_LIST )
  list ( APPEND ${list_} ${twx.R_FILES} )
  twx_export( ${list_} )
endfunction ()

# ANCHOR: twx_cfg_file_end
#[=======[
*/
/** @brief End the `cfg_file` grouping.
  *
  * Usage
  *
  *   twx_cfg_file_end ( [ID id] [ESCAPE_QUOTES] [NO_PRIVATE] [CFG_INI_IDS id1...] )
  *
  * * When ESCAPE_QUOTES is provided, forwards `ESCAPE_QUOTES`
  *   to forthcoming related `configure_file`.
  *
  * * `id1`, `id2` were previously used as arguments of
  *   `twx_cfg_write_begin()`. When no such id is provided
  *   every available `...cfg.ini` files will be used,
  *   see `twx_cfg_read()`.
  *
  * @param id for key `ID` is the optional identifier,
  * @param type for key `TYPE` is the optional type,
  *   required for modules.
  * @param in_dir for key `IN_DIR` is the input directory path,
  *   required except for modules,
  * @param out_dir for key `OUT_DIR` is the output directory path,
  *   required except for modules,
  * @param prefix for key `VAR_PREFIX` is a variable name prefix that will hold on return the list
  *   of full path to files that need configuration.
  *   The variable is named `<prefix>_<id>`.
  *   It is also a prefix for a variable holding the target name.
  *   This second variable is named `<prefix>_<id>_target`.
  *   This cannot be used when a module is given.
  * @param ids for key `CFG_INI_IDS` is an optional list of `...cfg.ini` files identifiers
  *   that will be forwarded to `twx_cfg_read()`
  * @param `ESCAPE_QUOTES`, optional flag mainly for cpp files.
  * @param `NO_PRIVATE`, optional flag to exclude private files.
  *   In that case privately named header files are ignored.
  * @param module for key `MODULE`, optional module name.
  *   If the module is not yet defined, we are creating source files for the module
  *   which file paths will eventually be exported.
  *   If the module is already defined, we are creating include header directory for the module static libraries.
  *   The module has then an ARCHIVE_OUTPUT_DIRECTORY property, and
  *   the `out_dir` is relative to that location.
  *   The `TARGET` and `MODULE` arguments are mutually exclusive.
  * @param target for key `TARGET`, optional target name.
  *   If the target is not yet defined, we are creating source files for the target
  *   which file paths will eventually be exported.
  *   If the target is already defined, we assume this is a static library
  *   for which we are creating include header directory.
  *   The target has then an ARCHIVE_OUTPUT_DIRECTORY property, and
  *   the `out_dir` is relative to that location. This is not suitable to
  *   configure sources before the build stage, because files may be edited afterwards,
  *   use an explicit target dependency instead.
  *   The `TARGET` and `MODULE` arguments are mutually exclusive.
  * 
  */
twx_cfg_file_end ( [ID id] ) {}
/*

#]=======]
function ( twx_cfg_file_end )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  twx_assert_non_void ( PROJECT_NAME )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "ESCAPE_QUOTES;NO_PRIVATE"
    "MODULE;ID;TYPE;VAR_PREFIX;TARGET;IN_DIR;OUT_DIR"
    "CFG_INI_IDS"
  )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twx.R_IN_DIR twx.R_OUT_DIR )
  twx_dir_complete_var ( twx.R_IN_DIR twx.R_OUT_DIR )
  if ( NOT DEFINED "${twx.R_ID}" )
    twx_assert_non_void ( TWX_CFG_FILE__ID_CURRENT )
    set ( twx.R_ID "${TWX_CFG_FILE__ID_CURRENT}" )
  endif ()
  twx_assert_non_void ( twx.R_ID )
  message ( DEBUG
    "twx_cfg_file_end: PROJECT/ID => ${PROJECT_NAME}/${twx.R_ID}"
  )
  if ( TWX_TEST AND NOT DEFINED twx.R_PREFIX )
    set ( twx.R_PREFIX "TWX_TEST" )
  endif ()
  set ( busy_ TWX_CFG_FILE__${PROJECT_NAME}_${twx.R_ID}_BUSY )
  if ( NOT ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_begin ( ID ${twx.R_ID} )" )
    return ()
  endif ()
  set ( list_ TWX_CFG_FILE__${PROJECT_NAME}_${twx.R_ID}_LIST )
  twx_ans_set (
    ONLY_ON_TEST
    "TWX_TEST_list=${${list_}}"
  )
  set ( in_ )
  set ( out_ )
  foreach ( file.in ${${list_}} )
    if ( twx.R_NO_PRIVATE AND "${file.in}" MATCHES "private" )
      continue ()
    endif ()
    twx_cfg_file_name_out ( "${file.in}" IN_VAR file.out )
    list ( APPEND in_  "${file.in}"  )
    list ( APPEND out_ "${file.out}" )
  endforeach ()
  twx_ans_set (
    ONLY_ON_TEST
    "TWX_TEST_in=${in_}"
    "TWX_TEST_out=${out_}"
  )
  twx_arg_pass_option ( NO_PRIVATE ESCAPE_QUOTES )
  set ( target_ )
  if ( TARGET "${twx.R_MODULE}" )
    twx_ans_set (
      ONLY_ON_TEST
      "TWX_TEST_BRANCH_1=MODULE"
    )
    # We are building the "include" directory.
    twx_module_complete ( "${twx.R_MODULE}" VAR_PREFIX twx.R )
    twx_assert_undefined ( twx.R_TARGET )
    twx_module_expose ( ${twx.R_MODULE} )
    if ( "${twx.R_IN_DIR}" STREQUAL "" )
      set ( twx.R_IN_DIR "${${twx.R_MODULE}_SRC_IN_DIR}" )
    else ()
      twx_dir_complete_var ( twx.R_IN_DIR )
    endif ()
    twx_assert_non_void ( twx.R_OUT_DIR )
    twx_dir_complete_var ( twx.R_OUT_DIR )
    if ( IS_ABSOLUTE "${twx.R_OUT_DIR}" )
      set ( output_directory_ "${twx.R_OUT_DIR}" )
    else ()
      set ( output_directory_ "${${twx.R_MODULE}_ARCHIVE_OUTPUT_DIRECTORY}" )
      if ( "${output_directory_}" MATCHES "NOTFOUND" )
        twx_fatal ( "Module ${twx.R_MODULE_NAME} has no ARCHIVE_OUTPUT_DIRECTORY: ${output_directory_}" )
        return ()
      endif ()
      set ( output_directory_ "${output_directory_}${twx.R_OUT_DIR}" )
    endif ()
    set ( cfg_ini_dir_ ${${twx.R_MODULE}_CFG_INI_DIR} )
    twx_state_serialize ()
    add_custom_command (
      TARGET "${twx.R_MODULE}"
      POST_BUILD
      COMMAND
        "${CMAKE_COMMAND}"
          "-DTWX_CFG_INI_DIR=${${twx.R_MODULE}_CFG_INI_DIR}"
          "-DTWX_IN_DIR=${twx.R_IN_DIR}"
          "-DTWX_OUT_DIR=${output_directory_}"
          "-DTWX_IN=${in_}"
          "-DTWX_CFG_INI_IDS=${twx.R_CFG_INI_IDS}"
          "${TWX-D_ESCAPE_QUOTES}"
          "${TWX-D_NO_PRIVATE}"
          "${-DTWX_STATE}"
          -P "${TWX_DIR}CMake/Script/TwxCfgFileScript.cmake"
      COMMENT
        "Configure ${PROJECT_NAME}'s ${twx.R_MODULE_NAME} include directory ${output_directory_}"
      VERBATIM
    )
  elseif ( TARGET "${twx.R_TARGET}" )
    twx_ans_set (
      ONLY_ON_TEST
      "TWX_TEST_BRANCH_1=TARGET"
    )
    # We are building the "include" directory.
    twx_assert_undefined ( twx.R_MODULE )
    twx_target_expose ( ${twx.R_TARGET} )
    if ( DEFINED "${twx.R_IN_DIR}" )
      twx_dir_complete_var ( twx.R_IN_DIR )
    else ()
      set ( twx.R_IN_DIR "${${twx.R_TARGET}_SRC_IN_DIR}" )
    endif ()
    twx_assert_non_void ( twx.R_OUT_DIR )
    twx_dir_complete_var ( twx.R_OUT_DIR )
    if ( IS_ABSOLUTE "${twx.R_OUT_DIR}" )
      set ( output_directory_ "${twx.R_OUT_DIR}" )
    else ()
      set ( output_directory_ "${${twx.R_TARGET}_ARCHIVE_OUTPUT_DIRECTORY}" )
      if ( "${output_directory_}" MATCHES "NOTFOUND" )
        twx_fatal ( "Target ${twx.R_TARGET} has no ARCHIVE_OUTPUT_DIRECTORY: ${output_directory_}" )
        return ()
      endif ()
      set ( output_directory_ "${output_directory_}${twx.R_OUT_DIR}" )
    endif ()
    set ( cfg_ini_dir_ ${${twx.R_TARGET}_CFG_INI_DIR} )
    if ( NOT EXISTS "${cfg_ini_dir_}" )
      set ( cfg_ini_dir_ "${TWX_CFG_INI_DIR}" )
    endif ()
    twx_state_serialize ()
    add_custom_command (
      TARGET "${twx.R_TARGET}"
      POST_BUILD
      COMMAND
        "${CMAKE_COMMAND}"
          "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
          "-DTWX_IN_DIR=${twx.R_IN_DIR}"
          "-DTWX_OUT_DIR=${output_directory_}"
          "-DTWX_IN=${in_}"
          "-DTWX_CFG_INI_IDS=${twx.R_CFG_INI_IDS}"
          "${TWX-D_ESCAPE_QUOTES}"
          "${TWX-D_NO_PRIVATE}"
          "${-DTWX_STATE}"
          -P "${TWX_DIR}CMake/Script/TwxCfgFileScript.cmake"
      COMMENT
        "Configure ${PROJECT_NAME}'s ${twx.R_TARGET} include directory ${output_directory_}"
      VERBATIM
    )
  else ()
    twx_ans_set (
      ONLY_ON_TEST
      "TWX_TEST_BRANCH_1=OTHER"
    )
    twx_cfg_path ( ID "${PROJECT_NAME}_${twx.R_ID}_file" IN_VAR stamped_ STAMPED )
    set ( cfg_ini_dir_ ${TWX_CFG_INI_DIR} )
    twx_assert_exists ( "${cfg_ini_dir_}" )
    set ( target_ "TwxCfgFile_${PROJECT_NAME}_${twx.R_ID}" )
    if ( NOT TARGET ${target_} )
      add_custom_target (
        ${target_}
        ALL
        DEPENDS
          ${stamped_}
        COMMENT
          "Configure ${PROJECT_NAME} files for ${twx.R_ID}"
      )
    endif ()
    # For the custom command below:
    set ( depends_ )
    set ( output_ )
    foreach ( file_ ${in_} )
      list ( APPEND depends_ "${twx.R_IN_DIR}${file_}" )
    endforeach ()
    foreach ( file_ ${out_} )
      list ( APPEND output_ "${twx.R_OUT_DIR}${file_}" )
    endforeach ()
    twx_state_serialize ()
    add_custom_command (
      OUTPUT
        "${stamped_}"
        ${output_}
      COMMAND
        "${CMAKE_COMMAND}"
          "-DTWX_CFG_INI_DIR=``${cfg_ini_dir_}''"
          "-DTWX_IN_DIR=``${twx.R_IN_DIR}''"
          "-DTWX_OUT_DIR=``${twx.R_OUT_DIR}''"
          "-DTWX_IN=${in_}"
          "-DTWX_CFG_INI_IDS=${twx.R_CFG_INI_IDS}"
          "${TWX-D_ESCAPE_QUOTES}"
          "${TWX-D_NO_PRIVATE}"
          "${-DTWX_STATE}"
          -P "${TWX_DIR}CMake/Script/TwxCfgFileScript.cmake"
      COMMAND
        "${CMAKE_COMMAND}"
          -E touch "${stamped_}"
      DEPENDS
        ${depends_}
      COMMENT
        "Configure ${PROJECT_NAME} files for ${twx.R_ID}"
      VERBATIM
    )
  endif ()
  if ( DEFINED twx.R_MODULE )
    twx_expect ( twx.R_VAR_PREFIX "" )
    twx_assert_non_void ( twx.R_TYPE )
    set ( export_ )
    foreach ( file_ ${out_} )
      list ( APPEND export_ "${twx.R_OUT_DIR}${file_}")
    endforeach ()
    list ( SORT export_ )
    twx_ans_set (
      "{twx.R_MODULE}_OUT_${twx.R_TYPE}=${export_}"
    )
  elseif ( DEFINED twx.R_VAR_PREFIX )
    set ( export_ )
    foreach ( file_ ${out_} )
      list ( APPEND export_ "${twx.R_OUT_DIR}${file_}")
    endforeach ()
    list ( SORT export_ )
    twx_ans_set (
      "${twx.R_VAR_PREFIX}_OUT_${twx.R_TYPE}=${export_}"
    )
    if ( TARGET ${target_} )
      twx_ans_set (
        "${twx.R_VAR_PREFIX}_${twx.R_ID}_TARGET=${target_}"
      )
    else ()
      set ( ${twx.R_VAR_PREFIX}_${twx.R_ID}_TARGET PARENT_SCOPE )
    endif ()
  endif ()
  twx_ans_export ()
  if ( NOT "${twx.R_MODULE}" STREQUAL "" )
    twx_export ( ${twx.R_ID} ${twx.R_ID}_TARGET )
  elseif ( NOT "${twx.R_VAR_PREFIX}" STREQUAL "" )
    twx_export (
      ${twx.R_VAR_PREFIX}_${twx.R_TYPE}
      ${twx.R_VAR_PREFIX}_${twx.R_TYPE}_TARGET
    )
  endif ()
  set ( ${list_} PARENT_SCOPE )
  set ( ${busy_} PARENT_SCOPE )
endfunction ( twx_cfg_file_end )

# ANCHOR: twx_cfg_files
#[=======[
*/
/** @brief Configure files.
  *
  * Configure a given list of files from a source directory
  * to a destination directory.
  * A custom command is created for this configuration step.
  * Its name is uniquely defined after a given identifier.
  * A `...stamp` file is created to record a time stamp.
  * The command creates the output files and depends on the input files.
  *
  * This is a shortcut to
  *
  *   twx_cfg_file_begin ( ... )
  *   ...
  *   twx_cfg_file_add ( ... )
  *   ...
  *   twx_cfg_file_end ( ... )
  *
  * @param module for key `MODULE`, an optional module name. When not provided,
  *   configuration relates to the current project.
  * @param type for key `TYPE`, is a unique type identifier like `SOURCES`, `HEADERS`.
  *   Same as in `twx_cfg_files_begin()`.
  *   When a module is provided, the unique identifier is `<module>_<type>`
  *   such that many different modules can be configured within a unique project.
  * @param id for key `ID`, is a unique identifier within a project.
  *   When not provided, it defaults to `<module>_<type>` if a module
  *   was given or simply to `<type>` otherwise.
  * @param prefix for key `VAR_PREFIX`, is the name prefix of a variable that contains on return
  *   the `;` separated list of all the configured files. The full variable name
  *   is `<prefix>_<type>`. If a module is given, this argument is ignored and
  *   and the list of configured files is exported in the variable simply named `<id>`.
  *   If no VAR_PREFIX nor MODULE is used, no exportation takes place.
  * @param files for key `FILE` is an optional list of sources to `configure_file()`.
  *   These are relative to `input_dir` before and to `output_dir` after.
  *   When non provided, it defaults to the value of `<module>_IN_<type>`.
  * @param target for key `TARGET`, an optional target name for `twx_cfg_file_end()`.
  *   Very similar to `<module>`, see `twx_cfg_file_end()`.
  * @param input_dir for key `IN_DIR`, an optional input directory. When not specified,
  *   it defaults to the value of `<module>_SRC_IN_DIR`.
  * @param output_dir for key `OUT_DIR`, an optional output directory. When not specified,
  *   it defaults to the value of `<module>_SRC_OUT_DIR`.
  * @param `ESCAPE_QUOTES` optional flag to indicate whether quotes should be escaped.
  *   Used for some SOURCES but not for some HEADERS, for example.
  * @param `NO_PRIVATE` optional flag to indicate whether private cfg ini files
  *   should be used.
  * @param ini_ids for key `CFG_INI_IDS`, specify the exact list of cfg ini files
  *   used with `configure_file`.
*/
twx_cfg_files ( [TYPE type] ... ) {}
/*
#]=======]
function ( twx_cfg_files )
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
      "ESCAPE_QUOTES;NO_PRIVATE"
      "MODULE;TYPE;ID;VAR_PREFIX;TARGET;IN_DIR;OUT_DIR"
      "CFG_INI_IDS;FILES"
  )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twx.R_TYPE )
  if ( NOT DEFINED twx.R_IN_DIR )
    twx_assert_non_void ( twx.R_MODULE )
    set ( twx.R_IN_DIR "${${twx.R_MODULE}_SRC_IN_DIR}" )
  endif ()
  if ( NOT DEFINED twx.R_OUT_DIR )
    twx_assert_non_void ( twx.R_MODULE )
    set ( twx.R_OUT_DIR "${${twx.R_MODULE}_SRC_OUT_DIR}" )
  endif ()
  if ( NOT DEFINED twx.R_FILES )
    twx_assert_non_void ( twx.R_MODULE )
    set ( twx.R_FILES "${${twx.R_MODULE}_IN_${twx.R_TYPE}}" )
  endif ()
  twx_assert_non_void ( twx.R_IN_DIR twx.R_OUT_DIR )
  if ( DEFINED twx.R_ID )
    twx_assert_non_void ( twx.R_ID )
  elseif ( DEFINED twx.R_MODULE )
    twx_assert_non_void ( twx.R_MODULE )
    set ( twx.R_ID "${twx.R_MODULE}_${twx.R_TYPE}" )
  else ()
    set ( twx.R_ID "${twx.R_TYPE}" )
  endif ()
  twx_cfg_file_begin ( ID "${twx.R_ID}" )
  block ()
  twx_message_log ( DEBUG
    "twx_cfg_files: ${TWX_CFG_FILE__ID_CURRENT} ->"
    DEEPER
  )
  twx_message_log ( DEBUG
    ${twx.R_FILES}
  )
  endblock ()
  twx_cfg_file_add (
    ID    "${twx.R_ID}"
    FILES ${twx.R_FILES}
  )
  twx_arg_pass_option ( ESCAPE_QUOTES NO_PRIVATE )
  twx_cfg_file_end (
    ID          "${twx.R_ID}"
    TYPE        "${twx.R_TYPE}"
    IN_DIR      "${twx.R_IN_DIR}"
    OUT_DIR     "${twx.R_OUT_DIR}"
    CFG_INI_IDS ${twx.R_CFG_INI_IDS}
    MODULE      ${twx.R_MODULE}
    TARGET      ${twx.R_TARGET}
    VAR_PREFIX  ${twx.R_VAR_PREFIX}
    ${twx.R_ESCAPE_QUOTES}
    ${twx.R_NO_PRIVATE}
  )
  twx_ans_set ( TWX_CFG_INI_DIR )
  twx_ans_export ()
endfunction ( twx_cfg_files )

twx_lib_did_load ()

#*/
