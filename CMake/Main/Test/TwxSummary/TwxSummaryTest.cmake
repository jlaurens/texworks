#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxModuleLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

file (
  COPY "${TWX_SOURCE_DIR}TwxCfg.ini"
  DESTINATION "${TWX_BUILD_DATA_DIR}"
)

twx_test_suite_will_begin ()
block ()

twx_cfg_update_factory ()
twx_cfg_update_git ()

twx_test_unit_will_begin ( )
if ( TWX_TEST_UNIT_RUN )
  block ()
  message ( "NO TEST YET" )
  endblock ()
endif ()
twx_test_unit_did_end ()

endblock ()
twx_test_suite_did_end ()

#*/