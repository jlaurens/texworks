#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

Updated information related to git.

Usage:
from a target at build time only
```
cmake ... -P .../TwxInfoTool.cmake
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
  - `GIT_OK`

#]===============================================]

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxInfoTool: ${PROJECT_NAME}" )
  message ( STATUS "TwxInfoTool: ${PROJECT_BINARY_DIR}" )
  message ( STATUS "TwxInfoTool: ${TWX_DIR}" )
elseif ( TWX_IS_BASED )
  message ( STATUS "TwxInfoTool" )
endif ()

if ( NOT TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

twx_assert_non_void ( PROJECT_NAME )
twx_assert_non_void ( PROJECT_BINARY_DIR )
twx_assert_non_void ( TWX_DIR )

include ( TwxInfoLib )

message (STATUS "TwxInfoTool:")

twx_info_update ()
