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

# ANCHOR: twx_dir_after_project
#[=======[*/
/** @brief Setup the state.
  *
  * Set various variables for a newly declareed project.
  *
  */
twx_base_after_project() {}
/*#]=======]
macro ( twx_dir_after_project )
  twx_expect_compare ( ${ARGC} == 1 )
  twx_expect_unequal_string ( "${PROJECT_NAME}" "" )
  # This has already been included
  message ( DEBUG "twx_dir_after_project: PROJECT_NAME => ${PROJECT_NAME}" )
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
  twx_dir_configure (
    BINARY_DIR "${PROJECT_BINARY_DIR}/"
    VAR_PREFIX TWX_PROJECT
    MKDIR
  )

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
  twx_expect_equal_string ( "${.BINARY_DIR}" "BINARY_DIR" )
  twx_expect_equal_string ( "${.VAR_PREFIX}" "VAR_PREFIX" )
  twx_expect_unequal_string ( "${twx.R_BINARY_DIR}" "/" )
  twx_assert_exists ( "${twx.R_BINARY_DIR}" )
  twx_assert_variable_name ( "${twx.R_VAR_PREFIX}" )
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

twx_lib_require ( "Fatal" "Assert" "Expect" )

twx_lib_did_load ()

#*/
