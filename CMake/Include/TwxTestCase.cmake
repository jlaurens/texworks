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
Includes `TwxCoreLib`.
*//*
#]===============================================]

# Guard
if ( COMMAND twx_test_case)
  return ()
endif ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

# ANCHOR: twx_test_case
#[=======[
*//**
Prepare the test working directory for testing executables.
Run from the `CMakeLists.txt` that defines the test.
We make a copy at a location where we have write access.
The source test case folder is `Test/WorkingDirectory`,
The destination is `<executable>.WorkingDirectory` near the executable.


@param executable the name of a valid executable
@param variable contains the full directory path
for the tests on return.

Includes `TwxCoreLib`
*/
twx_test_case ( executable variable ) {}
/*
#]=======]
function ( twx_test_case target_ variable_ )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  if ( TARGET ${target_} )
    set (
      directory_
      "${PROJECT_BINARY_DIR}/TwxProduct"
    )
    set_target_properties (
      ${target_}
      PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${directory_}"
    )
  else ()
    set ( directory_ "${PROJECT_BINARY_DIR}" )
  endif ()
  file ( MAKE_DIRECTORY "${directory_}" )
  set ( destination_ "${directory_}/${target_}.WorkingDirectory" )
  set ( temporaryDir "${PROJECT_BINARY_DIR}/TwxBuildData/Temporary" )
  message ( STATUS "FORM: ${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory")
  if ( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory" )
    message ( FATAL_ERROR "No WorkingDirectory" )
  endif ()
  file (
    COPY "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory"
    DESTINATION "${temporaryDir}"
  )
  if ( NOT EXISTS "${temporaryDir}/WorkingDirectory" )
    message ( FATAL_ERROR "COPY FAILED" )
  endif ()
  file (
    REMOVE_RECURSE "${destination_}"
  )
  message ( STATUS "DESTINATION: ${destination_}" )
  file (
    RENAME
      "${temporaryDir}/WorkingDirectory"
      "${destination_}"
  )
  file (
    REMOVE_RECURSE "${temporaryDir}"
  )
  set ( ${variable_} "${destination_}" PARENT_SCOPE )
  message ( STATUS "Test case folder: ${${variable_}}" )
endfunction ()
#*/
