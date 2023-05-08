#[===============================================[
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023

Usage:
```
include (TwxWarning)
```
## Global variables

* `TWX_WARNING_OPTIONS`: adapted to each compiler

Output:
* function `twx_warning`

#]===============================================]

# ANCHOR: TWX_WARNING_OPTIONS
#[=======[
# Initialize `TWX_WARNING_OPTIONS`
#]=======]
if ( NOT DEFINED TWX_WARNING_OPTIONS )
  if (MSVC)
    set (TWX_WARNING_OPTIONS /W4)
  else ()
    set (
      TWX_WARNING_OPTIONS
      -Wall -Wpedantic -Wextra -Wconversion
      -Wold-style-cast -Woverloaded-virtual
    )
  endif ()
endif ()

# ANCHOR: twx_warning_target
#[=======[
Usage:
```
twx_warning_target ( <target> )
```
Set warning options to the given target
#]=======]
function ( twx_warning_target target_ )
  target_compile_options (
    ${target_}
    PRIVATE ${TWX_WARNING_OPTIONS}
  )
endfunction ()

# ANCHOR: twx_warning_add
#[=======[
Usage:
```
twx_warning_add ( <warning_1> ... <warning_n> )
```
Set warning options to the given target
#]=======]
function ( twx_warning_add )
  list (
    APPEND
    TWX_WARNING_OPTIONS
    ${ARGN}
  )
endfunction ()
