#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Cfg.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

message ( STATUS "*" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT * )
twx_fatal_assert_passed ()
if ( TRUE )
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_cfg_path" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "path" )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_fatal_test ()
  twx_cfg_path ( a b c d )
  twx_fatal_assert_failed ()
  twx_fatal_test ()
  set ( p "NO${CMAKE_CURRENT_LIST_FILE}")
  # ID is the path to an existing file:
  twx_cfg_path ( ID "${CMAKE_CURRENT_LIST_FILE}" IN_VAR p )
  twx_expect ( p "${CMAKE_CURRENT_LIST_FILE}" )
  set ( TWX_CFG_INI_DIR "${CMAKE_CURRENT_LIST_DIR}/" )
  set ( p )
  twx_cfg_path ( ID "identifier" IN_VAR p )
  twx_expect ( p "${CMAKE_CURRENT_LIST_DIR}/TwxCfg_identifier.ini")
  set ( p )
  twx_cfg_path ( ID "identifier" IN_VAR p STAMPED )
  twx_expect ( p "${CMAKE_CURRENT_LIST_DIR}/TwxCfg_identifier.stamped")
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_cfg_ini_required_key_add/remove" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "ini_required_key_add/remove" )
twx_fatal_assert_passed ()
if ( TRUE )
  twx_assert_undefined ( TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  twx_cfg_ini_required_key_add ( FOO )
  twx_expect_in_list ( FOO TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  # message ( FATAL_ERROR "TWX_CFG_INI_REQUIRED_KEYS => \"${TWX_CFG_INI_REQUIRED_KEYS}\"")
  twx_cfg_ini_required_key_add ( CHI MEE )
  twx_expect_in_list ( CHI TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  twx_expect_in_list ( MEE TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  twx_cfg_ini_required_key_remove ( CHI )
  twx_expect_in_list ( FOO TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  twx_expect_not_in_list ( CHI TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
  twx_expect_in_list ( MEE TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_passed ()
endif ()
twx_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_cfg_update_factory" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "update_factory" )
twx_fatal_assert_passed ()
if ( TRUE )
  set ( content "TEST_KEY = TEST_VALUE;" )
  message ( TRACE "TWX_BUILD_DATA_DIR => \"${TWX_BUILD_DATA_DIR}\"" )
  file ( WRITE "${TWX_BUILD_DATA_DIR}TwxCfg_TEST.ini" "${content}" )
  twx_cfg_ini_required_key_add ( TEST_KEY )
  twx_cfg_update_factory ()
  twx_fatal_assert_passed ()
endif ()
twx_fatal_assert_passed ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#*/
