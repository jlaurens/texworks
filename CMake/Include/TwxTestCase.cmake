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
We make a copy at a location where we have write access.
The source test case folder is `Test/WorkingDirectory`,
The destination is `<executable>.WorkingDirectory` near the executable.


@param executable the name of a valid executable
@param variable contains the full directory path
for the tests on return.

Includes `TwxBase`
*/
twx_test_case ( variable TARGET executable ) {}
/*
#]=======]
function ( twx_test_case variable_ TARGET target_ )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  twx_assert_equal ( TARGET ${TARGET} )
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
  set ( temporaryDir "${TWX_PROJECT_BUILD_DATA_DIR}/Temporary" )
  message ( STATUS "FROM: ${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory")
  if ( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory" )
    twx_fatal ( "No WorkingDirectory" )
  endif ()
  file (
    COPY "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory"
    DESTINATION "${temporaryDir}"
  )
  if ( NOT EXISTS "${temporaryDir}/WorkingDirectory" )
    twx_fatal ( "COPY FAILED" )
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
endfunction ()
#*/
