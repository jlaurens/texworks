#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Base material everyone should include

See @ref CMake/README.md.

Usage:
```
include (
  "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxBase.cmake"
  NO_POLICY_SCOPE
)
```
This is called from a `CMakeFiles.txt` which perfectly knows where it lives
and can replace `<...>` with the proper subpath.

__Do not forget `NO_POLICY_SCOPE`!__

After a new `project(...)` instruction is executed, issue
```
twx_base_after_project ()
```
Output:
- `TWX_DIR`
- `twx_target_include_src()`

Also includes module `CMakeParseArguments` until this is built in.

Implementation details:
This script may be called in various situations.
- from the main `CMakeLists.txt` at configuration time
- from a target at build time
- from another script in `-P` mode, at either time.

In any cases, the global variables above are expected to point to
the same location. For `TWX_DIR` it is easy because its location
relative to the various `.cmake` script files is well known
at some early point.
*/
/*#]===============================================]

# Full include only once
if ( DEFINED TWX_IS_BASED )
  return ()
endif ()
# ANCHOR: twx_target_include_src
#[=======[*/
/** @brief Include `src` directories.
  *
  * Add the main `.../src` directory as well the `src`
  * subdirectory of the project binary directory to
  * the list of include directories of the given target.
  *
  * @param ... is a list of existing target names
  */
twx_target_include_src(...) {}
/*#]=======]
macro ( twx_base_after_project )
# This has already been included
  twx_message_more_verbose ( "TwxBase: CMAKE_PROJECT_NAME => ${CMAKE_PROJECT_NAME}" )

	set ( CMAKE_CXX_STANDARD 11 )
	# Tell CMake to run moc and friends when necessary:
	set ( CMAKE_AUTOMOC ON )
	set ( CMAKE_AUTOUIC ON )
	set ( CMAKE_AUTORCC ON )
	# As moc files are generated in the binary dir, tell CMake
	# to always look for includes there:
	set ( CMAKE_INCLUDE_CURRENT_DIR ON )

  set ( CMAKE_COLOR_MAKEFILE ON )

  # ANCHOR: TWX_BUILD_DIR
#[=======[*/
/** @brief Main build directory: .../TwxBuild
  *
  * Contains a copy of the sources, after an eventual configuration step.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_BUILD_DIR;
# ANCHOR: TWX_BUILD_DATA_DIR
/** @brief Main build directory: .../TwxBuildData
  *
  * Contains auxiliary data needed in the build process.
  * In particular, it contains shared `...cfg.ini` files that are used
  * in the `configure_file()` instructions steps.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_BUILD_DATA_DIR;
# ANCHOR: TWX_CFG_INI_DIR
/** @brief Main build directory: .../TwxBuildData */
TWX_CFG_INI_DIR;
# ANCHOR: TWX_PRODUCT_DIR
/** @brief Main build directory: .../TwxProduct
  *
  * Contains the main built products, executables, tests and bundles.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PRODUCT_DIR;
# ANCHOR: TWX_DOC_DIR
/** @brief Main documentation directory: .../TwxDoc
  *
  * Contains the main documentation.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_DOC_DIR;
# ANCHOR: TWX_PACKAGE_DIR
/** @brief Main dowload directory: .../TwxPackage
  *
  * Contains the downloaded material.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PACKAGE_DIR;
# ANCHOR: TWX_EXTERNAL_DIR
/** @brief Main external directory: .../TwxExternal
  *
  * Contains the material related to the manual and popppler data.
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_EXTERNAL_DIR;
/*#]=======]
  if ( "${TWX_BUILD_DIR}" STREQUAL "" )
    __twx_base_setup_dir ()
  endif ()

# ANCHOR: TWX_PROJECT_BUILD_DIR
#[=======[*/
/** @brief Project build directory: .../TwxBuild
  *
  * Contains a copy of the sources, after an eventual configuration step.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_BUILD_DIR;
# ANCHOR: TWX_PROJECT_BUILD_DATA_DIR
/** @brief Project build directory: .../TwxBuildData
  *
  * Contains auxiliary data needed in the build process.
  * In particular, it contains `...cfg.ini` files that are used
  * in the `configure_file()` instructions steps.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_BUILD_DATA_DIR;
# ANCHOR: TWX_PROJECT_PRODUCT_DIR
/** @brief Project build directory: .../TwxProduct
  *
  * Contains the built products, executables, tests and bundles.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_PRODUCT_DIR;
# ANCHOR: TWX_PROJECT_DOC_DIR
/** @brief Project documentation directory: .../TwxDoc
  *
  * Contains the project documentation.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_DOC_DIR;
# ANCHOR: TWX_PROJECT_PACKAGE_DIR
/** @brief Project documentation directory: .../TwxPackage
  *
  * Contains the project documentation.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_PACKAGE_DIR;
# ANCHOR: TWX_PROJECT_EXTERNAL_DIR
/** @brief Project documentation directory: .../TwxExternal
  *
  * Contains the project documentation and poppler data.
  *
  * Set by the `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_EXTERNAL_DIR;
/*#]=======]
  __twx_base_setup_dir ( PROJECT_ )

# Minor changes
  set ( TWX_NAME_CURRENT CMAKE_PROJECT_NAME )
  if ( NOT "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}" )
    set ( TWX_PROJECT_IS_ROOT OFF )
  endif ()
endmacro ( twx_base_after_project )

set ( TWX_IS_BASED ON )

# Next is run only once per cmake session.
# A different process can run this however on its own.

# We load the policies as soon as possible
# Before using any higher level cmake command
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )
twx_assert_non_void ( TWX_IS_BASED )


set ( TWX_PROJECT_IS_ROOT ON )

# ANCHOR: twx_target_include_src
#[=======[*/
/** @brief Include `src` directories.
  *
  * Add the main `.../src` directory as well the `src`
  * subdirectory of the project binary directory to
  * the list of include directories of the given target.
  *
  * @param ... is a list of existing target names
  */
twx_target_include_src(...) {}
/*#]=======]
function ( twx_target_include_src )
  twx_assert_non_void ( PROJECT_SOURCE_DIR )
  # TODO: remove PROJECT_BINARY_DIR
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )
  if ( EXISTS "${PROJECT_SOURCE_DIR}/src" )
    foreach ( target_ ${ARGN} )
      target_include_directories (
        ${target_}
        PRIVATE
          "${PROJECT_SOURCE_DIR}/src"
          "${TWX_PROJECT_BUILD_DIR}/src"
      )
    endforeach ()
  else ()
    foreach ( target_ ${ARGN} )
    target_include_directories (
        ${target_}
        PRIVATE
          "${TWX_DIR}/src"
          "${PROJECT_BINARY_DIR}/src"
      )
    endforeach ()
  endif ()
endfunction ( twx_target_include_src )

# ANCHOR: __twx_base_setup_dir ()
#[=======[
/** @brief Setup the various DIR variables
  *
  * Set by the very first `include ( TwxBase )`
  * that follows a `project()` declaration.
  */
__twx_base_setup_dir(...) {}
/*#]=======]
macro ( __twx_base_setup_dir )
  if ( NOT "${ARGN}" STREQUAL "" AND NOT "${ARGN}" STREQUAL "PROJECT_" )
    twx_fatal ( "Unsupported argument: ${ARGN}" )
  endif ()
  if ( NOT "${PROJECT_BINARY_DIR}" STREQUAL "" )
    set ( TWX_${ARGN}BUILD_DIR       "${PROJECT_BINARY_DIR}/TwxBuild" )
    set ( TWX_${ARGN}BUILD_DATA_DIR  "${PROJECT_BINARY_DIR}/TwxBuildData" )
    set ( TWX_${ARGN}CFG_INI_DIR     "${PROJECT_BINARY_DIR}/TwxBuildData" )
    set ( TWX_${ARGN}PRODUCT_DIR     "${PROJECT_BINARY_DIR}/TwxProduct" )
    set ( TWX_${ARGN}DOC_DIR         "${PROJECT_BINARY_DIR}/TwxDocumentation" )
    set ( TWX_${ARGN}DOWNLOAD_DIR    "${PROJECT_BINARY_DIR}/TwxDownload" )
    set ( TWX_${ARGN}PACKAGE_DIR     "${PROJECT_BINARY_DIR}/TwxPackage" )
    set ( TWX_${ARGN}EXTERNAL_DIR    "${PROJECT_BINARY_DIR}/TwxExternal" )
  endif ()
endmacro ()
__twx_base_setup_dir ()
__twx_base_setup_dir ( PROJECT_ )

#*/
