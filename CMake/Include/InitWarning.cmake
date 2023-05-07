#[===============================================[
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
#]===============================================]

if (NOT TWX_IS_BASED)
  message(FATAL_ERROR "Base not loaded")
endif ()

if (DEFINED WARNING_OPTIONS)
  return ()
endif()

#[=======[

# Initialize `WARNING_OPTIONS`

Usage:
```
include (InitWarning)
```
Must be included by primary `CMakeLists.txt`.

## Global variables

* `WARNING_OPTIONS`: adapted to each compiler

#]=======]

if (MSVC)
	set (WARNING_OPTIONS /W4)
else ()
	set (
    WARNING_OPTIONS
    -Wall -Wpedantic -Wextra -Wconversion
    -Wold-style-cast -Woverloaded-virtual
  )
endif ()
