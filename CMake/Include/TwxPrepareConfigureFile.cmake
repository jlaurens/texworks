#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

It prepares the context for `@...@` macro substitution operated by
`configure_file` instructions. It deals with static informations
that are known at configuration time and are not subject to change
for each build.

Usage:
at configuration time only
```
include ( TwxPrepareConfigureFile )
```
Input:
* `PROJECT_NAME`, required
* `PROJECT_SOURCE_DIR`, required
* `PROJECT_BINARY_DIR`, required
* `TWX_PROJECT.ini`, optional
* `TWX_BUILD_ID`, optional
* One of the files at `TWX_PROJECT.ini` or
  `<project source dir>/<project name>.ini` is required

Output:
* Cached entries `TWX_<project name>_<key>` where `<key>`
  is one of the static keys in `<project name>.ini`.
* `twx_configure_file_add` function.
* `Twx<Project name>ConfigureFile_target`

Here is the static list of recognized keys from `<project name>.ini`.
Other keys can be used but they must be managed elsewhere.
For each `<key>` we have `TWX_<project_name>_<key>`
to store the value.
* General info (static values)
  - `NAME`
  - `COPYRIGHT_YEARS`
  - `COPYRIGHT_HOLDERS`
  - `AUTHORS`
* Version (static values)
  - `VERSION_MAJOR`
  - `VERSION_MINOR`
  - `VERSION_PATCH`
  - `VERSION_TWEAK`
* Build (static values)
  - `BUILD_ID`
* Git (dynamic values)
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`

Implementation detail:
* one key is not a substring of another.

From these are built
* Derived keys:
  - `NAME_LOWER`
  - `NAME_UPPER`
  - `PROJECT_VERSION`
  - `PROJECT_VERSION_SHORT`
  - `GIT_OK`, whether the git information is accurate
* Packaging (static values)
  - `DOC_ICO`
  - `APP_ICO`
  - `WIN_MANIFEST`

NB: This is not base dependent.

#]===============================================]

if ( "${PROJECT_NAME}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_NAME" )
endif ()
if ( "${PROJECT_SOURCE_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_SOURCE_DIR" )
endif ()
if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_BINARY_DIR" )
endif ()
if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxPrepareConfigureFile: ${PROJECT_NAME}" )
  message ( STATUS "TwxPrepareConfigureFile: ${PROJECT_SOURCE_DIR}" )
  message ( STATUS "TwxPrepareConfigureFile: ${PROJECT_BINARY_DIR}" )
elseif ( TWX_IS_BASED )
  message ( STATUS "TwxPrepareConfigureFile" )
else ()
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

# Use a private function for local variables only
function ( twx__prepare_configure_file )
  # ANCHOR: Read file
  set (
    ini
    "${TWX_PROJECT.ini}"
  )
  if ( NOT EXISTS "${ini}" )
    set (
      ini
      "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.ini"
    )
    if ( NOT EXISTS "${ini}" )
      message ( FATAL_ERROR "No ${PROJECT_NAME}.ini" )
    endif ()
  endif ()
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "Parsing ${ini}" )
  endif ()
  # Parse the ini contents
  include ( TwxInfoLib )
  twx_info_read ( "${ini}" )
  twx_info_write_begin ()
  # verify the expectations
  foreach (
    key
    VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
    COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
  )
    if ( DEFINED TWX_INFO_${key} )
      twx_info_set ( "${key}" "${TWX_INFO_${key}}" )
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
    if ( DEFINED TWX_INFO_${key} )
      if ( TWX_INFO_${key} MATCHES "\\$Format:.*\\$" )
        twx_info_set ( "${key}" "" )
      else ()
        twx_info_set ( "${key}" "${TWX_INFO_${key}}" )
        set ( GIT_OK "${GIT_OK}${TWX_INFO_${key}}" )
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
  twx_info_set ( GIT_OK "${GIT_OK}" )
  # ANCHOR: Derived version strings, including a short one
  twx_info_set (
    PROJECT_VERSION "\
${TWX_INFO_VERSION_MAJOR}.\
${TWX_INFO_VERSION_MINOR}.\
${TWX_INFO_VERSION_PATCH}"
  )
  twx_info_set (
    PROJECT_VERSION_SHORT "\
${TWX_INFO_VERSION_MAJOR}.\
${TWX_INFO_VERSION_MINOR}"
  )
  # ANCHOR: NAMING
  twx_info_set ( NAME "${PROJECT_NAME}" )
  string ( TOLOWER "${PROJECT_NAME}" s )
  twx_info_set ( NAME_LOWER "${s}" )
  string ( TOUPPER "${PROJECT_NAME}" s )
  twx_info_set ( NAME_UPPER "${s}" )
  # Packaging
  if ( "${TWX_BUILD_ID}" STREQUAL "" )
    set ( TWX_BUILD_ID "personal" )
    set ( TWX_BUILD_ID "${TWX_BUILD_ID}" PARENT_SCOPE)
  endif ()
  twx_info_set ( BUILD_ID "${TWX_BUILD_ID}" )
  twx_info_set (
    DOC_ICO
    "${TWX_DIR}/res/images/TeXworks-doc.ico"
  )
  twx_info_set (
    APP_ICO
    "${TWX_DIR}/res/images/TeXworks.ico"
  )
  # The manifest is built by `configure_file`
  twx_info_set (
    WIN_MANIFEST
    "${PROJECT_BINARY_DIR}/res/winOS/TeXworks.exe.manifest"
  )
  twx_info_write_end ( STATIC )
  set (
    TWX_${PROJECT_NAME}_PREPARE_CONFIGURE_FILE_DONE
    ON
    PARENT_SCOPE
  )
endfunction ( twx__prepare_configure_file )

twx__prepare_configure_file ()
include ( TwxInfoGitUpdate )
twx_info_configure_depends ()

if ( NOT TARGET ${PROJECT_NAME}_configure_file_target )
  set (${PROJECT_NAME}_configure_file.in)
  set (${PROJECT_NAME}_configure_file.out)
# add_custom_command(
#   OUTPUT table.csv
#   COMMAND makeTable -i ${CMAKE_CURRENT_SOURCE_DIR}/input.dat
#                     -o table.csv
#   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/input.dat
#   VERBATIM)
# add_custom_target(generate_table_csv DEPENDS table.csv)

# add_custom_command(
#   OUTPUT foo.cxx
#   COMMAND genFromTable -i table.csv -case foo -o foo.cxx
#   DEPENDS table.csv           # file-level dependency
#           generate_table_csv  # target-level dependency
#   VERBATIM)
# add_library(foo foo.cxx)

# add_custom_command(
#   OUTPUT bar.cxx
#   COMMAND genFromTable -i table.csv -case bar -o bar.cxx
#   DEPENDS table.csv           # file-level dependency
#           generate_table_csv  # target-level dependency
#   VERBATIM)
# add_library(bar bar.cxx)
endif ()

# ANCHOR: twx_configure_file_add
#[=======[
This is called at the top level
If any added file belongs to the top `src` directory,
the `src/` component is removed.
#]=======]
function ( twx_configure_file_add ans )
  set ( ${ans} )
  set ( *.in  "${${PROJECT_NAME}_configure_file.in}"  )
  set ( *.out "${${PROJECT_NAME}_configure_file.out}" )
  while ( NOT "${ARGN}" STREQUAL "" )
    list ( GET ARGN 0 file.in)
    list ( REMOVE_AT ARGN 0 )
    # make file.in relative to the root directory
    # file (
    #   RELATIVE_PATH
    #   file.in
    #   "${TWX_DIR}"
    #   "${file.in}"
    # )
    # Build file.out from file.in
    # This will be related to the binary directory
    if ( file.in MATCHES "^(.*)\.in$" )
      set ( file.out "${CMAKE_MATCH_1}" )
    elseif ( file.in MATCHES "^(.*)\.in(\.*)$" )
      set ( file.out "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
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
  set ( ${ans} ${${ans}} PARENT_SCOPE )
endfunction ( twx_configure_file_add )

# ANCHOR: twx_configure_file_proceed
#[=======[
This is called at the top level
#]=======]
function ( twx_configure_file_proceed )
  if ( TWX_CONFIG_VERBOSE )
    message (
      STATUS
      "twx_configure_file_proceed: ${PROJECT_NAME}_configure_file.in => ${${PROJECT_NAME}_configure_file.in}"
    )
    message (
      STATUS
      "twx_configure_file_proceed: ${PROJECT_NAME}_configure_file.out => ${${PROJECT_NAME}_configure_file.out}"
    )
  endif ()
  if ( NOT "${${PROJECT_NAME}_configure_file.out}" STREQUAL "" )
    set (
      stamped
      "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}_configure_file.stamped"
    )
    add_custom_target(
      ${PROJECT_NAME}_configure_file_target
      ALL
      DEPENDS
        ${stamped}
        ${${PROJECT_NAME}_configure_file.out}
        ${${PROJECT_NAME}_configure_file.in}
      COMMENT
        "Configure ${PROJECT_NAME} files (Umbrella target)"
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
          -P "${TWX_DIR}/CMake/Include/TwxConfigureFiles.cmake"
      COMMAND
        "${CMAKE_COMMAND}"
          -E touch ${stamped}
      DEPENDS
        ${${PROJECT_NAME}_configure_file.in}
        "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Static.ini"
        "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Git.ini"
      COMMENT
        "Configure ${PROJECT_NAME} files"
      VERBATIM
    )
    unset (
      ${PROJECT_NAME}_configure_file.out
      PARENT_SCOPE
    )
  endif ()
endfunction ( twx_configure_file_proceed )

