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
* `twx_core_timestamp` function

NB: This does not load the base.

#]===============================================]

# guard

if ( TwxCoreLib_ALREADY )
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
