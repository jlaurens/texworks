#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Configure files.

It uses `configure_file` with given arguments.
We assume that the state is properly set beforehand.
Used by `twx_cfg_file_end` in a custom command
with dependencies.

Usage:
```
cmake ... -P .../Script/TwxCfgFileCommand.cmake
```

Expected input state:
- `TWX_CFG_INI_DIR` for `TwxCfgLib`
- `TWX_IN`, list of relative input paths denoted `<input_k>`
- `TWX_IN_DIR`, location of the input files
- `TWX_OUT_DIR`, location of the output files
- `TWX_CFG_INI_IDS`
- `TWX_ESCAPE_QUOTES` (usual boolean like text)
- required file: each one of the `TWX_IN` lists.

Reads both `...cfg.ini` files of the `TwxBuildData` folder for
`<key_i> = <value_i>` mapping. Then replace in any `<input_k>`
all occurrences of `@TWX_CFG_<key_i>@` by `<value_i>`
and store the result in the coresponding `<output_k>`.

Concerning the keys, one level of indirection
is deliberately chosen to ensure more code logic independance.
The keys inside the input files make no assumption about
the callee context and logic. They just care about the input file
semantic.

Concerning the values, double quotes `"` will be escaped
by the call to `configure_file` if `TWX_ESCAPE_QUOTES` is set,
otherwise they are left as is.

@note:
  The input state is partially read only.
  We can change some value to a different one except when
  the original value is not void and we wan't to erase it.
  Maybe unsetting is sufficient?
  More precisely, if `TWX_ESCAPE_QUOTES` is originally "TRUE"
  you can execute `set (TWX_ESCAPE_QUOTES FALSE )` to change the value
  to "FALSE", but `set (TWX_ESCAPE_QUOTES )` will come back to "TRUE".
  This surely has something to do with the cache level.
  This is why we have to use different variables.
*//*
#]===============================================]

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_state_deserialize ()

twx_assert_non_void ( TWX_IN TWX_IN_DIR TWX_OUT_DIR )

if ( TWX_NO_PRIVATE )
  set ( NO_PRIVATE_args_ NO_PRIVATE )
  twx_message ( VERBOSE "TwxCfgFileCommand (NO_PRIVATE):" "${TWX_IN_DIR} -> ${TWX_OUT_DIR}" DEEPER )
else ()
  set ( NO_PRIVATE_args_ )
  twx_message ( VERBOSE "TwxCfgFileCommand (PRIVATE):" "${TWX_IN_DIR} -> ${TWX_OUT_DIR}" DEEPER )
endif ()

include ( TwxCfgLib )
include ( TwxCfgFileLib )

twx_cfg_read ( ${TWX_CFG_INI_IDS} ${NO_PRIVATE_args_} ONLY_CONFIGURE )

# TODO: verify the efficiency of ..._TIMESTAMP_... tech
# Known timestamps:
# TWX_TIMESTAMP_static_CFG
# TWX_TIMESTAMP_git_CFG

if ( TWX_ESCAPE_QUOTES )
  set ( ESCAPE_QUOTES_arg ESCAPE_QUOTES )
else ()
  set ( ESCAPE_QUOTES_arg )
endif ()

foreach ( file.in ${TWX_IN} )
  twx_cfg_file_name_out ( file.out IN "${file.in}" )
  set ( input  "${TWX_IN_DIR}${file.in}"   )
  twx_assert_exists ( "${input}" )
  set ( output "${TWX_OUT_DIR}${file.out}" )
  twx_util_timestamp ( "${input}"  _ts_input  )
  twx_util_timestamp ( "${output}" _ts_output )
  if (  "${_ts_output}" GREATER "${_ts_input}"
    AND "${_ts_output}" GREATER "${TWX_TIMESTAMP_factory_CFG}"
    AND "${_ts_output}" GREATER "${TWX_TIMESTAMP_git_CFG}"
  )
    continue ()
  endif ()
  twx_message ( VERBOSE "TwxCfgFileCommand: ${file.in} => ${file.out}" )
  configure_file (
    "${input}"
    "${output}"
    ${ESCAPE_QUOTES_arg}
    @ONLY
  )
endforeach ()

twx_message ( VERBOSE "TwxCfgFileCommand... DONE" )

#*/
