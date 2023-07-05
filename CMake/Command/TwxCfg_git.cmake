#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Update the git Cfg data file.

Usage:
```
cmake ... -P .../CMake/Command/TwxCfg_git.cmake
```

Expected input state:

- `TWX_CFG_INI_DIR`
- `TWX_TEST` optional

Expected side effects:

- `<binary_dir>/TwxBuildData/<project name>-git.ini`
  is touched any time some data changes such that files must be reconfigured.
- When read, `TWX_<project name>_CFG_<key>` when `<key>` is one of
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`
  - `GIT_OK`
*//*
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()
twx_state_deserialize ()

twx_message ( VERBOSE "TwxCfg_git:" DEEPER )

include ( TwxCfgLib )

twx_cfg_read ( "factory" ONLY_CONFIGURE )
twx_cfg_read ( "git" QUIET ONLY_CONFIGURE )

foreach ( key HASH DATE OK )
  set ( new_${key} "${TWX_CFG_GIT_${key}}" )  
endforeach ()

set ( Unavailable "<Unavailable>" )
set ( new_BRANCH "${Unavailable}" )

# Try to run git to obtain the last commit hash, date and branch
find_package ( Git QUIET )
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
```
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
  if (  "${result_HASH}"   EQUAL "0" AND
        "${result_DATE}"   EQUAL "0" AND
        "${result_BRANCH}" EQUAL "0" AND
      NOT "${new_HASH}" STREQUAL "" AND
      NOT "${new_DATE}" STREQUAL "" AND
      NOT "${new_BRANCH}" STREQUAL "" )
    set ( new_OK ${TWX_CPP_TRUTHY_CFG} )
    execute_process (
      COMMAND "${GIT_EXECUTABLE}"
        "--git-dir=.git" "diff" "--ignore-cr-at-eol" "--quiet" "HEAD"
      WORKING_DIRECTORY "${TWX_DIR}"
      RESULT_VARIABLE MODIFIED_RESULT_twx
    )
    if ( "${MODIFIED_RESULT_twx}" EQUAL "1" )
      set( new_HASH "${new_HASH}*")
    endif ()
  endif ()
endif ( GIT_FOUND )

if ( TWX_TEST )
  twx_cfg_write_begin ( ID "git" )
  foreach (key_ HASH BRANCH)
    twx_cfg_set ( GIT_${key_} "TEST(${key_}):${new_${key_}}" )
  endforeach ()
  twx_cfg_set ( GIT_DATE "1978-07-06T05:04:03+02:01" )
  twx_cfg_set ( GIT_OK ${TWX_CPP_TRUTHY_CFG} )
  twx_cfg_write_end ()
  twx_message ( DEBUG "TwxCfg_git: Git commit info updated (TEST)" )
else ()
  twx_cfg_write_begin ( ID "git" )
  foreach ( key_ HASH DATE BRANCH OK )
    twx_cfg_set ( GIT_${key_} "${new_${key_}}" )
  endforeach ()
  twx_cfg_write_end ( ID "git" )
  twx_message ( DEBUG "TwxCfg_git: Git commit info updated" )
endif ()

#*/
