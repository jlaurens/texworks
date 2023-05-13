#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief `configure_file` helpers.

Each folder containing files that will be processed by `configure_file`
must be a cmake directory.

Usage:
at configuration time only
```
include ( TwxConfigureFileLib )
...
twx_configure_file_begin ()
...
twx_configure_file_add ( ... )
...
twx_configure_file_add ( ... )
...
twx_configure_file_add ( ... )
...
twx_configure_file_end ()
```
All this is in the same primary `CMakeLists.txt`

This process will transform `foo.in.bar` from the source
directory into `foo.bar` of the binary directory
through `configure_file`.

Here is the static list of recognized keys from `<project name>.ini`.
Other keys can be used but they must be managed elsewhere.
For each `<key>` we have both `TWX_<project_name>_<key>` and
`TWX_CFG_<key>` to store the value.
Input files will preferably contain `@TWX_CFG_<key>@` placeholders.

- General info (static values)
  - `NAME`
  - `COPYRIGHT_YEARS`
  - `COPYRIGHT_HOLDERS`
  - `AUTHORS`
- Version (static values)
  - `VERSION_MAJOR`
  - `VERSION_MINOR`
  - `VERSION_PATCH`
  - `VERSION_TWEAK`
- Build (static values)
  - `BUILD_ID`
- Git (dynamic values)
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`

From these are built
- Derived keys:
  - `NAME_LOWER`
  - `NAME_UPPER`
  - `PROJECT_VERSION`
  - `PROJECT_VERSION_SHORT`
  - `GIT_OK`, whether the git information is accurate
- Packaging (static values)
  - `DOC_ICO`
  - `APP_ICO`
  - `WIN_MANIFEST`

NB: This is not base dependent.
*/

Implementation detail:
- one key is not a substring of another.

/*
#]===============================================]

# ANCHOR: twx_configure_file_default_ini
#[=======[
*//**
@brief The project info file
*/
TWX_PROJECT.ini;
/**
@brief set `TWX_PROJECT.ini`

Usefull for testing purposes.

@param ini the path to the `.ini` project info file
  when standard values `${TWX_PROJECT.ini}` or
  `<project source dir>/<project name>.ini` don't match.
*/
twx_configure_file_default_ini ( ini ) {}
/*
#]=======]
function ( twx_configure_file_default_ini ini )
  # ANCHOR: Read file
  if ( NOT EXISTS "${TWX_PROJECT.ini}"
   AND NOT EXISTS "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.ini" )
    set ( TWX_PROJECT.ini "${ini}" )
    twx_export ( TWX_PROJECT.ini )
    if ( TWX_CONFIG_VERBOSE )
      message ( STATUS "TWX_PROJECT.ini => ${TWX_PROJECT.ini}")
    endif ()
  endif ()
endfunction ()

# ANCHOR: twx_configure_file_begin
#[=======[
*//**
@brief Prepare file configuration

Ensure that all the macros are properly defined.

Usage
```
<start of scope>
twx_configure_file_begin ()
...
twx_configure_file_add ( ... )
...
twx_configure_file_end ()
...
<end of scope>
```
Input state:
* `PROJECT_NAME`, required
* `PROJECT_SOURCE_DIR`, required
* `PROJECT_BINARY_DIR`, required
* `TWX_PROJECT.ini`, optional
* `TWX_BUILD_ID`, optional
*/
twx_configure_file_begin () {}
/*
#]=======]
function ( twx_configure_file_begin )
  # ANCHOR: Read file
  set (
    ${PROJECT_NAME}.ini
    "${TWX_PROJECT.ini}"
  )
  if ( NOT EXISTS "${${PROJECT_NAME}.ini}" )
    set (
      ${PROJECT_NAME}.ini
      "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.ini"
    )
    if ( NOT EXISTS "${${PROJECT_NAME}.ini}" )
      set (
        ${PROJECT_NAME}.ini
        "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}.ini"
      )
      if ( NOT EXISTS "${${PROJECT_NAME}.ini}" )
        set (
          ${PROJECT_NAME}.ini
          "${CMAKE_SOURCE_DIR}/${PROJECT_NAME}.ini"
        )
        if ( NOT EXISTS "${ini}" )
          message ( FATAL_ERROR "No ${PROJECT_NAME}.ini" )
        endif ()
      endif ()
    endif ()
  endif ()
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "Parsing ${${PROJECT_NAME}.ini}" )
  endif ()
  # Parse the ini contents
  include ( TwxCfgLib )
  twx_cfg_read ( "${${PROJECT_NAME}.ini}" )
  twx_cfg_write_begin ()
  # verify the expectations
  foreach (
    key
    VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
    COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
  )
    if ( DEFINED TWX_CFG_${key} )
      twx_cfg_set ( "${key}" "${TWX_CFG_${key}}" )
    else ()
      message (
        FATAL_ERROR
        "Missing value for key ${key} in ${PROJECT_NAME}.ini"
      )
    endif ()
  endforeach ()
  # ANCHOR: Git info verification
  set ( GIT_OK )
  foreach ( key GIT_HASH GIT_DATE )
    # We assume that both keys are defined
    if ( DEFINED TWX_CFG_${key} )
      if ( TWX_CFG_${key} MATCHES "\\$Format:.*\\$" )
        twx_cfg_set ( "${key}" "" )
      else ()
        twx_cfg_set ( "${key}" "${TWX_CFG_${key}}" )
        set ( GIT_OK "${GIT_OK}${TWX_CFG_${key}}" )
      endif ()
    else ()
      message (
        FATAL_ERROR
        "Missing value for key ${key} in ${PROJECT_NAME}.ini: ${lines}"
      )
    endif ()
  endforeach ()
  if ( "${GIT_OK}" STREQUAL "" )
    set ( GIT_OK 0 )
  else ()
    set ( GIT_OK 1 )
  endif()
  twx_cfg_set ( GIT_OK "${GIT_OK}" )
  # ANCHOR: Derived version strings, including a short one
  twx_cfg_set (
    PROJECT_VERSION "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}.\
${TWX_CFG_VERSION_PATCH}"
  )
  twx_cfg_set (
    PROJECT_VERSION_SHORT "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}"
  )
  # ANCHOR: NAMING
  twx_cfg_set ( NAME "${PROJECT_NAME}" )
  string ( TOLOWER "${PROJECT_NAME}" s )
  twx_cfg_set ( NAME_LOWER "${s}" )
  string ( TOUPPER "${PROJECT_NAME}" s )
  twx_cfg_set ( NAME_UPPER "${s}" )
  # Packaging
  if ( "${TWX_BUILD_ID}" STREQUAL "" )
    set ( TWX_BUILD_ID "personal" )
    twx_export ( TWX_BUILD_ID )
  endif ()
  twx_cfg_set ( BUILD_ID "${TWX_BUILD_ID}" )
  twx_cfg_write_end ( "static" )
  set (
    TWX_${PROJECT_NAME}_PREPARE_CONFIGURE_FILE_DONE
    ON
    PARENT_SCOPE
  )
  include ( TwxCfgLib )
  twx_cfg_update ()
  set ( ${PROJECT_NAME}_configure_file.in )
  set ( ${PROJECT_NAME}_configure_file.out )
	if ( POLICY CMP0140 )
    return (
      PROPAGATE
      ${PROJECT_NAME}.ini
      ${PROJECT_NAME}_configure_file.in
      ${PROJECT_NAME}_configure_file.out
    )
  else ()
    twx_export ( ${PROJECT_NAME}.ini )
    twx_export ( ${PROJECT_NAME}_configure_file.in )
    twx_export ( ${PROJECT_NAME}_configure_file.out )
    return ()
  endif ()
endfunction ( twx_configure_file_begin )

# ANCHOR: twx_configure_file_add
#[=======[
*//**
@brief Configure some files.

@param added is the name of a variable that contains on return
  the `;` separated list of all the configured files
@param file is a file path in the top source directory `TWX_DIR`.
@param ... more file paths
*/
twx_configure_file_add ( added file ... ) {}
/*
#]=======]
function ( twx_configure_file_add ans )
  set ( ${ans} )
  set ( .in  "${${PROJECT_NAME}_configure_file.in}"  )
  set ( .out "${${PROJECT_NAME}_configure_file.out}" )
  while ( NOT "${ARGN}" STREQUAL "" )
    list ( GET ARGN 0 file.in)
    list ( REMOVE_AT ARGN 0 )
    # make file.in relative to the root directory
    file (
      RELATIVE_PATH
      file.out
      "${TWX_DIR}"
      "${file.in}"
    )
    # Build file.out from file.in
    # This will be related to the current binary directory
    if ( file.out MATCHES "^(.*)\.in$" )
      set (
        file.out
        "${PROJECT_BINARY_DIR}/${CMAKE_MATCH_1}"
      )
    elseif ( file.out MATCHES "^(.*)\.in(\.*)$" )
      set (
        file.out
        "${PROJECT_BINARY_DIR}/${CMAKE_MATCH_1}${CMAKE_MATCH_2}"
      )
    else ()
      message ( FATAL_ERROR "Unsupported: ${file}")
    endif ()
    list ( APPEND .in  "${file.in}"  )
    list ( APPEND .out "${file.out}" )
    # This is where we manage the `src/` header:
    # if ( file.out MATCHES "^src/(.*)")
    #   list ( APPEND ${ans} "${CMAKE_MATCH_1}" )
    # else ()
    #   list ( APPEND ${ans} "${file.out}" )
    # endif ()
    list ( APPEND ${ans} "${file.out}" )
  endwhile ()
  # export
  foreach ( k in out )
    set (
      ${PROJECT_NAME}_configure_file.${k}
      ${.${k}}
      PARENT_SCOPE
    )
  endforeach ()
  twx_export ( ${ans} )
endfunction ( twx_configure_file_add )

# ANCHOR: twx_configure_file_end
#[=======[
*//**
@brief End the `configure_file` grouping.

This is called only once per project.
*/
twx_configure_file_end () {}
/*
#]=======]
function ( twx_configure_file_end )
  if ( TWX_CONFIG_VERBOSE )
    message (
      STATUS
      "twx_configure_file_end: ${PROJECT_NAME}_configure_file.in => ${${PROJECT_NAME}_configure_file.in}"
    )
    message (
      STATUS
      "twx_configure_file_end: ${PROJECT_NAME}_configure_file.out => ${${PROJECT_NAME}_configure_file.out}"
    )
  endif ()
  if ( NOT "${${PROJECT_NAME}_configure_file.out}" STREQUAL "" )
    twx_cfg_path ( stamped "configure_file" STAMPED )
    set (
      target
      ${PROJECT_NAME}_configure_file_target
    )
    if ( NOT TARGET ${target} )
      add_custom_target(
        ${target}
        ALL
        DEPENDS
          ${stamped}
        COMMENT
          "Configure ${PROJECT_NAME} files"
      )
    endif ()
    include ( TwxCfgLib )
    twx_cfg_path ( _path_static static )
    twx_cfg_path ( _path_git git )
    set_property(
      DIRECTORY 
      APPEND 
      PROPERTY CMAKE_CONFIGURE_DEPENDS
      ${${PROJECT_NAME}.ini}
      ${${PROJECT_NAME}_configure_file.in}
      ${_path_static}
      ${_path_git}
    )
    add_custom_command (
      OUTPUT
        ${stamped}
        ${${PROJECT_NAME}_configure_file.out}
      COMMAND
        "${CMAKE_COMMAND}"
          "-DPROJECT_NAME=${PROJECT_NAME}"
          "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
          "-DSOURCE_IN=${${PROJECT_NAME}_configure_file.in}"
          "-DBINARY_OUT=${${PROJECT_NAME}_configure_file.out}"
          -P "${TWX_DIR}/CMake/Include/TwxConfigureFileTool.cmake"
      COMMAND
        "${CMAKE_COMMAND}"
          -E touch ${stamped}
      DEPENDS
        ${${PROJECT_NAME}_configure_file.in}
      COMMENT
        "Configure ${PROJECT_NAME} files"
      VERBATIM
    )
    unset (
      ${PROJECT_NAME}_configure_file.out
      PARENT_SCOPE
    )
  endif ()
endfunction ( twx_configure_file_end )

# ANCHOR: twx_configure_files
#[=======[
*//**
@brief Configure files.

This is a shortcut to
```
twx_configure_file_begin ()
...
twx_configure_file_add ( ... )
...
twx_configure_file_end ()
```
Only one `twx_configure_files` is supported per project.

@param added is the name of a variable that contains on return
  the `;` separated list of all the configured files
@param file is a file path in the top source directory `TWX_DIR`.
@param ... more file paths
*/
twx_configure_files ( added file ... ) {}
/*
#]=======]
function ( twx_configure_files out )
  twx_configure_file_begin ()
  twx_configure_file_add (
    ${out} ${ARGN}
  )
  twx_configure_file_end ()
  twx_export ( ${out} )
endfunction ()

#*/
