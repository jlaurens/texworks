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

if (DEFINED TWX_GUARD_CMake_Include_WithQT)
  return ()
endif()

set(TWX_GUARD_CMake_Include_WithQT)

#[=======[
# Qt management utilities

## Global variables

* `QT_VERSION_MAJOR`: `5`, `6`, `7`...
* `QT_VERSION_MINOR`
* `QT_VERSION_PATCH`
* `QtMAJOR`: `Qt5` or `Qt6`.

There is no `QT_VERSION_TWEAK`.

## Utilities:

* `twx_append_QT`

The `Core` is always required.

#]=======]

if (NOT DEFINED QT_VERSION_MAJOR)
	if (DEFINED QT_DEFAULT_MAJOR_VERSION)
		set(QT_VERSION_MAJOR ${QT_DEFAULT_MAJOR_VERSION})
	else ()
	  set(QT_VERSION_MAJOR 5)	  
	endif ()
endif ()

# Expose the major version number of Qt to the preprocessor. This is necessary
# to include the correct Qt headers (as QTVERSION is not defined before any Qt
# headers are included)
add_definitions(
	-DQT_VERSION_MAJOR=${QT_VERSION_MAJOR}
)

# Convenience variable
set(QtMAJOR "Qt${QT_VERSION_MAJOR}")

# 1 utilities to find a package and append a component to the given variable
# in general QT_LIBRARIES.

include(CMakeParseArguments)

#[=======[
This function will load Qt components.
The libraries are collected in the `QT_LIBRARIES` variable.

Usage:
```
twx_append_QT(
	[REQUIRED <required_1> <required_2> ...]
	[OPTIONAL <optional_1> <optional_2> ...]
)
```
#]=======]
macro (twx_append_QT)
	# this must be a macro because the found packages are likely to
	# change variables within the caller's scope,
	# at least the "..._FOUND" ones.
	cmake_parse_arguments(TWX_l "" "" "REQUIRED;OPTIONAL" ${ARGN})
	# Find all the packages
	find_package(
		${QtMAJOR}
		REQUIRED COMPONENTS ${TWX_l_REQUIRED}
		OPTIONAL_COMPONENTS ${TWX_l_OPTIONAL} QUIET
	)
	# Record the libraries, when not already done.
	foreach(TWX_comp IN ITEMS ${TWX_l_REQUIRED})
	  list(FIND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} TWX_k)
		if (${TWX_k} LESS 0)
		  list (APPEND QT_LIBRARIES ${QtMAJOR}::${TWX_comp})
		endif ()
	endforeach ()
	foreach (TWX_comp IN ITEMS ${TWX_l_OPTIONAL})
# TODO: move to CMake 3.3
		list (FIND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} TWX_k)
		if (${TWX_k} LESS 0)
   		list (APPEND QT_LIBRARIES ${QtMAJOR}::${TWX_comp})
		endif ()
	endforeach ()
	# unset local variables
	unset (TWX_l_REQUIRED)
	unset (TWX_l_OPTIONAL)
	unset (TWX_comp)
	unset (TWX_k)
endmacro ()

set (QT_LIBRARIES)

twx_append_QT (REQUIRED Core)

set(QT_VERSION_MINOR "${${QtMAJOR}_VERSION_MINOR}")
set(QT_VERSION_PATCH "${${QtMAJOR}_VERSION_PATCH}")

if (NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "5.6.0")
	# Old Qt versions were heavily using 0 instead of nullptr, giving lots
	# of false positives
	list(APPEND WARNING_OPTIONS -Wzero-as-null-pointer-constant)
endif ()
