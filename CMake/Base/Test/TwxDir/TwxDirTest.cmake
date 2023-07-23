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

twx_test_suite_will_begin ()
block ()

twx_test_unit_will_begin ( NAME "twx_dir_configure" ID configure )
if ( TWX_TEST_UNIT_RUN )
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
    # message ( TR@CE "TWX_${p_} => \"${TWX_${p_}}\"" )
    twx_assert_exists ( "${TWX_${p_}}" )
  endforeach ()
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#/*
