#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks

*//** @file
@brief The translation management

This file must be added by a primary `CMakeLists.txt`
*//*
#]===============================================]

include_guard ( GLOBAL )

if ( NOT TARGET TeXworks )
  message ( FATAL_ERROR "Not for direct use" )
endif ()

twx_assert_non_void ( TWX_BUILD_DIR )

file ( GLOB TeXworks_TRANS_TS   "${TWX_DIR}src/*.ts" )
file ( GLOB QT_TRANS_QM         "${TWX_DIR}src/*.qm" )

include ( TwxTranslationLib )

twx_translation_target_setup (
  TeXworks
  BUILD_DIR "${TWX_BUILD_DIR}"
  TS_FILES ${TeXworks_TRANS_TS}
  QM_FILES ${QT_TRANS_QM}
  UI_FILES ${TeXworks_UIS}
)
