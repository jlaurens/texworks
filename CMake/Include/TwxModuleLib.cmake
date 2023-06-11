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

A module is a set of data and informations.
It comes in two flavours: one for testing purposes
and one for normal use.

On normal use, a static library target is created by calls to
`twx_module_load()`. In order to allow such calls to happen in blocks,
we record the informations related to the module into the target,
without the need to export them before returning from functions.
The `twx_module_expose()` ensures that variables are properly set.

On test use, the information is available at the current test level and 
there is no need to use the target as global storage.

See @ref CMake/README.md.

*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_module_load )
# This has already been included
  return ()
endif ()

# ANCHOR: Properties
#[=======[*/
/** @brief Custom property for targets */ TWX_DIR;
/** @brief Custom property for targets */ TWX_SRC_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR_FOR_TESTING;
/** @brief Custom property for targets */ TWX_SOURCES;
/** @brief Custom property for targets */ TWX_HEADERS;
/** @brief Custom property for targets */ TWX_UIS;
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

define_property (
  TARGET PROPERTY TWX_IN_SOURCES
  BRIEF_DOCS "Input sources"
  FULL_DOCS "List of input sources (before configure_file)"
)

define_property (
  TARGET PROPERTY TWX_IN_HEADERS
  BRIEF_DOCS "Input headers"
  FULL_DOCS "List of Input headers (before configure_file)"
)

define_property (
  TARGET PROPERTY TWX_IN_UIS
  BRIEF_DOCS "Input UIs"
  FULL_DOCS "List of Input UIs (before configure_file)"
)

define_property (
  TARGET PROPERTY TWX_SOURCES
  BRIEF_DOCS "Sources"
  FULL_DOCS "List of sources"
)

define_property (
  TARGET PROPERTY TWX_HEADERS
  BRIEF_DOCS "Headers"
  FULL_DOCS "List of headers"
)

define_property (
  TARGET PROPERTY TWX_UIS
  BRIEF_DOCS "UIs"
  FULL_DOCS "List of UIs"
)

define_property (
  TARGET PROPERTY TWX_QT
  BRIEF_DOCS "QT"
  FULL_DOCS "List of required QT libraries"
)

define_property (
  TARGET PROPERTY TWX_LIBRARIES
  BRIEF_DOCS "Libraries"
  FULL_DOCS "List of required libraries and frameworks"
)

define_property (
  TARGET PROPERTY TWX_MODULES
  BRIEF_DOCS "Modules"
  FULL_DOCS "List of required modules"
)

define_property (
  TARGET PROPERTY TWX_INCLUDE_DIRECTORIES
  BRIEF_DOCS "Include directories"
  FULL_DOCS "List of other directories to include"
)

set (
  twx_module_properties
  SRC_DIR INCLUDE_DIR INCLUDE_DIR_FOR_TESTING
  IN_SOURCES IN_HEADERS IN_UIS SOURCES HEADERS UIS
  QT LIBRARIES MODULES
  INCLUDE_DIRECTORIES
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
  set ( module_DIR_ "${TWX_DIR}/modules/Twx${twxR_NAME}" )
  if ( NOT "${twxR_NAME}" STREQUAL "" AND EXISTS "${module_DIR_}" )
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
  * @param module_var holds on return the full module name
  * @param name_var for key NAME, holds on return the base module name, without the leading `Twx`.
  */
twx_module_name ( module_var NAME name_var ) {}
/*#]=======]
function ( twx_module_name twxR_module NAME twxR_name )
twx_assert_equal ( NAME ${NAME} )
twx_assert_non_void ( twxR_module twxR_name )
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
  set ( ${twxR_module} "${module_}"       PARENT_SCOPE )
  set ( ${twxR_name}   "${CMAKE_MATCH_1}" PARENT_SCOPE )
endfunction ()

# SECTION: Directories
# ANCHOR: twx_module_dir
#[=======[*/
/** @brief The location of a module.
  *
  * @param VAR ans is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_dir( ans_var NAME name MUST_EXIST ) {}
/*#]=======]
function ( twx_module_dir )
  twx_parse_arguments ( "MUST_EXIST" "VAR;MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( twxR_VAR )
  twx_assert_non_void ( twxR_MODULE )
  if ( NOT MATCHES twxR_MODULE "^Twx" )
    set ( twxR_MODULE Twx${twxR_MODULE} )
  endif ()
  set ( ${twxR_VAR} "${TWX_DIR}/modules/${twxR_MODULE}/CMake" )
  if ( twxR_MUST_EXIST AND NOT EXISTS "${${twxR_VAR}}" )
    twx_fatal ( "No module named ${twxR_NAME}" )
  endif ()
  twx_export ( ${twxR_VAR} )
endfunction ()

# ANCHOR: twx_module_src_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param VAR ans is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_src_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_src_dir )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${twxR_VAR}/src" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_ui_dir
#[=======[*/
/** @brief Get the location of ui files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param VAR ans is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_ui_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_ui_dir )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${twxR_VAR}/ui" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_Test_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param VAR ans is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_test_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_Test_dir )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${twxR_VAR}/Test" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_CMake_dir
#[=======[*/
/** @brief Get the location of CMake files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param VAR ans is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_test_dir( VAR ans MMODULE name [MUST_EXIST] ) {}
/*#]=======]
function ( twx_module_CMake_dir )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${twxR_VAR}/CMake" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_include_dir
#[=======[*/
/** @brief Get the location of headers.
  *
  * If the module is not already loaded, load it
  * with `twx_module_load()`.
  * Then put the header location in the variable.
  *
  * @param dir for key VAR is the name of a variable holding the result
  * @param module for key MODULE, is the name or short name of a module, like Core, Typeset...
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_include_dir( VAR dir MODULE module [TEST]) {}
/*#]=======]
function ( twx_module_include_dir )
VERIFY UI
  twx_parse_arguments ( "TEST" "VAR;MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( twxR_VAR )
  twx_assert_non_void ( twxR_MODULE )
  if ( NOT twxR_MODULE MATCHES "^Twx" )
    set ( twxR_MODULE Twx${twxR_MODULE} )
  endif ()
  if ( twxR_TEST )
    set ( property_ TWX_INCLUDE_DIR_FOR_TESTING )
  else ()
    set ( property_ TWX_INCLUDE_DIR )
  endif ()
  twx_module_load ( ${twxR_MODULE} )
  get_target_property(
    ${twxR_VAR}
    ${twxR_MODULE}
    ${property_}
  )
  if ( "${${twxR_VAR}}" MATCHES "NOTFOUND" )
    twx_fatal ( "Internal inconsistency (property ${property_} not set on module ${twxR_MODULE})")
  endif ()
  twx_export ( ${twxR_VAR} )
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
  * - `<module>_SOURCES`: the list of configured sources
  * - `<module>_HEADERS`: the list of configured headers
  * - The required Qt libraries are appended
  *
  * @see
  * - `TwxCfgFileLib.cmake`
  * - `TwxCfgPaths.cmake`
  *
  * @param name is the list of names or short names of the module to setup
  */
twx_module_setup( NAME name ) {}
/*#]=======]
IN PROGRESS
VERIFY
function ( twx_module_setup twxR_module )
   twx_assert_non_void (
    twxR_module
    TWX_DIR
    TWX_PROJECT_BUILD_DIR
    TWX_PROJECT_BUILD_DATA_DIR
  )
  list ( INSERT ARGN 0 ${twxR_module})
  foreach ( module_ ${ARGN} )
    if ( module_ MATCHES "^Twx(.+)$" )
      set ( name_ ${CMAKE_MATCH_1} )
    else ()
      set ( name_ ${module_} )
      set ( module_ Twx${module_} )
    endif ()
    twx_cfg_setup ()
    foreach ( t_ SOURCES HEADERS UIS )
      set ( ${module_}_IN_${t_} )
      set ( ${module_}_${t_} )
    endforeach ()
    foreach ( t_ DIR SRC_DIR QT LIBRARIES MODULES INCLUDE_DIRECTORIES )
      set ( ${module_}_${t_} )
    endforeach ()
    twx_module_src_dir ( VAR ${module_}_SRC_DIR MODULE ${module_} )
    include ( "${${module_}_SRC_DIR}/Setup.cmake" )
    twx_cfg_write_begin ( ID "${name_}_private" )
    foreach ( f_ ${${module_}_IN_SOURCES} ${${module_}_IN_HEADERS} )
      if ( "${f_}" MATCHES "^(.*_private)[.](in[.])?([^.]+)$" )
        twx_cfg_set (
          include_${CMAKE_MATCH_1}_${CMAKE_MATCH_3}
          "#include \"${f_}\""
        )
      endif ()
    endforeach ( f_ )
    twx_cfg_write_end ()
    include ( TwxCfgFileLib )
    twx_cfg_files (
      ID 			SOURCES
      FILES 	${${module_}_IN_SOURCES}
      IN_DIR 	"${${module_}_SRC_DIR}"
      OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
      EXPORT 	${module_}
      ESCAPE_QUOTES
    )
    twx_cfg_files (
      ID 			HEADERS
      FILES 	${${module_}_IN_HEADERS}
      IN_DIR  "${${module_}_SRC_DIR}"
      OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src"
      EXPORT 	${module_}
    )
    # twx_cfg_files (
    #   ID 			UIS
    #   FILES 	${${module_}_IN_UIS}
    #   IN_DIR  "${${module_}_SRC_DIR}" OR /ui?
    #   OUT_DIR "${TWX_PROJECT_BUILD_DIR}/src" 
    #   EXPORT 	${module_}
    # )
    twx_export (
      IN_SOURCES IN_HEADERS IN_UIS SOURCES HEADERS UIS
      DIR SRC_DIR QT LIBRARIES MODULES INCLUDE_DIRECTORIES
      EXPORT_PREFIX ${module_}_
    )
    twx_export (
      CMAKE_MODULE_PATH
    )
  endforeach ( module_ )
endfunction ()

# ANCHOR: twx_module_declare
#[=======[*/
/** @brief Declare a module.
  *
  * Setup the files for the current module.
  * The module is not yet configured.
  * The module name is guessed from the file location.
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
  * @param Qt libraries for key QT
  * @param libraries for key LIBRARIES
  * @param modules for key MODULES
  * @param include_directories for key INCLUDE_DIRECTORIES
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
    list ( APPEND "${module_twx}_IN_${t_}" ${twxR_${t_}} )
  endforeach ()
  foreach ( t_ LIBRARIES MODULES QT INCLUDE_DIRECTORIES )
    list ( APPEND "${module_twx}_${t_}" ${twxR_${t_}} )
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
  * * Read from `twx_module_setup()`.
  *
  * Output state: a static library target named Twx::<name>.
  * The `CMAKE_MODULE_PATH` is updated if there are CMake files
  * specific to the module.
  */
twx_module_configure() {}
/*#]=======]
function ( twx_module_configure )
  twx_assert_non_void (
    TWX_DIR
    TWX_PROJECT_PRODUCT_DIR
    TWX_PROJECT_BUILD_DIR
  )
  twx_module_name ( module_ NAME name_ )
  twx_assert_non_void (
    module_
    name_
    TWX_PROJECT_BUILD_DATA_DIR
  )
  if ( DEFINED ${module_}__CONFIGURING )
    twx_fatal ( "Module ${name_} indirectly depends on itself." )
  endif ()
  if ( TARGET ${module_} )
    twx_module_expose ( MODULES "${name_}" )
    return ()
  endif ()
  set ( ${module_}__CONFIGURING ON )
  twx_module_setup ( NAME "${name_}" )
  twx_assert_non_void (
    ${module_}_DIR
    ${module_}_SRC_DIR
  )
  add_library(
    ${module_}
    STATIC
    ${${module_}_SOURCES}
    ${${module_}_HEADERS}
  )
  twx_module_deep ( VAR ${module_}_MODULES )
  twx_module_add ( ${${module_}_MODULES} MODULES ${module_} )
  target_link_libraries (
    ${module_}
    ${${module_}_QT}
    ${${module_}_LIBRARIES}
  )
  target_include_directories (
    ${module_}
    PRIVATE
      "${TWX_PROJECT_BUILD_DIR}/src"
      ${${module_}_INCLUDE_DIRECTORIES}
  )
  set_target_properties (
    ${module_}
    PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  twx_cfg_files (
    TARGET 	${module_}
    ID 			INCLUDE_HEADERS
    FILES 	${${module_}_IN_HEADERS}
    IN_DIR	"${${module_}_SRC_DIR}"
    OUT_DIR	"include"
    NO_PRIVATE
  )
  twx_cfg_files (
    TARGET 	${module_}
    ID 			INCLUDE_HEADERS_PRIVATE
    FILES 	${${module_}_IN_HEADERS}
    IN_DIR	"${${module_}_SRC_DIR}"
    OUT_DIR	"include_for_testing"
  )
  include ( TwxWarning )
  twx_warning_target ( ${module_} )

  if ( NOT TARGET Twx::${name_} )
    add_library ( Twx::${name_} ALIAS ${module_} )
  endif ()
  # store the properties
  set (
    ${module_}_SRC_DIR
    "${TWX_PROJECT_BUILD_DIR}/src"
  )
  set (
    ${module_}_INCLUDE_DIR
    "${TWX_PROJECT_PRODUCT_DIR}/include"
  )
  set (
    ${module_}_INCLUDE_DIR_FOR_TESTING
    "${TWX_PROJECT_PRODUCT_DIR}/include_for_testing"
  )
  twx_module_synchronize ( MODULES ${module_} )
  twx_export (
    CMAKE_MODULE_PATH
  )
endfunction ()

# ANCHOR: twx_module_synchronize
#[=======[*/
/** @brief Synchronize a target with the current state.
  *
  * Ensure that all the variables associate to a module are properly
  * recorded in the target.
  *
  * @param ... is a non empty list of modules 
  */
twx_module_synchronize( MODULES ... ) {}
/*#]=======]
function ( twx_module_synchronize )
  twx_parse_arguments ( "" "" "MODULES;NAMES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( n_ ${twxR_NAMES})
    list ( APPEND twxR_MODULES Twx${n_} )
  endforeach ()
  twx_assert_non_void ( twxR_MODULES )
  foreach ( m_ ${twxR_MODULES})
    twx_assert_target ( ${m_} ) 
    foreach ( p_ ${twx_module_properties} )
      set_target_properties ( ${m_} PROPERTIES TWX_${p_} "${v_}" )
    endforeach ()
  endforeach ()
endfunction ( twx_module_synchronize )

# ANCHOR: twx_module_expose
#[=======[*/
/** @brief Expose a module.
  *
  * Ensure that all the variables associate to a module are properly set.
  * 
  *
  * @param ... for key MODULES is a list of modules 
  * @param ... for key NAMES is a list of module names
  * One of these list must not be empty.
  */
twx_module_expose( [MODULES ...] [NAMES ...] ) {}
/*#]=======]
function ( twx_module_expose )
  twx_parse_arguments ( "" "" "MODULES;NAMES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( n_ ${twxR_NAMES})
    list ( APPEND twxR_MODULES Twx${n_} )
  endforeach ()
  twx_assert_non_void ( twxR_MODULES )
  foreach ( m_ ${twxR_MODULES})
    twx_assert_target ( ${m_} ) 
    foreach ( p_ ${twx_module_properties} )
      if ( DEFINED ${m_}_${p_} )
        break ()
      endif ()
      get_target_property ( v_ ${m_} TWX_${p_} )
      set ( ${m_}_${p_} "${v_}" PARENT_SCOPE )
    endforeach ()
  endforeach ()
endfunction ( twx_module_expose )

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
  * @param modules is a possibly empty list of existing module names or short names
  */
twx_module_load( modules ... ) {}
/*#]=======]
function ( twx_module_load twxR_name )
  list ( INSERT ARGN 0 "${twxR_name}" )
  foreach ( module_ ${ARGN} )
    if ( module_ MATCHES "Twx(.+)$" )
      set ( name_ ${CMAKE_MATCH_1} )
    else ()
      set ( name_ ${module_} )
      set ( module_ Twx${module_} )
    endif ()
    if ( TARGET ${module_} )
      twx_module_expose ( ${module_} )
      continue ()
    endif ()
    IN PROGRESS
    twx_module_dir ( VAR module_DIR_ ${module} MUST_EXIST )
    if ( ${module_}__twx_module_load )
      twx_fatal ( "Circular dependency of module ${module_}" )
    endif ()
    set ( ${module_twx}__twx_module_load ON )
    add_subdirectory ( "${module_DIR_}" "TwxModules/${module_twx}")
    if ( NOT TARGET Twx::${name_} )
      twx_fatal ( "Failed to load module ${module_}" )
    endif ()
    twx_module_expose ( ${module_} )
    unset ( ${module_}__twx_module_load )
  endforeach ()
endfunction ()

# ANCHOR: twx_module_deep
#[=======[*/
/** @brief Resolve dependencies.
  *
  * @param variable for key VAR, on input a list of module names. On output,
  * this list also contains the modules that were added to the given modules,
  * and so on.
  */
twx_module_resolve ( variable ) {}
/*#]=======]
function ( twx_module_deep VAR twxR_variable )
  twx_assert_equal ( VAR "${VAR}" )
  set ( names_ )
  while ( NOT "${twxR_variable}" STREQUAL "" )
    list ( GET twxR_variable 0 n_ )
    list ( REMOVE_AT twxR_variable 0 )
    if ( NOT ${n_}__twx_module_deep )
      twx_module_load ( ${n_} )
      list ( APPEND modules_ ${n_} )
      set ( ${n_}__twx_module_deep ON )
      foreach ( n__ Twx${n_}_MODULES )
        if ( NOT ${n_}__twx_module_deep )
          list ( APPEND twxR_variable ${n__} )
        endif ()
      endforeach ()
    endif ()
  endwhile ()
  set ( ${twxR_variable} "${names_}" PARENT_SCOPE )
endfunction ( twx_module_deep )

# ANCHOR: twx_module_add
#[=======[*/
/** @brief Add a module to a target.
  *
  * If the module is not already loaded, load it
  * with `twx_module_load()`.
  * Then configure the given target to use this module.
  * `twx_module_add()` can be called multiple time on the same target
  * and modules.
  *
  * @param modules is a possibly empty list of existing module names or short names
  * @param targets for key TO_TARGETS is a list of existing target names
  * @param to_modules for key TO_MODULES is a possibly empty list of existing module names or short names
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_add ( modules ... TO_TARGETS targets ... [TEST] ) {}
/*#]=======]
function ( twx_module_add )
  twx_parse_arguments ( "TEST" "" "TARGETS;TO_MODULES" ${ARGN} )
  if ( "${twxR_UNPARSED_ARGUMENTS}" STREQUAL "" )
    return ()
  endif ()
  twx_assert_parsed ()
  twx_pass_option ( TEST )
  # Add the modules to the targets
  foreach ( target_ ${twxR_TO_TARGETS} )
    twx_assert_target ( ${target_} )
    foreach ( m_ ${twxR_UNPARSED_ARGUMENTS} )
      if ( NOT m_ MATCHES "^Twx" )
        set ( m_ Twx${m_} )
      endif ()
      add_dependencies ( ${target_} ${m_} )
      target_link_libraries (
        ${target_}
        ${m_}
      )
      twx_module_include_dir (
        VAR include_dir_
        "${m_}"
        ${twxR_TEST}
      )
      IN PROGRESS
      target_include_directories (
        ${target_}
        PRIVATE "${include_dir_}"
      )
    endforeach ()
  endforeach ()
  foreach ( n_ ${twxR_TO_NAMES} )
    list ( APPEND twxR_TO_MODULES Twx${n_} )
  endforeach ()
  twx_module_expose ( MODULES ${twxR_TO_MODULES} )
  foreach ( module_ ${twxR_TO_MODULES} )
    foreach ( m_ ${twxR_MODULES} )
      foreach ( s_ MODULES QT LIBRARIES INCLUDE_DIRECTORIES )
        list ( APPEND ${module_}_${s_} ${${m_}_${s_}} )
        list ( REMOVE_DUPLICATES ${module_}_${s_} )
      endforeach ( s_ )
    endforeach ( m_ )
  endforeach ( module_ )
  foreach ( module_ ${twxR_TO_MODULES} )
    set (
      libraries_
      ${${module_}_LIBRARIES}
      ${${module_}_MODULES}
    )
    foreach ( n_ ${${module_}_QT} )
      list ( APPEND libraries_ Qt::${n_} )
    endforeach ()
    if ( NOT "${libraries_}" STREQUAL "" )
      target_link_libraries (
        ${module_}
        ${libraries_}
      )
    endif ()
    target_include_directories (
      ${module_}
      PRIVATE
        "${TWX_DIR}/modules/include"
        "${TWX_PROJECT_BUILD_DIR}/src"
        ${${module_}_INCLUDE_DIRECTORIES}
    )
    foreach ( m_ ${${module_}_MODULES} )
      add_dependencies ( ${module_} ${m_} )
      twx_module_include_dir (
        VAR include_dir_
        ${m_}
      )
      target_include_directories (
        ${module_}
        PRIVATE "${include_dir_}"
      )
    endforeach ()
  endforeach ()
endfunction ( twx_module_add )

# ANCHOR: twx_module_includes
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
twx_module_includes(names ... TARGETS targets ... ) {}
/*#]=======]
function ( twx_module_includes )
N PRO
  twx_parse_arguments ( "" "" "TARGETS" ${ARGN} )
  foreach ( target_ ${twxR_TARGETS} )
    twx_assert_target ( "${target_}" )
    target_include_directories (
      ${target_}
      PRIVATE
        "${TWX_DIR}/modules/include"
    )
    foreach ( name_ ${twxR_UNPARSED_ARGUMENTS} )
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

# ANCHOR: twx_module_complete
#[=======[*/
/** @brief Complete the target setup.
  *
  * 
  *
  * @param name is a list of module names
  * @param targets for key TARGETS is a list of existing target names
  */
twx_module_complete( [MODULES ...] [NAMES ...] ) {}
/*#]=======]
function ( twx_module_complete )
  twx_parse_arguments ( "" "" "MODULES;NAMES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( n_ ${twxR_NAMES})
    list ( APPEND twxR_MODULES Twx${n_} )
  endforeach ()
  twx_assert_non_void ( twxR_MODULES )
  twx_module_expose ( MODULES ${twxR_MODULES} )
  foreach ( module_ ${twxR_MODULES} )
    set (
      libraries_
      ${${module_}_MODULES}
      ${${module_}_LIBRARIES}
    )
    twx_Qt_find ( REQUIRED ${${module_}_QT} )
    foreach ( qt_ ${${module_}_QT} )
      list ( APPEND libraries_ Qt::${qt_} )
    endforeach ()
    if ( NOT "${libraries_}" STREQUAL "" )
      target_link_libraries (
        ${module_}
        ${libraries_}
      )
    endif ()
    target_include_directories (
      ${module_}
      PRIVATE
        "${TWX_DIR}/modules/include"
        ${${module_}_INCLUDE_DIRECTORIES}
        "${TWX_PROJECT_BUILD_DIR}/src"
    )
  endforeach ()
endfunction ()

# ANCHOR: twx_module_test
#[=======[*/
/** @brief Add test suite.
  *
  * Called from the main `CMakeLists.txt`
  */
twx_module_test() {}
/*#]=======]
macro ( twx_module_test )
  if ( NOT TWX_NO_TEST )
    set ( TWX_TEST ON )
    enable_testing ()
    add_subdirectory ( Test TwxTest)
  endif ()
endmacro ()

#*/
