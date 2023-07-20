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
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)

twx_state_key_add (
  CMAKE_SOURCE_DIR
  CMAKE_BINARY_DIR
  TWX_CFG_INI_REQUIRED_KEYS
)

twx_cfg_ini_required_key_add (
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
    if ( DEFINED TWX_CFG_${key_} )
      if ( TWX_CFG_${key_} MATCHES "\\$Format:.*\\$" )
        twx_cfg_set ( "${key_}" "" )
      else ()
        twx_cfg_set ( "${key_}" "${TWX_CFG_${key_}}" )
        set ( GIT_OK "${GIT_OK}${TWX_CFG_${key_}}" )
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
  twx_cfg_set ( DOMAIN "${TWX_NAME}.${TWX_CFG_ORGANIZATION_DOMAIN}" )
  string ( REPLACE "." ";" niamod "${TWX_CFG_ORGANIZATION_DOMAIN}" )
  list ( REVERSE niamod )
  string ( REPLACE ";" "." niamod "${niamod}" )
  twx_cfg_set ( APPLICATION_ID "${niamod}.${TWX_COMMAND}" )
  twx_cfg_set ( ASSEMBLY_IDENTITY "TUG.${TWX_NAME}.${TWX_NAME}" )
endmacro ()
#*/
