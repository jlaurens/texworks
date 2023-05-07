#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

Updated information related to git.

Usage:
from a target at build time only
```
include ( TwxUpdateGit )
```
Input:
* `PROJECT_NAME`
* `PROJECT_BINARY_DIR`

Output:
* `<binary_dir>/build_data/<project name>Git.ini`
  is touched any time some info changes such that files must be reconfigured.
* `TWX_<project name>_INFO_<key>` when `<key>` is one of
  - `GIT_HASH`
  - `Git_DATE`
  - `GIT_BRANCH`

#]===============================================]

if ( "${PROJECT_NAME}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_NAME" )
endif ()
if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Undefined PROJECT_BINARY_DIR" )
endif ()

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxUpdateGit: ${PROJECT_NAME}" )
  message ( STATUS "TwxUpdateGit: ${PROJECT_BINARY_DIR}" )
  message ( STATUS "TwxUpdateGit: ${TWX_DIR}" )
elseif ( TWX_IS_BASED )
  message ( STATUS "TwxUpdateGit" )
endif ()

if ( NOT TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

# ANCHOR: GIT
# The actual values related to git are
# `TWX_<project name>_INFO_GIT_HASH`,
# `TWX_<project name>_INFO_GIT_DATE`,
# `TWX_<project name>_INFO_GIT_BRANCH`
# `TWX_<project name>_INFO_GIT_OK`

find_package ( Git QUIET )

function ( twx__update_git )

  set ( old_HASH   "${TWX_${PROJECT_NAME}_INFO_GIT_HASH}"   )
  set ( old_DATE   "${TWX_${PROJECT_NAME}_INFO_GIT_DATE}"   )
  set ( old_BRANCH "${TWX_${PROJECT_NAME}_INFO_GIT_BRANCH}" )
  set ( old_OK     "${TWX_${PROJECT_NAME}_INFO_GIT_OK}"     )

  include ( TwxInfoLib )
  
  twx_info_read ( GIT QUIET )
  
  if ( NOT TWX_INFO_READ_FAILED )
    foreach ( key HASH DATE BRANCH OK )
      set ( old_${key} "${TWX_INFO_${key}}" )
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
    include ( TwxInfoLib )
    twx_info_write_begin ()
    twx_info_set ( GIT_HASH   "${new_HASH}"   )
    twx_info_set ( GIT_DATE   "${new_DATE}"   )
    twx_info_set ( GIT_BRANCH "${new_BRANCH}" )
    twx_info_set ( GIT_OK     "${new_OK}"     )
    twx_info_write_end ( GIT )
    message ( STATUS "Git commit info updated" )
  endif ()

endfunction ( twx__update_git )

twx__update_git ()
