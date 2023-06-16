#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Writes a some contents in a text file

Usage:
```
cmake ... -P .../Command/TwxWriteCommand.cmake
```

Expected input state:
- `TWX_CONTENTS`: the text to write
- `TWX_OUTPUT`: the output file location.
*//*
#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_assert_non_void ( TWX_OUTPUT )

twx_message_verbose ( "TwxWriteCommand: -> ${TWX_OUTPUT}" )

file (
  WRITE
  "${TWX_OUTPUT}"
  "${TWX_CONTENTS}"
)

#*/
