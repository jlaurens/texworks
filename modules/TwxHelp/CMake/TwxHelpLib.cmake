#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief This is a pure test file.

Make a build folder and use cmake ... && cmake --build ...
*/
/*#]===============================================]

if ( NOT TWX_IS_BASED )
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
  endif ()
  set (
    TWX_MANUAL_ARCHIVE
    "${TWX_EXTERNAL_DIR}/${CMAKE_MATCH_1}"
  )
  set (
    TWX_MANUAL_BASE
    "${TWX_EXTERNAL_DIR}/${CMAKE_MATCH_2}/texworks-help"
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
  twx_parse_arguments ( "" "DEV;TEST;VERBOSE;URL;ARCHIVE;BASE;SHA256" "" ${ARGN} )
  twx_assert_parsed ()

  if ( EXISTS "${my_twx_ARCHIVE}" )
    file ( SHA256 "${my_twx_ARCHIVE}" actual_sha256_ )
    if ( NOT actual_sha256_ STREQUAL my_twx_SHA256 )
      file ( REMOVE "${my_twx_ARCHIVE}" )
      file ( REMOVE_RECURSE "${my_twx_BASE}" )
    endif ()
  endif ()

  if ( NOT EXISTS "${my_twx_ARCHIVE}" )
    message (
      STATUS
      "Downloading TeXworks HTML manual from ${my_twx_URL}"
    )
    file (
      DOWNLOAD "${my_twx_URL}"
      "${my_twx_ARCHIVE}"
      EXPECTED_HASH SHA256=${my_twx_SHA256}
      SHOW_PROGRESS
    )
  else ( )
    message (
      STATUS "Using archive in '${my_twx_ARCHIVE}'"
    )
  endif ()

  if ( NOT EXISTS "${my_twx_BASE}" )
    message (
      STATUS "Creating '${my_twx_BASE}'"
    )
    file (
      MAKE_DIRECTORY "${my_twx_BASE}"
    )
    execute_process (
      COMMAND unzip "${my_twx_ARCHIVE}"
      WORKING_DIRECTORY "${my_twx_BASE}"
    )
  else ()
    message (
      STATUS "Using '${my_twx_BASE}'"
    )
  endif ()
  twx_assert_exists ( my_twx_BASE )
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
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_URL=${TWX_MANUAL_URL}"
      "-DTWX_ARCHIVE=${TWX_MANUAL_ARCHIVE}"
      "-DTWX_BASE=${TWX_MANUAL_BASE}"
      "-DTWX_SHA256=${TWX_MANUAL_SHA256}"
      "-DTWX_DEV=${TWX_DEV}"
      "-DTWX_TEST=${TWX_TEST}"
      "-DTWX_VERBOSE=${TWX_VERBOSE}"
      -P "${TwxManualCommand.cmake}"
  )
endfunction ()
#*/
