#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Test unit utility
  *
  * Utility to setup the test folder.
  *
  * Usage:
  *
  *   include ( TwxUnitLib )
  *
  */
/*
#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_unit_case
#[=======[
*/
/** @brief Prepare the test working directory for testing executables.
  *
  * Run from the `CMakeLists.txt` that defines the test with
  * àdd_executable ()`.
  *
  * - The executable `RUNTIME_OUTPUT_DIRECTORY` property is set to
  * the build product directory.
  * - The source test case folder is `Test/WorkingDirectory`,
  * it must exist.
  * - The destination is `<executable>.WorkingDirectory` near the executable.
  * We make a copy at a location where we have write access.
  * - In order to track the changes, a custom command is used.
  *
  * @param executable for key `TARGET`, the name of a valid test executable
  * @param ans for key `IN_VAR`, contains on return the full directory path
  * for the tests.
  *
  * Includes `TwxBase`
  */
twx_unit_case ( TARGET executable IN_VAR ans ) {}
/*
#]=======]
function ( twx_unit_case )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  # State
  twx_assert_exists ( "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory/" )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  file ( MAKE_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}" )
  # API
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR;TARGET" ""
  )
  twx_arg_assert_parsed ()
  twx_assert_target ( "${twx.R_TARGET}" )
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  # Job
  set_target_properties (
    ${twx.R_TARGET}
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${twx.R_IN_VAR}
    "${TWX_PROJECT_PRODUCT_DIR}${twx.R_TARGET}.WorkingDirectory/"
  )
  if ( NOT TARGET ${twx.R_TARGET}.WorkingDirectory )
    twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
    set (
      stamped_
      "${TWX_PROJECT_BUILD_DATA_DIR}${twx.R_TARGET}.WorkingDirectory.stamped"
    )
    twx_state_serialize ()
    add_custom_command (
      COMMAND "${CMAKE_COMMAND}"
        "-DTWX_TARGET=\"${twx.R_TARGET}\""
        "-DTWX_SOURCE_DIR=\"${CMAKE_CURRENT_LIST_DIR}/\""
        "-DTWX_TEMPORARY_DIR=\"${TWX_PROJECT_BUILD_DATA_DIR}Temporary/\""
        "-DTWX_DESTINATION_DIR=\"${TWX_PROJECT_PRODUCT_DIR}\""
        "${-DTWX_STATE}"
        -P "${TWX_DIR}CMake/Script/TwxUnitScript.cmake"
      COMMAND
        "${CMAKE_COMMAND}"
          -E touch "${stamped_}"
      COMMENT
        "Setup ${twx.R_TARGET} working directory"
      OUTPUT "${stamped_}"
    )
    add_custom_target (
      ${twx.R_TARGET}.WorkingDirectory
      DEPENDS
      "${stamped_}"
    )
  endif ()
  add_dependencies( ${twx.R_TARGET} ${twx.R_TARGET}.WorkingDirectory )
  twx_export ( ${twx.R_IN_VAR} )
endfunction ()

twx_lib_require ( "Dir" )

twx_lib_did_load ()
#*/
