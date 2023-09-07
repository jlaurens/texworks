#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxDirLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

# ANCHOR: configure
twx_test_unit_push ( NAME "twx_dir_configure" CORE configure )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  foreach (
    p_
      BUILD_DIR
      BUILD_DATA_DIR
      DOXYDOC_DIR
      CFG_INI_DIR
      PRODUCT_DIR
      DOC_DIR
      DOWNLOAD_DIR
      PACKAGE_DIR
      EXTERNAL_DIR
  )
    # message ( TR@CE "TWX_${p_} => ``${TWX_${p_}}''" )
    twx_test_simple_check ( "${TWX_${p_}}" )
    twx_assert_exists ( "${TWX_${p_}}" )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: complete_var
twx_test_unit_push ( CORE complete_var )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "Undefined" )
  set ( TwxDirTest.VAR )
  twx_dir_complete_var ( TwxDirTest.VAR )
  twx_test_simple_fail ()

  twx_test_simple_check ( "ABC" )
  set ( TwxDirTest.VAR "ABC" )
  twx_dir_complete_var ( TwxDirTest.VAR )
  twx_expect ( TwxDirTest.VAR "ABC/" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "ABC/" )
  set ( TwxDirTest.VAR "ABC/" )
  twx_dir_complete_var ( TwxDirTest.VAR )
  twx_expect ( TwxDirTest.VAR "ABC/" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "ABC//" )
  set ( TwxDirTest.VAR "ABC//" )
  twx_dir_complete_var ( TwxDirTest.VAR )
  twx_expect ( TwxDirTest.VAR "ABC//" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#/*
