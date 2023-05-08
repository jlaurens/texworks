#[===============================================[
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

Core library.

Usage:
```
include ( TwxCoreLib )
```
Output:
* `TWX_PATH_LIST_SEPARATOR`, `;` on windows, `:` elsewhere,
* `TWX_OS_SWITCHER`: one of "MacOS", "WinOS", "UnixOS"
* `twx_assert_non_void`
* `twx_core_timestamp` function

NB: This does not load the base.

#]===============================================]

# Guard
if ( DEFINED TWX_OS_SWITCHER )
  return ()
endif ()

# ANCHOR: Utility `twx_core_timestamp`
#[=======[
Usage:
```
twx_core_timestamp ( <file_path> <variable> )
```
Records the file timestamp.
The precision is 1s.
Correct up to 2036-02-27.
#]=======]
function ( twx_core_timestamp file_path ans )
  file (
    TIMESTAMP "${file_path}" ts "%S:%M:%H:%j:%Y" UTC
  )
  if ( ts MATCHES "^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$" )
    math(
      EXPR
      ts "
      ${CMAKE_MATCH_1} + 60 * (
        ${CMAKE_MATCH_2} + 60 * (
          ${CMAKE_MATCH_3} + 24 * (
            ${CMAKE_MATCH_4} + 365 * (
              ${CMAKE_MATCH_5}-2023
            )
          )
        )
      )"
    )
    if ( CMAKE_MATCH_5 GREATER 2024 )
      math(
        EXPR
        ts
        "${ts} + 86400" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2028 )
      math(
        EXPR
        ts
        "${ts} + 172800" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2032 )
      math(
        EXPR
        ts
        "${ts} + 259200" 
      )
    elseif ( CMAKE_MATCH_5 GREATER 2036 )
      math(
        EXPR
        ts
        "${ts} + 345600" 
      )
    endif ()
  else ()
    set ( ts 0 )
  endif ()
  set ( ${ans} "${ts}" PARENT_SCOPE )
endfunction ()

# ANCHOR: TWX_PATH_LIST_SEPARATOR
if (WIN32)
	set ( TWX_PATH_LIST_SEPARATOR ";" )
else ()
	set ( TWX_PATH_LIST_SEPARATOR ":" )
endif ()


# ANCHOR: SWITCHER
if (WIN32)
  set ( TWX_OS_SWITCHER "WinOS" )
elseif (APPLE)
  set ( TWX_OS_SWITCHER "MacOS" )
else ()
  set ( TWX_OS_SWITCHER "UnixOS" )
endif ()

# ANCHOR: twx_assert_non_void
#[=======[
Usage:
```
twx_assert_non_void( <variable_name> )
```
Raises when the variable is empty.
#]=======]
function ( twx_assert_non_void _variable )
  if ( "${${_variable}}" STREQUAL "" )
    message ( FATAL_ERROR "Missing ${_variable}")
  endif ()
endfunction ()
