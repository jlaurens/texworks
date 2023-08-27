#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxAssertLib test suite.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_will_begin ()
block ()

# ANCHOR: undefined
twx_test_unit_will_begin ( ID "undefined" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Undefined dummy" )
  unset ( dummy )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "Defined dummy" )
  set ( dummy "" )
  twx_assert_undefined ( dummy )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: defined
twx_test_unit_will_begin ( ID "defined" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Defined dummy" )
  set ( dummy "" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "Undefined dummy" )
  unset ( dummy )
  twx_assert_defined ( dummy )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: compare_yes
twx_test_unit_will_begin ( NAME "twx_assert_compare(yes)" ID compare_yes )
if ( TWX_TEST_UNIT_RUN )
  block ()
  macro ( twx_test_one_shot )
    string ( REPLACE ";" " " twx_test_one_shot.v "${ARGV}" )
    twx_test_simple_start ( "Assert ${twx_test_one_shot.v}" )
    twx_assert_compare ( ${ARGV} )
    twx_test_simple_assert_pass ()
  endmacro ()
  twx_test_one_shot ( 1 < 2 )
  twx_test_one_shot ( 1 <= 2 )
  twx_test_one_shot ( 2 <= 2 )
  twx_test_one_shot ( 2 == 2 )
  twx_test_one_shot ( 2 = 2 )
  twx_test_one_shot ( 2 >= 2 )
  twx_test_one_shot ( 3 >= 2 )
  twx_test_one_shot ( 3 > 2 )
  twx_test_one_shot ( 3 <> 2 )
  twx_test_one_shot ( 3 != 2 )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: compare_no
twx_test_unit_will_begin ( NAME "twx_assert_compare(no)" ID compare_no )
if ( TWX_TEST_UNIT_RUN )
  block ()
  macro ( twx_test_one_shot )
    string ( REPLACE ";" " " twx_test_one_shot.v "${ARGV}" )
    twx_test_simple_start ( "Assert ! ${twx_test_one_shot.v}" )
    twx_assert_compare ( ${ARGV} )
    twx_test_simple_assert_fail ()
  endmacro ()
  twx_test_one_shot ( 3 < 2 )
  twx_test_one_shot ( 3 <= 2 )
  twx_test_one_shot ( 3 == 2 )
  twx_test_one_shot ( 3 = 2 )
  twx_test_one_shot ( 2 >= 3 )
  twx_test_one_shot ( 2 > 3 )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: compare_pipe_yes
twx_test_unit_will_begin ( NAME "twx_assert_compare(pipe/yes)" ID compare_pipe_yes )
if ( TWX_TEST_UNIT_RUN )
  block ()
  macro ( twx_test_one_shot )
    string ( REPLACE ";" " " twx_test_one_shot.v "${ARGV}" )
    twx_test_simple_start ( "Assert ${twx_test_one_shot.v}" )
    twx_assert_compare ( ${ARGV} )
    twx_test_simple_assert_pass ()
  endmacro ()
  twx_test_one_shot ( 1 < 2 < 3 )
  twx_test_one_shot ( 1 < 2 > 1 )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: compare_pipe_no
twx_test_unit_will_begin ( NAME "twx_assert_compare(pipe/no)" ID compare_pipe_no )
if ( TWX_TEST_UNIT_RUN )
  block ()
  macro ( twx_test_one_shot )
    string ( REPLACE ";" " " twx_test_one_shot.v "${ARGV}" )
    twx_test_simple_start ( "Assert ! ${twx_test_one_shot.v}" )
    twx_assert_compare ( ${ARGV} )
    twx_test_simple_assert_fail ()
  endmacro ()
  twx_test_one_shot ( 3 < 2 < 3 )
  twx_test_one_shot ( 1 < 2 < 1 )
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: non_void
twx_test_unit_will_begin ( ID "non_void" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "foo => bar" )
  set ( foo bar )
  twx_assert_non_void ( foo )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => bar, bar => baz" )
  set ( foo bar )
  set ( bar baz )
  twx_assert_non_void ( foo bar )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => UNDEFINED" )
  set ( foo )
  twx_assert_non_void ( foo )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "foo => bar, bar => UNDEFINED" )
  set ( foo bar )
  set ( bar )
  twx_assert_non_void ( foo bar )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "foo => UNDEFINED, bar => baz" )
  set ( foo )
  set ( bar baz )
  twx_assert_non_void ( foo bar )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: 0
twx_test_unit_will_begin ( ID 0 )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "Empty" )
  twx_assert_0 ( "" )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "0" )
  twx_assert_0 ( "0" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "Empty, 0" )
  twx_assert_0 ( "" "0" )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "0, 0" )
  twx_assert_0 ( "0" "0" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "0, Empty" )
  twx_assert_0 ( "0" "" )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: true/false
twx_test_unit_will_begin ( ID "true/false" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  set ( foo ON )
  twx_test_simple_start ( "foo => ON, TRUE" )
  twx_assert_true ( "foo" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => ON, TRUE, $" )
  twx_assert_true ( "${foo}" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => ON, FALSE" )
  twx_assert_false ( "foo" )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "foo => ON, FALSE, $" )
  twx_assert_false ( "${foo}" )
  twx_test_simple_assert_fail ()

  set ( foo OFF )
  twx_test_simple_start ( "foo => OFF, FALSE" )
  twx_assert_false ( "foo" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => OFF, FALSE, $" )
  twx_assert_false ( "${foo}" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "foo => OFF, TRUE" )
  twx_assert_true ( "foo" )
  twx_test_simple_assert_fail ()
  twx_test_simple_start ( "foo => OFF, TRUE, $" )
  twx_assert_true ( "${foo}" )
  twx_test_simple_assert_fail ()

  set ( foo "ON" )
  twx_test_simple_start ( "foo => ON" )
  twx_assert_true ( foo "${foo}" )
  twx_test_simple_assert_pass ()

  set ( foo ON )
  set ( bar ON )
  twx_test_simple_start ( "foo => ON, bar => ON" )
  twx_assert_true ( "${foo}" )
  twx_test_simple_assert_pass ()
  twx_assert_true ( "foo" "bar" "${foo}" "${bar}" )
  twx_test_simple_start ( "foo => ON, bar => ON(2)" )
  twx_assert_true ( "foo" "bar" "${foo}" "${bar}" )
  twx_test_simple_assert_pass ()
  
  twx_test_simple_start ( "foo => UNDEFINED" )
  set ( foo )
  twx_assert_false ( foo "foo" )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "Empty" )
  twx_assert_true ( "" )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "wizz => UNDEFINED")
  set ( wizz )
  twx_assert_false ( "wizz" )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "wizz => UNDEFINED, foo => wizz")
  set ( wizz )
  set ( foo "wizz" )
  twx_assert_true ( "foo" )
  twx_test_simple_assert_pass ()

  twx_test_simple_start ( "foo => N, FALSE" )
  set ( foo N )
  twx_assert_false ( foo )
  twx_test_simple_assert_pass ()
  
  twx_test_simple_start ( "foo => N, TRUE" )
  set ( foo N )
  twx_assert_true ( foo )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: exists
twx_test_unit_will_begin ( ID "exists" )
if ( TWX_TEST_UNIT_RUN )
  block ()
  twx_test_simple_start ( "exists" )
  twx_assert_exists ( "${CMAKE_CURRENT_LIST_DIR}/" )
  twx_test_simple_assert_pass ()
  twx_test_simple_start ( "!exists" )
  twx_assert_exists ( "${CMAKE_CURRENT_LIST_DIR}/NO_FILE_AT_THIS_PATH" )
  twx_test_simple_assert_fail ()
  endblock ()
endif ()
twx_test_unit_did_end ()

# ANCHOR: target
twx_test_unit_will_begin ( ID "target" )
if ( TWX_TEST_UNIT_RUN AND NOT TARGET TwxAssertTest.cmakeDummyTarget )
  block ()
  twx_test_simple_start ( "No target" )
  twx_assert_target ( "TwxAssertTest.cmakeDummyTarget" )
  twx_test_simple_assert_fail ()
  add_custom_target ( "TwxAssertTest.cmakeDummyTarget" )
  twx_test_simple_start ( "Target" )
  twx_assert_target ( "TwxAssertTest.cmakeDummyTarget" )
  twx_test_simple_assert_pass ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/