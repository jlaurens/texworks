#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Test suite utility

Utility to setup the test folder.

Usage:
```
include (TwxTestLib)
```
*//*
#]===============================================]

# Guard
if ( COMMAND twx_test_case)
  return ()
endif ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake" )

# ANCHOR: twx_test_case
#[=======[
*//**
@brief Prepare the test working directory for testing executables.

Run from the `CMakeLists.txt` that defines the test.
The target `RUNTIME_OUTPUT_DIRECTORY` property is set to
the build product directory.
We make a copy at a location where we have write access.
The source test case folder is `Test/WorkingDirectory`,
it must exist.
The destination is `<executable>.WorkingDirectory` near the executable.
In order to track the changes, a custom command is used.

@param ans for key VAR, contains on return the full directory path
for the tests.
@param executable for key TARGET, the name of a valid executable

Includes `TwxBase`
*/
twx_test_case ( VAR ans TARGET executable ) {}
/*
#]=======]
function ( twx_test_case )
  if ( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory" )
    twx_fatal ( "No WorkingDirectory" )
  endif ()
  twx_parse_arguments ( "" "VAR;TARGET" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_target ( ${twxR_TARGET} )
  twx_assert_non_void ( twxR_VAR )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  file ( MAKE_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}" )
  set_target_properties (
    ${twxR_TARGET}
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${twxR_VAR}
    "${TWX_PROJECT_PRODUCT_DIR}${twxR_TARGET}.WorkingDirectory"
  )
  if ( NOT "" STREQUAL "" )
  # Remove this branch when done
    set ( temporaryDir_ "${TWX_PROJECT_BUILD_DATA_DIR}Temporary" )
    twx_message_verbose ( "twx_test_case FROM: ${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory")
    file (
      COPY "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory"
      DESTINATION "${temporaryDir_}"
    )
    if ( NOT EXISTS "${temporaryDir_}/WorkingDirectory" )
      twx_fatal ( "COPY FAILED" )
    endif ()
    file (
      REMOVE_RECURSE "${${twxR_VAR}}"
    )
    twx_message_verbose ( "twx_test_case DESTINATION: ${${twxR_VAR}}" )
    file (
      RENAME
        "${temporaryDir_}/WorkingDirectory"
        "${${twxR_VAR}}"
    )
    file (
      REMOVE_RECURSE "${temporaryDir_}"
    )
  else ()
    if ( NOT TARGET ${twxR_TARGET}.WorkingDirectory )
      twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
      set (
        stamped_
        "${TWX_PROJECT_BUILD_DATA_DIR}${twxR_TARGET}.WorkingDirectory.stamped"
      )
      twx_state_serialize ()
      add_custom_command (
        COMMAND "${CMAKE_COMMAND}"
          "-DTWX_TARGET=\"${twxR_TARGET}\""
          "-DTWX_SOURCE_DIR=\"${CMAKE_CURRENT_LIST_DIR}/\""
          "-DTWX_TEMPORARY_DIR=\"${TWX_PROJECT_BUILD_DATA_DIR}Temporary/\""
          "-DTWX_DESTINATION_DIR=\"${TWX_PROJECT_PRODUCT_DIR}\""
          "${TWX_STATE_ARGUMENT}"
          -P "${TWX_DIR}CMake/Command/TwxTestCommand.cmake"
        COMMAND
          "${CMAKE_COMMAND}"
            -E touch "${stamped_}"
        COMMENT
          "Setup ${twxR_TARGET} working directory"
        OUTPUT "${stamped_}"
      )
      add_custom_target (
        ${twxR_TARGET}.WorkingDirectory
        DEPENDS
        "${stamped_}"
      )
    endif ()
    add_dependencies( ${twxR_TARGET} ${twxR_TARGET}.WorkingDirectory )
  endif ()
  twx_export ( ${twxR_VAR} )
endfunction ()
#*/
