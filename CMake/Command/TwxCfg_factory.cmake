#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Updated project factory Cfg data

Usage:
from a process or custom command
```
cmake ... -P .../CMake/Command/TwxCfg_factory.cmake
```

Input:
  - `PROJECT_NAME`
  - `TWX_${PROJECT_NAME}_INI`
  - `PROJECT_BINARY_DIR`
  - `TWX_DIR`

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
  - `NAME_LOWER`
  - `NAME_UPPER`
  - `PROJECT_VERSION`
  - `PROJECT_VERSION_SHORT`
  - `GIT_OK`, whether the git information is accurate

  *//*
#]===============================================]

if ( NOT TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

twx_assert_non_void ( PROJECT_NAME )
twx_assert_non_void ( TWX_${PROJECT_NAME}_INI )
twx_assert_non_void ( PROJECT_BINARY_DIR )
twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
twx_assert_non_void ( TWX_DIR )

include ( TwxCfgLib )

if ( TWX_VERBOSE )
  message ( STATUS "TwxCfg_factory: ${PROJECT_NAME}" )
  message ( STATUS "TwxCfg_factory: ${TWX_${PROJECT_NAME}_INI}" )
  message ( STATUS "TwxCfg_factory: ${PROJECT_BINARY_DIR}" )
  message ( STATUS "TwxCfg_factory: ${TWX_DIR}" )
endif ()

# Parse the ini contents
if ( TWX_VERBOSE )
  message ( STATUS "Parsing ${TWX_${PROJECT_NAME}_INI}" )
endif ()
twx_cfg_read ( "${TWX_${PROJECT_NAME}_INI}" )
twx_cfg_write_begin ( ID "factory" )
# verify the expectations
foreach (
  key
  VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
  COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
  ORGANIZATION_DOMAIN ORGANIZATION_NAME
)
  if ( DEFINED TWX_CFG_${key} )
    twx_cfg_set ( "${key}" "${TWX_CFG_${key}}" )
  else ()
    message (
      FATAL_ERROR
      "Missing value for key ${key} in TWX_${PROJECT_NAME}_INI (${TWX_${PROJECT_NAME}_INI})"
    )
  endif ()
endforeach ()
# ANCHOR: Git info verification
set ( GIT_OK )
foreach ( key GIT_HASH GIT_DATE )
  # We assume that both keys are defined
  if ( DEFINED TWX_CFG_${key} )
    if ( TWX_CFG_${key} MATCHES "\\$Format:.*\\$" )
      twx_cfg_set ( "${key}" "" )
    else ()
      twx_cfg_set ( "${key}" "${TWX_CFG_${key}}" )
      set ( GIT_OK "${GIT_OK}${TWX_CFG_${key}}" )
    endif ()
  else ()
    message (
      FATAL_ERROR
      "Missing value for key ${key} in TWX_${PROJECT_NAME}_INI: ${lines}"
    )
  endif ()
endforeach ()
if ( "${GIT_OK}" STREQUAL "" )
  set ( GIT_OK ${TWX_CPP_FALSY_CFG} )
else ()
  set ( GIT_OK ${TWX_CPP_TRUTHY_CFG} )
endif()
twx_cfg_set ( GIT_OK "${GIT_OK}" )
# ANCHOR: Derived version strings, including a short one
twx_cfg_set (
  PROJECT_VERSION "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}.\
${TWX_CFG_VERSION_PATCH}"
)
twx_cfg_set (
  PROJECT_VERSION_SHORT "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}"
)
# ANCHOR: NAMING
twx_cfg_set ( NAME "${PROJECT_NAME}" )
string ( TOLOWER "${PROJECT_NAME}" s )
twx_cfg_set ( NAME_LOWER "${s}" )
string ( TOUPPER "${PROJECT_NAME}" s )
twx_cfg_set ( NAME_UPPER "${s}" )
# Packaging
if ( "${TWX_BUILD_ID}" STREQUAL "" )
  set ( TWX_BUILD_ID "personal" )
endif ()
twx_cfg_set ( BUILD_ID "${TWX_BUILD_ID}" )
twx_cfg_set ( APPLICATION_IMAGE ":/images/images/${PROJECT_NAME}.png" )
twx_cfg_set ( APPLICATION_IMAGE_128 ":/images/images/${PROJECT_NAME}-128.png")

twx_cfg_write_end ( ID "factory" )

#*/
