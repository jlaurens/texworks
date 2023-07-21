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

message ( STATUS "twx_dir_configure" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT configure )
twx_fatal_assert_passed ()
if ( TRUE )
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
endif ()
twx_fatal_assert_passed ()
endblock ()

endblock ()
twx_test_suite_did_end ()

#/*
