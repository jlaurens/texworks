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
Prepare the TestCase directory for testing executables.
Run from the `CMakeLists.txt` that defines the test.
We make a copy at a location where we have write access.
The source test case folder is `Test/TestCase`,
The destination is `<binary_dir>/<executable>.testCase`.

@param executable the name of a valid executable
@param variable contains the full directory path
for the tests on return.

Includes `TwxCoreLib`
*/
twx_test_case ( executable variable ) {}
/*
#]=======]
function ( twx_test_case executable_name_ variable_ )
  twx_assert_non_void ( CMAKE_BINARY_DIR )
  file (
    COPY
      "${CMAKE_CURRENT_LIST_DIR}/Test/TestCase"
    DESTINATION
      "${CMAKE_BINARY_DIR}/build_data/"
  )
  file (
    REMOVE_RECURSE
      "${CMAKE_BINARY_DIR}/${executable_name_}.TestCase"
  )
  set (
    ${variable_}
    "${CMAKE_BINARY_DIR}/${executable_name_}.TestCase"
  )
  file (
    RENAME
      "${CMAKE_BINARY_DIR}/build_data/TestCase"
      "${${variable_}}"
  )
  twx_export ( "${variable_}" )
  message ( STATUS "Test case folder: ${${variable_}}" )
endfunction ()
#*/
