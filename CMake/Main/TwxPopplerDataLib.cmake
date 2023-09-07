#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief This is a pure test file.

Make a build folder and use cmake ... && cmake --build ...
*/
/*#]===============================================]

include_guard ( GLOBAL )

if ( NOT DEFINED /TWX/IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}../Base/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

set (
  TwxPopplerDataScript.cmake
  "${CMAKE_CURRENT_LIST_DIR}/../Script/TwxPopplerDataScript.cmake"
)
twx_assert_exists ( "${TwxPopplerDataScript}".cmake )

# ANCHOR: Utility `twx_poppler_data_setup`
#[=======[
*/
/** @brief Setup state for TeXworks poppler_data
  *
  * Output state:
  * * `TWX_POPPLER_DATA_URL`
  * * `TWX_POPPLER_DATA_SHA256`
  * * `TWX_POPPLER_DATA_ARCHIVE`
  * * `TWX_POPPLER_DATA_BASE`
  *
  */
twx_poppler_data_setup () {}
/*
#]=======]
function ( twx_poppler_data_setup )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  twx_assert_non_void ( TWX_EXTERNAL_DIR )

  include ( TwxCfgLib )
  twx_cfg_setup ()
  twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
  twx_assert_non_void ( /TWX/CFG/POPPLER_DATA_URL )
  twx_assert_non_void ( /TWX/CFG/POPPLER_DATA_SHA256 )

  set ( TWX_POPPLER_DATA_URL "${/TWX/CFG/POPPLER_DATA_URL}" )
  if ( NOT "${TWX_POPPLER_DATA_URL}" MATCHES "/(([^/]+)[.]tar[.]gz$)" )
    twx_fatal ( "Unexpected URL ${TWX_POPPLER_DATA_URL}" )
    return ()
  endif ()
  set (
    TWX_POPPLER_DATA_ARCHIVE
    "${TWX_EXTERNAL_DIR}${CMAKE_MATCH_1}"
  )
  set (
    TWX_POPPLER_DATA_BASE
    "${TWX_EXTERNAL_DIR}${CMAKE_MATCH_2}/texworks-help"
  )
  set ( TWX_POPPLER_DATA_SHA256 "${/TWX/CFG/POPPLER_DATA_SHA256}" )
  twx_export (
    URL SHA256 ARCHIVE BASE
    VAR_PREFIX TWX_POPPLER_DATA
  )
endfunction ()

# ANCHOR: Utility `twx_poppler_data_prepare`
#[=======[
*/
/** @brief Prepare the poppler_data material
  *
  * Central function to download and expand the poppler_data.
  * @param dev for key `DEV`
  */
twx_poppler_data_prepare () {}
/*
#]=======]
function ( twx_poppler_data_prepare )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "DEV;TEST;VERBOSE;URL;ARCHIVE;BASE;SHA256" "" )
  twx_arg_assert_parsed ()

  if ( EXISTS "${twx.R_ARCHIVE}" )
    file ( SHA256 "${twx.R_ARCHIVE}" actual_sha256_ )
    if ( NOT actual_sha256_ STREQUAL twx.R_SHA256 )
      file ( REMOVE "${twx.R_ARCHIVE}" )
      file ( REMOVE_RECURSE "${twx.R_BASE}" )
    endif ()
  endif ()

  if ( NOT EXISTS "${twx.R_ARCHIVE}" )
    message (
      STATUS
      "Downloading Poppler data from ${twx.R_URL}"
    )
    file (
      DOWNLOAD "${twx.R_URL}"
      "${twx.R_ARCHIVE}"
      EXPECTED_HASH SHA256=${twx.R_SHA256}
      SHOW_PROGRESS
    )
  else ( )
    message (
      STATUS "Using archive in '${twx.R_ARCHIVE}'"
    )
  endif ()
  twx_assert_exists ( "${twx.R_ARCHIVE}" )
endfunction ()

# ANCHOR: Utility `twx_poppler_data_process`
#[=======[
*/
/** @brief Alternate method to prepare the poppler_data material
  *
  * Calls `twx_poppler_data_prepare()` through `TwxPopplerDataScript.cmake`.
  */
twx_poppler_data_process () {}
/*
#]=======]
function ( twx_poppler_data_process )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_URL=${TWX_POPPLER_DATA_URL}"
      "-DTWX_ARCHIVE=${TWX_POPPLER_DATA_ARCHIVE}"
      "-DTWX_BASE=${TWX_POPPLER_DATA_BASE}"
      "-DTWX_SHA256=${TWX_POPPLER_DATA_SHA256}"
      "${-DTWX_STATE}"
      -P "${TwxPopplerDataScript.cmake}"
    COMMAND_ERROR_IS_FATAL ANY
  )
endfunction ()

include ( TwxAssertLib )
include ( TwxStateLib )

#*/
