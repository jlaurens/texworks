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
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_fatal_test ()
  twx_cfg_path ( a b c d )
  twx_fatal_assert_fail ()
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
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: ini_required_key_add/remove
twx_test_unit_push ( CORE "ini_required_key_add/remove" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_assert_undefined ( TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  twx_cfg_ini_required_key_add ( FOO )
  twx_expect_in_list ( FOO TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  # message ( FATAL_ERROR "TWX_CFG_INI_REQUIRED_KEYS => ``${TWX_CFG_INI_REQUIRED_KEYS}''")
  twx_cfg_ini_required_key_add ( CHI MEE )
  twx_expect_in_list ( CHI TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  twx_expect_in_list ( MEE TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  twx_cfg_ini_required_key_remove ( CHI )
  twx_expect_in_list ( FOO TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  twx_expect_not_in_list ( CHI TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  twx_expect_in_list ( MEE TWX_CFG_INI_REQUIRED_KEYS )
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: read(1)
twx_test_unit_push ( CORE "read(1)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( what "TEST_KEY = TEST_VALUE" )  
  twx_cfg_path ( ID "read" IN_VAR where )
  file ( WRITE "${where}" "${what}" )
  twx_cfg_read ( read )
  twx_expect ( TWX_CFG_TEST_KEY TEST_VALUE )
  twx_fatal_assert_pass ()
  file ( REMOVE "${where}" )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: read(ONLY_CONFIGURE)
twx_test_unit_push ( CORE "read(ONLY_CONFIGURE)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_write_begin ( ID "read" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_write_end ()
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_assert_undefined ( TWX_${PROJECT_NAME}_CFG_TEST_KEY_1 )
  block ()
  twx_cfg_read ()
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_${PROJECT_NAME}_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_fatal_assert_pass ()
  endblock ()
  block ()
  twx_cfg_read ( ONLY_CONFIGURE )
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_assert_undefined ( TWX_${PROJECT_NAME}_CFG_TEST_KEY_1 )
  twx_fatal_assert_pass ()
  endblock ()
  twx_cfg_path ( ID "write" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: read(NO_PRIVATE)
twx_test_unit_push ( CORE "read(NO_PRIVATE)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( what_1 "TEST_KEY_1 = TEST_VALUE_1" )  
  twx_cfg_path ( ID "read" IN_VAR where_1 )
  file ( WRITE "${where_1}" "${what_1}" )
  set ( what_2 "TEST_KEY_2 = TEST_VALUE_2" )  
  twx_cfg_path ( ID "read_private" IN_VAR where_2 )
  file ( WRITE "${where_2}" "${what_2}" )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_2 )
  block ()
  twx_cfg_read ()
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_CFG_TEST_KEY_2 TEST_VALUE_2 )
  endblock ()
  block ()
  twx_cfg_read ( NO_PRIVATE)
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_2 )
  endblock ()
  twx_fatal_assert_pass ()
  file ( REMOVE "${where_1}" )
  file ( REMOVE "${where_2}" )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: write(1)
twx_test_unit_push ( CORE "write(1)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ()
  block ()
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_2 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_3 )
  twx_cfg_read ( "write" )
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_CFG_TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( TWX_CFG_TEST_KEY_3 TEST_VALUE_3 )
  endblock ()
  twx_cfg_path ( ID "write" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: write(1')
twx_test_unit_push ( CORE "write(1')" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_path ( ID "write" IN_VAR where )
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( ID "write" "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( ID "write" "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ( ID "write" )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_2 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_3 )
  block ()
  twx_cfg_read ( "write" )
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_CFG_TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( TWX_CFG_TEST_KEY_3 TEST_VALUE_3 )
  file ( REMOVE "${where}" )
  endblock ()
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: write(2)
twx_test_unit_push ( CORE "write(2)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_2 )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_3 )
  twx_cfg_write_begin ( ID "outer" )
  twx_cfg_write_begin ( ID "inner" )
  twx_cfg_set ( ID "outer" "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_set ( ID "inner" "TEST_KEY_2=TEST_VALUE_2" "TEST_KEY_3=TEST_VALUE_3" )
  twx_cfg_write_end ( ID "outer" )
  twx_cfg_write_end ( ID "inner" )
  twx_cfg_read ( "inner" )
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  twx_expect ( TWX_CFG_TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( TWX_CFG_TEST_KEY_3 TEST_VALUE_3 )
  twx_cfg_read ( "outer" )
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  twx_expect ( TWX_CFG_TEST_KEY_2 TEST_VALUE_2 )
  twx_expect ( TWX_CFG_TEST_KEY_3 TEST_VALUE_3 )
  twx_cfg_path ( ID "outer" IN_VAR where )
  file ( REMOVE "${where}" )
  twx_cfg_path ( ID "inner" IN_VAR where )
  file ( REMOVE "${where}" )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: write(3)
twx_test_unit_push ( CORE "write(3)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_path ( ID "write" IN_VAR where )
  twx_cfg_write_begin ( ID "write" )
  twx_cfg_set ( "TEST_KEY_1=TEST_VALUE_1" )
  twx_cfg_write_end ()
  twx_assert_undefined ( TWX_CFG_TEST_KEY_1 )
  block ()
  twx_cfg_read ( "${where}" )
  twx_expect ( TWX_CFG_TEST_KEY_1 TEST_VALUE_1 )
  file ( REMOVE "${where}" )
  endblock ()
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_factory
twx_test_unit_push ( CORE "update_factory" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  set ( what "TEST_KEY = TEST_VALUE" )
  set ( where "${TWX_BUILD_DATA_DIR}TwxCfg_TEST.ini" )
  message ( TRACE "TWX_BUILD_DATA_DIR => ``${TWX_BUILD_DATA_DIR}''" )
  message ( DEBUG "Creating ``${where}''" )
  file ( WRITE "${where}" "${what}" )
  twx_cfg_ini_required_key_add ( TEST_KEY )
  twx_cfg_update_factory ()
  twx_fatal_assert_pass ()
  file ( REMOVE "${where}" )
  if ( EXISTS "${where}" )
    twx_fatal ( "``${where}'' is still there." )
  endif ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_git(0)
twx_test_unit_push ( CORE "update_git(0)" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_write_begin ( ID "git" )
  foreach (key_ HASH BRANCH)
    twx_cfg_set ( "GIT_${key_}=TEST(${key_})" )
  endforeach ()
  twx_cfg_set ( GIT_DATE=1978-07-06T05:04:03+02:01 )
  twx_cfg_set ( GIT_OK=${TWX_CPP_TRUTHY_CFG} )
  twx_cfg_write_end ()
  foreach ( x HASH BRANCH DATE OK )
    set ( TWX_CFG_GIT_${x} "<FAIL>" )
  endforeach ()
  twx_cfg_read ( git ONLY_CONFIGURE )
  twx_expect ( TWX_CFG_GIT_HASH "TEST(HASH)" )
  twx_expect ( TWX_CFG_GIT_BRANCH "TEST(BRANCH)" )
  twx_expect ( TWX_CFG_GIT_DATE "1978-07-06T05:04:03+02:01" )
  twx_assert_true ( TWX_CFG_GIT_OK )
  twx_expect_equal_number ( ${TWX_CFG_GIT_OK} 1 )
  twx_cfg_path ( ID git IN_VAR p )
  file ( REMOVE "${p}" )
  if ( EXISTS "${p}" )
    message ( FATAL_ERROR "p => ``${p}''" )
  endif ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: update_git
twx_test_unit_push ( CORE "update_git" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  # twx_cfg_update_git ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: setup
twx_test_unit_push ( CORE "setup" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  # twx_cfg_setup ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
