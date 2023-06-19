#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Test suite command

Command to setup the test folder.

Usage:
```
cmake ... -P .../TwxTestCommand.cmake
```
Input state:
- `TWX_TARGET`
- `TWX_SOURCE_DIR`
- `TWX_TEMPORARY_DIR`
- `TWX_DESTINATION_DIR`
- `TWX_VERBOSE`
- `TWX_TEST`

*//*
#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
  NO_POLICY_SCOPE
)

twx_assert_non_void ( TWX_TARGET )
twx_assert_non_void ( TWX_SOURCE_DIR )
twx_assert_exists ( "${TWX_SOURCE_DIR}WorkingDirectory" )
twx_assert_non_void ( TWX_TEMPORARY_DIR )
twx_assert_non_void ( TWX_DESTINATION_DIR )

twx_message_deeper ()
file ( MAKE_DIRECTORY "${TWX_TEMPORARY_DIR}" )
file (
  COPY "${TWX_SOURCE_DIR}WorkingDirectory"
  DESTINATION "${TWX_TEMPORARY_DIR}"
)
twx_assert_exists ( "${TWX_TEMPORARY_DIR}WorkingDirectory" )
file (
  REMOVE_RECURSE "${TWX_DESTINATION_DIR}${TWX_TARGET}.WorkingDirectory"
)
twx_message_verbose ( "TwxTestCommand DESTINATION: ${TWX_DESTINATION_DIR}${TWX_TARGET}.WorkingDirectory" )
file (
  RENAME
    "${TWX_TEMPORARY_DIR}WorkingDirectory"
    "${TWX_DESTINATION_DIR}${TWX_TARGET}.WorkingDirectory"
)
file (
  REMOVE_RECURSE "${TWX_TEMPORARY_DIR}WorkingDirectory"
)
twx_message_verbose ( "TwxTestCommand Setup: ${TWX_DESTINATION_DIR}${TWX_TARGET}.WorkingDirectory")
#*/
