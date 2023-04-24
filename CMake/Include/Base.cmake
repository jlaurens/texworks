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

#[=======[

See the `README.md`.
Usage:
```
include (
  "${CMAKE_CURRENT_LIST_DIR}/<....>/CMake/Include/Base.cmake"
  NO_POLICY_SCOPE
)
```
where `<....>` are replaced with a proper subpath.
This is called from a `CMakeFiles.txt` which perfectly knows where it lives.

DO NOT forget `NO_POLICY_SCOPE`!

After a new `project(...)` instruction is executed, issue
```
include ( Base )
```

#]=======]

# Full include only once
if ( DEFINED TWX_IS_BASED )
# This has already been included
# Minor changes
  set ( TWX_NAME_CURRENT CMAKE_PROJECT_NAME )
  if ( NOT DEFINED TWX_NAME_ROOT )
    set ( TWX_NAME_ROOT CMAKE_PROJECT_NAME )
  endif ()
  if ( NOT "${TWX_NAME_ROOT}" STREQUAL "${TWX_NAME_CURRENT}" )
    set ( TWX_PROJECT_IS_ROOT OFF )
  endif ()
  return ()
endif ()

set ( TWX_IS_BASED ON )
# Next is run only once per cmake session.
# A different process can run this however.

# We load the policies as soon as possible
# Before using any higher level cmake command
include (
  "${CMAKE_CURRENT_LIST_DIR}/BasePolicy.cmake"
  NO_POLICY_SCOPE
)

#[=======[ Global variables
Some global variable mimic CMake variables in a more semantic way
* `TWX_NAME_ROOT` is for the main project,
  defined by the very first `project(...)` instruction.
  `Base.cmake` should be loaded at the begining of
  any main `CMakeLists.txt`, and it should be reloaded after each
  `project(...)` instruction.
  For example, `TWX_NAME_ROOT` is set to "TeXworks" when
  building the application.
  When building submodules, essentially for testing purposes,
  this name will most certainly be different.
* `TWX_NAME_CURRENT` is for the current project.
  It is set from any `CMakeLists.txt` that can be main.
* `TWX_PROJECT_IS_ROOT` is switched `ON` the first time `Base.cmake`
  is loaded after a `project` instruction.
  On subsequent load attempts, this is switched `OFF`. 
#]=======]

set (TWX_PROJECT_IS_ROOT ON)

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same localtion, in particular when called from a module
or a sub code unit. `TWX_DIR_ROOT` is always "at the top"
because it is defined relative to this included file.
#]=======]
get_filename_component (
  TWX_DIR_ROOT
  "${CMAKE_CURRENT_LIST_DIR}/../.."
  REALPATH
)
## Convenient paths from root
set ( TWX_DIR_CMake     "${TWX_DIR_ROOT}/CMake" )
set ( TWX_DIR_modules   "${TWX_DIR_ROOT}/modules" )
set ( TWX_DIR_src       "${TWX_DIR_ROOT}/src" )
set ( TWX_DIR_res       "${TWX_DIR_ROOT}/res" )
set ( TWX_DIR_trans     "${TWX_DIR_ROOT}/trans" )
set ( TWX_DIR_scripting "${TWX_DIR_ROOT}/scripting" )
set ( TWX_DIR_testcases "${TWX_DIR_ROOT}/testcases" )

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Include` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
]=======]
list (
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR_CMake}/Include"
  "${TWX_DIR_CMake}/Modules"
)
# Then we include shared components
include ( BaseTools )
include ( BaseConfig )
