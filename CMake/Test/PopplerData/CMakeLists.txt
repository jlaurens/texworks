#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief This is a pure test file.

Make a build folder and use cmake ... && cmake --build ...
*/
/*#]===============================================]

cmake_minimum_required ( VERSION 3.25 )

include_guard ( GLOBAL )


include (
  "${CMAKE_CURRENT_LIST_DIR}/../../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)

project ( TwxPopplerDataTest )

twx_base_after_project ()

include ( TwxPopplerDataLib )
twx_poppler_data_setup ()
twx_poppler_data_process ()
