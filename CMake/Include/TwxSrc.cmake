#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

See `CMake/README.md`.

Usage:
```
include ( TwxSrc )
```
`Base` relative.

Output:
* `twx_src_relative`
* `twx_src_list_append`

#]===============================================]
if ( NOT DEFINED TWX_IS_BASED )
  message ( FATAL_ERROR "`Base` not loaded." )
endif ()

if ( DEFINED TwxSrc_ALREADY )
  return ()
endif ()

set ( TwxSrc_ALREADY )

if ( "${TWX_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Missing TWX_DIR" )
endif ()

if ( "${PROJECT_BINARY_DIR}" STREQUAL "" )
  message ( FATAL_ERROR "Missing PROJECT_BINARY_DIR" )
endif ()

# ANCHOR: twx_src_relative
#[=======[
Get the component relative to `<TWX_DIR>/src` or `<PROJECT_BINARY_DIR>/src`.

Usage:
```
twx_src_relative ( full_path variable )
```

Arguments:
* `full_path` is a full path.
* `variable` will receive the relative path.

#]=======]
function ( twx_src_relative full_path variable )
  file (
    RELATIVE_PATH
    relative
    "${TWX_DIR}/src"
    "${full_path}"
  )
  if ( relative MATCHES "^\.\./" )
    file (
      RELATIVE_PATH
      relative
      "${PROJECT_BINARY_DIR}/src"
      "${full_path}"
    )
    if ( relative MATCHES "^\.\./" )
      message ( FATAL_ERROR "${full_path} does not belong to ${TWX_DIR}" )
    endif ()
  endif ()
  set (
    "${variable}"
    "${relative}"
    PARENT_SCOPE
  )
endfunction ()

# ANCHOR: twx_src_list_append
#[=======[
Append a relative path to a file list

Usage:
```
twx_src_list_append ( path_list full_path_1 [ full_path_2 ... ] )
```

Arguments:
* `list` is the list name.
* `full_path_i` will be processed by `twx_relative`

#]=======]
function ( twx_src_list_append path_list full_path )
  while ( true )
    twx_src_relative ( "${full_path}" relative )
    list ( APPEND "${path_list}" "${relative}" )
    if ( "${ARGN}" STREQUAL "" )
      break ()
    endif ()
    list ( GET ARGN 0 full_path)
    list ( REMOVE_AT ARGN 0 )
  endwhile ()
  set (
    "${path_list}"
    ${${path_list}}
    PARENT_SCOPE
  )
endfunction ()

