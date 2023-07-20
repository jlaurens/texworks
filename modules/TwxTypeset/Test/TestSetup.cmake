#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxTypeset/Test Cmake file

Custom setup.

*/
/*
#]===============================================]

include_guard ( GLOBAL )

# A fake typesetting engine
twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME TWX_MODULE_TEST )
twx_assert_target ( test_${TWX_MODULE} )
add_executable (
  engine_${TWX_MODULE}
  main.cpp
)
set_target_properties (
  engine_${TWX_MODULE}
  PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}"
    SUFFIX ".program"
)
