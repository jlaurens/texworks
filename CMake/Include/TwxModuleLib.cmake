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

# ANCHOR: twx_module_name
#[=======[*/
/** @brief Get the module name.
  *
  * Retrieve the module name from the path.
  * This MUST be called from the the directory of the module.
  * Used in various `/modules/Twx.../CMakeLists.txt`, indirectly in general.
  *
  * @param name is the name of the module to setup
  */
twx_module_name ( name_var_ ) {}
/*#]=======]
function ( twx_module_name name_var_ )
  twx_assert_non_void ( name_var_ )
  get_filename_component (
    module_
    "${CMAKE_CURRENT_LIST_DIR}"
    NAME
  )
  if ( NOT "${TWX_DIR}/modules/${module_}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}" )
    twx_fatal ( "Bad usage: ${CMAKE_CURRENT_LIST_DIR} != ${TWX_DIR}/modules/${module_}" )
  endif ()
  if ( NOT "${module_}" MATCHES "^Twx(.*)$")
    twx_fatal ( "Bad usage: not a module folder ${CMAKE_CURRENT_LIST_DIR}" )
  endif ()
  set ( ${name_var_} "${CMAKE_MATCH_1}" PARENT_SCOPE )
endfunction ()

# SECTION: Directories
# ANCHOR: twx_module_dir
#[=======[*/
/** @brief The location of a module.
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
    twx_fatal ( "No module named ${my_twx_NAME}" )
  endif ()
  twx_export ( ${dir_} )
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
  * @param name for key NAME, is the name of a module, like Core, Typeset...
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_include_dir( dir_var NAME name [TEST]) {}
/*#]=======]
function ( twx_module_include_dir dir_ )
  twx_parse_arguments ( "TEST" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  if ( my_twx_TEST )
    set ( property_ TWX_INCLUDE_DIR_FOR_TESTING )
  else ()
    set ( property_ TWX_INCLUDE_DIR )
  endif ()
  twx_module_load ( ${my_twx_NAME} )
  get_target_property(
    ${dir_}
    Twx${my_twx_NAME}
    ${property_}
  )
  if ( "${${dir_}}" MATCHES "NOTFOUND" )
    twx_fatal ( "Internal inconsistency")
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
  * @param name for key NAME, is the name of a module, like Core, Typeset...
  */
twx_module_src_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_src_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}/src" )
  if ( NOT EXISTS "${${dir_}}" )
    twx_fatal ( "No module named ${my_twx_NAME}" )
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
  * @param name for key NAME, is the name of a module, like Core, Typeset...
  */
twx_module_ui_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_ui_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}/ui" )
  if ( NOT EXISTS "${${dir_}}" )
    twx_fatal ( "No module named ${my_twx_NAME}" )
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
  * @param name for key NAME, is the name of a module, like Core, Typeset...
  */
twx_module_test_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_test_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}/Test" )
  if ( NOT EXISTS "${${dir_}}" )
    twx_fatal ( "No module named ${my_twx_NAME}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# ANCHOR: twx_module_CMake_dir
#[=======[*/
/** @brief Get the location of CMake files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param dir_var is the name of a variable holding the resulr
  * @param name for key NAME, is the name of a module, like Core, Typeset...
  */
twx_module_test_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_CMake_dir dir_ )
  twx_parse_arguments ( "" "NAME" "" ${ARGN} )
  twx_assert_parsed ()
  set ( ${dir_} "${TWX_DIR}/modules/Twx${my_twx_NAME}/CMake" )
  if ( NOT EXISTS "${${dir_}}" )
    twx_fatal ( "No module named ${my_twx_NAME}" )
  endif ()
  twx_export ( ${dir_} )
endfunction ()

# !SECTION

# SECTION: Setup and use
# ANCHOR: twx_module_setup
#[=======[*/
/** @brief Setup a module.
  *
  * Reads the `Setup.cmake` file of a module.
  * 
  * Output state:
  * - `Twx<module name>_SOURCES`: the list of configured sources
  * - `Twx<module name>_HEADERS`: the list of configured headers
  *
  * @see
  * - `TwxCfgFileLib.cmake`
  * - `TwxCfgPaths.cmake`
  *
  * @param name is the name of the module to setup
  */
twx_module_setup( NAME name ) {}
/*#]=======]
macro ( twx_module_setup NAME name_twx )
  twx_assert_equal ( NAME ${NAME} )
  twx_assert_non_void ( TWX_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  twx_cfg_setup ()
  set ( module_twx Twx${name_twx} )
  foreach ( t_twx SOURCES HEADERS UIS )
    set ( ${module_twx}_IN_${t_twx} )
    set ( ${module_twx}_${t_twx} )
  endforeach ()
  foreach ( t_twx DIR LIBRARIES MODULES INCLUDE_DIRECTORIES )
    set ( ${module_twx}_${t_twx} )
  endforeach ()
  twx_module_src_dir ( ${module_twx}_DIR NAME ${name_twx} )
  include ( "${module_twx}_DIR/Setup.cmake" )
  twx_cfg_write_begin ( ID "${module_twx}_private" )
  foreach ( f_twx ${${module_twx}_IN_SOURCES} ${${module_twx}_IN_HEADERS} )
    if ( "${f_twx}" MATCHES "^(.*_private)[.](in[.])?([^.]+)$" )
      twx_cfg_set (
        include_${CMAKE_MATCH_1}_${CMAKE_MATCH_3}
        "#include \"${f_twx}\""
      )
    endif ()
  endforeach ()
  twx_cfg_write_end ( ID "${${module_twx}}_private" )
  twx_module_src_dir ( src_DIR_ NAME ${name_twx} )
  include ( TwxCfgFileLib )
  twx_cfg_files (
    ID 			SOURCES
    FILES 	${${module_twx}_IN_SOURCES}
    IN_DIR 	"${src_DIR_}"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
    EXPORT 	${module_twx}
    ESCAPE_QUOTES
  )
  twx_cfg_files (
    ID 			HEADERS
    FILES 	${${module_twx}_IN_HEADERS}
    IN_DIR  "${src_DIR_}"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
    EXPORT 	${module_twx}
  )
  # twx_cfg_files (
  #   ID 			UIS
  #   FILES 	${${module_twx}_IN_UIS}
  #   IN_DIR  "${src_DIR_}" OR /ui?
  #   OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src" 
  #   EXPORT 	${module_twx}
  # )
  unset ( t_twx )
  unset ( f_twx )
  unset ( module_twx )
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
  * Output state:
  * - `CMAKE_MODULE_PATH`
  * - `Twx<module name>_DIR`: the location of the module
  * - `Twx<module name>_IN_SOURCES`: list of sources, before configuration
  * - `Twx<module name>_IN_HEADERS`: list of headers, before configuration
  * - `Twx<module name>_IN_UIS`: list of uis, before configuration
  * - `Twx<module name>_LIBRARIES`: list of libraries for linkage
  * - `Twx<module name>_MODULES`: list of needed modules
  * - `Twx<module name>_QT`: list of Qt library names (eg Widgets)
  * - `Twx<module name>_INCLUDE_DIRECTORIES`: arguments of `include_directories`
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
    twx_fatal ( "Unexpected usage" )
  endif ()
  set ( name_twx "${CMAKE_MATCH_1}" )
  set ( module_twx "Twx${name_twx}" )
  twx_parse_arguments ( "" "" "SOURCES;HEADERS;UIS;LIBRARIES;MODULES;QT;INCLUDE_DIRECTORIES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( t_ SOURCES HEADERS UIS )
    list ( APPEND "${module_twx}_IN_${t_}" ${my_twx_${t_}} )
  endforeach ()
  foreach ( t_ LIBRARIES MODULES QT INCLUDE_DIRECTORIES )
    list ( APPEND "${module_twx}_${t_}" ${my_twx_${t_}} )
  endforeach ()
  twx_assert_non_void ( TWX_DIR )
  set ( ${module_twx}_DIR "${TWX_DIR}/modules/${module_twx}" )
  if ( EXISTS "${module_twx}_DIR/CMake" )
    list (
      INSERT CMAKE_MODULE_PATH 0
      "${module_twx}_DIR/CMake"
    )
    list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )
  endif ()
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
  * Output state: a static library target named Twx::<name>.
  * The `CMAKE_MODULE_PATH` is updated if there are CMake files
  * specific to the module.
  */
twx_module_configure() {}
/*#]=======]
function ( twx_module_configure )
  
  twx_assert_non_void ( TWX_DIR )
  twx_assert_non_void ( TWX_PROJECT_PRODUCT_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DIR )

  twx_module_name ( name_twx )
  twx_module_setup ( NAME "${name_twx}" )
  
  set ( module_twx "Twx${name_twx}" )

  add_library (
    ${module_twx}
    STATIC
    ${${module_twx}_SOURCES}
    ${${module_twx}_HEADERS}
  )
  foreach ( qt_ ${${module_twx}_QT} )
    twx_Qt_append ( ${qt_} )
  endforeach ()
  twx_Qt_link_libraries ( ${module_twx} )
  target_link_libraries (
    ${module_twx}
    ${${module_twx}_LIBRARIES}
  )
  target_include_directories (
    ${module_twx}
    PRIVATE
      "${TWX_PROJECT_BUILD_DIR}/src"
      ${${module_twx}_INCLUDE_DIRECTORIES}
  )
  if ( NOT "${${module_twx}_MODULES}" STREQUAL "")
    twx_module_add ( ${${module_twx}_MODULES} TARGETS ${module_twx} )
  endif ()
  set_target_properties (
    ${module_twx}
    PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  twx_cfg_files (
    TARGET 	${module_twx}
    ID 			INCLUDE_HEADERS
    FILES 	${${module_twx}_IN_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include"
    NO_PRIVATE
  )
  twx_cfg_files (
    TARGET 	${module_twx}
    ID 			INCLUDE_HEADERS_PRIVATE
    FILES 	${${module_twx}_IN_HEADERS}
    IN_DIR	"${src_DIR_}"
    OUT_DIR	"include_for_testing"
  )
  set_target_properties (
    ${module_twx}
    PROPERTIES
      TWX_SRC_DIR "${TWX_PROJECT_BUILD_DIR}/src"
      TWX_INCLUDE_DIR "${TWX_PROJECT_PRODUCT_DIR}/include"
      TWX_INCLUDE_DIR_FOR_TESTING "${TWX_PROJECT_PRODUCT_DIR}/include_for_testing"
  )
  include ( TwxWarning )
  twx_warning_target ( ${module_twx} )

  if ( NOT TARGET Twx::${name_twx} )
    add_library ( Twx::${name_twx} ALIAS ${module_twx} )
  endif ()

  twx_export (
    ${module_twx}_DIR
    ${module_twx}_SOURCES
    ${module_twx}_IN_SOURCES
    ${module_twx}_HEADERS
    ${module_twx}_IN_HEADERS
    ${module_twx}_UIS
    ${module_twx}_IN_UIS
    CMAKE_MODULE_PATH
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
function ( twx_module_load name_twx )
  list ( INSERT ARGN 0 "${name_twx}" )
  foreach ( name_twx ${ARGN} )
    set ( module_twx "Twx${name_twx}" )
    if ( TARGET ${module_twx} )
      continue ()
    endif ()
    twx_module_dir ( module_DIR_ NAME "${name_twx}" MUST_EXIST )
    if ( ${module_twx}_IS_CURRENTLY_LOADING )
      twx_fatal ( "Circular dependency of module ${name_twx}" )
    endif ()
    set ( ${module_twx}_IS_CURRENTLY_LOADING ON )
    add_subdirectory ( "${module_DIR_}" "TwxModules/${module_}")
    if ( NOT TARGET Twx::${name_twx} )
      twx_fatal ( "Failed to load module ${name_twx}" )
    endif ()
    unset ( ${module_twx}_IS_CURRENTLY_LOADING )
  endforeach ()
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

#*/
