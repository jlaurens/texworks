#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

if (NOT TWX_IS_BASED)
  message(FATAL_ERROR "Base not loaded")
endif ()

if (DEFINED TWX_WARNING_OPTIONS)
  return ()
endif()

#[=======[

# Initialize `TWX_WARNING_OPTIONS`

Usage:
```
include (InitWarning)
```
Must be included by primary `CMakeLists.txt`.

## Global variables

* `TWX_WARNING_OPTIONS`: adapted to each compiler

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
