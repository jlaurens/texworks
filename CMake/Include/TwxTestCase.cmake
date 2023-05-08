#[===============================================[
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023

Usage:
```
include (TwxTestCase)
```

Output:
* function `twx_test_case`

Includes `TwxCoreLib`.

#]===============================================]

# Guard
if ( COMMAND twx_test_case)
  return ()
endif ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )

# ANCHOR: twx_test_case
#[=======[
Prepare the TestCase directory for testing executables.
We make a copy at a location where we have write access.
Usage:
```
twx_test_case ( executable_name variable )
```
Run from the `CMakeLists.txt` that defines the test.
On return, `<variable>` contains the full directory path
for the tests.

Includes `TwxCoreLib`

#]=======]
function ( twx_test_case executable_name variable )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  file (
    COPY
      "${CMAKE_CURRENT_LIST_DIR}/Test/TestCase"
    DESTINATION
      "${PROJECT_BINARY_DIR}/build_data/"
  )
  file (
    REMOVE_RECURSE
      "${PROJECT_BINARY_DIR}/${executable_name}.TestCase"
  )
  set (
    ${variable}
    "${PROJECT_BINARY_DIR}/${executable_name}.TestCase"
  )
  file (
    RENAME
      "${PROJECT_BINARY_DIR}/build_data/TestCase"
      "${${variable}}"
  )
  twx_export ( "${variable}" )
endfunction ()
