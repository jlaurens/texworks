#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Include .
  *
  * Usage:
  * ```
  * include ( TwxWarningLib
  * Lib )
  * ```
  */
/*
#]===============================================]

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Core/TwxCore.cmake"
)

twx_lib_will_load ()

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
)

twx_state_key_add (
  CMAKE_SOURCE_DIR
  CMAKE_BINARY_DIR
  TWX_FACTORY_INI
)

twx_cfg_ini_keys_add (
  VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
  COPYRIGHT_YEARS COPYRIGHT_HOLDERS AUTHORS
  ORGANIZATION_DOMAIN ORGANIZATION_NAME ORGANIZATION_SHORT_NAME
  POPPLER_DATA_URL POPPLER_DATA_SHA256 URW35_FONTS_URL
  MANUAL_HTML_URL MANUAL_HTML_SHA256
  URL_HOME URL_HOME_DEV URL_ISSUES URL_GPL MAIL_ADDRESS
)

twx_cfg_register_hooked ( TwxInclude_Cfg_task_git )

macro ( TwxInclude_Cfg_task_git )
  # ANCHOR: Git info verification
  set ( GIT_OK )
  foreach ( key_ GIT_HASH GIT_DATE )
    # We assume that both keys are defined
    if ( DEFINED /TWX/CFG/${key_} )
      if ( /TWX/CFG/${key_} MATCHES "\\$Format:.*\\$" )
        twx_cfg_set ( "${key_}" "" )
      else ()
        twx_cfg_set ( "${key_}" "${/TWX/CFG/${key_}}" )
        set ( GIT_OK "${GIT_OK}${/TWX/CFG/${key_}}" )
      endif ()
    else ()
      message (
        FATAL_ERROR
        "Missing value for key_ ${key_} in TWX_FACTORY_INI: ${lines}"
      )
    endif ()
  endforeach ()
  if ( "${GIT_OK}" STREQUAL "" )
    set ( GIT_OK ${TWX_CPP_FALSY_CFG} )
  else ()
    set ( GIT_OK ${TWX_CPP_TRUTHY_CFG} )
  endif()
  twx_cfg_set ( GIT_OK "${GIT_OK}" )
endmacro ()

twx_cfg_register_hooked ( TwxInclude_Cfg_hooked_version )

# ANCHOR: Derived version strings, including a short one
macro ( TwxInclude_Cfg_hooked_version )
  twx_cfg_set (
    VERSION_LONG "\
  ${/TWX/CFG/VERSION_MAJOR}.\
  ${/TWX/CFG/VERSION_MINOR}.\
  ${/TWX/CFG/VERSION_PATCH}.\
  ${/TWX/CFG/VERSION_TWEAK}"
  )
  twx_cfg_set (
    VERSION "\
  ${/TWX/CFG/VERSION_MAJOR}.\
  ${/TWX/CFG/VERSION_MINOR}.\
  ${/TWX/CFG/VERSION_PATCH}"
  )
  twx_cfg_set (
    VERSION_SHORT "\
  ${/TWX/CFG/VERSION_MAJOR}.\
  ${/TWX/CFG/VERSION_MINOR}"
  )
endmacro ()

twx_cfg_register_hooked ( TwxInclude_Cfg_hooked_naming )

  # ANCHOR: NAMING
macro ( TwxInclude_Cfg_hooked_naming )
  twx_cfg_set ( NAME "${TWX_NAME}" )
  string ( TOLOWER "${TWX_NAME}" s_ )
  twx_cfg_set ( NAME_LOWER "${s_}" )
  twx_cfg_set ( COMMAND "${s_}" )
  string ( TOUPPER "${TWX_NAME}" s_ )
  twx_cfg_set ( NAME_UPPER "${s_}" )
endmacro ()

twx_cfg_register_hooked ( TwxInclude_Cfg_hooked_packaging )

  # ANCHOR: Packaging
macro ( TwxInclude_Cfg_hooked_packaging )
  if ( "${TWX_BUILD_ID}" STREQUAL "" )
    set ( TWX_BUILD_ID "personal" )
  endif ()
  twx_cfg_set ( BUILD_ID "${TWX_BUILD_ID}" )
  twx_cfg_set ( APPLICATION_IMAGE ":/images/images/${TWX_NAME}.png" )
  twx_cfg_set ( APPLICATION_IMAGE_128 ":/images/images/${TWX_NAME}-128.png")
  # Misc
endmacro ()

twx_cfg_register_hooked ( TwxInclude_Cfg_hooked_misc )

# ANCHOR: MISC
macro ( TwxInclude_Cfg_hooked_misc )
  twx_cfg_set ( DOMAIN "${TWX_NAME}.${/TWX/CFG/ORGANIZATION_DOMAIN}" )
  string ( REPLACE "." ";" niamod "${/TWX/CFG/ORGANIZATION_DOMAIN}" )
  list ( REVERSE niamod )
  string ( REPLACE ";" "." niamod "${niamod}" )
  twx_cfg_set ( APPLICATION_ID "${niamod}.${TWX_COMMAND}" )
  twx_cfg_set ( ASSEMBLY_IDENTITY "TUG.${TWX_NAME}.${TWX_NAME}" )
endmacro ()

# ANCHOR: /TWX/DEV
#[=======[*/
/** @brief Whether in developer mode
  *
  * Initially unset.
  * See @ref TWX_NAME.
  */
/TWX/DEV;
/*#]=======]

option ( /TWX/DEV "To activate developer mode" )

# ANCHOR: TWX_NAME
#[=======[*/
/** @brief The main project name
  *
  * One level of indirection is used for two reasons:
  *
  * * the word `TeXworks` is used so many times while refering to
  *   different meanings,
  * * One may need to change that name. In particular, this name
  *   is reflected in different parts of the file system. We want to
  *   allow a developper to have both a release version and  a developer
  *   version and let them live side by side with nothing in common.
  *   In particular, the developer version is not allowed to break
  *   an existing release version.
  *
  * Set to `TeXworks` in normal mode but to `TeXworks-dev`
  * when `/TWX/DEV` is set.
  * In developer mode, use for example
  *
  *   cmake ... -DTWX_DEV=ON ...
  *
  * Shared by Twx modules and main code.
  * In particular, main configuration files for metadata
  * like version and names are <TWX_NAME>.ini.
  *
  * See also the `TeXworks.ini` and `TeXworks-dev.ini`
  * configuration files at the top level.
  *
  * When testing, this value can be set beforehand, in that case,
  * it will not be overwritten.
  */
TWX_NAME;
/** @brief The main project command
  *
  * This is the main project name in lowercase.
  */
TWX_COMMAND;
/*#]=======]
if ( "${TWX_NAME}" STREQUAL "" )
  if ( /TWX/DEV )
    set ( TWX_NAME TeXworks-dev )
  else ()
    set ( TWX_NAME TeXworks )
  endif ()
endif ()

if ( "${TWX_COMMAND}" STREQUAL "" )
  string ( TOLOWER "${TWX_NAME}" TWX_COMMAND)
endif ()

twx_lib_require (
  Warning
  Unit
  Doxydoc
  CfgPATH
  CfgFile
  # Target
  # Module
  # Summary
  # Translation
  # Qt
  # PopplerData
  # CfgPaths
  # CfgFileLib

)

twx_message_log ( VERBOSE
  "NAME => ${TWX_NAME}"
  "COMMAND => ${TWX_COMMAND}"
  NO_SHORT
)

twx_lib_did_load ()

#*/
