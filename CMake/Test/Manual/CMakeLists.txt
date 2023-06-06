#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief This is a pure test file.

Make a build folder and use cmake ... && cmake --build ...
*/
/*#]===============================================]

cmake_minimum_required ( VERSION 3.1 )
project ( TwxManualTest )

set (
  TwxManualCommand.cmake
  "${CMAKE_CURRENT_LIST_DIR}/../../Command/TwxManualCommand.cmake"
)
if ( NOT EXISTS "${TwxManualCommand.cmake}" )
  message ( FATAL_ERROR "Internal inconsistency" )
endif ()

execute_process (
  COMMAND "${CMAKE_COMMAND}"
    "-DPROJECT_BINARY_DIR=${PROJECT_BINARY_DIR}"
    "-DTWX_DEV=${TWX_DEV}"
    "-DTWX_TEST=${TWX_TEST}"
    "-DTWX_VERBOSE=${TWX_VERBOSE}"
    -P "${TwxManualCommand.cmake}"
)
