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

twx_test_suite_push ()
block ()

# ANCHOR: POC
twx_test_unit_push ( NAME POC )
if ( TWX_TEST_UNIT.RUN )
  block ()
  function ( twx_test_unit_push_POC )
    cmake_parse_arguments (
      PARSE_ARGV 0 twx.R
      "" "A;B" ""
    )
    set ( A ${twx.R_A} PARENT_SCOPE )
    set ( B ${twx.R_B} PARENT_SCOPE )
  endfunction ()
  set ( A foo )
  set ( B bar )
  twx_test_unit_push_POC ( A B )
  twx_assert_undefined ( A )
  twx_assert_undefined ( B )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: name_out
twx_test_unit_push ( CORE name_out )
if ( TWX_TEST_UNIT.RUN )
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
twx_test_unit_pop ()

# ANCHOR: Balance
twx_test_unit_push ( CORE begin_1 )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_file_begin ( ID twx_test_unit_push.foo )
  twx_cfg_file_begin ( ID twx_test_unit_push.foo )
  twx_fatal_assert_fail ()
  twx_cfg_file_end ( ID twx_test_unit_push.bar )
  twx_fatal_assert_fail ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Normal usage
twx_test_unit_push ( NAME Normal )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_file_begin ( ID twx_test_unit_push.foo )
  twx_cfg_file_begin ( ID twx_test_unit_push.foo )
  twx_fatal_assert_fail ()
  twx_cfg_file_end ( ID twx_test_unit_push.bar )
  twx_fatal_assert_fail ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: add
twx_test_unit_push ( CORE add )
if ( TWX_TEST_UNIT.RUN )
  block ()
  twx_cfg_file_add ()
  twx_fatal_assert_fail ()
  twx_cfg_file_begin ( ID twx_test_unit_push.baz )
  twx_cfg_file_add ( FILES FILE.in FILE.in.txt FILE.private.in )
  twx_cfg_file_end (
    IN_DIR "TEST_IN_DIR"
    OUT_DIR "TEST_OUT_DIR"
  )
  twx_fatal_assert_pass ()
  twx_ans_expose ()
  # twx_ans_log ()
  twx_expect ( TWX_TEST_BRANCH_1 OTHER )
  twx_expect_list ( TWX_TEST_in FILE.in FILE.in.txt FILE.private.in )
  twx_expect_list ( TWX_TEST_out FILE FILE.txt FILE.private )
  twx_fatal_assert_pass ()

  twx_cfg_file_begin ( ID twx_test_unit_push.chi )
  twx_cfg_file_add ( FILES FILE.in FILE.in.txt FILE.private.in )
  twx_cfg_file_end (
    NO_PRIVATE
    IN_DIR "TEST_IN_DIR"
    OUT_DIR "TEST_OUT_DIR"
  )
  twx_fatal_assert_pass ()
  twx_ans_expose ()
  twx_expect ( TWX_TEST_BRANCH_1 OTHER )
  twx_expect_list ( TWX_TEST_in FILE.in FILE.in.txt )
  twx_expect_list ( TWX_TEST_out FILE FILE.txt )
  twx_fatal_assert_pass ()

  # twx_ans_log ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Files
twx_test_unit_push ( NAME Files )
if ( TWX_TEST_UNIT.RUN )
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
twx_test_unit_pop ()

# ANCHOR: POCbuild
twx_test_unit_push ( NAME POCbuild )
if ( TWX_TEST_UNIT.RUN )
  block ()
  if ( "${CMAKE_BINARY_DIR}" MATCHES "/${TWX_TEST_UNIT.FULL}" )
    # reentrant call
    message ( "CMAKE_SOURCE_DIR => ``${CMAKE_SOURCE_DIR}''")
    message ( "CMAKE_BINARY_DIR => ``${CMAKE_BINARY_DIR}''")
    message ( FATAL_ERROR "**********" )
  else ()
    set ( pwd "${CMAKE_BINARY_DIR}/${TWX_TEST_UNIT.FULL}" )
    file ( MAKE_DIRECTORY "${pwd}" )
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
    # twx_fatal_assert_pass ()
  endif ()
  message ( FATAL_ERROR "**********" )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

message ( FATAL_ERROR "**********" )
#*/
