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

message ( STATUS "TwxCfgLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxCfgLib.cmake")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExpect/TwxExpectTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxDir/TwxDirTest.cmake")

block ()
twx_test_suite_will_begin ()

message ( STATUS "*" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT * )
twx_test_fatal_assert_passed ()
if ( TRUE )
endif ()
twx_test_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_cfg_path" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "path" )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_test_fatal ()
  twx_cfg_path ( a b c d )
  twx_test_fatal_assert_failed ()
  twx_test_fatal ()
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
twx_test_fatal_assert_passed ()
endblock ()

message ( STATUS "twx_cfg_update_factory" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "update_factory" )
twx_test_fatal_assert_passed ()
if ( TRUE )
  set ( TWX_CFG_INI_DIR "${CMAKE_CURRENT_LIST_DIR}/" )
  set ( content "TEST_KEY = TEST_VALUE;" )
  message ( TRACE "TWX_BUILD_DATA_DIR => \"${TWX_BUILD_DATA_DIR}\"" )
  file ( WRITE "${TWX_BUILD_DATA_DIR}TwxCfg_TEST.ini" "${content}" )
  twx_cfg_update_factory ()
endif ()
twx_test_fatal_assert_passed ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxCfgLib test... DONE")

#*/
