#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Updated project factory Cfg data

Usage:
from a process or custom command
```
cmake ... -P .../CMake/Script/TwxCfg_factory.cmake
```

Input:
  - `TWX_NAME`
  - `TWX_FACTORY_INI`
  - `TWX_CFG_INI_DIR`

Output:
  - an updated factory Cfg data file

Used by `twx_cfg_setup()`.

Here is the factory list of recognized keys from `<project name>.ini`.
Other keys can be used but they must be managed elsewhere.
For each `<key>` we have both `TWX_<project_name>_<key>` and
`TWX_CFG_<key>` to store the value.
Input files will preferably contain `@TWX_CFG_<key>@` placeholders.

- General info (static values)
  - `NAME`
  - `COPYRIGHT_YEARS`
  - `COPYRIGHT_HOLDERS`
  - `AUTHORS`
- Organization (static values)
  - `ORGANIZATION_DOMAIN`
  - `ORGANIZATION_NAME`
  - `ORGANIZATION_SHORT_NAME`
- Version (static values)
  - `VERSION_MAJOR`
  - `VERSION_MINOR`
  - `VERSION_PATCH`
  - `VERSION_TWEAK`
- Build (static values)
  - `BUILD_ID`
- Git (dynamic values)
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`

From these are built
- Derived keys:
  - `COMMAND`, `NAME_LOWER` (synonyms)
  - `NAME_UPPER`
  - `VERSION_LONG`
  - `VERSION`
  - `VERSION_SHORT`
  - `GIT_OK`, whether the git information is accurate
  - `DOMAIN`
  - `ID`
  - `ASSEMBLY_IDENTITY`

*//*
#]===============================================]

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)

message ( STATUS "CMAKE_MODULE_PATH => \"${CMAKE_MODULE_PATH}\"" )

twx_state_deserialize ()

message ( STATUS "TWX_TEST => \"${TWX_TEST}\"" )
message ( STATUS "TWX_TEST_SUITE_LIST => \"${TWX_TEST_SUITE_LIST}\"" )

twx_test_during ( ID Cfg IN_VAR during_Cfg_ )

if ( NOT during_Cfg_ )
  include ( TwxInclude )
endif ()

include ( TwxCfgLib )

message ( STATUS "TwxCfg_factory.cmake..." )

message ( TRACE "TWX_DIR => \"${TWX_DIR}\"" )
twx_assert_non_void ( TWX_NAME )


twx_message ( VERBOSE "TwxCfg_factory:" DEEPER )
twx_message ( VERBOSE
  "TWX_NAME        => ${TWX_NAME}"
  "TWX_CFG_INI_DIR => ${TWX_CFG_INI_DIR}"
)

# Parse the ini contents
twx_message ( VERBOSE "Parsing ${TWX_FACTORY_INI}" )
twx_cfg_read ( "${TWX_FACTORY_INI}" )
twx_cfg_write_begin ( ID "factory" )
# verify the expectations
foreach (
  key_
  ${TWX_CFG_INI_REQUIRED_KEYS}
)
  if ( DEFINED TWX_CFG_${key_} )
    twx_cfg_set ( "${key_}=${TWX_CFG_${key_}}" )
  else ()
    twx_fatal (
      "Missing value for key_ ${key_} in TWX_FACTORY_INI (${TWX_FACTORY_INI})"
    )
    return ()
  endif ()
endforeach ()

foreach ( task_ ${TWX_CFG_FACTORY_TASKS} )
  cmake_language ( CALL "${task_}" )
endforeach ()

twx_cfg_write_end ( ID "factory" )

message ( STATUS "TwxCfg_factory.cmake... DONE")

#*/
