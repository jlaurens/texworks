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

message ( STATUS "TwxDirLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../../TwxDirLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxAssert/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxExpect/TwxExpectTest.cmake" )

block ()
twx_test_suite_will_begin ()

message ( STATUS "twx_dir_configure" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT configure )
twx_test_fatal_assert_passed ()
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
twx_test_fatal_assert_passed ()
endblock ()

twx_test_suite_did_end ()
endblock ()

message ( STATUS "TwxDirLib test... DONE")

#/*
