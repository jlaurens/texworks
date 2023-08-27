#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Download and expand the Poppler data

Usage:
```
  cmake ... -P .../TwxPopplerDataScript.cmake
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

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_state_deserialize ()

include ( TwxPopplerDataLib )
twx_poppler_data_prepare (
  URL     "${TWX_URL}"
  ARCHIVE "${TWX_ARCHIVE}"
  BASE    "${TWX_BASE}"
  SHA256  "${TWX_SHA256}"
  DEV     "${TWX_DEV}"
  TEST    "${TWX_TEST}"
  CMAKE_MESSAGE_LOG_LEVEL "${CMAKE_MESSAGE_LOG_LEVEL}"
)
#*/