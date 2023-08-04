#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxCfgFileLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

# ANCHOR: POC
twx_test_unit_will_begin ( NAME POC )
if ( TWX_TEST_UNIT_RUN )
  block ()
  function ( twx_test_unit_will_begin_POC )
    cmake_parse_arguments (
      PARSE_ARGV 0 twx.R
      "" "A;B" ""
    )
    set ( A ${twx.R_A} PARENT_SCOPE )
    set ( B ${twx.R_B} PARENT_SCOPE )
  endfunction ()
  set ( A foo )
  set ( B bar )
  twx_test_unit_will_begin_POC ( A B )
  twx_assert_undefined ( A )
  twx_assert_undefined ( B )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: name_out
twx_test_unit_will_begin ( ID name_out )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( x )
  twx_cfg_file_name_out ( "a/b.in" IN_VAR x )
  twx_expect ( x "a/b" )
  set ( x )
  twx_cfg_file_name_out ( "a/b.in.whatever" IN_VAR x )
  twx_expect ( x "a/b.whatever" )
  set ( x )
  twx_cfg_file_name_out ( "a.in/b.whatever" IN_VAR x )
  twx_expect ( x "a.in/b.whatever" )
  set ( x )
  twx_cfg_file_name_out ( "a/b.inner" IN_VAR x )
  twx_expect ( x "a/b.inner" )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: Balance
twx_test_unit_will_begin ( ID begin_1 )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_cfg_file_begin ( ID twx_test_unit_will_begin.foo )
  twx_cfg_file_begin ( ID twx_test_unit_will_begin.foo )
  twx_fatal_assert_failed ()
  twx_cfg_file_end ( ID twx_test_unit_will_begin.bar )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: Normal usage
twx_test_unit_will_begin ( NAME Normal )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_cfg_file_begin ( ID twx_test_unit_will_begin.foo )
  twx_cfg_file_begin ( ID twx_test_unit_will_begin.foo )
  twx_fatal_assert_failed ()
  twx_cfg_file_end ( ID twx_test_unit_will_begin.bar )
  twx_fatal_assert_failed ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: add
twx_test_unit_will_begin ( ID add )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_cfg_file_add ()
  twx_fatal_assert_failed ()
  twx_cfg_file_begin ( ID twx_test_unit_will_begin.baz )
  twx_cfg_file_add ( FILES FILE.in FILE.in.txt FILE.private.in )
  twx_cfg_file_end (
    IN_DIR "TEST_IN_DIR"
    OUT_DIR "TEST_OUT_DIR"
  )
  twx_fatal_assert_passed ()
  twx_ans_expose ()
  # twx_ans_log ()
  twx_expect ( TWX_TEST_BRANCH_1 OTHER )
  twx_expect_list ( TWX_TEST_in FILE.in FILE.in.txt FILE.private.in )
  twx_expect_list ( TWX_TEST_out FILE FILE.txt FILE.private )
  twx_fatal_assert_passed ()

  twx_cfg_file_begin ( ID twx_test_unit_will_begin.chi )
  twx_cfg_file_add ( FILES FILE.in FILE.in.txt FILE.private.in )
  twx_cfg_file_end (
    NO_PRIVATE
    IN_DIR "TEST_IN_DIR"
    OUT_DIR "TEST_OUT_DIR"
  )
  twx_fatal_assert_passed ()
  twx_ans_expose ()
  twx_expect ( TWX_TEST_BRANCH_1 OTHER )
  twx_expect_list ( TWX_TEST_in FILE.in FILE.in.txt )
  twx_expect_list ( TWX_TEST_out FILE FILE.txt )
  twx_fatal_assert_passed ()

  # twx_ans_log ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: Files
twx_test_unit_will_begin ( NAME Files )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_cfg_files (
    TYPE		    TEST_TYPE
    FILES  	    FILE.in FILE.in.txt FILE.in.private
    IN_DIR 	    "TEST_IN_DIR"
    OUT_DIR     "TEST_OUT_DIR"
    VAR_PREFIX  twx
  )
  twx_ans_expose ()
  twx_expect_list (
    twx_OUT_TEST_TYPE
    TEST_OUT_DIR/FILE
    TEST_OUT_DIR/FILE.private
    TEST_OUT_DIR/FILE.txt
  )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: POCbuild
twx_test_unit_will_begin ( NAME POCbuild )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( pwd "${CMAKE_BINARY_DIR}/TwxTest/${TWX_TEST_DOMAIN_NAME}/${TWX_TEST_SUITE_NAME}/${TWX_TEST_UNIT_NAME}" )
  file(MAKE_DIRECTORY "${pwd}" )
  message ( ${CMAKE_CURRENT_LIST_DIR} )
  twx_state_serialize ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "${CMAKE_CURRENT_LIST_DIR}/POCBuild"
    WORKING_DIRECTORY "${pwd}"
    RESULT_VARIABLE POCbuild.result
    COMMAND_ERROR_IS_FATAL ANY
  )
  # cmake ../CMake/Include/Test
  # add_subdirectory ( "${CMAKE_CURRENT_LIST_DIR}/POCBuild" )
  twx_fatal_assert_passed ()
  message ( FATAL_ERROR "**********" )
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

message ( FATAL_ERROR "**********" )
#*/
