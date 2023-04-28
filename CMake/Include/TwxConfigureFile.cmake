
#[=======[
This file is part of the TeXworks build system.
It configures the given files with the given keys.
Usage:
```
include ( TwxConfigureFile )
...
twx_configure_file_prepare (
  <key_1> <value_1>
  ...
  <key_n> <value_n>
)
...
twx_configure_file (
  input
  output
  [ONLY_CHANGED]
)
```
This will replace in iput all occurrences of `@__TWX_<key_i>__@`
by `<value_i>` and store the result in output.
Concerning the keys, one level of indirection
is deliberately chosen to ensure more code logic independance.
The keys inside the input files make no assumption about
the callee context and logic. They just care about the input file
semantic.

When `ONLY_CHANGED` is given, the file configuration occurs
only when there is a change in the result.

Actually, the `prepare` stage if equivalent to
a sequence of
```
set ( __TWX_<key_i>__ "<value_i>")
```
executed in the callee variable scope. The input files
should contain as many `@__TWX__<key_i>__@` as necessary.
JL
#]=======]

function ( twx_configure_file_prepare)
  while ( NOT ARGN STREQUAL "" )
    list ( GET ARGN 0 key )
    list ( REMOVE_AT ARGN 0 )
    if ( NOT ARGN STREQUAL "" )
      list ( GET ARGN 0 value )
      list ( REMOVE_AT ARGN 0 )
      if ( TWX_CONFIG_VERBOSE )
        message ( STATUS "__TWX_${key}__ => ${value}")
      endif ()
      set ( __TWX_${key}__ "${value}" PARENT_SCOPE )
    else ()
      set ( __TWX_${key}__ ""         PARENT_SCOPE )
    endif ()
  endwhile ()
endfunction ()

function ( twx_configure_file input output )
  if ( NOT ARGN STREQUAL "" )
    list ( GET ARGN 0 only_changed )
    if ( only_changed STREQUAL "ONLY_CHANGED" )
      configure_file( "${input}" "${output}(configured)" @ONLY )
      execute_process(
        COMMAND ${CMAKE_COMMAND}
        -E compare_files "${output}" "${output}(configured)"
        RESULT_VARIABLE compare_result
      )
      if( compare_result EQUAL 0)
        file (
          REMOVE
          "${output}(configured)"
        )
      else ()
        file (
          RENAME
          "${output}(configured)" "${output}"
        )
      endif()
      return ()
    endif ()
  endif ()
  configure_file( "${input}" "${output}" @ONLY )
endfunction ()

