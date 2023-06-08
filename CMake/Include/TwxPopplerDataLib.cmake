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
  TwxPopplerDataCommand.cmake
  "${CMAKE_CURRENT_LIST_DIR}/../Command/TwxPopplerDataCommand.cmake"
)
twx_assert_exists ( TwxPopplerDataCommand.cmake )

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
  twx_assert_non_void ( TWX_CFG_POPPLER_DATA_URL )
  twx_assert_non_void ( TWX_CFG_POPPLER_DATA_SHA256 )

  set ( TWX_POPPLER_DATA_URL "${TWX_CFG_POPPLER_DATA_URL}" )
  if ( NOT "${TWX_POPPLER_DATA_URL}" MATCHES "/(([^/]+)[.]tar[.]gz$)" )
    twx_fatal ( "Unexpected URL ${TWX_POPPLER_DATA_URL}" )
  endif ()
  set (
    TWX_POPPLER_DATA_ARCHIVE
    "${TWX_EXTERNAL_DIR}/${CMAKE_MATCH_1}"
  )
  set (
    TWX_POPPLER_DATA_BASE
    "${TWX_EXTERNAL_DIR}/${CMAKE_MATCH_2}/texworks-help"
  )
  set ( TWX_POPPLER_DATA_SHA256 "${TWX_CFG_POPPLER_DATA_SHA256}" )
  twx_export (
    TWX_POPPLER_DATA_URL
    TWX_POPPLER_DATA_SHA256
    TWX_POPPLER_DATA_ARCHIVE
    TWX_POPPLER_DATA_BASE
  )
endfunction ()

# ANCHOR: Utility `twx_poppler_data_prepare`
#[=======[
*/
/** @brief Prepare the poppler_data material
  *
  * Central function to download and expand the poppler_data.
  */
twx_poppler_data_prepare () {}
/*
#]=======]
function ( twx_poppler_data_prepare )
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
      "Downloading Poppler data from ${my_twx_URL}"
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
  twx_assert_exists ( my_twx_ARCHIVE )
endfunction ()

# ANCHOR: Utility `twx_poppler_data_process`
#[=======[
*/
/** @brief Alternate method to prepare the poppler_data material
  *
  * Calls `twx_poppler_data_prepare()` through `TwxPopplerDataCommand.cmake`.
  */
twx_poppler_data_process () {}
/*
#]=======]
function ( twx_poppler_data_process )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_URL=${TWX_POPPLER_DATA_URL}"
      "-DTWX_ARCHIVE=${TWX_POPPLER_DATA_ARCHIVE}"
      "-DTWX_BASE=${TWX_POPPLER_DATA_BASE}"
      "-DTWX_SHA256=${TWX_POPPLER_DATA_SHA256}"
      "-DTWX_DEV=${TWX_DEV}"
      "-DTWX_TEST=${TWX_TEST}"
      "-DTWX_VERBOSE=${TWX_VERBOSE}"
      -P "${TwxPopplerDataCommand.cmake}"
  )
endfunction ()
#*/
