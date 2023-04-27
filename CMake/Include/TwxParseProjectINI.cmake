#[=======[
This file is part of the TeXworks build system.
It parses `<Project name>.ini`.
Usage:
```
project ( ... )
...
include ( TwxParseProjectINI )

twx_parse_project_INI ( project_name project_source_dir)
```
Input:
* `<project_source_dir>/<project_name>.ini`, required:
  the file to parse.

Output: on success
* Standard variables are set
  - `PROJECT_VERSION`, `<PROJECT-NAME>_VERSION`
  - `PROJECT_VERSION_MAJOR`, `<PROJECT-NAME>_VERSION_MAJOR`
  - `PROJECT_VERSION_MINOR`, `<PROJECT-NAME>_VERSION_MINOR`
  - `PROJECT_VERSION_PATCH`, `<PROJECT-NAME>_VERSION_PATCH`
  - `PROJECT_VERSION_TWEAK`, `<PROJECT-NAME>_VERSION_TWEAK`
* Custom variables
  - `TWX_PROJECT_COPYRIGHT`, `TWX_<PROJECT-NAME>_COPYRIGHT`:
    the short copyright notice
  - `TWX_PROJECT_AUTHORS`, `TWX_<PROJECT-NAME>_AUTHORS`:
    the short authors list
  - `TWX_PROJECT_GIT_HASH_STATIC`, `TWX_<PROJECT-NAME>_GIT_HASH_STATIC`:
    The git commit hash
  - `TWX_PROJECT_GIT_DATE_STATIC`, `TWX_<PROJECT-NAME>_GIT_DATE_STATIC`:
    The git commit date
The `GIT` related variables are only set when the
source tree is retrieved from Github as an archive.
JL
#]=======]

function ( twx_parse_project_INI project_name project_source_dir )
  if ( NOT project_name )
    message (
      FATAL_ERROR
      "Missing argument project_name"
    )
  endif ()
  if ( NOT project_source_dir )
    message (
      FATAL_ERROR
      "Missing argument project_source_dir"
    )
  endif ()
  if ( TWX_${project_name}.ini )
  # already parsed
    return ()
  endif ()
  # ANCHOR: Read file
  set (
    TWX_${project_name}.ini
    "${project_source_dir}/${project_name}.ini"
  )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "Parsing ${TWX_${project_name}.ini}" )
  endif ()
  # Get the file contents in a local variable
  file (
    STRINGS "${TWX_${project_name}.ini}"
    lines_twx
    ENCODING UTF-8
  )
  # for each line <key> = "<value>"
  # the local variable `<key>_` is set to <value>
  foreach (
    k_twx
    VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
    COPYRIGHT AUTHORS
    GIT_HASH GIT_DATE
  )
    if ( lines_twx MATCHES "${k_twx}[^<]*<<<([^>]*)>>>" )
      set ( ${k_twx}_value "${CMAKE_MATCH_1}" )
      message ( STATUS "${k_twx}_value => ${${k_twx}_value}")
    else ()
      message (
        FATAL_ERROR
        "Missing value for key ${k_twx} in ${project_name}.ini"
      )
    endif ()
  endforeach ()

  # ANCHOR: Notice
  foreach ( k_twx COPYRIGHT AUTHORS )
    set (
      TWX_PROJECT_${k_twx}
      "${${k_twx}_value}"
    )
    set (
      TWX_${project_name}_${k_twx}
      "${${k_twx}_value}"
    )
  endforeach ()
  # ANCHOR: Version
  # The version numbers, each time we have 2 variables
  # for the same value.
  # It makes 
  foreach ( k_twx VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK )
    set (
      PROJECT_${k_twx}
      ${${k_twx}_value}
    )
    set (
      ${project_name}_${k_twx}
      ${PROJECT_${k_twx}}
    )
  endforeach ()
  # The version strings
  set (
    PROJECT_VERSION
    "${VERSION_MAJOR_value}.${VERSION_MINOR_value}"
  )
  set (
    ${project_name}_VERSION
    "${PROJECT_VERSION}"
  )
  # ANCHOR: Git info
  foreach ( k_twx GIT_HASH GIT_DATE )
    if ( ${k_twx}_value MATCHES "\\$Format:.*\\$" )
      set (
        TWX_PROJECT_${k_twx}_STATIC
      )
      set (
        TWX_${project_name}_${k_twx}_STATIC
      )
    else ()
      set (
        TWX_PROJECT_${k_twx}_STATIC
        "${${k_twx}_value}"
      )
      set (
        TWX_${project_name}_${k_twx}_STATIC
        "${${k_twx}_value}"
      )
    endif ()
  endforeach ()

  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "PROJECT_VERSION => ${PROJECT_VERSION}" )
    message ( STATUS "PROJECT_VERSION_MAJOR => ${PROJECT_VERSION_MAJOR}" )
    message ( STATUS "PROJECT_VERSION_MINOR => ${PROJECT_VERSION_MINOR}" )
    message ( STATUS "PROJECT_VERSION_PATCH => ${PROJECT_VERSION_PATCH}" )
    message ( STATUS "PROJECT_VERSION_TWEAK => ${PROJECT_VERSION_TWEAK}" )
    message ( STATUS "TWX_PROJECT_COPYRIGHT => ${TWX_PROJECT_COPYRIGHT}" )
    message ( STATUS "TWX_PROJECT_AUTHORS => ${TWX_PROJECT_AUTHORS}" )
    message ( STATUS "TWX_PROJECT_GIT_HASH_STATIC => ${TWX_PROJECT_GIT_HASH_STATIC}" )
    message ( STATUS "TWX_PROJECT_GIT_DATE_STATIC => ${TWX_PROJECT_GIT_DATE_STATIC}" )
  endif ()
  # Export
  foreach ( k_twx VERSION VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK )
    set ( PROJECT_${k_twx} "${PROJECT_${k_twx}}" PARENT_SCOPE )
    set ( ${PROJECT_NAME}_${k_twx} "${${PROJECT_NAME}_${k_twx}}" PARENT_SCOPE )
  endforeach ()
  foreach ( k_twx COPYRIGHT AUTHORS GIT_HASH_STATIC GIT_DATE_STATIC )
    set ( TWX_PROJECT_${k_twx} "${TWX_PROJECT_${k_twx}}" PARENT_SCOPE )
    set ( TWX_${PROJECT_NAME}_${k_twx} "${TWX_${PROJECT_NAME}_${k_twx}}" PARENT_SCOPE )
  endforeach ()
  set (
    TWX_${project_name}.ini
    "TWX_${project_name}.ini"
    PARENT_SCOPE
  )
endfunction ()

