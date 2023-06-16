#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief `cfg_file` helpers.

Each folder containing files that will be processed by `cfg_file`
must be a cmake directory.

Usage:
at configuration time only
```
include ( TwxCfgFileLib )
...
twx_cfg_file_begin ( id )
...
twx_cfg_file_add ( ... )
...
twx_cfg_file_add ( ... )
...
twx_cfg_file_add ( ... )
...
twx_cfg_file_end ( id )
```
All this is in the same variable scope.

This process will transform `foo.in.bar` from the source
directory into `foo.bar` of the binary directory
through `...cfg.ini` files.

Headers will contain a private part suitable for testing purposes.
For static libraries built with modules, these private part are not
part of the publicly available headers. As a consequence,
some `...cfg.ini` maybe excluded from the build process.

By convention, if a file name contains "private", it is considered private.
If the `NO_PRIVATE` flag is active, any private file is ignored.
This holds for both source files and `...cfg.ini` files.

NB: This does not depend on `TwxBase`.
*//*

Implementation detail:
- one key is not a substring of another.

#]===============================================]

# ANCHOR: twx_cfg_file_begin
#[=======[
*//**
@brief Prepare file configuration

Ensure that all the macros are properly defined.

Usage
```
<start of scope>
twx_cfg_file_begin ( ID id )
...
twx_cfg_file_add ( ... )
...
twx_cfg_file_end ( )
...
<end of scope>
```
Input state:
- `PROJECT_NAME`, required

Output state:
- `TWX_CFG__FILE_ID_CURRENT`, private 

@param id for key ID, a unique required identifier
*/
twx_cfg_file_begin ( ID id ) {}
/*
#]=======]
function ( twx_cfg_file_begin )
  twx_parse_arguments ( "" "ID" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( PROJECT_NAME twxR_ID )
  set ( busy_ ${PROJECT_NAME}_${twxR_ID}_CFG_BUSY )
  if ( ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_end ( ID ${twxR_ID} )" )
  endif ()
  set ( ${busy_} ON PARENT_SCOPE )
  set ( TWX_CFG__FILE_ID_CURRENT "${twxR_ID}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_cfg_file_add
#[=======[
*//**
@brief Configure some files.

See `twx_cfg_file_begin()`.

@param id for key ID, an optional identifier, it defaults to the one
  most recently given to twx_cfg_file_begin()
@param file is an absolute file path.
@param ... more file paths
*/
twx_cfg_file_add ( [ID id] FILES file ... ) {}
/*
#]=======]
function ( twx_cfg_file_add )
  twx_parse_arguments ( "" "ID" "FILES" ${ARGN} )
  twx_assert_parsed ()
  if ( NOT twxR_ID )
    twx_assert_non_void ( TWX_CFG__FILE_ID_CURRENT )
    set ( twxR_ID "${TWX_CFG__FILE_ID_CURRENT}" )
  endif ()
  twx_assert_non_void ( twxR_ID )
  set ( busy_ ${PROJECT_NAME}_${twxR_ID}_CFG_BUSY )
  if ( NOT ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_begin ( ID ${twxR_ID} )" )
  endif ()
  set ( files_ ${PROJECT_NAME}_${twxR_ID}_CFG_FILES )
  list ( APPEND ${files_} ${twxR_FILES} )
  twx_export( ${files_} )
endfunction ()

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
twx_cfg_file_name_out ( var_out IN file_name ) {}
/*
Beware of regular expression syntax.
#]=======]
function ( twx_cfg_file_name_out var_out IN file_name )
  twx_assert_equal ( IN ${IN} )
  if ( file_name MATCHES "^(.*)[.]in$" )
    set ( ${var_out} "${CMAKE_MATCH_1}" )
  elseif ( file_name MATCHES "^(.*)[.]in([.].+)$" )
    set ( ${var_out} "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
  else ()
    set ( ${var_out} "${file_name}" )
  endif ()
  twx_export ( ${var_out} )
endfunction ()

# ANCHOR: twx_cfg_file_end
#[=======[
*/
/** @brief End the `cfg_file` grouping.
  *
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
  * @param id for key ID is the optional identifier,
  * @param in_dir for key IN_DIR is the required input directory path,
  * @param out_dir for key OUT_DIR is the required output directory path,
  * @param export_ans for key EXPORT is a variable name prefix that will hold on return the list
  *   of full path to files that need configuration.
  *   The variable is named `<prefix>_<id>`.
  *   It is also a prefix for a variable holding the target name.
  *   This second variable is named `<prefix>_<id>_target`.
  * @param ids for key CFG_INI_IDS is an optional list of `...cfg.ini` files identifiers
  *   that will be forwarded to `twx_cfg_read()`
  * @param ESCAPE_QUOTES, optional flag mainly for cpp files.
  * @param NO_PRIVATE, optional flag to exclude private files.
  *   In that case privately named header files are ignored.
  * @param target for key TARGET, optional target name.
  *   Useful to create the inlude header directory for static libraries.
  *   When the target has an ARCHIVE_OUTPUT_DIRECTORY property,
  *   the `out_dir` is relative to that location. This is not suitable to
  *   configure sources before the build stage, use an explicit target dependency.
  */
twx_cfg_file_end ( [ID id] ) {}
/*

#]=======]
function ( twx_cfg_file_end )
  twx_assert_non_void ( PROJECT_NAME )
  twx_parse_arguments (
    "ESCAPE_QUOTES;NO_PRIVATE"
    "ID;EXPORT;TARGET;IN_DIR;OUT_DIR"
    "CFG_INI_IDS"
    ${ARGN}
  )
  twx_assert_parsed ()
  twx_assert_non_void ( IN_DIR OUT_DIR )
  if ( "${twxR_ID}" STREQUAL "" )
    twx_assert_non_void ( TWX_CFG__FILE_ID_CURRENT )
    set ( twxR_ID "${TWX_CFG__FILE_ID_CURRENT}" )
  endif ()
  twx_assert_non_void ( twxR_ID )
  twx_message_more_verbose (
    "twx_cfg_file_end: PROJECT/ID => ${PROJECT_NAME}/${twxR_ID}"
  )
  set ( busy_ ${PROJECT_NAME}_${twxR_ID}_CFG_BUSY )
  if ( NOT ${busy_} )
    twx_fatal ( "Missing twx_cfg_file_begin ( ID ${twxR_ID} )" )
  endif ()
  set ( files_ ${PROJECT_NAME}_${twxR_ID}_CFG_FILES )
  set ( in_ )
  set ( out_ )
  foreach ( file.in ${${files_}} )
    if ( twxR_NO_PRIVATE AND "${file.in}" MATCHES "private" )
      continue ()
    endif ()
    twx_cfg_file_name_out ( file.out IN "${file.in}" )
    list ( APPEND in_  "${file.in}"  )
    list ( APPEND out_ "${file.out}" )
  endforeach ()

  if ( "${twxR_TARGET}" STREQUAL "" )
    # No TARGET given
    twx_cfg_path ( stamped ID "${PROJECT_NAME}_${twxR_ID}_file" STAMPED )
    set (
      target_
      ${PROJECT_NAME}_${twxR_ID}_cfg_ini
    )
    if ( NOT TARGET ${target_} )
      add_custom_target (
        ${target_}
        ALL
        DEPENDS
          ${stamped}
        COMMENT
          "Configure ${PROJECT_NAME} files for ${twxR_ID}"
      )
    endif ()
    # For the custom command below:
    set ( depends_ )
    set ( output_ )
    foreach ( file_ ${in_} )
      list ( APPEND depends_ "${twxR_IN_DIR}/${file_}" )
    endforeach ()
    foreach ( file_ ${out_} )
      list ( APPEND output_ "${twxR_OUT_DIR}/${file_}" )
    endforeach ()
    add_custom_command (
      OUTPUT
        "${stamped}"
        ${output_}
      COMMAND
        "${CMAKE_COMMAND}"
          "-DPROJECT_NAME=${PROJECT_NAME}"
          "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
          "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
          "-DTWX_IN_DIR=${twxR_IN_DIR}"
          "-DTWX_OUT_DIR=${twxR_OUT_DIR}"
          "-DTWX_IN=${in_}"
          "-DTWX_CFG_INI_IDS=${twxR_CFG_INI_IDS}"
          "-DTWX_ESCAPE_QUOTES=${twxR_ESCAPE_QUOTES}"
          "-DTWX_NO_PRIVATE=${twxR_NO_PRIVATE}"
          "-DTWX_VERBOSE=${TWX_VERBOSE}"
          "-DTWX_DEV=${TWX_DEV}"
          "-DTWX_MESSAGE_DEPTH=${TWX_MESSAGE_DEPTH}"
          -P "${TWX_DIR}/CMake/Command/TwxCfgFileCommand.cmake"
      COMMAND
        "${CMAKE_COMMAND}"
          -E touch "${stamped}"
      DEPENDS
        ${depends_}
      COMMENT
        "Configure ${PROJECT_NAME} files for ${twxR_ID}"
      VERBATIM
    )
  elseif ( NOT TARGET ${twxR_TARGET} )
    twx_fatal ( "Unknown target ${twxR_TARGET}" )
  else ()
    if ( IS_ABSOLUTE "${twxR_OUT_DIR}" )
      set ( output_directory_ "${twxR_OUT_DIR}" )
    else ()
      get_target_property(
        output_directory_
        ${twxR_TARGET}
        ARCHIVE_OUTPUT_DIRECTORY
      )
      if ( output_directory_ MATCHES "NOTFOUND" )
        twx_fatal ( "Target ${twxR_TARGET} has no ARCHIVE_OUTPUT_DIRECTORY: ${output_directory_}" )
      endif ()
      set ( output_directory_ "${output_directory_}/${twxR_OUT_DIR}" )
    endif ()
    add_custom_command (
      TARGET "${twxR_TARGET}"
      POST_BUILD
      COMMAND
        "${CMAKE_COMMAND}"
          "-DPROJECT_NAME=${PROJECT_NAME}"
          "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
          "-DTWX_CFG_INI_DIR=${TWX_CFG_INI_DIR}"
          "-DTWX_IN_DIR=${twxR_IN_DIR}"
          "-DTWX_OUT_DIR=${output_directory_}"
          "-DTWX_IN=${in_}"
          "-DTWX_CFG_INI_IDS=${twxR_CFG_INI_IDS}"
          "-DTWX_ESCAPE_QUOTES=${twxR_ESCAPE_QUOTES}"
          "-DTWX_NO_PRIVATE=${twxR_NO_PRIVATE}"
          "-DTWX_VERBOSE=${TWX_VERBOSE}"
          "-DTWX_DEV=${TWX_DEV}"
          "-DTWX_MESSAGE_DEPTH=${TWX_MESSAGE_DEPTH}"
          -P "${TWX_DIR}/CMake/Command/TwxCfgFileCommand.cmake"
      COMMENT
        "Configure ${PROJECT_NAME} include directory"
      VERBATIM
    )
  endif ()
  if ( NOT "${twxR_EXPORT}" STREQUAL "" )
    set ( export_ )
    foreach ( file_ ${out_} )
      list ( APPEND export_ "${twxR_OUT_DIR}/${file_}")
    endforeach ()
    list ( SORT export_ )
    set ( ${twxR_EXPORT}_${twxR_ID} "${export_}" PARENT_SCOPE )
    set ( ${twxR_EXPORT}_${twxR_ID}_target "${target_}" PARENT_SCOPE )
  endif ()
  unset ( ${files_} PARENT_SCOPE )
  unset ( ${busy_} PARENT_SCOPE )
endfunction ( twx_cfg_file_end )

# ANCHOR: twx_cfg_files
#[=======[
*//**
@brief Configure files.

Configure a given list of files from a source directory
to a destination directory.
A custom command is created for this configuration step.
Its name is uniquely defined after a given identifier.
A `...stamp` file is created to record a time stamp.
The command creates the output files and depends on the input files.

This is a shortcut to
```
twx_cfg_file_begin ( ... )
...
twx_cfg_file_add ( ... )
...
twx_cfg_file_end ( ... )
```
@param id is a unique id, same for `twx_cfg_files_begin()`
@param added is the name of a variable that contains on return
  the `;` separated list of all the configured files
@param file is a file path in the top source directory `TWX_DIR`.
@param ... more file paths
*/
twx_cfg_files ( [ID id] ... ) {}
/*
#]=======]
function ( twx_cfg_files )
  twx_parse_arguments (
    "ESCAPE_QUOTES;NO_PRIVATE"
    "ID;EXPORT;TARGET;IN_DIR;OUT_DIR"
    "CFG_INI_IDS;FILES"
    ${ARGN}
  )
  twx_assert_parsed ()
  twx_assert_non_void ( twxR_IN_DIR )
  twx_assert_non_void ( twxR_OUT_DIR )
  twx_cfg_file_begin ( ID "${twxR_ID}" )
  twx_message_more_verbose (
    "twx_cfg_files: ${TWX_CFG__FILE_ID_CURRENT}"
    "twx_cfg_files: twxR_FILES =>"
  )
  twx_message_more_verbose (
    ${twxR_FILES}
  )
  twx_cfg_file_add (
    ID    "${twxR_ID}"
    FILES ${twxR_FILES}
  )
  twx_pass_option ( ESCAPE_QUOTES )
  twx_pass_option ( NO_PRIVATE )
  twx_cfg_file_end (
    ID          "${twxR_ID}"
    IN_DIR      "${twxR_IN_DIR}"
    OUT_DIR     "${twxR_OUT_DIR}"
    CFG_INI_IDS "${twxR_CFG_INI_IDS}"
    EXPORT      ${twxR_EXPORT}
    TARGET      ${twxR_TARGET}
    ${twxR_ESCAPE_QUOTES}
    ${twxR_NO_PRIVATE}
  )
  if ( NOT "${twxR_EXPORT}" STREQUAL "" )
    twx_export ( ${twxR_EXPORT}_${twxR_ID} )
  endif ()
endfunction ()

#*/
