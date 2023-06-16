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
  - `TWX_NAME`
  - `TWX_FACTORY_INI`
  - `TWX_CFG_INI_DIR`
  - `TWX_MESSAGE_DEPTH`

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

if ( NOT DEFINED TWX_IS_BASED )
  include (
    "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

twx_assert_non_void ( TWX_NAME )

include ( TwxCfgLib )

twx_message_more_verbose (
  "TwxCfg_factory: TWX_NAME        => ${TWX_NAME}"
  "TwxCfg_factory: TWX_FACTORY_INI => ${TWX_FACTORY_INI}"
  "TwxCfg_factory: TWX_CFG_INI_DIR => ${TWX_CFG_INI_DIR}"
  DEEPER
)

# Parse the ini contents
twx_message_more_verbose ( "TwxCfg_factory: Parsing ${TWX_FACTORY_INI}" )
twx_cfg_read ( "${TWX_FACTORY_INI}" )
twx_cfg_write_begin ( ID "factory" )
# verify the expectations
foreach (
  key
  VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
  COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
  ORGANIZATION_DOMAIN ORGANIZATION_NAME ORGANIZATION_SHORT_NAME
  POPPLER_DATA_URL POPPLER_DATA_SHA256 URW35_FONTS_URL
  MANUAL_HTML_URL MANUAL_HTML_SHA256
  URL_HOME URL_HOME_DEV URL_ISSUES URL_GPL MAIL_ADDRESS
)
  if ( DEFINED TWX_CFG_${key} )
    twx_cfg_set ( "${key}" "${TWX_CFG_${key}}" )
  else ()
    message (
      FATAL_ERROR
      "Missing value for key ${key} in TWX_FACTORY_INI (${TWX_FACTORY_INI})"
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
      "Missing value for key ${key} in TWX_FACTORY_INI: ${lines}"
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
  VERSION_LONG "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}.\
${TWX_CFG_VERSION_PATCH}.\
${TWX_CFG_VERSION_TWEAK}"
)
twx_cfg_set (
  VERSION "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}.\
${TWX_CFG_VERSION_PATCH}"
)
twx_cfg_set (
  VERSION_SHORT "\
${TWX_CFG_VERSION_MAJOR}.\
${TWX_CFG_VERSION_MINOR}"
)
# ANCHOR: NAMING
twx_cfg_set ( NAME "${TWX_NAME}" )
string ( TOLOWER "${TWX_NAME}" s )
twx_cfg_set ( NAME_LOWER "${s}" )
twx_cfg_set ( COMMAND "${s}" )
string ( TOUPPER "${TWX_NAME}" s )
twx_cfg_set ( NAME_UPPER "${s}" )
# Packaging
if ( "${TWX_BUILD_ID}" STREQUAL "" )
  set ( TWX_BUILD_ID "personal" )
endif ()
twx_cfg_set ( BUILD_ID "${TWX_BUILD_ID}" )
twx_cfg_set ( APPLICATION_IMAGE ":/images/images/${TWX_NAME}.png" )
twx_cfg_set ( APPLICATION_IMAGE_128 ":/images/images/${TWX_NAME}-128.png")
# Misc
twx_cfg_set ( DOMAIN "${TWX_NAME}.${TWX_CFG_ORGANIZATION_DOMAIN}" )
string ( REPLACE "." ";" niamod "${TWX_CFG_ORGANIZATION_DOMAIN}" )
list ( REVERSE niamod )
string ( REPLACE ";" "." niamod "${niamod}" )
twx_cfg_set ( APPLICATION_ID "${niamod}.${TWX_COMMAND}" )
twx_cfg_set ( ASSEMBLY_IDENTITY "TUG.${TWX_NAME}.${TWX_NAME}" )

twx_cfg_write_end ( ID "factory" )

#*/
