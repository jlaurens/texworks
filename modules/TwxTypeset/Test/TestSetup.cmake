#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxTypeset/Test Cmake file

Defines a test suite.

Input:
- `TwxTypeset_SOURCES`
- `TwxTypeset_HEADERS`
*/
/*
#]===============================================]

# A fake typesetting engine
twx_assert_non_void ( TWX_MODULE )
twx_assert_target ( ${TWX_MODULE}Test )
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
