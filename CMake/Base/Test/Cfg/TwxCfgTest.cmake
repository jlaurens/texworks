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

twx_test_suite_push ()
block ()

# ANCHOR: path
twx_test_unit_push ( CORE "path" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "a b c d" )
  twx_cfg_path ( a b c d )
  twx_test_simple_fail ()

  twx_test_simple_check ( "NO${CMAKE_CURRENT_LIST_FILE}" )
  set ( p "NO${CMAKE_CURRENT_LIST_FILE}")
  # ID is the path to an existing file:
  twx_cfg_path ( ID "${CMAKE_CURRENT_LIST_FILE}" IN_VAR p )
  twx_expect ( p "${CMAKE_CURRENT_LIST_FILE}" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "identifier" )
  set ( /TWX/CFG/INI/DIR "${CMAKE_CURRENT_LIST_DIR}/" )
  set ( p )
  twx_cfg_path ( ID "identifier" IN_VAR p )
  twx_expect ( p "${CMAKE_CURRENT_LIST_DIR}/TwxCfg_identifier.ini")
  twx_test_simple_pass ()

  twx_test_simple_check ( "identifier STAMPED" )
  set ( p )
  twx_cfg_path ( ID "identifier" IN_VAR p STAMPED )
  twx_expect ( p "${CMAKE_CURRENT_LIST_DIR}/TwxCfg_identifier.stamped")
  twx_test_simple_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: ini_keys
twx_test_unit_push ( CORE "ini_keys" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Save" )
  twx_cfg_ini_keys_get ( IN_VAR saved )
  set ( v "Dummy" )
  twx_cfg_ini_keys_clear ( IN_VAR v )
  twx_test_stop ( v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  twx_test_simple_check ( "add/remove FOO" )
  set ( v )
  twx_cfg_ini_keys_add ( FOO IN_VAR v )
  twx_expect_in_list ( FOO "${v}" )
  twx_cfg_ini_keys_remove ( FOO IN_VAR v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Restore" )
  twx_cfg_ini_keys_add ( ${saved} IN_VAR V )
  twx_expect_equal_string ( v "${saved}" )
  twx_test_simple_pass ()

  twx_test_stop ()

  twx_test_simple_check ( "CHI MEE" )
  twx_cfg_ini_keys_add ( "CHI MEE" )
  twx_expect_in_list ( CHI /TWX/CFG/INI/REQUIRED_KEYS )
  twx_expect_in_list ( MEE /TWX/CFG/INI/REQUIRED_KEYS )
  twx_test_simple_pass ()

  twx_test_simple_check ( "-CHI" )
  twx_cfg_ini_keys_remove ( CHI )
  twx_expect_in_list ( CHI /TWX/CFG/INI/REQUIRED_KEYS )
  twx_test_simple_fail ()

  twx_test_simple_check ( "-FOO" )
  twx_cfg_ini_keys_remove ( FOO )
  twx_expect_not_in_list ( FOO /TWX/CFG/INI/REQUIRED_KEYS )
  twx_expect_in_list ( MEE /TWX/CFG/INI/REQUIRED_KEYS )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: read(1)
twx_test_unit_push ( CORE "read" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "TEST_KEY = TEST_VALUE" )
  set ( what "TEST_KEY = TEST_VALUE" )  
  twx_cfg_path ( ID "read" IN_VAR where )
  file ( WRITE "${where}" "${what}" )
  twx_cfg_read ( read )
  twx_expect ( /TWX/CFG/TEST_KEY TEST_VALUE )
  twx_fatal_assert_pass ()
  file ( REMOVE "${where}" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_write_begin ( ID "read" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_write_end ()
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_assert_undefined ( TWX.${PROJECT_NAME}/CFG/TEST_KEY_1 )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Normal" )
  block ()
  twx_cfg_read ()
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_${PROJECT_NAME}/CFG/TEST_KEY_1 TEST_VALUE_1 )
  endblock ()
  twx_test_simple_pass ()

  twx_test_simple_check ( "ONLY_CONFIGURE" )
  block ()
  twx_cfg_read ( ONLY_CONFIGURE )
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_assert_undefined ( /TWX.${PROJECT_NAME}/CFG/TEST_KEY_1 )
  endblock ()
  twx_test_simple_pass ()

  twx_test_simple_check ( "REMOVE" )
  twx_cfg_path ( ID "write" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "REMOVE" )
  set ( what_1 "TEST_KEY_1 = TEST_VALUE_1" )  
  twx_cfg_path ( ID "read" IN_VAR where_1 )
  file ( WRITE "${where_1}" "${what_1}" )
  set ( what_2 "TEST_KEY_2 = TEST_VALUE_2" )  
  twx_cfg_path ( ID "read_private" IN_VAR where_2 )
  file ( WRITE "${where_2}" "${what_2}" )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_2 )
  block ()
  twx_cfg_read ()
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( /TWX/CFG/TEST_KEY_2 TEST_VALUE_2 )
  endblock ()
  block ()
  twx_cfg_read ( NO_PRIVATE)
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_2 )
  endblock ()
  file ( REMOVE "${where_1}" )
  file ( REMOVE "${where_2}" )
  twx_test_simple_pass ()
  
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: write
twx_test_unit_push ( CORE "write" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Normal, explicit" )
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ( ID "write" )
  block ()
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_2 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_3 )
  twx_cfg_read ( "write" )
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( /TWX/CFG/TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( /TWX/CFG/TEST_KEY_3 TEST_VALUE_3 )
  endblock ()
  twx_cfg_path ( ID "write" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_test_simple_pass ()
  

  twx_test_simple_check ( "Normal, implicit" )
  twx_cfg_path ( ID "write" IN_VAR where )
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( ID "write" "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( ID "write" "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ()
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_2 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_3 )
  block ()
  twx_cfg_read ( "write" )
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( /TWX/CFG/TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( /TWX/CFG/TEST_KEY_3 TEST_VALUE_3 )
  file ( REMOVE "${where}" )
  endblock ()
  twx_test_simple_pass ()

  twx_test_simple_check ( "Embedded" )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_2 )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_3 )
  twx_cfg_write_begin ( ID "outer" )
  twx_cfg_write_begin ( ID "inner" )
  twx_cfg_set ( ID "outer" "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( ID "inner" "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ( ID "outer" )
  twx_cfg_write_end ( ID "inner" )
  twx_cfg_read ( "inner" )
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  twx_expect ( /TWX/CFG/TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( /TWX/CFG/TEST_KEY_3 TEST_VALUE_3 )
  twx_cfg_read ( "outer" )
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( /TWX/CFG/TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( /TWX/CFG/TEST_KEY_3 TEST_VALUE_3 )
  twx_cfg_path ( ID "outer" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_cfg_path ( ID "inner" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Simple" )
  twx_cfg_path ( ID "write" IN_VAR where )
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_write_end ()
  twx_assert_undefined ( /TWX/CFG/TEST_KEY_1 )
  block ()
  twx_cfg_read ( "${where}" )
  twx_expect ( /TWX/CFG/TEST_KEY_1 TEST_VALUE_1 )
  file ( REMOVE "${where}" )
  endblock ()
  twx_test_simple_pass ()
  
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_factory
twx_test_unit_push ( CORE "update_factory" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "TwxCfg_TEST.ini" )
  set ( what "TEST_KEY = TEST_VALUE" )
  set ( where "${TWX_BUILD_DATA_DIR}TwxCfg_TEST.ini" )
  message ( TRACE "TWX_BUILD_DATA_DIR => ``${TWX_BUILD_DATA_DIR}''" )
  message ( DEBUG "Creating ``${where}''" )
  file ( WRITE "${where}" "${what}" )
  twx_cfg_ini_keys_add ( TEST_KEY )
  twx_cfg_update_factory ()
  file ( REMOVE "${where}" )
  if ( EXISTS "${where}" )
    twx_fatal ( "``${where}'' is still there." )
  endif ()
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_git(0)
twx_test_unit_push ( CORE "update_git(0)" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "0" )
  twx_cfg_write_begin ( ID "git" )
  foreach (key_ HASH BRANCH)
    twx_cfg_set ( "GIT_${key_}=TEST(${key_})" )
  endforeach ()
  twx_cfg_set ( GIT_DATE=1978-07-06T05:04:03+02:01 )
  twx_cfg_set ( GIT_OK=${TWX_CPP_TRUTHY_CFG} )
  twx_cfg_write_end ()
  foreach ( x HASH BRANCH DATE OK )
    set ( /TWX/CFG/GIT_${x} "<FAIL>" )
  endforeach ()
  twx_cfg_read ( git ONLY_CONFIGURE )
  twx_expect ( /TWX/CFG/GIT_HASH "TEST(HASH)" )
  twx_expect ( /TWX/CFG/GIT_BRANCH "TEST(BRANCH)" )
  twx_expect ( /TWX/CFG/GIT_DATE "1978-07-06T05:04:03+02:01" )
  twx_assert_true ( /TWX/CFG/GIT_OK )
  twx_expect_equal_number ( ${/TWX/CFG/GIT_OK} 1 )
  twx_cfg_path ( ID git IN_VAR p )
  file ( REMOVE "${p}" )
  if ( EXISTS "${p}" )
    message ( FATAL_ERROR "p => ``${p}''" )
  endif ()
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_git
twx_test_unit_push ( CORE "update_git" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  # twx_cfg_update_git ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: setup
twx_test_unit_push ( CORE "setup" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  # twx_cfg_setup ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
