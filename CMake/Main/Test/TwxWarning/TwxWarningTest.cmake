#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxWarningLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

add_library (
  TwxWarningTest.cmake
  "${CMAKE_CURRENT_LIST_DIR}/SOURCES/main.c"
)

twx_test_unit_push ( CORE contains )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( ans_ FALSE )
  twx_warning_contains ( IN_VAR ans_ )
  twx_assert_true ( ans_ )
  twx_fatal_assert_pass ()
  set ( ans_ TRUE )
  twx_warning_contains ( "-WHATEVER" IN_VAR ans_ )
  twx_assert_false ( ans_ )
  twx_fatal_assert_pass ()
  set ( ans_ FALSE )
  twx_warning_contains ( TARGET TwxWarningTest.cmake IN_VAR ans_ )
  twx_fatal_assert_pass ()
  twx_assert_true ( ans_ )
  twx_fatal_assert_pass ()
  set ( ans_ TRUE )
  twx_warning_contains ( "-WHATEVER" TARGET TwxWarningTest.cmake IN_VAR ans_ )
  twx_assert_false ( ans_ )
  twx_fatal_assert_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( CORE add/remove )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( ans_ TRUE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" IN_VAR ans_ )
  twx_assert_false ( ans_ )
  twx_warning_add ()
  twx_fatal_assert_fail ()
  twx_warning_add ( "-WTWX_DUMMY_WARNING" )
  set ( ans_ FALSE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" IN_VAR ans_ )
  twx_assert_true ( ans_ )
  twx_warning_remove ( "-WTWX_DUMMY_WARNING" )
  set ( ans_ TRUE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" IN_VAR ans_ )
  twx_assert_false ( ans_ )
  twx_warning_add ( "-WTWX_DUMMY_WARNING" )
  set ( ans_ FALSE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" IN_VAR ans_ )
  twx_assert_true ( ans_ )
  twx_warning_remove ()
  set ( ans_ TRUE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" IN_VAR ans_ )
  twx_assert_false ( ans_ )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( CORE add-target )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( ans_ TRUE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" TARGET TwxWarningTest.cmake IN_VAR ans_ )
  twx_assert_false ( ans_ )
  twx_warning_add ( "-WTWX_DUMMY_WARNING" TARGET TwxWarningTest.cmake )
  set ( ans_ FALSE )
  twx_warning_contains ( "-WTWX_DUMMY_WARNING" TARGET TwxWarningTest.cmake IN_VAR ans_ )
  twx_assert_true ( ans_ )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
