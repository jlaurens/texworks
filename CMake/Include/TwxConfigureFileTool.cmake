#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Configure files.

It uses `configure_file` with given arguments ensuring that
the state is properly set beforehands.

Usage:
```
cmake ... -P .../TwxConfigureFileTool.cmake
```

Expected input state:
- `PROJECT_NAME`,
- `PROJECT_BINARY_DIR`,
- `SOURCE_IN`, list of input full paths denoted `<input_k>`
- `BINARY_OUT`, list of corresponding output full paths denoted `<output_k>`
- required file: each one of the `SOURCE_IN` list

Reads both `.ini` files of the `build_data` folder for
`<key_i> = <value_i>` mapping. Then replace in any `<input_k>`
all occurrences of `@TWX_CFG_<key_i>@` by `<value_i>`
and store the result in the coresponding `<output_k>`.

Concerning the keys, one level of indirection
is deliberately chosen to ensure more code logic independance.
The keys inside the input files make no assumption about
the callee context and logic. They just care about the input file
semantic.

Concerning the values, double quotes `"` will be escaped
by the call to `configure_file`.
*//*
#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_assert_non_void ( SOURCE_IN )
twx_assert_non_void ( BINARY_OUT )

include ( TwxCfgLib )

twx_cfg_read ( ONLY_CONFIGURE )

# TODO: verify next
# Known timestamps:
# TWX_CFG_TIMESTAMP_STATIC
# TWX_CFG_TIMESTAMP_GIT

while ( NOT "${SOURCE_IN}" STREQUAL "" )
  list ( GET SOURCE_IN 0 input )
  list ( REMOVE_AT SOURCE_IN 0 )
  list ( GET BINARY_OUT 0 output )
  list ( REMOVE_AT BINARY_OUT 0 )
  twx_core_timestamp ( "${input}" _ts_input )
  twx_core_timestamp ( "${output}" _ts_output )
  if (  _ts_output GREATER _ts_input
    AND _ts_output GREATER TWX_CFG_TIMESTAMP_STATIC
    AND _ts_output GREATER TWX_CFG_TIMESTAMP_GIT
  )
    continue ()
  endif ()
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "configure_file: ${input} => ${output}" )
  endif ()
  configure_file (
    "${input}"
    "${output}"
    ESCAPE_QUOTES
    @ONLY
  )
  # configure_file( "${input}" "${output}(configured)" ESCAPE_QUOTES @ONLY )
  # execute_process(
  #   COMMAND ${CMAKE_COMMAND}
  #   -E compare_files "${output}" "${output}(configured)"
  #   RESULT_VARIABLE compare_result
  # )
  # if( compare_result EQUAL 0)
  #   file (
  #     REMOVE
  #     "${output}(configured)"
  #   )
  # else ()
  #   file (
  #     RENAME
  #     "${output}(configured)" "${output}"
  #   )
  # endif()
endwhile ()

#*/
