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

# ANCHOR: TWX_INCLUDE_DIR property
#[=======[*/
/** @brief Custom property for targets */ TWX_SRC_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR_FOR_TESTING;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_SRC_DIR
  BRIEF_DOCS "src location"
  FULL_DOCS "Stores the source location in the appropriate build directory"
)
define_property (
  TARGET PROPERTY TWX_INCLUDE_DIR
  BRIEF_DOCS "include location"
  FULL_DOCS "Stores the headers include location"
)
define_property (
  TARGET PROPERTY TWX_INCLUDE_DIR_FOR_TESTING
  BRIEF_DOCS "include location, only for testing"
  FULL_DOCS "Stores the headers include location, only for testing"
)

include ( TwxCfgFileLib )
include ( TwxCfgLib )

# ANCHOR: twx_module_setup
#[=======[*/
/** @brief Setup a module.
  *
  * Reads the `Setup.cmake` file of a module
  *
  * @see
  * - `TwxCfgFileLib.cmake`
  * - `TwxCfgPaths.cmake`
  *
  * @param name is the name of the module to setup
  */
twx_module_setup( NAME name ) {}
/*#]=======]
macro ( twx_module_setup NAME TWX_MODULE_NAME )
  twx_assert_equal ( NAME ${NAME} )
  twx_assert_non_void ( TWX_DIR )
  foreach ( t_ SOURCES HEADERS UIS )
    set ( Twx${TWX_MODULE_NAME}_IN_${t_} )
    set ( Twx${TWX_MODULE_NAME}_${t_} )
  endforeach ()
  foreach ( t_ LIBRARIES MODULES INCLUDE_DIRECTORIES )
    set ( Twx${TWX_MODULE_NAME}_${t_} )
  endforeach ()
  twx_module_src_dir ( src_DIR_ NAME ${TWX_MODULE_NAME} )
  include ( "${src_DIR_}/Setup.cmake" )
  twx_cfg_write_begin ( ID "${module_}_private" )
  foreach ( f_ ${Twx${TWX_MODULE_NAME}_IN_SOURCES} ${${module_}_IN_HEADERS} )
    if ( "${f_}" MATCHES "^(.*_private)[.](in[.])?([^.]+)$" )
      twx_cfg_set (
        include_${CMAKE_MATCH_1}_${CMAKE_MATCH_3}
        "#include \"${f_}\""
      )
    endif ()
  endforeach ()
  twx_cfg_write_end ( ID "${module_}_private" )
  # Default main ini file
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  twx_cfg_setup ()
  twx_module_src_dir ( src_DIR_ NAME ${TWX_MODULE_NAME} )
  include ( TwxCfgFileLib )
  twx_cfg_files (
    ID 			SOURCES
    FILES 	${Twx${TWX_MODULE_NAME}_IN_SOURCES}
    IN_DIR 	"${src_DIR_}"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
    EXPORT 	Twx${TWX_MODULE_NAME}
    ESCAPE_QUOTES
  )
  twx_cfg_files (
    ID 			HEADERS
    FILES 	${Twx${TWX_MODULE_NAME}_IN_HEADERS}
    IN_DIR  "${src_DIR_}"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
    EXPORT 	Twx${TWX_MODULE_NAME}
  )
  # twx_cfg_files (
  #   ID 			UIS
  #   FILES 	${Twx${TWX_MODULE_NAME}_IN_UIS}
  #   IN_DIR  "${src_DIR_}" OR /ui?
  #   OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src" 
  #   EXPORT 	Twx${TWX_MODULE_NAME}
  # )
endmacro ()

# ANCHOR: twx_module_declare
#[=======[*/
/** @brief Setup a module.
  *
  * Setup the files for the current module.
  * The module is not yet configured.
  * The module named is guessed from the file location.
  * This must be called from inside the `src` folder
  * of a module folder.
  *
  * @param sources for key SOURCES
  * @param headers for key HEADERS
  * @param uis for key UIS
  * @param libraries for key LIBRARIES
  * @param include_directories for key INCLUDE_DIRECTORIES
  * @param modules for key MODULES
  */
twx_module_declare( SOURCES sources ... ) {}
/*#]=======]
macro ( twx_module_declare )
  if ( NOT "${CMAKE_CURRENT_LIST_FILE}" MATCHES "/modules/Twx([^/]+)/src/Setup.cmake$" )
    message ( FATAL_ERROR "Unexpected usage" )
  endif ()
  set ( name_ "${CMAKE_MATCH_1}" )
  set ( module_ "Twx${name_}" )
  twx_parse_arguments ( "" "" "SOURCES;HEADERS;UIS;LIBRARIES;MODULES;INCLUDE_DIRECTORIES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( t_ SOURCES HEADERS UIS )
    list ( APPEND "${module_}_IN_${t_}" ${my_twx_${t_}})
  endforeach ()
  foreach ( t_ LIBRARIES MODULES INCLUDE_DIRECTORIES )
    list ( APPEND "${module_}_${t_}" ${my_twx_${t_}})
  endforeach ()
endmacro ()

# ANCHOR: twx_module_configure
#[=======[*/
/** @brief Configure a module.
  *
  * This should be run from the module directory
  * main `CMakeLists.txt` only. The name of the module
  * is guessed from the location of this file.
  *
  * Input state:
  * * `/modules/Twx<name>/src/Setup.cmake`, which defines
  *   - `Twx<name>_SOURCES`, `Twx<name>_IN_SOURCES`:
  *      the list of sources, either relative or absolute
  *   - `Twx<name>_HEADERS`, `Twx<name>_IN_HEADERS`:
  *     the list of headers, either relative or absolute
  *   - `Twx<name>_LIBRARIES`, `Twx<name>_INCLUDE_DIRECTORIES`
  *      and `Twx<name>_MODULES` for dependencies.
  * * `/modules/Twx<name>/ui/Setup.cmake`, which defines
  *   - `Twx<name>_UIS`, `Twx<name>_IN_UIS`:
  *      the list of ui files, either relative or absolute
  *      This is work in progress.
  *
  * Output: a static library target named Twx::<name>.
  *
  */
twx_module_configure() {}
/*#]=======]
function ( twx_module_configure )
  
  twx_assert_non_void ( TWX_DIR )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )

  get_filename_component (
    module_
    "${CMAKE_CURRENT_LIST_DIR}"
    NAME
  )
  if ( NOT "${TWX_DIR}/modules/${module_}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}" )
    message ( FATAL_ERROR "Bad usage: ${CMAKE_CURRENT_LIST_DIR} != ${TWX_DIR}/modules/${module_}" )
  endif ()
  if ( NOT "${module_}" MATCHES "^Twx(.*)$")
    message ( FATAL_ERROR "Bad usage: not a module folder ${CMAKE_CURRENT_LIST_DIR}" )
  endif ()
  set ( name_ "${CMAKE_MATCH_1}" )

  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  twx_module_setup ( NAME "${name_}" )
  
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
  foreach ( name_ ${${module_}_MODULES} )
    if ( NOT TARGET Twx${name_} )
      message ( FATAL_ERROR "Wrong module name: ${name_}" )
    endif ()
    target_link_libraries (
      ${module_}
      Twx${name_}
    )
    twx_module_include_dir ( dir_ NAME ${name_} )
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
    FILES 	${${module_}_IN_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include"
    NO_PRIVATE
  )
  twx_cfg_files (
    TARGET 	${module_}
    ID 			INCLUDE_HEADERS_PRIVATE
    FILES 	${${module_}_IN_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include_for_testing"
  )
  set_target_properties (
    ${module_}
    PROPERTIES
      TWX_SRC_DIR "${TWX_PROJECT_BUILD_DIR}/src"
      TWX_INCLUDE_DIR "${TWX_PROJECT_PRODUCT_DIR}/include"
      TWX_INCLUDE_DIR_FOR_TESTING "${TWX_PROJECT_PRODUCT_DIR}/include_for_testing"
  )
  include ( TwxWarning )
  twx_warning_target ( ${module_} )

  if ( NOT TARGET Twx::${name_} )
    add_library ( Twx::${name_} ALIAS ${module_} )
  endif ()

  twx_export (
    ${module_}_SOURCES
    ${module_}_IN_SOURCES
    ${module_}_HEADERS
    ${module_}_IN_HEADERS
    ${module_}_UIS
    ${module_}_IN_UIS
  )
endfunction ()

# ANCHOR: twx_module_load
#[=======[*/
/** @brief Load and setup a module.
  *
  * If the module is already loaded, do nothing.
  * Elseways add the appropriate subdirectory.
  * The `twx_module_configure()` should be used there.
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
  * Its custom properties TWX_INCLUDE_DIR and TWX_INCLUDE_DIR_FOR_TESTING
  * point to the location of the corresponding headers.
  *
  * @param names is the module names to load
  */
twx_module_load(name ...) {}
/*#]=======]
function ( twx_module_load name_ )
  list ( INSERT ARGN 0 "${name_}" )
  foreach ( name_ ${ARGN} )
    set ( module_ "Twx${name_}" )
    if ( TARGET ${module_} )
      continue ()
    endif ()
    twx_module_dir ( module_DIR_ NAME "${name_}" MUST_EXIST )
    if ( Twx${name_}_IS_CURRENTLY_LOADING )
      message ( FATAL_ERROR "Circular dependency of module ${name_}" )
    endif ()
    set ( Twx${name_}_IS_CURRENTLY_LOADING ON )
    add_subdirectory ( "${module_DIR_}" "TwxModules/${module_}")
    if ( NOT TARGET Twx::${name_} )
      message ( FATAL_ERROR "Failed to load module ${name_}" )
    endif ()
    unset ( Twx${name_}_IS_CURRENTLY_LOADING )
  endforeach ()
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
  * @param name for key NAME, is the name of a module, like Core, Engine...
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_include_dir( dir_var NAME name [TEST]) {}
/*#]=======]
function ( twx_module_include_dir dir_ )
  twx_parse_arguments ( "TEST" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  if ( my_twx_TEST )
    set ( property_ TWX_INCLUDE_DIR )
  else ()
    set ( property_ TWX_INCLUDE_DIR_FOR_TESTING )
  endif ()
  twx_module_load ( ${my_twx_NAME} )
  get_target_property(
    ${dir_}
    Twx${my_twx_NAME}
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
  * @param name for key NAME, is the name of a module, like Core, Engine...
  */
twx_module_src_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_src_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}/src" )
  if ( NOT EXISTS "${${dir_}}" )
    message ( FATAL_ERROR "No module named ${my_twx_NAME}" )
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
  * @param name for key NAME, is the name of a module, like Core, Engine...
  */
twx_module_ui_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_ui_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
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
  * @param name for key NAME, is the name of a module, like Core, Engine...
  */
twx_module_test_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_test_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
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
  * @param names is a list of module names, without leading `Twx`, like "Core"...
  * @param targets for key TARGETS is a list of existing target names
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_add ( names ... TARGETS targets ... [TEST] ) {}
/*#]=======]
function ( twx_module_add )
  twx_parse_arguments ( "TEST" "" "TARGETS" ${ARGN} )
  twx_assert_non_void ( my_twx_TARGETS )
  twx_assert_non_void ( my_twx_UNPARSED_ARGUMENTS )
  twx_pass_option ( TEST )
  foreach ( target_ ${my_twx_TARGETS} )
    twx_assert_target ( ${target_} )
    foreach ( name_ ${my_twx_UNPARSED_ARGUMENTS} )
      twx_module_load ( "${name_}" )
      target_link_libraries (
        ${target_}
        Twx::${name_}
      )
      twx_module_include_dir (
        include_dir_
        NAME "${name_}"
        ${my_twx_TEST}
      )
      target_include_directories (
        ${target_}
        PRIVATE "${include_dir_}"
      )
    endforeach ()
  endforeach ()
endfunction ()

# ANCHOR: twx_module_src_include
#[=======[*/
/** @brief Include some module `src` directories into targets.
  *
  * Add the `src` build subdirectory of the modules to the given targets.
  * The modules are loaded in order to use the real source files after
  * the various `configure_file()` step.
  *
  * This is mainly used by test suites that do not link with the module.
  *
  * @notes:
  * * Contrary to twx_target_include_src(), the source subdirectory is not included.
  * * This is run while configuring a module.
  *
  * @param name is a list of module names
  * @param targets for key TARGETS is a list of existing target names
  */
twx_module_src_include(names ... TARGETS targets ... ) {}
/*#]=======]
function ( twx_module_src_include )
  twx_parse_arguments ( "" "" "TARGETS" ${ARGN} )
  foreach ( target_ ${my_twx_TARGETS} )
    twx_assert_target ( "${target_}" )
    foreach ( name_ ${my_twx_UNPARSED_ARGUMENTS} )
      twx_module_load( "${name_}" )
      add_dependencies ( ${target_} Twx${name_} )
      target_include_directories (
        ${target_}
        PRIVATE
          "${TWX_PROJECT_BUILD_DIR}/src"
      )
    endforeach ()
  endforeach ()
endfunction ()

# ANCHOR: twx_module_exists
#[=======[*/
/** @brief Whether a module exists.
  *
  * @param ans_var is the name of a boolean like variable holding the result.
  * @param name for key NAME is a module name, without leading `Twx`.
  */
twx_module_exists( ans_var NAME name) {}
/*#]=======]
function ( twx_module_exists ans )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( TWX_DIR )
  set ( module_DIR_ "${TWX_DIR}/modules/Twx${my_twx_NAME}" )
  if ( NOT "${my_twx_NAME}" STREQUAL "" AND EXISTS "${module_DIR_}" )
    set ( ${ans} ON )
  else ()
    set ( ${ans} OFF )
  endif ()
  twx_export ( ${ans} )
endfunction ()


# ANCHOR: twx_module_dir
#[=======[*/
/** @brief Whether a module exists.
  *
  * @param ans_var is the name of a variable holding the result.
  * @param name for key NAME is a module name, without leading `Twx`.
  * @param MUST_EXIST a flag to raise if the module does not exist
  */
twx_module_dir( ans_var NAME name MUST_EXIST ) {}
/*#]=======]
function ( twx_module_dir dir_ )
  twx_parse_arguments ( "MUST_EXIST" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( TWX_DIR )
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}" )
  if ( my_twx_MUST_EXIST AND NOT EXISTS "${${dir_}}" )
    message ( FATAL_ERROR "No module named ${my_twx_NAME}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

#*/
