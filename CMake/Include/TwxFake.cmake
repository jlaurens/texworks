#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

It sets up the state for `@...@` macro substitution operated by
`configure_file` instructions. Dynamic values are updated,
mainly related to git. Afterwards, `configure_file` can be used
and all `@...@` macros will be correctly substituted.

Usage:
from a target at build time only
```
include ( TwxSetupConfigureFile )
```
Input:
* `PROJECT_NAME`
* `PROJECT_BINARY_DIR`

Output:
* `<binary_dir>/build_data/<project name>Git.ini`
  is touched any time some info changes such that files must be reconfigured.
* Variables `TWX_INFO_<key>` are defined with `TWX_<project name>_<key>` values
  for each `<key>` defined in `TwxPrepareConfigureFile`.

#]===============================================]

message (
  STATUS
  "CMAKE_CURRENT_LIST_DIR => ${CMAKE_CURRENT_LIST_DIR}"
)
message (
  STATUS
  "CMAKE_SOURCE_DIR => ${CMAKE_SOURCE_DIR}"
)
message (
  STATUS
  "TWX_TwxCoreTest_COPYRIGHT_HOLDERS => ${TWX_TwxCoreTest_COPYRIGHT_HOLDERS}"
)
