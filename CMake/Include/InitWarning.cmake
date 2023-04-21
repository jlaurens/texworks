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
	set(WARNING_OPTIONS /W4)
else ()
	set(WARNING_OPTIONS -Wall -Wpedantic -Wextra -Wconversion -Wold-style-cast -Woverloaded-virtual)
  if (QT_VERSION_MAJOR)
    if (NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "5.6.0")
      # Old Qt versions were heavily using 0 instead of nullptr, giving lots
      # of false positives
      list(APPEND WARNING_OPTIONS -Wzero-as-null-pointer-constant)
    endif ()
  endif ()
endif ()
