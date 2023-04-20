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
* `twx_setup_Qt_VERSION`

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

twx_log(LEVEL 1 "# Setting up ${CMAKE_PROJECT_NAME} for ${QtMAJOR}")

# 1 utilities to find a package and append a component to the given variable
# in general QT_LIBRARIES.

include(CMakeParseArguments)

#[=======[
This function will load Qt components.
The libraries are collected in the `QT_LIBRARIES` variable.

Usage:
```
twx_append_QT(
	REQUIRED <required_1> <required_2> ...
	OPTIONAL <optional_1> <optional_2> ...
)
```
#]=======]
macro (twx_append_QT)
	# this must be a macro because the found packages are likely to
	# change variables within the caller's scope,
	# at least the "_FOUND" ones.
	cmake_parse_arguments(TWX_l "" "" "REQUIRED;OPTIONAL" ${ARGN})
	# Find all the packages
	find_package(
		${QtMAJOR}
		REQUIRED COMPONENTS ${TWX_l_REQUIRED}
		OPTIONAL_COMPONENTS ${TWX_l_OPTIONAL} QUIET
	)
	# Record the libraries
	foreach(COMPONENT IN ITEMS ${TWX_l_REQUIRED})
		list(APPEND QT_LIBRARIES ${QtMAJOR}::${COMPONENT})
	endforeach()
	foreach(COMPONENT IN ITEMS ${TWX_l_OPTIONAL})
	  if(${QtMAJOR}${COMPONENT}_FOUND)
			list(APPEND QT_LIBRARIES ${QtMAJOR}::${COMPONENT})
		endif()
	endforeach()
	# unset local variables
	unset(TWX_l_REQUIRED)
	unset(TWX_l_OPTIONAL)
endmacro ()

#[=======[
Define global variables `QT_VERSION_...` as shortcuts to the real version.
#]=======]
macro (twx_setup_QT_VERSION)
	if (NOT DEFINED QT_VERSION_MINOR)
		set(QT_VERSION_MINOR "${${QtMAJOR}_VERSION_MINOR}")
		set(QT_VERSION_PATCH "${${QtMAJOR}_VERSION_PATCH}")
	endif ()
endmacro ()

set (QT_LIBRARIES)
