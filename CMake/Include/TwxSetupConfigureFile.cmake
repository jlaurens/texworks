#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

It sets up the state for `@...@` macro substitution operated by
`configure_file` instructions. Dynamic values are updated,
mainly related to git. Afterwards, `configure_file` can be used
and all `@...@` macros will be correctly substituted.

Usage:
from a target at build time only
```
include ( TwxSetupConfigureFile )
```
Input:
* `PROJECT_NAME`
* `PROJECT_BINARY_DIR`

Output:
* `<binary_dir>/build_data/<project name>Git.ini`
  is touched any time some info changes such that files must be reconfigured.
* Variables `TWX_INFO_<key>` are defined with `TWX_<project name>_<key>` values
  for each `<key>` defined in `TwxPrepareConfigureFile`.

#]===============================================]

if ( "${PROJECT_NAME}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_NAME" )
endif ()
if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_BINARY_DIR" )
endif ()
if ( "${TWX_${PROJECT_NAME}_PREPARE_CONFIGURE_FILE_DONE}" STREQUAL "" )
  message ( FATAL_ERROR "Run `twx_prepare_configure_file" )
endif ()

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxSetupConfigureFile: ${PROJECT_NAME}" )
  message ( STATUS "TwxSetupConfigureFile: ${PROJECT_BINARY_DIR}" )
  message ( STATUS "TwxSetupConfigureFile: ${TWX_DIR}" )
elseif ( TWX_IS_BASED )
  message ( STATUS "TwxSetupConfigureFile" )
endif ()

if ( NOT TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

# ANCHOR: GIT
# The actual values related to git are
# `TWX_<project name>_GIT_HASH`,
# `TWX_<project name>_GIT_DATE`,
# `TWX_<project name>_GIT_BRANCH`
# `TWX_<project name>_GIT_OK`

find_package ( Git QUIET )

function ( twx__setup_configure_file )

  set ( old_HASH   "${TWX_${PROJECT_NAME}_GIT_HASH}"   )
  set ( old_DATE   "${TWX_${PROJECT_NAME}_GIT_DATE}"   )
  set ( old_BRANCH "${TWX_${PROJECT_NAME}_GIT_BRANCH}" )
  set ( old_OK     "${TWX_${PROJECT_NAME}_GIT_OK}"     )

  set (
    Git.ini
    "${PROJECT_BINARY_DIR}/build_data/${PROJECT_NAME}Git.ini"
  )
  if ( EXISTS "${Git.ini}" )
    file (
      STRINGS "${Git.ini}"
      lines
      ENCODING UTF-8
    )
    # for each line `key = value`
    # the local variable `new_<key>` is set to `<value>`.
    foreach ( key HASH DATE BRANCH OK )
      if ( lines MATCHES "${key}[ ]*=([^>]*)" )
        string ( STRIP CMAKE_MATCH_1 "${CMAKE_MATCH_1}")
        set ( old_${key} "${CMAKE_MATCH_1}" )
      else ()
        message (
          FATAL_ERROR
          "Missing value for key ${key} in ${Git.ini}"
        )
      endif ()
    endforeach ()
  endif ()

  foreach ( key HASH DATE BRANCH OK )
    set ( new_${key} "${old_${key}}" )    
  endforeach ()

  set ( Unavailable "<Unavailable>" )
  set ( new_BRANCH "${Unavailable}" )

  # Try to run git to obtain the last commit hash, date and branch
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
````
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
        set ( new_OK ON )
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

  if (  NOT old_HASH   STREQUAL new_HASH OR
        NOT old_DATE   STREQUAL new_DATE OR
        NOT old_BRANCH STREQUAL new_BRANCH )
    # If everything worked and the data has changed, update the output file
    # The contents of the file is not really relevant
    # it just serves as verification
    file (
      WRITE
      "${Git.ini}"
      "\
  ;READ ONLY
  ;This file is generated automatically by the TWX build system
  [${PROJECT_NAME} git informations]
  GIT_HASH   = ${new_HASH}
  GIT_DATE   = ${new_DATE}
  GIT_BRANCH = ${new_BRANCH}
  GIT_OK     = ${new_OK}
  "
    )
    message ( STATUS "Git commit info updated" )
  endif ()
  # export:
  foreach ( key HASH DATE BRANCH OK )
    set ( TWX_${PROJECT_NAME}_${key} "${new_${key}}" PARENT_SCOPE )    
  endforeach ()

  # if ( NOT TARGET "" )
  #   add_custom_target (

  #   )
  # endif ()
  
endfunction ( twx__setup_configure_file )

twx__setup_configure_file ()

foreach ( key IN LISTS TWX_${PROJECT_NAME}_CONFIGURE_FILE_KEYS )
  set (
    TWX_INFO_${key}
    "${TWX_${PROJECT_NAME}_${key}}"
  )    
endforeach ()

# # ANCHOR: Get the list of all the *.in files (and friends)
# set (
#   list.txt
#   "${TWX_DIR_build}/build_ini/TwxInList.txt"
# )
# if ( NOT EXISTS "${list.txt}" )
#   message ( STATUS "GLOB_RECURSE: CMAKE_SOURCE_DIR => ${CMAKE_SOURCE_DIR}")
#   file (
#     GLOB_RECURSE files_twx
#     RELATIVE "${CMAKE_SOURCE_DIR}"
#     "res/*.in"
#     "res/*.in.*"
#     "src/*.in"
#     "src/*.in.*"
#   )
#   string (
#     REPLACE ";" "\n" files_twx "${files_twx}"
#   )
#   file (
#     WRITE "${list.txt}" ${files_twx}
#   )
# endif ()

# file (
#   STRINGS
#   "${list.txt}"
#   files_twx
#   ENCODING UTF-8
# )
# while ( NOT "${files_twx}" STREQUAL "" )
#   list ( GET files_twx 0 file )
#   list ( REMOVE_AT files_twx 0 )
#   message ( STATUS "file => ${file}" )
#   if ( file MATCHES "(.*)\.in$")
#     set (
#       output
#       "${CMAKE_MATCH_1}"
#     )
#   elseif ( file MATCHES "(.*)\.in(\..*)" )
#     set (
#       output
#       "${CMAKE_MATCH_1}${CMAKE_MATCH_2}"
#     )
#   else ()
#     message ( FATAL_ERROR "Logically unreachable" )
#   endif ()
#   twx_configure_file (
#     "${CMAKE_SOURCE_DIR}/${file}"
#     "${TWX_DIR_build}/${output}"
#     ONLY_CHANGED
#   )
#   if ( TWX_CONFIG_VERBOSE )
#     message ( STATUS "configure_file: ${CMAKE_SOURCE_DIR}/${file} -> ${TWX_DIR_build}/${output}" )
#   endif ()
# endwhile ()

# unset ( files_twx )
