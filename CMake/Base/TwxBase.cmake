#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Base material everyone should include
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxBase.cmake"
  *     NO_POLICY_SCOPE
  *   )
  *
  * This is called from a `CMakeFiles.txt` which perfectly knows where it lives
  * and can replace `<...>` with the proper subpath.
  *
  * __Do not forget `NO_POLICY_SCOPE`!__
  *
  * After a new `project(...)` instruction is executed, issue
  *
  *   twx_base_after_project ()
  *
  * Output:
  * - `TWX_DIR`
  * - `twx_base_after_project()`
  * - `twx_base_set_build_dirs()`
  *
  * Implementation details:
  * This script may be called in various situations.
  * - from the main `CMakeLists.txt` at configuration time
  * - from another script in `-P` mode, at either time.
  *
  * In any cases, the global variables above are expected to point to
  * the same location. For `TWX_DIR` it is easy because its location
  * relative to the various `.cmake` script files is well known
  * at some early point.
  */
/*#]===============================================]

# Full include only once
if ( DEFINED TWX_IS_BASED )
  return ()
endif ()

string(ASCII 01 TWX_CHAR_SOH )
string(ASCII 02 TWX_CHAR_STX )
string(ASCII 03 TWX_CHAR_ETX )
string(ASCII 25 TWX_CHAR_EM )
string(ASCII 26 TWX_CHAR_SUB )
string(ASCII 28 TWX_CHAR_FS  )
string(ASCII 29 TWX_CHAR_GS  )
string(ASCII 30 TWX_CHAR_RS  )
string(ASCII 31 TWX_CHAR_US  )

# ANCHOR: twx_set_if_defined
#[=======[*/
/** @brief Set or unset.
  *
  * @param var is the variable to set
  * @param from_var is the variable holding the value.
  * If <from_var> is defined, var is set to the value,
  * otherwise var is unset. Assignments occur in the caller scope.
  */
twx_set_if_defined( var from_var ) {}
/*#]=======]
function ( twx_set_if_defined var_ from_ )
  set ( var_name_ ${var_} )
  set ( from_name_ ${from_} )
  twx_assert_variable ( ${var_name_} )
  twx_assert_variable ( ${from_name_} )
  if ( DEFINED ${from_name_} )
    set ( ${var_} "${${from_name_}}" PARENT_SCOPE )
  else ()
    unset ( ${var_} PARENT_SCOPE )
  endif ()
endfunction ( twx_set_if_defined )

# ANCHOR: twx_base_prettify
#[=======[
*/
/** @brief Turn a content into human readable
  *
  * @param ... a list of strings to manipulate.
  * Support the `$|` syntax.
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_base_prettify(... IN_VAR var) {}
/*
#]=======]
function ( twx_base_prettify )
  twx_arg_assert_count ( ${ARGC} > 2 )
  set ( i 0 )
  set ( v )
  unset ( twxR_IN_VAR )
  while ( TRUE )
    if ( "${ARGV${i}}" STREQUAL IN_VAR )
      twx_increment ( VAR i <= "${ARGC}" )
      twx_assert_defined ( i )
      set ( twxR_IN_VAR "${ARGV${i}}" )
      twx_assert_variable ( "${twxR_IN_VAR}" )
      twx_increment ( VAR i )
      twx_arg_assert_count ( "${ARGC}" == "${i}" )
      break ()
    endif ()
    set ( v "${ARGV${i}}" )
    string ( REPLACE "${TWX_CHAR_SOH}"  "<SOH/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_STX}"  "<STX/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_ETX}"  "<ETX/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_EM}"   "<EM/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_SUB}"  "<SUB/>"  v "${v}" )
    string ( REPLACE "${TWX_CHAR_FS}"   "<FS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_GS}"   "<GS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_RS}"   "<RS/>"   v "${v}" )
    string ( REPLACE "${TWX_CHAR_US}"   "<US/>"   v "${v}" )
    string ( APPEND value_ "${v}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_arg_assert ( IN_VAR )
  set ( "${twxR_IN_VAR}" "${value_}" PARENT_SCOPE )
endfunction ()

# ANCHOR: TWX_PATH_LIST_SEPARATOR
#[=======[
*/
/** @brief The system dependent path list separator.
  *
  * `;` on windows and friends, `:` otherwise.
  */
TWX_PATH_LIST_SEPARATOR;
/*#]=======]
if (WIN32)
	set ( TWX_PATH_LIST_SEPARATOR ";" )
else ()
	set ( TWX_PATH_LIST_SEPARATOR ":" )
endif ()

# ANCHOR: SWITCHER
#[=======[
*//**
The system dependent switcher is used as path component.
Possible values are
- `os_windows`,
- `os_darwin`,
- `os_other`,
*/
TWX_OS_SWITCHER;
/*#]=======]
if (WIN32)
  set ( TWX_OS_SWITCHER "os_windows" )
elseif (APPLE)
  set ( TWX_OS_SWITCHER "os_darwin" )
else ()
  set ( TWX_OS_SWITCHER "os_other" )
endif ()

# ANCHOR: twx_base_after_project
#[=======[*/
/** @brief Setup the state.
  *
  * Set various variables for the newly declareed project.
  *
  */
twx_base_after_project() {}
/*#]=======]
macro ( twx_base_after_project )
  if ( NOT ${ARGC} EQUAL 0 )
    message ( FATAL_ERROR "Too many arguments (0): ARGV => \"${ARGV}\"" )
  endif ()
  if ( "${PROJECT_NAME}" STREQUAL "" )
    message ( FATAL_ERROR "Missing project(...)" )
  endif ()
  # This has already been included
  message ( DEBUG "twx_base_after_project: PROJECT_NAME => ${PROJECT_NAME}" )

	set ( CMAKE_CXX_STANDARD 11 )
  if ( APPLE )
    enable_language ( OBJCXX )
  endif ()

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
/** @brief Main build directory: .../TwxProduct/
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
    twx_base_set_build_dirs (
      BINARY_DIR "${PROJECT_BINARY_DIR}/"
      VAR_PREFIX TWX
    )
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
# ANCHOR: TWX_PROJECT_DOXYDOC_DIR
/** @brief Project build directory: .../TwxDoxydoc/
  *
  * Contains the documentation built by doxydoc.
  */
TWX_PROJECT_DOXYDOC_DIR;
# ANCHOR: TWX_PROJECT_PRODUCT_DIR
/** @brief Project build directory: .../TwxProduct/
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
  twx_base_set_build_dirs (
    BINARY_DIR "${PROJECT_BINARY_DIR}/"
    VAR_PREFIX TWX_PROJECT
  )

# Minor changes
  if ( NOT "${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}" )
    set ( TWX_PROJECT_IS_ROOT OFF )
  endif ()
endmacro ( twx_base_after_project )

set ( TWX_IS_BASED ON )

# Next is meant to be run only once per cmake session.
# However, a different process can run this on its own.

# We load the policies as soon as possible
# Before using any higher level cmake command
include (
  "${CMAKE_CURRENT_LIST_DIR}/TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)

set ( TWX_PROJECT_IS_ROOT ON )

# ANCHOR: twx_base_set_build_dirs ()
#[=======[
/** @brief Set various build location variables
  *
  * All the locations end with exactly one `/` character.
  *
  * @param binary for key `BINARY_DIR`, must end with exactly one `/`.
  * @param prefix for key `VAR_PREFIX` optional
  * @param PARENT_SCOPE optional flag to indicate wether affectations occur
  * in the parent scope instead of the current scope.
  */
twx_base_set_build_dirs( ... ) {}
/*#]=======]
macro ( twx_base_set_build_dirs twx_base_set_build_dirs.BINARY_DIR twx_base_set_build_dirs.BINARY_DIR )
  if ( NOT "${twx_base_set_build_dirs.BINARY_DIR}" STREQUAL "BINARY_DIR" )
    message ( FATAL_ERROR "Unexpected ${twx_base_set_build_dirs.BINARY_DIR} instead of BINARY_DIR" )
  endif ()
  if ( "${twx_base_set_build_dirs.BINARY_DIR}" STREQUAL "" )
    message ( FATAL_ERROR "Missing argument" )
  endif ()
  unset ( twx_base_set_build_dirs.VAR_PREFIX )
  set ( twx_base_set_build_dirs.PARENT_SCOPE )
  if ( "${ARGC}" GREATER "2" )
    if ( "${ARGV2}" STREQUAL "VAR_PREFIX" )
      if ( "${ARGC}" LESS "4" )
        message ( FATAL_ERROR "Wrong number of arguments." )
      else ()
        set ( twx_base_set_build_dirs.VAR_PREFIX "${ARGV3}" )
        if ( "${ARGV4}" STREQUAL PARENT_SCOPE )
          set ( twx_base_set_build_dirs.PARENT_SCOPE PARENT_SCOPE )
          if ( "${ARGC}" GREATER "5" )
            message ( FATAL_ERROR "Too many arguments (extra ${ARGV5})." )
          endif ()
        endif ()
      endif ()
    elseif ( "${ARGV2}" STREQUAL PARENT_SCOPE )
      set ( twx_base_set_build_dirs.PARENT_SCOPE PARENT_SCOPE )
      if ( "${ARGC}" GREATER "3" )
        message ( FATAL_ERROR "Too many arguments (extra ${ARGV3})." )
      endif ()
    endif ()
  endif ()
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_BUILD_DIR       "${twx_base_set_build_dirs.BINARY_DIR}TwxBuild/"         ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_BUILD_DATA_DIR  "${twx_base_set_build_dirs.BINARY_DIR}TwxBuildData/"     ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_DOXYDOC_DIR     "${twx_base_set_build_dirs.BINARY_DIR}TwxDoxydoc/"       ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_CFG_INI_DIR     "${twx_base_set_build_dirs.BINARY_DIR}TwxBuildData/"     ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_PRODUCT_DIR     "${twx_base_set_build_dirs.BINARY_DIR}TwxProduct/"       ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_DOC_DIR         "${twx_base_set_build_dirs.BINARY_DIR}TwxDocumentation/" ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_DOWNLOAD_DIR    "${twx_base_set_build_dirs.BINARY_DIR}TwxDownload/"      ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_PACKAGE_DIR     "${twx_base_set_build_dirs.BINARY_DIR}TwxPackage/"       ${twx_base_set_build_dirs.PARENT_SCOPE} )
  set ( ${twx_base_set_build_dirs.VAR_PREFIX}_EXTERNAL_DIR    "${twx_base_set_build_dirs.BINARY_DIR}TwxExternal/"      ${twx_base_set_build_dirs.PARENT_SCOPE} )
endmacro ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )
twx_assert_non_void ( TWX_IS_BASED )

twx_base_set_build_dirs (
  BINARY_DIR "${CMAKE_BINARY_DIR}/"
  VAR_PREFIX TWX
)
twx_base_set_build_dirs (
  BINARY_DIR "${CMAKE_BINARY_DIR}/"
  VAR_PREFIX TWX_PROJECT
)

twx_message ( VERBOSE
  "ROOT   DIR => ${TWX_DIR}"
  "SOURCE DIR => ${CMAKE_SOURCE_DIR}"
  "BINARY DIR => ${CMAKE_BINARY_DIR}"
  NO_SHORT
)
#*/
