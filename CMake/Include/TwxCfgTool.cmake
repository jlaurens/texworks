#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Updated Cfg data

Mainly related to git.
A straightforward front end to `twx_cfg_update()`.

Usage:
from a target at build time only
```
cmake ... -P .../CMake/Include/TwxCfgTool.cmake
```
Used by `twx_cfg_setup()`.
*//*
#]===============================================]

if ( NOT TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

twx_assert_non_void ( PROJECT_NAME )
twx_assert_non_void ( PROJECT_BINARY_DIR )
twx_assert_non_void ( TWX_DIR )

include ( TwxCfgLib )

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxCfgTool: ${PROJECT_NAME}" )
  message ( STATUS "TwxCfgTool: ${PROJECT_BINARY_DIR}" )
  message ( STATUS "TwxCfgTool: ${TWX_DIR}" )
endif ()

twx_cfg_update ()

#*/
