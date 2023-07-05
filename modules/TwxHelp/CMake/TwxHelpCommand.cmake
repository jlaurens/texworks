#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Download and expand the TeXworks manual.

Usage:
```
  cmake -DPROJECT_BINARY_DIR="... -P .../TwxManualCommand.cmake
```

Loads `TwxBase`.

Input state:
- `TWX_URL`
- `TWX_ARCHIVE`
- `TWX_BASE`
- `TWX_SHA256`

Output state: the directory `<current binary dir>/TwxManual`
contains both the downloaded `zip` archive and its expansion.

It is not strong enough to recognize a change in the inflated files.
If these files are edited or deleted then the build system is not informed.
*/
/*#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)

include ( TwxManualLib )
twx_manual_prepare (
  URL     "${TWX_URL}"
  ARCHIVE "${TWX_ARCHIVE}"
  BASE    "${TWX_BASE}"
  SHA256  "${TWX_SHA256}"
  DEV     "${TWX_DEV}"
  TEST    "${TWX_TEST}"
  CMAKE_MESSAGE_LOG_LEVEL "${CMAKE_MESSAGE_LOG_LEVEL}"
)
#*/
