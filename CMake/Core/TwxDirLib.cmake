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
  * - `twx_dir_configure()`
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

include_guard ( GLOBAL )

twx_lib_will_load ()

twx_lib_require ( Var Assert Expect )

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same location, in particular when called from a module
or a sub code unit. The same holds for `CMAKE_SOURCE_DIR`.
`TWX_DIR` is always "at the top" because it is defined
relative to this included file.
#]=======]
file (
  REAL_PATH
  "${CMAKE_CURRENT_LIST_DIR}/../../"
  TWX_DIR
)

# ANCHOR: twx_dir_complete_var
#[=======[*/
/** @brief Complete dir variables contents.
  *
  * When the variable is not empty, ensures that it ends with a `/`.
  * The resulting path may not exists though.
  *
  * @param ..., non empty list of string variables containing locations of directories.
  *
  */
twx_dir_complete_var(...) {}
/*
Implementation details:
The argument are IO variable names, such that we must name local variables with great care,
otherwise there might be a conflict.
#]=======]
function ( twx_dir_complete_var twx_dir_complete_var.var )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  set ( twx_dir_complete_var.i 0 )
  while ( TRUE )
    set ( twx_dir_complete_var.v "${ARGV${twx_dir_complete_var.i}}" )
    # message ( TR@CE "v => ``${twx_dir_complete_var.v}''")
    twx_var_assert_name ( "${twx_dir_complete_var.v}" )
    twx_assert_defined ( "${twx_dir_complete_var.v}" )
    set ( twx_dir_complete_var.w "${${twx_dir_complete_var.v}}" )
    if ( NOT "${twx_dir_complete_var.w}" STREQUAL "" AND NOT "${twx_dir_complete_var.w}" MATCHES "/$" )
      set ( "${twx_dir_complete_var.v}" "${twx_dir_complete_var.w}/" PARENT_SCOPE )
    endif ()
    math ( EXPR twx_dir_complete_var.i "${twx_dir_complete_var.i}+1" )
    if ( twx_dir_complete_var.i GREATER_EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_dir_complete_var )

twx_dir_complete_var ( TWX_DIR )

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Base` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
]=======]
list (
  PREPEND CMAKE_MODULE_PATH
  "${TWX_DIR}CMake/Core"
  "${TWX_DIR}CMake/Base"
  "${TWX_DIR}CMake/Main"
  "${TWX_DIR}CMake/Modules"
)
list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )
message ( DEBUG "CMAKE_MODULE_PATH setup DONE" )

# ANCHOR: twx_dir_after_project
#[=======[*/
/** @brief Setup the state.
  *
  * Set various variables for a newly declared project.
  *
  */
twx_base_after_project() {}
/*#]=======]
macro ( twx_dir_after_project )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  twx_expect_compare ( ${ARGC} == 1 )
  twx_expect_unequal_string ( "${PROJECT_NAME}" "" )
  # This has already been included
  message ( DEBUG "PROJECT_NAME => ${PROJECT_NAME}" )
# ANCHOR: TWX_BUILD_DIR
#[=======[*/
/** @brief Main build directory: .../TwxBuild
  *
  * Contains a copy of the sources, after an eventual configuration step.
  *
  * Set by the very first `include ( TwxCore )`
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
  * Set by the very first `include ( TwxCore )`
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
  * Set by the very first `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PRODUCT_DIR;
# ANCHOR: TWX_DOC_DIR
/** @brief Main documentation directory: .../TwxDoc
  *
  * Contains the main documentation.
  *
  * Set by the very first `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_DOC_DIR;
# ANCHOR: TWX_PACKAGE_DIR
/** @brief Main dowload directory: .../TwxPackage
  *
  * Contains the downloaded material.
  *
  * Set by the very first `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PACKAGE_DIR;
# ANCHOR: TWX_EXTERNAL_DIR
/** @brief Main external directory: .../TwxExternal
  *
  * Contains the material related to the manual and popppler data.
  *
  * Set by the very first `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_EXTERNAL_DIR;
# ANCHOR: TWX_TEST_DIR
/** @brief Main test directory: .../TwxTest
  *
  * Contains the material related to the manual and popppler data.
  *
  * Set by the very first `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_TEST_DIR;
/*#]=======]
  if ( "${TWX_BUILD_DIR}" STREQUAL "" )
    twx_assert_exists ( "${PROJECT_BINARY_DIR}" )
    twx_dir_configure (
      BINARY_DIR "${PROJECT_BINARY_DIR}/"
      VAR_PREFIX TWX
      MKDIR
    )
  endif ()

# ANCHOR: TWX_PROJECT_BUILD_DIR
#[=======[*/
/** @brief Project build directory: .../TwxBuild
  *
  * Contains a copy of the sources, after an eventual configuration step.
  *
  * Set by the `include ( TwxCore )`
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
  * Set by the `include ( TwxCore )`
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
  * Set by the `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_PRODUCT_DIR;
# ANCHOR: TWX_PROJECT_DOC_DIR
/** @brief Project documentation directory: .../TwxDoc
  *
  * Contains the project documentation.
  *
  * Set by the `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_DOC_DIR;
# ANCHOR: TWX_PROJECT_PACKAGE_DIR
/** @brief Project documentation directory: .../TwxPackage
  *
  * Contains the project documentation.
  *
  * Set by the `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_PACKAGE_DIR;
# ANCHOR: TWX_PROJECT_EXTERNAL_DIR
/** @brief Project documentation directory: .../TwxExternal
  *
  * Contains the project documentation and poppler data.
  *
  * Set by the `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_EXTERNAL_DIR;
# ANCHOR: TWX_PROJECT_TEST_DIR
/** @brief Project test directory: .../TwxTest
  *
  * Contains the project test data.
  *
  * Set by the `include ( TwxCore )`
  * that follows a `project()` declaration.
  */
TWX_PROJECT_TEST_DIR;
/*#]=======]
  twx_dir_configure (
    BINARY_DIR "${PROJECT_BINARY_DIR}/"
    VAR_PREFIX TWX_PROJECT
    MKDIR
  )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ( twx_dir_after_project )

# ANCHOR: twx_dir_configure ()
#[=======[
/** @brief Set various build location variables
  *
  * All these directory locations end with exactly one `/` character.
  *
  * @param binary for key `BINARY_DIR`, must end with exactly one `/`.
  * @param prefix for key `VAR_PREFIX`
  * @param PARENT_SCOPE optional flag to indicate wether affectations occur
  * in the parent scope instead of the current scope.
  */
twx_dir_configure( BINARY_DIR dir VAR_PREFIX prefix [PARENT_SCOPE] [MKDIR]) {}
/*#]=======]
macro (
  twx_dir_configure
  .BINARY_DIR
  twx.R_BINARY_DIR
  .VAR_PREFIX
  twx.R_VAR_PREFIX
)
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  twx_expect_equal_string ( "${.BINARY_DIR}" "BINARY_DIR" )
  twx_expect_equal_string ( "${.VAR_PREFIX}" "VAR_PREFIX" )
  twx_expect_unequal_string ( "${twx.R_BINARY_DIR}" "/" )
  twx_assert_exists ( "${twx.R_BINARY_DIR}" )
  twx_var_assert_name ( "${twx.R_VAR_PREFIX}" )
  set ( twx_dir_configure.PARENT_SCOPE )
  set ( twx_dir_configure.MKDIR )
  if ( ${ARGC} GREATER "4" )
    if ( "${ARGV4}" STREQUAL PARENT_SCOPE )
      set ( twx_dir_configure.PARENT_SCOPE PARENT_SCOPE )
      if ( ${ARGC} GREATER "5" )
        twx_assert_compare ( ${ARGC} == 6 )
        twx_expect_equal_string ( "${ARGV5}" MKDIR )
        set ( twx_dir_configure.MKDIR ON )
      else ()
        twx_assert_compare ( ${ARGC} == 5 )
      endif ()
    else ()
      twx_assert_compare ( ${ARGC} == 5 )
      twx_expect_equal_string ( "${ARGV4}" MKDIR )
      set ( twx_dir_configure.MKDIR ON )
    endif ()
  endif ()
  set ( ${twx.R_VAR_PREFIX}_BUILD_DIR       "${twx.R_BINARY_DIR}TwxBuild/"         ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_BUILD_DATA_DIR  "${twx.R_BINARY_DIR}TwxBuildData/"     ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_DOXYDOC_DIR     "${twx.R_BINARY_DIR}TwxDoxydoc/"       ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_CFG_INI_DIR     "${twx.R_BINARY_DIR}TwxBuildData/"     ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_PRODUCT_DIR     "${twx.R_BINARY_DIR}TwxProduct/"       ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_DOC_DIR         "${twx.R_BINARY_DIR}TwxDocumentation/" ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_DOWNLOAD_DIR    "${twx.R_BINARY_DIR}TwxDownload/"      ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_PACKAGE_DIR     "${twx.R_BINARY_DIR}TwxPackage/"       ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_EXTERNAL_DIR    "${twx.R_BINARY_DIR}TwxExternal/"      ${twx_dir_configure.PARENT_SCOPE} )
  set ( ${twx.R_VAR_PREFIX}_TEST_DIR        "${twx.R_BINARY_DIR}TwxTest/"          ${twx_dir_configure.PARENT_SCOPE} )
  set (
    TwxBuild_DESCRIPTION
    "It contains intermediate build files"
  )
  set (
    TwxBuildData_DESCRIPTION
    "It contains various data for the build process"
  )
  set (
    TwxDoxydoc_DESCRIPTION
    "It contains doxygen documentation"
  )
  set (
    TwxProduct_DESCRIPTION
    "It contains the built products"
  )
  set (
    TwxDocumentation_DESCRIPTION
    "It contains documentation"
  )
  set (
    TwxDownload_DESCRIPTION
    "It contains download material"
  )
  set (
    TwxPackage_DESCRIPTION
    "It contains various packages"
  )
  set (
    TwxExternal_DESCRIPTION
    "It contains external material"
  )
  set (
    TwxTest_DESCRIPTION
    "It contains test material"
  )
  if ( twx_dir_configure.MKDIR )
    foreach (
      p
        Build
        BuildData
        Doxydoc
        Product
        Documentation
        Download
        Package
        External
        Test
    )
      file ( MAKE_DIRECTORY "${twx.R_BINARY_DIR}Twx${p}" )
      file ( WRITE
        "${twx.R_BINARY_DIR}Twx${p}/Readme.md"
        [[
This folder is automatically generated by the Twx build and test system.
]]
        ${Twx${p}_DESCRIPTION}
      )
    endforeach ()
  endif ()
  set ( twx_dir_configure.PARENT_SCOPE )
  set ( twx_dir_configure.MKDIR )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

twx_dir_configure (
  BINARY_DIR "${CMAKE_BINARY_DIR}/"
  VAR_PREFIX TWX
  MKDIR
)

twx_dir_configure (
  BINARY_DIR "${CMAKE_BINARY_DIR}/"
  VAR_PREFIX TWX_PROJECT
)

twx_lib_did_load ()

#*/
