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
include ( Base )
```
Output:
- `TWX_DIR`
- `twx_target_include_src()`

Includes module `TwxCoreLib`.
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
# This has already been included
  if ( TWX_VERBOSE )
    message ( STATUS "TwxBase: ${CMAKE_PROJECT_NAME}(${TWX_DIR})" )
  endif ()

	set ( CMAKE_CXX_STANDARD 11 )
	# Tell CMake to run moc and friends when necessary:
	set ( CMAKE_AUTOMOC ON )
	set ( CMAKE_AUTOUIC ON )
	set ( CMAKE_AUTORCC ON )
	# As moc files are generated in the binary dir, tell CMake
	# to always look for includes there:
	set ( CMAKE_INCLUDE_CURRENT_DIR ON )

  set ( CMAKE_COLOR_MAKEFILE ON )

# Important:
  set ( TWX_PROJECT_BUILD_DIR "${PROJECT_BINARY_DIR}/TwxBuild" )
  set ( TWX_PROJECT_PRODUCT_DIR "${PROJECT_BINARY_DIR}/TwxProduct" )
 
# Minor changes
  set ( TWX_NAME_CURRENT CMAKE_PROJECT_NAME )
  if ( NOT "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}" )
    set ( TWX_PROJECT_IS_ROOT OFF )
  endif ()
  return ()
endif ()

set ( TWX_IS_BASED ON )

# ANCHOR: twx_message_verbose
#[=======[*/
/** @brief Log status message in verbose mode
  *
  * @param ... are text messages
  */
twx_message_verbose(...) {}
/*#]=======]
function ( twx_message_verbose mode_ )
  if ( NOT "${mode_}" STREQUAL "STATUS" )
    list ( INSERT ARGN 0 "${mode_}" )
    set ( mode_ )
  endif ()
  if ( TWX_VERBOSE )
    foreach ( msg_ IN LISTS ARGN)
      message ( ${mode_} "${msg_}" )
    endforeach ()
  endif ()
endfunction ()

# ANCHOR: TWX_DEV
#[=======[*/
/** @brief Whether in developer mode
  *
  * Initially unset.
  * See @ref TWX_PROJECT_NAME.
  */
TWX_DEV;
/*#]=======]

# ANCHOR: TWX_PROJECT_NAME
#[=======[*/
/** @brief The main project name
  *
  * One level of indirection is used for two reasons:
  *
  * * the word `TeXworks` is used so many times while refering to
  *   different meanings,
  * * One may need to change that name. In particular, this name
  *   is reflected in different parts of the file system. We want to
  *   allow a developper to have both a release version and  a developer
  *   version and let them live side by side with nothing in common.
  *   In particular, the developer version is not allowed to break
  *   an existing release version.
  *
  * Set to `TeXworks` in normal mode but to `TeXworks-dev`
  * when if `TWX_DEV` is set.
  * In developer mode, use for example
  * 
  *   cmake ... -DTWX_DEV=ON ...
  * 
  * Shared by Twx modules and main code.
  * In particular, main configuration files for metadata
  * like version and names are <TWX_PROJECT_NAME>.ini.
  *
  * See also the `TeXworks.ini` and `TeXworks-dev.ini`
  * configuration files at the top level.
  */
TWX_PROJECT_NAME;
/*#]=======]
if ( TWX_DEV )
  set ( TWX_PROJECT_NAME TeXworks-dev )
else ()
  set ( TWX_PROJECT_NAME TeXworks )
endif ()

twx_message_verbose( STATUS "TwxBase: TWX_PROJECT_NAME => ${TWX_PROJECT_NAME}" )

# Next is run only once per cmake session.
# A different process can run this however on its own.

# We load the policies as soon as possible
# Before using any higher level cmake command
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

set (TWX_PROJECT_IS_ROOT ON)

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same location, in particular when called from a module
or a sub code unit. The same holds for `CMAKE_SOURCE_DIR`.
`TWX_DIR` is always "at the top" because it is defined
relative to this included file.
#]=======]
get_filename_component (
  TWX_DIR
  "${CMAKE_CURRENT_LIST_DIR}/../.."
  REALPATH
)

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Include` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
We also rely on QtPDF embeded modules.
]=======]
list (
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR}/CMake/Include"
  "${TWX_DIR}/CMake/Modules"
  "${TWX_DIR}/modules/QtPDF/CMake/Modules"
)

# ANCHOR: twx_target_include_src
#[=======[*/
/** @brief Include `src` directories.
  *
  * Add the main `.../src` directory as well the `src`
  * subdirectory of the project binary directory to
  * the list of include directories of the given target.
  *
  * For each module provided, add to the include list
  * the `.../src` folder of the source and build directories.
  * @param target is an existing target name
  * @param ... is an optional list of module names
  */
twx_target_include_src(target ...) {}
/*#]=======]
function ( twx_target_include_src target_ )
  twx_assert_non_void ( PROJECT_SOURCE_DIR )
  twx_assert_non_void ( PROJECT_BINARY_DIR )
  if ( EXISTS "${PROJECT_SOURCE_DIR}/src" )
    target_include_directories (
      ${target_}
      PRIVATE "${PROJECT_SOURCE_DIR}/src" "${PROJECT_BINARY_DIR}/src"
    )
  else ()
    target_include_directories (
      ${target_}
      PRIVATE "${TWX_DIR}/src" "${PROJECT_BINARY_DIR}/src"
    )
  endif ()
endfunction ( twx_target_include_src )

include ( TwxCoreLib )

include ( CMakeParseArguments )

# ANCHOR: twx_parse_arguments
#[=======[*/
/** @brief Covers `cmake_parse_arguments` with name `my_twx`.
  *
  * @param ..., forwards to `cmake_parse_arguments(my_twx ...)`.
  */
twx_parse_arguments(...) {}
/*#]=======]
macro ( twx_parse_arguments OPTIONALS ONES MANIES )
  cmake_parse_arguments ( my_twx "${OPTIONALS}" "${ONES}" "${MANIES}" ${ARGN} )
endmacro ()

# ANCHOR: twx_assert_parsed
#[=======[*/
/** @brief Raise if there are unparsed arguments. */
twx_assert_parsed() {}
/*#]=======]
macro ( twx_assert_parsed )
  # NB remember that arguments in functions and macros are not the same
  if ( NOT "${my_twx_UNPARSED_ARGUMENTS}" STREQUAL "" )
    message ( FATAL_ERROR "Unparsed arguments ${my_twx_UNPARSED_ARGUMENTS}" )
  endif ()
endmacro ()

message ( STATUS "TwxBase: initialize(${TWX_DIR})" )

#[=======[
*/
#]=======]
