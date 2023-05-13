#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Helpers for module

Usage:
  include ( TwxModuleLib )

The modules are expected to share the same structure.
See the `/modules/TwxCore` directory for an example.

See @ref CMake/README.md.

*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_module_load )
# This has already been included
  return ()
endif ()

# ANCHOR: TWX_INCLUDE property
#[=======[*/
/** @brief Custom property for targets */ TWX_INCLUDE;
/** @brief Custom property for targets */ TWX_INCLUDE_FOR_TESTING;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_INCLUDE
  BRIEF_DOCS "include location"
  FULL_DOCS "Stores the headers include location"
)
define_property (
  TARGET PROPERTY TWX_INCLUDE_FOR_TESTING
  BRIEF_DOCS "include location, only for testing"
  FULL_DOCS "Stores the headers include location, only for testing"
)

include ( TwxCfgFileLib )

# ANCHOR: twx_module_setup
#[=======[*/
/** @brief Setup a module.
  *
  * This should be run from the module directory
  * main `CMakeLists.txt` only. The name of the module
  * is guessed from the location of this file.
  *
  * Input state:
  * * `/modules/Twx<name>/src/Setup.cmake`, which defines
  *   - `Twx<name>_SOURCES`, `Twx<name>_RELATIVE_SOURCES`:
  *      the list of sources, either relative or absolute
  *   - `Twx<name>_HEADERS`, `Twx<name>_RELATIVE_HEADERS`:
  *     the list of headers, either relative or absolute
  *   - `Twx<name>_LIBRARIES`, `Twx<name>_INCLUDE_DIRECTORIES`
  *      and `Twx<name>_MODULES` for dependencies.
  * * `/modules/Twx<name>/ui/Setup.cmake`, which defines
  *   - `Twx<name>_UIS`, `Twx<name>_RELATIVE_UIS`:
  *      the list of ui files, either relative or absolute
  *      This is work in progress.
  *
  * Output: a static library target named Twx::<name>.
  *
  */
twx_module_setup() {}
/*#]=======]
function ( twx_module_setup )
  
  twx_assert_non_void ( TWX_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )

  get_filename_component (
    module_
    "${CMAKE_CURRENT_LIST_DIR}"
    NAME
  )
  if ( NOT "${TWX_DIR}/modules/${module_}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}" )
    message ( FATAL_ERROR "Bad usage: ${CMAKE_CURRENT_LIST_DIR} != ${TWX_DIR}/modules/${module_}" )
  endif ()
  if ( NOT "${module_}" MATCHES "^Twx(.*)$")
    message ( FATAL_ERROR "Bad usage" )
  endif ()
  set ( name_ "${CMAKE_MATCH_1}" )
  set ( src_DIR_ "${TWX_DIR}/modules/${module_}/src" )
  include ( "${src_DIR_}/Setup.cmake" )
  
  add_library(
    ${module_}
    STATIC
    ${${module_}_SOURCES}
    ${${module_}_HEADERS}
  )
  target_link_libraries (
    ${module_}
    ${QT_LIBRARIES}
    ${${module_}_LIBRARIES}
  )
  target_include_directories (
    ${module_}
    PRIVATE
      "${TWX_PROJECT_BUILD_DIR}/src"
      ${${module_}_INCLUDE_DIRECTORIES}
  )
  foreach ( m_ IN LISTS ${module_}_MODULES )
    if ( NOT TARGET Twx${m_} )
      message ( FATAL_ERROR "Wrong module name: ${m_}" )
    endif ()
    target_link_libraries (
      ${module_}
      Twx${_m}
    )
    twx_module_include_dir ( dir_ MODULE ${m_} )
    target_include_directories (
      ${module_}
      PRIVATE
        ${dir_}
    )
  endforeach ()
  set_target_properties (
    ${module_}
    PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  twx_cfg_files (
    TARGET 	${module_}
    ID 			INCLUDE_HEADERS
    FILES 	${${module_}_RELATIVE_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include"
    NO_PRIVATE
  )
  twx_cfg_files (
    TARGET 	${module_}
    ID 			INCLUDE_HEADERS_PRIVATE
    FILES 	${${module_}_RELATIVE_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include_for_testing"
  )
  set_target_properties (
    ${module_}
    PROPERTIES
      TWX_INCLUDE "${TWX_PROJECT_PRODUCT_DIR}/include"
      TWX_INCLUDE_FOR_TESTING "${TWX_PROJECT_PRODUCT_DIR}/include_for_testing"
  )
  include ( TwxWarning )
  twx_warning_target ( ${module_} )

  if ( NOT TARGET Twx::${name_} )
    add_library ( Twx::${name_} ALIAS ${module_} )
  endif ()

  twx_export (
    ${module_}_SOURCES
    ${module_}_RELATIVE_SOURCES
    ${module_}_HEADERS
    ${module_}_RELATIVE_HEADERS
    ${module_}_UIS
    ${module_}_RELATIVE_UIS
  )
endfunction ()

# ANCHOR: twx_module_load
#[=======[*/
/** @brief Load and setup a module.
  *
  * If the module is already loaded, do nothing.
  * Elseways add the appropriate subdirectory.
  * The `twx_module_setup()` should be used there.
  *
  * Raises if the module does not exist.
  *
  * This is not reentrant: subdirectories should
  * never even try to load themselves.
  *
  * In practive, modules are loaded from:
  *
  * -  `/CMakeLists.txt`
  * -  `/src/CMakeLists.txt`
  * -  `/Test/CMakeLists.txt` and `/unit-tests/CMakeLists.txt`
  *
  * and from any other `Twx` module.
  *
  * -  `/modules/Twx_<name>/CMakeLists.txt`
  * -  `/modules/Twx_<name>/src/CMakeLists.txt`
  * -  `/modules/Twx_<name>/Test/CMakeLists.txt`
  *
  * Anyway, the `TwxBase` cmake library must be loaded ahead of time.
  *
  * Output: a static library target named Twx::<name>.
  * Its custom properties TWX_INCLUDE and TWX_INCLUDE_FOR_TESTING
  * point to the location of the corresponding headers.
  *
  * @param name is the name of a module
  */
twx_module_load(name) {}
/*#]=======]
function ( twx_module_load name_ )
  set ( module_ "Twx${name_}" )
  if ( TARGET ${module_} )
    return ()
  endif ()
  if ( Twx${name_}_IS_CURRENTLY_LOADING )
    message ( FATAL_ERROR "Circular dependency of module ${name_}" )
  endif ()
  set ( Twx${name_}_IS_CURRENTLY_LOADING ON )
  set ( module_DIR_ "${TWX_DIR}/modules/${module_}" )
  if ( NOT EXISTS "${module_DIR_}" )
    message ( FATAL_ERROR "No module named ${name_}, see ${TWX_DIR}/modules/Twx*" )
  endif ()
  add_subdirectory ( "${module_DIR_}" )
  if ( NOT TARGET Twx::Core )
    message ( FATAL_ERROR "Failed to load module ${name_}" )
  endif ()
  unset ( Twx${name_}_IS_CURRENTLY_LOADING )
endfunction ()

# ANCHOR: twx_module_include_dir
#[=======[*/
/** @brief Get the location of headers.
  *
  * If the module is not already loaded, load it
  * with `twx_module_load()`.
  * Then put the header location in the variable.
  *
  * @param dir_var is the name of a variable holding the resulr
  * @param name for key MODULE, is the name of a module, like Core, Engine...
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_include_dir( dir_var MODULE name [TEST]) {}
/*#]=======]
function ( twx_module_include_dir dir_ )
  twx_parse_arguments ( "TEST" "MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  if ( my_twx_TEST )
    set ( property_ TWX_INCLUDE )
  else ()
    set ( property_ TWX_INCLUDE_FOR_TESTING )
  endif ()
  twx_module_load ( ${my_twx_MODULE} )
  get_target_property(
    ${dir_}
    Twx${my_twx_MODULE}
    ${property_}
  )
  if ( "${${dir_}}" STREQUAL "NOTFOUND" )
    message ( FATAL_ERROR "Internal inconsistency")
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# ANCHOR: twx_module_src_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param dir_var is the name of a variable holding the resulr
  * @param name for key MODULE, is the name of a module, like Core, Engine...
  */
twx_module_src_dir( dir_var MODULE name) {}
/*#]=======]
function ( twx_module_src_dir dir_ )
  twx_parse_arguments ( "" "MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_MODULE}/src" )
  if ( NOT EXISTS "${${dir_}}" )
    message ( FATAL_ERROR "No module named ${my_twx_MODULE}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# ANCHOR: twx_module_ui_dir
#[=======[*/
/** @brief Get the location of ui files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param dir_var is the name of a variable holding the resulr
  * @param name for key MODULE, is the name of a module, like Core, Engine...
  */
twx_module_ui_dir( dir_var MODULE name) {}
/*#]=======]
function ( twx_module_ui_dir dir_ )
  twx_parse_arguments ( "" "MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_MODULE}/ui" )
  if ( NOT EXISTS "${${dir_}}" )
    message ( FATAL_ERROR "No module named ${my_twx_MODULE}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# ANCHOR: twx_module_test_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param dir_var is the name of a variable holding the resulr
  * @param name for key MODULE, is the name of a module, like Core, Engine...
  */
twx_module_test_dir( dir_var MODULE name) {}
/*#]=======]
function ( twx_module_test_dir dir_ )
  twx_parse_arguments ( "" "MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_MODULE}/Test" )
  if ( NOT EXISTS "${${dir_}}" )
    message ( FATAL_ERROR "No module named ${my_twx_MODULE}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# ANCHOR: twx_module_add
#[=======[*/
/** @brief Add a module to a target.
  *
  * If the module is not already loaded, load it
  * with `twx_module_load()`.
  * Then configure the given target to use this module.
  *
  * @param name is the name of a module, like Core, Engine...
  * @param target for key TO is the name of an existing target
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_add ( module TARGET target [TEST] ) {}
/*#]=======]
function ( twx_module_add name_ )
  cmake_parse_arguments( my_twx "" "TARGET" "" ${ARGN} )
  set ( target_ "${my_twx_TARGET}" )
  if ( NOT TARGET "${my_twx_TARGET}" )
    message ( FATAL_ERROR "No ${my_twx_TARGET} target" )
  endif ()
  set ( module_ "Twx${name_}" )
  twx_module_load ( "${name_}" )
  target_link_libraries (
    ${my_twx_TARGET}
    ${module_}
  )
  twx_module_include_dir (
    include_dir_
    MODULE "${name_}"
    ${my_twx_UNPARSED_ARGUMENTS}
  )
  message ( "DEBUG: ${my_twx_TARGET}")
  message ( "DEBUG: ${include_dir_}")
  target_include_directories (
    ${my_twx_TARGET}
    PRIVATE "${include_dir_}"
  )
endfunction ()

# ANCHOR: twx_module_include_src
#[=======[*/
/** @brief Include `src` directories for a module target.
  *
  * Add the `src` subdirectory of the project binary directory to
  * the list of include directories of the given module target.
  *
  * Input state:
  * * `TWX_PROJECT_BUILD_DIR`
  *
  * @notes:
  * * Contrary to twx_target_include_src(), the source subdirectory is not included.
  * * This is run while configuring a module.
  *
  * @param target is a module target, either static library or test
  */
twx_module_include_src(target) {}
/*#]=======]
function ( twx_module_include_src target_ )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )
  target_include_directories (
    ${target_}
    PRIVATE
      "${TWX_PROJECT_BUILD_DIR}/src"
  )
endfunction ()

#*/
