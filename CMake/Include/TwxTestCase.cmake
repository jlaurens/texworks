#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Test suite utility

Utility to setup the test folder.

Usage:
```
include (TwxTestCase)
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
Prepare the test working directory for testing executables.
Run from the `CMakeLists.txt` that defines the test.
The target `RUNTIME_OUTPUT_DIRECTORY` property is set to
the build product directory.
We make a copy at a location where we have write access.
The source test case folder is `Test/WorkingDirectory`,
The destination is `<executable>.WorkingDirectory` near the executable.
In order to track the changes, a custom command is used.

@param executable the name of a valid executable
@param variable contains on return the full directory path
for the tests on return.

Includes `TwxBase`
*/
twx_test_case ( variable TARGET executable ) {}
/*
#]=======]
function ( twx_test_case variable_twx TARGET target_twx )
  twx_assert_equal ( TARGET "${TARGET}" )
  twx_assert_target ( target_twx )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  set (
    destination_DIR_twx
    "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set_target_properties (
    ${target_twx}
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${variable_twx}
    "${destination_DIR_twx}/${target_twx}.WorkingDirectory"
  )
  set (
    stamped_twx
    "${TWX_PROJECT_BUILD_DATA_DIR}/${target_twx}.WorkingDirectory.stamped"
  )
  add_custom_command (
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_TARGET=\"${target_twx}\""
      "-DTWX_SOURCE_DIR=\"${CMAKE_CURRENT_LIST_DIR}\""
      "-DTWX_TEMPORARY_DIR=\"${TWX_PROJECT_BUILD_DATA_DIR}/Temporary\""
      "-DTWX_DESTINATION_DIR=\"${destination_DIR_twx}\""
      "-DTWX_VERBOSE=${TWX_VERBOSE}"
      "-DTWX_TEST=${TWX_TEST}"
      -P "${TWX_DIR}/CMake/Command/TwxTestCaseCommand.cmake"
    COMMAND
      "${CMAKE_COMMAND}"
        -E touch "${stamped_twx}"
    COMMENT
      "Setup ${target_twx} working directory"
    OUTPUT "${stamped_twx}"
  )
  add_custom_target (
    ${target_twx}.WorkingDirectory
    DEPENDS
    "${stamped_twx}"
  )
  add_dependencies( ${target_twx} ${target_twx}.WorkingDirectory )
  twx_export ( ${variable_twx} )
endfunction ()
#*/
