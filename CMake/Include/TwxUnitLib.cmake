#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Test suite utility
  *
  * Utility to setup the test folder.
  *
  * Usage:
  * ```
  * include (TwxTestLib)
  * ```
  *//*
#]===============================================]

include_guard ( GLOBAL )

# Guard
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
  NO_POLICY_SCOPE
)

# ANCHOR: twx_unit_case
#[=======[
*//** @brief Prepare the test working directory for testing executables.
  *
  * Run from the `CMakeLists.txt` that defines the test.
  * The target `RUNTIME_OUTPUT_DIRECTORY` property is set to
  * the build product directory.
  * We make a copy at a location where we have write access.
  * The source test case folder is `Test/WorkingDirectory`,
  * it must exist.
  * The destination is `<executable>.WorkingDirectory` near the executable.
  * In order to track the changes, a custom command is used.
  *
  * @param ans for key `VAR`, contains on return the full directory path
  * for the tests.
  * @param executable for key `TARGET`, the name of a valid executable
  *
  * Includes `TwxBase`
  */
twx_unit_case ( IN_VAR ans TARGET executable ) {}
/*
#]=======]
function ( twx_unit_case )
  if ( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory/" )
    message ( FATAL_ERROR "No WorkingDirectory" )
  endif ()
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "IN_VAR;TARGET" "" )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Too many arguments: \"${twx.R_UNPARSED_ARGUMENTS}\"" )
  endif ()
  if ( NOT TARGET "${twx.R_TARGET}" )
    message ( FATAL_ERROR "Unknown target \"${twx.R_TARGET}\"" )
  endif ()
  if ( NOT "${twx.R_IN_VAR}" MATCHES "[^ ]" )
    message ( FATAL_ERROR "Bad variable name \"${twx.R_IN_VAR}\"" )
  endif ()
  if ( NOT "${TWX_PROJECT_PRODUCT_DIR}" MATCHES "[^ ]" )
    message ( FATAL_ERROR "Undefined TWX_PROJECT_PRODUCT_DIR" )
  endif ()
  file ( MAKE_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}" )
  set_target_properties (
    ${twx.R_TARGET}
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${twx.R_IN_VAR}
    "${TWX_PROJECT_PRODUCT_DIR}${twx.R_TARGET}.WorkingDirectory"
  )
  if ( NOT "" STREQUAL "" )
  # Remove this branch when done
    set ( temporaryDir_ "${TWX_PROJECT_BUILD_DATA_DIR}Temporary" )
    twx_message ( VERBOSE "twx_unit_case FROM: ${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory")
    file (
      COPY "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory"
      DESTINATION "${temporaryDir_}"
    )
    if ( NOT EXISTS "${temporaryDir_}/WorkingDirectory" )
      twx_fatal ( "COPY FAILED" )
      return ()
    endif ()
    file (
      REMOVE_RECURSE "${${twx.R_IN_VAR}}"
    )
    twx_message ( VERBOSE "twx_unit_case DESTINATION: ${${twx.R_IN_VAR}}" )
    file (
      RENAME
        "${temporaryDir_}/WorkingDirectory"
        "${${twx.R_IN_VAR}}"
    )
    file (
      REMOVE_RECURSE "${temporaryDir_}"
    )
  else ()
    if ( NOT TARGET ${twx.R_TARGET}.WorkingDirectory )
      if ( "${TWX_PROJECT_BUILD_DATA_DIR}" STREQUAL "" )
        twx_fatal ( "Undefined TWX_PROJECT_BUILD_DATA_DIR" )
        return ()
      endif ()
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
          -P "${TWX_DIR}CMake/Script/TwxTestScript.cmake"
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
  endif ()
  twx_export ( ${twx.R_IN_VAR} )
endfunction ()

message ( DEBUG "TwxTestLib loaded" )
#*/
