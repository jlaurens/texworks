#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief This is a pure test file.

Make a build folder and use cmake ... && cmake --build ...
*/
/*#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

set (
  TwxManualCommand.cmake
  "${CMAKE_CURRENT_LIST_DIR}/../Command/TwxManualCommand.cmake"
)
twx_assert_exists ( TwxManualCommand.cmake )

# ANCHOR: Utility `twx_manual_setup`
#[=======[
*/
/** @brief Setup state for TeXworks manual
  *
  * Output state:
  * * `TWX_MANUAL_URL`
  * * `TWX_MANUAL_SHA256`
  * * `TWX_MANUAL_ARCHIVE`
  * * `TWX_MANUAL_BASE`
  *
  */
twx_manual_setup () {}
/*
#]=======]
function ( twx_manual_setup )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  twx_assert_non_void ( TWX_EXTERNAL_DIR )

  include ( TwxCfgLib )
  twx_cfg_setup ()
  twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
  twx_assert_non_void ( TWX_CFG_MANUAL_HTML_URL )
  twx_assert_non_void ( TWX_CFG_MANUAL_HTML_SHA256 )

  set ( TWX_MANUAL_URL "${TWX_CFG_MANUAL_HTML_URL}" )
  if ( NOT "${TWX_MANUAL_URL}" MATCHES "/(([^/]+)[.]zip)" )
    twx_fatal ( "Unexpected URL ${TWX_MANUAL_URL}" )
    return ()
  endif ()
  set (
    TWX_MANUAL_ARCHIVE
    "${TWX_EXTERNAL_DIR}${CMAKE_MATCH_1}"
  )
  set (
    TWX_MANUAL_BASE
    "${TWX_EXTERNAL_DIR}${CMAKE_MATCH_2}/texworks-help"
  )
  set ( TWX_MANUAL_SHA256 "${TWX_CFG_MANUAL_HTML_SHA256}" )
  twx_export (
    TWX_MANUAL_URL
    TWX_MANUAL_SHA256
    TWX_MANUAL_ARCHIVE
    TWX_MANUAL_BASE
  )
endfunction ()

# ANCHOR: Utility `twx_manual_prepare`
#[=======[
*/
/** @brief Prepare the manual material
  *
  * Central function to download and expand the manual.
  */
twx_manual_prepare () {}
/*
#]=======]
function ( twx_manual_prepare )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "DEV;TEST;VERBOSE;URL;ARCHIVE;BASE;SHA256" "" )
  twx_arg_assert_parsed ()

  if ( EXISTS "${twxR_ARCHIVE}" )
    file ( SHA256 "${twxR_ARCHIVE}" actual_sha256_ )
    if ( NOT actual_sha256_ STREQUAL twxR_SHA256 )
      file ( REMOVE "${twxR_ARCHIVE}" )
      file ( REMOVE_RECURSE "${twxR_BASE}" )
    endif ()
  endif ()

  if ( NOT EXISTS "${twxR_ARCHIVE}" )
    message (
      STATUS
      "Downloading TeXworks HTML manual from ${twxR_URL}"
    )
    file (
      DOWNLOAD "${twxR_URL}"
      "${twxR_ARCHIVE}"
      EXPECTED_HASH SHA256=${twxR_SHA256}
      SHOW_PROGRESS
    )
  else ( )
    message (
      STATUS "Using archive in '${twxR_ARCHIVE}'"
    )
  endif ()

  if ( NOT EXISTS "${twxR_BASE}" )
    message (
      STATUS "Creating '${twxR_BASE}'"
    )
    file (
      MAKE_DIRECTORY "${twxR_BASE}"
    )
    execute_process (
      COMMAND unzip "${twxR_ARCHIVE}"
      WORKING_DIRECTORY "${twxR_BASE}"
    )
  else ()
    message (
      STATUS "Using '${twxR_BASE}'"
    )
  endif ()
  twx_assert_exists ( twxR_BASE )
endfunction ()

# ANCHOR: Utility `twx_manual_process`
#[=======[
*/
/** @brief Alternate method to prepare the manual material
  *
  * Calls `twx_manual_prepare()` through `TwxManualCommand.cmake`.
  */
twx_manual_process () {}
/*
#]=======]
function ( twx_manual_process )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_URL=${TWX_MANUAL_URL}"
      "-DTWX_ARCHIVE=${TWX_MANUAL_ARCHIVE}"
      "-DTWX_BASE=${TWX_MANUAL_BASE}"
      "-DTWX_SHA256=${TWX_MANUAL_SHA256}"
      "${TWX-D_STATE}"
      -P "${TwxManualCommand.cmake}"
  )
endfunction ()
#*/
