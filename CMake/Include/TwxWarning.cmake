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

if ( DEFINED TWX_WARNING_OPTIONS )
  return ()
endif ()

# ANCHOR: TWX_WARNING_OPTIONS
#[=======[
# Initialize `TWX_WARNING_OPTIONS`
#]=======]
if (MSVC)
	set (TWX_WARNING_OPTIONS /W4)
else ()
	set (
    TWX_WARNING_OPTIONS
    -Wall -Wpedantic -Wextra -Wconversion
    -Wold-style-cast -Woverloaded-virtual
  )
endif ()

# ANCHOR: target_compile_options
#[=======[
Usage:
```
twx_warning ( <target> )
```
Set warning options to the given target
#]=======]
function ( twx_warning target_ )
  target_compile_options (
    ${target_}
    PRIVATE ${TWX_WARNING_OPTIONS}
  )
endfunction ()
