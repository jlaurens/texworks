#[=====================================[

See the `README.md`.
Usage:
```
include (
  "${CMAKE_CURRENT_LIST_DIR}/..../CMake/Include/Base.cmake"
  NO_POLICY_SCOPE
)
```
where `....` are replaced with a proper subpath.
This is called from a `CMakeFiles.txt` which perfectly knows where it lives.

DO NOT forget `NO_POLICY_SCOPE`!

#]=====================================]

#Include only once
if (DEFINED TWX_DIR_ROOT)
  set (TWX_PROJECT_IS_ROOT OFF)
  set (TWX_NAME_CURRENT CMAKE_PROJECT_NAME)
  return ()
endif()

#[=======[ Global variables
Some global variable mimic CMake variables in a more semantic way
* `TWX_NAME_MAIN` is for the main project,
  defined by the very first `project(...)` instruction.
  `Base.cmake` should be loaded at the begining of
  any main `CMakeLists.txt`, and it should be reloaded after each
  `project(...)` instruction.
  `TWX_NAME_MAIN` is set to "TeXworks" when building the application.
  When building submodules, essentially for testing purposes,
  this name will most certainly be different.
* `TWX_NAME_CURRENT` is for the current project.
  It is set from any `CMakeLists.txt` that can be main.
* `TWX_PROJECT_IS_ROOT` is switched `ON` the first time `Base.cmake`
  is loaded after a `project` instruction.
  On subsequent load attempts, this is switched `OFF`. 
]=======]

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same localtion, in particular when called from a module
or a sub code unit. `TWX_DIR_ROOT` is always "at the top"
because it is defined relative to this included file.
]=======]
get_filename_component(
  TWX_DIR_ROOT
  "${CMAKE_CURRENT_LIST_DIR}/../.."
  REALPATH
)

## Paths from root
set(TWX_DIR_CMake     "${TWX_DIR_ROOT}/CMake")
set(TWX_DIR_modules   "${TWX_DIR_ROOT}/modules")
set(TWX_DIR_src       "${TWX_DIR_ROOT}/src")
set(TWX_DIR_res       "${TWX_DIR_ROOT}/res")
set(TWX_DIR_trans     "${TWX_DIR_ROOT}/trans")
set(TWX_DIR_scripting "${TWX_DIR_ROOT}/scripting")

## A more semantic shortcut
set(TWX_DIR_build "${CMAKE_CURRENT_BINARY_DIR}")
 
#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Include` and `CMake/Modules` available.
The former contains tools and utilities
whereas the latter only contains modules.
]=======]
list(
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR_CMake}/Include"
  "${TWX_DIR_CMake}/Modules"
)

if (TWX_CMakeLists_STEP_Policy)
  include (
    BasePolicy
    NO_POLICY_SCOPE
  )
endif ()

if (TWX_CMakeLists_STEP_Tools)
  include (BaseTools)
endif ()

if (TWX_CMakeLists_STEP_Config)
  include (BaseConfig)
endif ()

