#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Download and expand the TeXworks manual.

Usage:
```
  cmake -DPROJECT_BINARY_DIR="... -P .../TwxManualCommand.cmake
```

Loads `TwxBase`.

Input state:
- `PROJECT_BINARY_DIR`

Output state: the directory `<current binary dir>/TwxManual`
contains both the downloaded `zip` archive and its expansion.

It is not strong enough to recognize a change in the inflated files.
If these files are edited or deleted then the build system is not informed.
*/
/*#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_message_verbose ( STATUS "THIS IS TwxManualCommand.cmake" )

twx_assert_non_void ( PROJECT_BINARY_DIR )
twx_assert_non_void ( TWX_MANUAL_DIR )

include ( TwxCfgLib )
twx_cfg_setup ()
twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
twx_assert_non_void ( TWX_CFG_MANUAL_HTML_URL )
twx_assert_non_void ( TWX_CFG_MANUAL_HTML_SHA256 )

if ( NOT "${TWX_CFG_MANUAL_HTML_URL}" MATCHES "/(([^/]+)[.]zip)" )
  twx_fatal ( "Unexpected URL ${TWX_CFG_MANUAL_HTML_URL}" )
endif ()
set (
  manual_archive_
  "${TWX_MANUAL_DIR}/${CMAKE_MATCH_1}"
)
set (
  manual_base_
  "${TWX_MANUAL_DIR}/${CMAKE_MATCH_2}"
)
# Download and install TeXworks manual
# ------------------------------------

if ( EXISTS "${manual_archive_}" )
  file ( SHA256 "${manual_archive_}" actual_sha256_ )
  if ( NOT actual_sha256_ STREQUAL TWX_CFG_MANUAL_HTML_SHA256 )
    file ( REMOVE "${manual_archive_}" )
    file ( REMOVE_RECURSE "${manual_base_}" )
  endif ()
endif ()

if ( NOT EXISTS "${manual_archive_}" )
  message (
    STATUS
    "Downloading TeXworks HTML manual from ${TWX_CFG_MANUAL_HTML_URL}"
  )
  file (
    DOWNLOAD "${TWX_CFG_MANUAL_HTML_URL}"
    "${manual_archive_}"
    EXPECTED_HASH SHA256=${TWX_CFG_MANUAL_HTML_SHA256}
    SHOW_PROGRESS
  )
else ( )
  message (
    STATUS "Using archive in '${manual_archive_}'"
  )
endif ()

if ( NOT EXISTS "${manual_base_}" )
  message (
    STATUS "Creating '${manual_base_}'"
  )
  file (
    MAKE_DIRECTORY "${manual_base_}"
  )
  execute_process (
    COMMAND unzip "${manual_archive_}"
    WORKING_DIRECTORY "${manual_base_}"
  )
else ()
  message (
    STATUS "Using '${manual_base_}'"
  )
endif ()
twx_assert_exists ( manual_base_ )
