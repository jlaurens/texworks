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
cmake ... -P .../Command/TwxCfgOneFileCommand.cmake
```

Expected input state:
- `TWX_INPUT`, one absolute input location
- `TWX_OUTPUT`, one absolute output location
- `TWX_CFG_INI_IDS`
- `TWX_ESCAPE_QUOTES` (usual boolean like text)
- `TWX_VERBOSE`
- required file: `TWX_INPUT`.

Reads both `...cfg.ini` files of the `TwxBuildData` folder for
`<key_i> = <value_i>` mapping. Then replace in the input
all occurrences of `@TWX_CFG_<key_i>@` by `<value_i>`
and store the result in the coresponding output.

*//*
#]===============================================]

include (
  "${CMAKE_CURRENT_LIST_DIR}/../Include/TwxBase.cmake"
  NO_POLICY_SCOPE
)

twx_assert_non_void ( TWX_INPUT )
twx_assert_non_void ( TWX_OUTPUT )

twx_message_verbose ( "TwxCfgOneFileCommand: ${TWX_INPUT} -> ${TWX_OUTPUT}" DEEPER )

include ( TwxCfgLib )
include ( TwxCfgFileLib )

if ( TWX_NO_PRIVATE )
  set ( NO_PRIVATE_args_ NO_PRIVATE )
else ()
  set ( NO_PRIVATE_args_ )
endif ()

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

twx_assert_exists ( TWX_INPUT )
twx_core_timestamp ( "${TWX_INPUT}"  _ts_input  )
twx_core_timestamp ( "${outTWX_OUTPUTput}" _ts_output )
if (  _ts_output GREATER _ts_input
  AND _ts_output GREATER TWX_TIMESTAMP_static_CFG
  AND _ts_output GREATER TWX_TIMESTAMP_git_CFG
)
twx_message_verbose ( "TwxCfgFileCommand: ${TWX_INPUT} => ${TWX_OUTPUT}" )
configure_file (
  "${TWX_INPUT}"
  "${TWX_OUTPUT}"
  ${ESCAPE_QUOTES_arg}
  @ONLY
)

twx_message_verbose ( "TwxCfgOneFileCommand... DONE" )

#*/
