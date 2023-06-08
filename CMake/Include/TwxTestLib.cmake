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

@param executable the name of a valid executable
@param variable contains on return the full directory path
for the tests on return.

Includes `TwxBase`
*/
twx_test_case ( variable TARGET executable ) {}
/*
#]=======]
function ( twx_test_case twxR_variable TARGET twxR_target )
  if ( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory" )
    twx_fatal ( "No WorkingDirectory" )
  endif ()
  twx_assert_equal ( TARGET ${TARGET} )
  twx_assert_target ( ${twxR_target} )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  file ( MAKE_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}" )
  set_target_properties (
    ${twxR_target}
    PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${twxR_variable}
    "${TWX_PROJECT_PRODUCT_DIR}/${twxR_target}.WorkingDirectory"
  )
  if ( NOT "" STREQUAL "" )
    set ( temporaryDir_ "${TWX_PROJECT_BUILD_DATA_DIR}/Temporary" )
    message ( STATUS "FROM: ${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory")
    file (
      COPY "${CMAKE_CURRENT_LIST_DIR}/WorkingDirectory"
      DESTINATION "${temporaryDir_}"
    )
    if ( NOT EXISTS "${temporaryDir_}/WorkingDirectory" )
      twx_fatal ( "COPY FAILED" )
    endif ()
    file (
      REMOVE_RECURSE "${${twxR_variable}}"
    )
    message ( STATUS "DESTINATION: ${${twxR_variable}}" )
    file (
      RENAME
        "${temporaryDir_}/WorkingDirectory"
        "${${twxR_variable}}"
    )
    file (
      REMOVE_RECURSE "${temporaryDir_}"
    )
  else ()
    if ( NOT TARGET ${twxR_target}.WorkingDirectory )
      twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
      set (
        stamped_
        "${TWX_PROJECT_BUILD_DATA_DIR}/${twxR_target}.WorkingDirectory.stamped"
      )
      add_custom_command (
        COMMAND "${CMAKE_COMMAND}"
          "-DTWX_TARGET=\"${twxR_target}\""
          "-DTWX_SOURCE_DIR=\"${CMAKE_CURRENT_LIST_DIR}\""
          "-DTWX_TEMPORARY_DIR=\"${TWX_PROJECT_BUILD_DATA_DIR}/Temporary\""
          "-DTWX_DESTINATION_DIR=\"${TWX_PROJECT_PRODUCT_DIR}\""
          "-DTWX_VERBOSE=${TWX_VERBOSE}"
          "-DTWX_TEST=${TWX_TEST}"
          "-DTWX_DEV=${TWX_DEV}"
          -P "${TWX_DIR}/CMake/Command/TwxTestCommand.cmake"
        COMMAND
          "${CMAKE_COMMAND}"
            -E touch "${stamped_}"
        COMMENT
          "Setup ${twxR_target} working directory"
        OUTPUT "${stamped_}"
      )
      add_custom_target (
        ${twxR_target}.WorkingDirectory
        DEPENDS
        "${stamped_}"
      )
    endif ()
    add_dependencies( ${twxR_target} ${twxR_target}.WorkingDirectory )
  endif ()
  twx_export ( ${twxR_variable} )
endfunction ()
#*/
