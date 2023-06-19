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
It is uniquely identified by its short name `<name>` or full name `Twx<name>`.
The full name is exactly one of the `modules` subfolder.
The short name is used for better readability.

A module comes in two flavours: one for testing purposes
and one for normal use.

On normal use, a static library target is created by calls to
`twx_module_load()`. In order to allow such calls to happen in blocks,
we record the informations related to the module into the target,
without the need to export them before returning from functions.
Later, the `twx_module_expose()` ensures that variables are properly set.

The data available correspond to the custom `TWX_...` property names defined below.
The `TWX_MODULE_TARGET_PROPERTIES` is the list of such property names.

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
/** @brief Custom property for targets */ TWX_SRC_IN_DIR;
/** @brief Custom property for targets */ TWX_SRC_OUT_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR;
/** @brief Custom property for targets */ TWX_INCLUDE_DIR_FOR_TESTING;
/** @brief Custom property for targets */ TWX_SOURCES;
/** @brief Custom property for targets */ TWX_HEADERS;
/** @brief Custom property for targets */ TWX_UIS;
/** @brief Custom property for targets */ TWX_BINARIES;
/** @brief Custom property for targets */ TWX_QT_COMPONENTS;
/** @brief Custom property for targets */ TWX_LIBRARIES;
/** @brief Custom property for targets */ TWX_QT_LIBRARIES;
/** @brief Custom property for targets */ TWX_OTHER_LIBRARIES;
/** @brief Custom property for targets */ TWX_MODULES;
/** @brief Custom property for targets */ TWX_INCLUDE_DIRECTORIES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_SRC_IN_DIR
  BRIEF_DOCS "src location before configure_file"
  FULL_DOCS "Stores the source location in the appropriate build directory"
)
define_property (
  TARGET PROPERTY TWX_SRC_OUT_DIR
  BRIEF_DOCS "src location after configure_file"
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
  FULL_DOCS "List of sources, absolute paths"
)

define_property (
  TARGET PROPERTY TWX_HEADERS
  BRIEF_DOCS "Headers"
  FULL_DOCS "List of headers, absolute paths"
)

define_property (
  TARGET PROPERTY TWX_UIS
  BRIEF_DOCS "UIs"
  FULL_DOCS "List of UIs, absolute paths"
)

define_property (
  TARGET PROPERTY TWX_QT_COMPONENTS
  BRIEF_DOCS "Qt components"
  FULL_DOCS "List of supplemental required Qt components"
)

define_property (
  TARGET PROPERTY TWX_QT_LIBRARIES
  BRIEF_DOCS "Qt libraries"
  FULL_DOCS "List of required Qt libraries, from base components and supplemental components"
)

define_property (
  TARGET PROPERTY TWX_OTHER_LIBRARIES
  BRIEF_DOCS "Other libraries"
  FULL_DOCS "List of required libraries and frameworks not related to Qt"
)

define_property (
  TARGET PROPERTY TWX_LIBRARIES
  BRIEF_DOCS "Libraries"
  FULL_DOCS "List of all required libraries and frameworks"
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
  TWX_MODULE_TARGET_PROPERTIES
  DIR SRC_IN_DIR SRC_OUT_DIR INCLUDE_DIR INCLUDE_DIR_FOR_TESTING
  IN_SOURCES IN_HEADERS IN_UIS SOURCES HEADERS UIS
  QT_COMPONENTS QT_LIBRARIES OTHER_LIBRARIES LIBRARIES
  MODULES INCLUDE_DIRECTORIES
)

include ( TwxCfgFileLib )
include ( TwxCfgLib )

# ANCHOR: twx_module_guess
#[=======[*/
/** @brief Get the module name.
  *
  * This function allows to share a great amount of code between modules.
  * Used in various `/modules/Twx.../CMakeLists.txt`, indirectly in general.
  * This MUST be called from either the directory of the module
  * or its test subdirectory.
  *
  * @param module_var for key VAR_MODULE holds on return the full module name. Optional.
  * @param name_var for key VAR_NAME, holds on return the short module name, without the leading `Twx`. Optional.
  */
twx_module_guess ( VAR_MODULE module_var VAR_NAME  name_var ) {}
/*#]=======]
function ( twx_module_guess )
  twx_parse_arguments ( "" "VAR_MODULE;VAR_NAME" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( TWX_DIR )
  get_filename_component (
    module_
    "${CMAKE_CURRENT_LIST_DIR}"
    NAME
  )
  if ( "${module_}" STREQUAL "Test" )
    get_filename_component (
      module_
      "${CMAKE_CURRENT_LIST_DIR}"
      DIRECTORY
    )
    get_filename_component (
      module_
      "${module_}"
      NAME
    )
  endif ()
  if ( NOT "${TWX_DIR}modules/${module_}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}" )
    if ( NOT "${TWX_DIR}modules/${module_}/Test" STREQUAL "${CMAKE_CURRENT_LIST_DIR}" )
      twx_fatal ( "Bad usage: ${CMAKE_CURRENT_LIST_DIR} != ${TWX_DIR}modules/${module_}" )
    endif ()
  endif ()
  if ( NOT "${module_}" MATCHES "^Twx(.*)$")
    twx_fatal ( "Bad usage: not a module folder ${CMAKE_CURRENT_LIST_DIR}" )
  endif ()
  set ( ${twxR_VAR_MODULE} "${module_}"       PARENT_SCOPE )
  set ( ${twxR_VAR_NAME}   "${CMAKE_MATCH_1}" PARENT_SCOPE )
endfunction ()

# SECTION: Directories
# ANCHOR: twx_module_dir
#[=======[*/
/** @brief The location of a module.
  *
  * Global function that returns the location of a module in the source tree.
  * This does not load the module
  * but it may raise if the module does not exist.
  * 
  * @param ans for key VAR, is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_dir( VAR ans MODULE module MUST_EXIST ) {}
/*#]=======]
function ( twx_module_dir )
  twx_parse_arguments ( "MUST_EXIST" "VAR;MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( twxR_VAR )
  twx_assert_non_void ( twxR_MODULE )
  if ( NOT twxR_MODULE MATCHES "^Twx" )
    set ( twxR_MODULE Twx${twxR_MODULE} )
  endif ()
  set ( ${twxR_VAR} "${TWX_DIR}modules/${twxR_MODULE}" )
  if ( NOT EXISTS "${${twxR_VAR}}" )
    if ( twxR_MUST_EXIST )
      twx_fatal ( "No module named ${twxR_MODULE} (${ARGN})" )
    else ()
      set ( ${twxR_VAR} )    
    endif ()
  endif ()
  twx_export ( ${twxR_VAR} )
endfunction ()

# ANCHOR: twx_module_src_in_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param ans for key VAR, is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_src_in_dir( VAR ans MODULE name) {}
/*#]=======]
function ( twx_module_src_in_dir )
  twx_parse_arguments ( "" "VAR" "" ${ARGN} )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${${twxR_VAR}}/src" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_ui_dir
#[=======[*/
/** @brief Get the location of ui files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param ans for key VAR, is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_ui_dir( VAR ans MODULE name) {}
/*#]=======]
function ( twx_module_ui_dir )
  twx_parse_arguments ( "" "VAR" "" ${ARGN} )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${${twxR_VAR}}/ui" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_Test_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param ans for key VAR, is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_test_dir( dir_var NAME name) {}
/*#]=======]
function ( twx_module_Test_dir )
  twx_parse_arguments ( "" "VAR" "" ${ARGN} )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${${twxR_VAR}}/Test" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_CMake_dir
#[=======[*/
/** @brief Get the location of CMake files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param ans for key VAR, is the name of a variable holding the result.
  * @param module for key MODULE, is a module name or short name (without leading `Twx`).
  * @param MUST_EXIST optional flag to raise if the module does not exist
  */
twx_module_test_dir( VAR ans MMODULE name [MUST_EXIST] ) {}
/*#]=======]
function ( twx_module_CMake_dir )
  twx_parse_arguments ( "" "VAR" "" ${ARGN} )
  twx_module_dir ( ${ARGN} )
  set ( ${twxR_VAR} "${${twxR_VAR}}/CMake" PARENT_SCOPE )
endfunction ()

# !SECTION

# SECTION: Setup and use

#ANCHOR - twx_module_after_project ()
#[=======[
/** @brief Terminate configuration after the project is set.
  *
  * Must be called after any `project()` invocation.
  * The purpose is to copy to the build src folder the private headers of
  * `.../modules/include/`.
  * No argument.
  *
  * Output state:
  * - `TWX_MODULES_DIR` is the location of all the modules.
  * - `TWX_MODULES_INCLUDE_DIR` is the location of shared source and header files.
  * - The target named `${PROJECT_NAME}_MODULES_INCLUDE_cfg_files` created by `twx_cfg_files()`
  *
#]=======]
function ( twx_module_after_project )
  twx_assert_non_void ( PROJECT_NAME )
  set ( TWX_MODULES_DIR "${TWX_DIR}modules/" )
  set ( TWX_MODULES_INCLUDE_DIR "${TWX_MODULES_DIR}include/" )
  file ( GLOB privates_ "${TWX_MODULES_INCLUDE_DIR}*_private.h" )
  set ( includes_ )
  foreach ( p_ ${privates_} )
    if ( "${p_}" MATCHES "^${TWX_MODULES_INCLUDE_DIR}(.+)$")
      set ( n_ "${CMAKE_MATCH_1}" )
    else ()
      # Very unlikely to happen...
      get_filename_component ( n_ "${p_}" NAME )
    endif ()
    list ( APPEND includes_ "${n_}" )
  endforeach ()
  include ( TwxCfgFileLib )
  twx_cfg_files (
    TYPE		MODULES_INCLUDE
    FILES 	${includes_}
    IN_DIR 	"${TWX_MODULES_INCLUDE_DIR}"
    OUT_DIR "${TWX_PROJECT_BUILD_DIR}modules/include/"
    EXPORT TWX
  )
  twx_assert_target ( ${PROJECT_NAME}_MODULES_INCLUDE_cfg_files )
  twx_export ( TWX_MODULES_DIR )
  twx_export ( TWX_MODULES_INCLUDE_DIR )
endfunction ( twx_module_after_project )

# ANCHOR: twx_module_setup
#[=======[*/
/** @brief Setup a module.
  *
  * Reads the `Setup.cmake` file of a module.
  * 
  * Output state:
  * - `<module>_SOURCES`: the list of configured sources
  * - `<module>_HEADERS`: the list of configured headers
  * - `<module>_LIBRARIES`, `<module>_QT_LIBRARIES`, `<module>_OTHER_LIBRARIES`
  *
  * @see
  * - `TwxCfgFileLib.cmake`
  * - `TwxCfgPaths.cmake`
  *
  * @param ... is a list of names or short names
  * When empty, a module is guessed.
  * of the modules to setup
  */
twx_module_setup( ... ) {}
/*#]=======]
function ( twx_module_setup )
  twx_message_deeper ()
  twx_assert_non_void (
    TWX_DIR
    TWX_PROJECT_BUILD_DIR
    TWX_PROJECT_BUILD_DATA_DIR
  )
  if ( "${ARGN}" STREQUAL "" )
    twx_module_guess ( VAR_MODULE ARGN VAR_NAME dummy_ )
  endif ()
  include ( TwxQtLib )
  twx_cfg_setup ()
  foreach ( module_ ${ARGN} )
    if ( module_ MATCHES "^Twx(.+)$" )
      set ( name_ ${CMAKE_MATCH_1} )
    else ()
      set ( name_ ${module_} )
      set ( module_ Twx${module_} )
    endif ()
    if ( ${module_}_IS_SETUP )
      continue ()
    endif ()
    twx_message_verbose ( "twx_module_setup: ${name_}" "-----------------")
    foreach ( p_ ${TWX_MODULE_TARGET_PROPERTIES} )
      set ( ${module_}_${p_} )
    endforeach ()
    twx_module_src_in_dir ( VAR ${module_}_SRC_IN_DIR MODULE ${module_} )
    twx_assert_non_void ( ${module_}_SRC_IN_DIR )
    include ( "${${module_}_SRC_IN_DIR}/Setup.cmake" )
    twx_cfg_write_begin ( ID "${name_}_private" )
    file ( GLOB includes_ "${TWX_DIR}modules/include/*_private.h" )
    foreach ( f_ ${${module_}_IN_SOURCES} ${${module_}_IN_HEADERS} ${includes_} )
      get_filename_component ( f_ "${f_}" NAME )
      if ( "${f_}" MATCHES "^(.*_private)[.](in[.])?([^.]+)$" )
        twx_cfg_set (
          include_${CMAKE_MATCH_1}_${CMAKE_MATCH_3}
          "#include \"${f_}\""
        )
      endif ()
    endforeach ( f_ )
    twx_cfg_write_end ()
    include ( TwxCfgFileLib )
    set ( ${module_}_SRC_OUT_DIR "${TWX_PROJECT_BUILD_DIR}src" )
    twx_cfg_files (
      MODULE 	${module_}
      TYPE		SOURCES
      ESCAPE_QUOTES
    )
    twx_cfg_files (
      MODULE 	${module_}
      TYPE		HEADERS
    )
    # twx_cfg_files (
    #   MODULE 	${module_}
    #   TYPE		UIS
    #   FILES 	${${module_}_IN_UIS}
    #   IN_DIR  "${${module_}_SRC_IN_DIR}" OR /ui?
    #   OUT_DIR "${${module_}_SRC_OUT_DIR}" 
    #   EXPORT 	${module_}
    # )
    set ( ${module_}_QT_LIBRARIES )
    twx_Qt_fresh ( VAR ${module_}_QT_LIBRARIES REQUIRED ${${module_}_QT_COMPONENTS} )
    set (
      ${module_}_LIBRARIES
      ${${module_}_QT_LIBRARIES}
      ${${module_}_OTHER_LIBRARIES}
    )
    list (
      INSERT
      ${module_}_INCLUDE_DIRECTORIES
      0
      "${TWX_DIR}modules/include"
    )
    set ( ${module_}_IS_SETUP ON )
    twx_export (
      ${TWX_MODULE_TARGET_PROPERTIES} IS_SETUP
      EXPORT_PREFIX ${module_}_
    )
    twx_export (
      CMAKE_MODULE_PATH
    )
    twx_message_verbose ( "twx_module_setup: ${name_} DONE" "-----------------")
  endforeach ( module_ )
endfunction ( twx_module_setup )

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
  * - `<module>_DIR`: the location of the module
  * - `<module>_IN_SOURCES`: list of sources, before configuration
  * - `<module>_IN_HEADERS`: list of headers, before configuration
  * - `<module>_IN_UIS`: list of uis, before configuration
  * - `<module>_OTHER_LIBRARIES`: list of libraries for linkage
  * - `<module>_MODULES`: list of needed modules
  * - `<module>_QT_COMPONENTS`: list of Qt library names (eg Widgets)
  * - `<module>_INCLUDE_DIRECTORIES`: arguments of `include_directories`
  *
  * @param sources for key SOURCES
  * @param headers for key HEADERS
  * @param uis for key UIS
  * @param Qt components for key QT_COMPONENTS
  * @param libraries for key OTHER_LIBRARIES
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
  twx_parse_arguments ( "" "" "SOURCES;HEADERS;UIS;OTHER_LIBRARIES;MODULES;QT_COMPONENTS;INCLUDE_DIRECTORIES" ${ARGN} )
  twx_assert_parsed ()
  foreach ( t_ SOURCES HEADERS UIS )
    list ( APPEND "${module_twx}_IN_${t_}" ${twxR_${t_}} )
  endforeach ()
  foreach ( t_ OTHER_LIBRARIES MODULES QT_COMPONENTS INCLUDE_DIRECTORIES )
    list ( APPEND "${module_twx}_${t_}" ${twxR_${t_}} )
  endforeach ()
  twx_assert_non_void ( TWX_DIR )
  set ( ${module_twx}_DIR "${TWX_DIR}modules/${module_twx}" )
  if ( EXISTS "${module_twx}_DIR/CMake" )
    list (
      INSERT CMAKE_MODULE_PATH 0
      "${module_twx}_DIR/CMake"
    )
    list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )
  endif ()
endmacro ( twx_module_declare )

# ANCHOR: twx_module_configure
#[=======[*/
/** @brief Configure a module.
  *
  * This should be run from the module directory
  * main or test `CMakeLists.txt` only. The name of the module
  * is automatically guessed from the location of this file.
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
  twx_message_deeper ()
  twx_assert_non_void (
    TWX_DIR
    TWX_PROJECT_PRODUCT_DIR
    TWX_PROJECT_BUILD_DIR
    TWX_PROJECT_BUILD_DATA_DIR
  )
  twx_module_guess ( VAR_MODULE module_ VAR_NAME name_ )
  twx_assert_non_void (
    module_
    name_
  )
  if ( TARGET ${module_} )
    return ()
  endif ()
  twx_message_verbose ( "twx_module_configure: ${name_}" "---------------------" )
  if ( DEFINED ${module_}__twx_module_configure )
    twx_fatal ( "Module ${name_} indirectly depends on itself." )
  endif ()
  set ( ${module_}__twx_module_configure ON )
  twx_module_setup ( "${name_}" )
  twx_assert_non_void (
    ${module_}_DIR
    ${module_}_SRC_IN_DIR
    ${module_}_SRC_OUT_DIR
  )
  add_library (
    ${module_}
    STATIC
    ${${module_}_SOURCES}
    ${${module_}_HEADERS}
  )
  set ( ${module_}_IS_MODULE "ON" )
  twx_module_add ( ${${module_}_MODULES} TO_TARGETS ${module_} )
  set (
    libraries_
    ${${module_}_LIBRARIES}
  )
  if ( NOT "${libraries_}" STREQUAL "" )
    target_link_libraries (
      ${module_}
      ${libraries_}
    )
  endif ()
  target_include_directories (
    ${module_}
    PRIVATE
      "${${module_}_SRC_OUT_DIR}"
      ${${module_}_INCLUDE_DIRECTORIES}
  )
  set_target_properties (
    ${module_}
    PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  twx_cfg_files (
    MODULE 	${module_}
    TYPE		INCLUDE_HEADERS
    FILES 	${${module_}_IN_HEADERS}
    OUT_DIR	"include"
    NO_PRIVATE
  )
  twx_cfg_files (
    MODULE 	${module_}
    TYPE		INCLUDE_HEADERS_PRIVATE
    FILES 	${${module_}_IN_HEADERS}
    OUT_DIR	"include_for_testing"
  )
  include ( TwxWarning )
  twx_warning_target ( ${module_} )

  if ( NOT TARGET Twx::${name_} )
    add_library ( Twx::${name_} ALIAS ${module_} )
  endif ()
  # store the properties
  set (
    ${module_}_SRC_OUT_DIR
    "${TWX_PROJECT_BUILD_DIR}src"
  )
  set (
    ${module_}_INCLUDE_DIR
    "${TWX_PROJECT_PRODUCT_DIR}include"
  )
  set (
    ${module_}_INCLUDE_DIR_FOR_TESTING
    "${TWX_PROJECT_PRODUCT_DIR}include_for_testing"
  )
  twx_module_synchronize ( ${module_} )
  twx_export (
    CMAKE_MODULE_PATH
  )
  twx_message_verbose ( "twx_module_configure: ${name_} DONE" "---------------------" )
endfunction ( twx_module_configure )

# ANCHOR: twx_module_synchronize
#[=======[*/
/** @brief Synchronize a target with the current state.
  *
  * Ensure that all the variables associate to a module are properly
  * recorded in the target.
  *
  * @param ... is a list of modules names or short names
  */
twx_module_synchronize( ... ) {}
/*#]=======]
function ( twx_module_synchronize )
  foreach ( m_ ${ARGN})
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    twx_assert_target ( ${m_} ) 
    foreach ( p_ ${TWX_MODULE_TARGET_PROPERTIES} )
      set ( v_ "${${m_}_${p_}}")
      set_target_properties ( ${m_} PROPERTIES TWX_${p_} "${v_}" )
    endforeach ()
  endforeach ()
endfunction ( twx_module_synchronize )

# ANCHOR: twx_module_expose
#[=======[*/
/** @brief Expose a module.
  *
  * Ensure that all the variables associate to a module are properly set.
  * Loads the module if necessary.
  *
  * @param ... is a list of module names or short names.
  * When this list is empty, the module is guessed with `twx_module_guess()`.
  */
twx_module_expose( ... ) {}
/*#]=======]
function ( twx_module_expose )
  if ( "${ARGN}" STREQUAL "" )
    twx_module_guess ( VAR_MODULE ARGN VAR_NAME dummy_ )
  endif ()
  foreach ( m_ ${ARGN})
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    twx_module_load ( ${m_} )
    foreach ( p_ ${TWX_MODULE_TARGET_PROPERTIES} )
      get_target_property ( v_ ${m_} TWX_${p_} )
      twx_message_more_verbose ( "twx_module_expose: ${m_}_${p_} => ${v_}")
      if ( "${v_}" MATCHES "NOTFOUND" )
        twx_fatal ( "==============")
      endif ()
      set ( ${m_}_${p_} "${v_}" PARENT_SCOPE )
    endforeach ()
    set ( ${m_}_IS_MODULE "ON" PARENT_SCOPE )
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
  twx_message_deeper ()
  list ( INSERT ARGN 0 "${twxR_name}" )
  foreach ( module_ ${ARGN} )
    if ( module_ MATCHES "^Twx(.+)$" )
      set ( name_ ${CMAKE_MATCH_1} )
    else ()
      set ( name_ ${module_} )
      set ( module_ Twx${module_} )
    endif ()
    if ( TARGET ${module_} )
      continue ()
    endif ()
    twx_message_verbose ( "twx_module_load: ${name_}" "----------------")
    twx_module_dir ( VAR module_DIR_ MODULE ${module_} MUST_EXIST )
    add_subdirectory ( "${module_DIR_}" "TwxModules/${module_}")
    if ( NOT TARGET Twx::${name_} )
      twx_fatal ( "Failed to load module ${module_}" )
    endif ()
    twx_message_verbose ( "twx_module_load: ${name_} DONE" "----------------")
    twx_assert_equal ( "${${module_}__twx_module_load}" "" )
  endforeach ()
endfunction ( twx_module_load )

# ANCHOR: twx_module_include_dir
#[=======[*/
/** @brief Get the location of headers.
  *
  * If the module is not already loaded, load it
  * with `twx_module_load()`.
  * Then put the header location in the variable.
  * The result depends on the module flavour.
  * This is indirectly used by targets that link against the module.
  *
  * @param dir for key VAR is the name of a variable holding the result
  * @param module for key MODULE, is the name or short name of a module, like Core, Typeset...
  * @param TEST is a flag to choose between normal and testing headers
  */
twx_module_include_dir( VAR dir MODULE module [TEST]) {}
/*#]=======]
function ( twx_module_include_dir )
  twx_parse_arguments ( "TEST" "VAR;MODULE" "" ${ARGN} )
  twx_assert_parsed ()
  twx_assert_non_void ( twxR_VAR twxR_MODULE )
  if ( NOT twxR_MODULE MATCHES "^Twx" )
    set ( twxR_MODULE Twx${twxR_MODULE} )
  endif ()
  twx_module_load ( ${twxR_MODULE} )
  twx_module_expose ( ${twxR_MODULE} )
  if ( twxR_TEST )
    set ( p_ INCLUDE_DIR_FOR_TESTING )
  else ()
    set ( p_ INCLUDE_DIR )
  endif ()
  set (
    ${twxR_VAR}
    ${${twxR_MODULE}_${p_}}
  )
  twx_assert_non_void ( ${twxR_VAR} )
  twx_export ( ${twxR_VAR} )
endfunction ()

# ANCHOR: twx_module_add
#[=======[*/
/** @brief Add a list of modules to targets.
  *
  * Used by `CMakeLists.txt`, in particular for testing.
  * Modules use it indirectly through `twx_module_configure()`.
  *
  * If the modules to add are not not already loaded,
  * load them with `twx_module_load()`.
  * Then configure the given targets to use these modules.
  * 
  * `twx_module_add()` can be called multiple time on the same targets
  * or modules.
  *
  * @param modules..., is a possibly empty list of existing module names or short names
  * @param to_targets for key TO_TARGETS is a list of existing target names
  * @param TEST is a flag to choose between normal and testing headers.
  * Ignored for module targets.
  */
twx_module_add ( modules ... TO_TARGETS targets ... [TEST] ) {}
/*#]=======]
function ( twx_module_add )
  twx_parse_arguments ( "TEST" "" "TO_TARGETS" ${ARGN} )
  if ( "${twxR_UNPARSED_ARGUMENTS}" STREQUAL "" )
    return ()
  endif ()
  twx_pass_option ( TEST )
  set ( modules_to_add_ )
  # change short module names to long ones
  foreach ( m_ ${twxR_UNPARSED_ARGUMENTS} )
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    list ( APPEND modules_to_add_ ${m_} )
  endforeach ()
  # load all the modules
  twx_module_load ( ${modules_to_add_} )
  # Add the modules to the targets
  foreach ( target_ ${twxR_TO_TARGETS} )
    twx_assert_target ( ${target_} )
    if ( ${target_}_IS_MODULE )
      set ( mode_ )
      set ( test_ )
    else ()
      set ( mode_ PRIVATE )
      set ( test_ ${twxR_TEST} )
    endif ()
    foreach ( m_ ${modules_to_add_} )
      target_link_libraries (
        ${target_}
        ${mode_} ${m_}
      )
      # Now target_ depends on m_ and will link against m_
      # and all the libraries linked with m_
      twx_module_include_dir (
        VAR include_dir_
        MODULE "${m_}"
        ${test_}
      )
      target_include_directories (
        ${target_}
        PRIVATE "${include_dir_}"
      )
      if ( NOT "${test_}" STREQUAL "" )
        target_include_directories (
          ${target_}
          # Next is not very strong
          PRIVATE "${TWX_DIR}modules/include"
        )
      endif ()
    endforeach ()
  endforeach ()
endfunction ( twx_module_add )

# ANCHOR: twx_module_includes
#[=======[*/
/** @brief Include some module `src` directories into targets.
  *
  * Add the `src` build subdirectory of the modules to the given targets.
  * The modules are not loaded but they are set up in order to use the real
  * source files after the various `configure_file()` steps.
  *
  * This is mainly used by test suites that do not link with a module
  * but include its sources, as well as the shared modules include folder.
  * Nevertheless, the module is loaded.
  *
  * @param modules is a list of module names or short names
  * @param targets for key IN_TARGETS is a list of existing target names
  */
twx_module_includes(modules ... IN_TARGETS targets ... ) {}
/*#]=======]
function ( twx_module_includes )
  twx_message_deeper ()
  twx_parse_arguments ( "" "" "IN_TARGETS" ${ARGN} )
  foreach ( target_ ${twxR_IN_TARGETS} )
    twx_assert_target ( "${target_}" )
    foreach ( module_ ${twxR_UNPARSED_ARGUMENTS} )
      if ( NOT module_ MATCHES "^Twx" )
        set ( module_ Twx${module_} )
      endif ()
      twx_module_setup ( ${module_} )
      twx_assert_non_void (
        ${module_}_IS_SETUP
        ${module_}_SRC_OUT_DIR
        NO_TWXR
      )
      twx_message_verbose ( "twx_module_includes: ${target_} <= ${module_}" )
      add_dependencies ( ${target_} ${module_} )
      target_include_directories (
        ${target_}
        PRIVATE
          "${${module_}_SRC_OUT_DIR}"
          "${${module_}_INCLUDE_DIRECTORIES}"
      )
    endforeach ()
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
endmacro ( twx_module_test )

# ANCHOR: twx_module_configure_main
#[=======[*/
/** @brief Configure a module.
  *
  * Convenient method called from the module main `CMakeLists.txt`
  */
twx_module_configure_main() {}
/*#]=======]
macro ( twx_module_configure_main )
  twx_module_guess ( VAR_MODULE module_ VAR_NAME name_ )
  twx_message_verbose ( "twx_module_configure_main: ${name_}" DEEPER )
  include ( TwxQTLib )
  twx_Qt_fresh ()
  twx_module_configure ()
  include ( TwxDoxydocLib )
  twx_doxydoc ()
  twx_message_verbose ( "twx_module_configure_main: TEST" )
  twx_module_test ()
  twx_message_verbose ( "DEBUG: twx_module_configure_main: DONE" )
  twx_message_verbose ( "DEBUG: ${TWX_MODULE}_TEST_SUITE" )
  twx_module_summary ()
endmacro ( twx_module_configure_main )

# ANCHOR: twx_module_configure_test
#[=======[*/
/** @brief Configure a module.
  *
  * Convenient method called from the module test `CMakeLists.txt`
  */
twx_module_configure_test() {}
/*#]=======]
macro ( twx_module_configure_test )
  twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME TWX_MODULE_TEST )
  twx_message_verbose ( "${TWX_MODULE} test suite:" DEEPER )
  include ( TwxModuleLib )
  set ( TWX_TEST ON )
  enable_testing ()
  if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.ini" )
    set (
      TWX_FACTORY_INI
      "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.ini"
    )
  endif ()
  twx_module_setup ( ${TWX_MODULE} )
  add_executable (
    test_${TWX_MODULE}
    ${${TWX_MODULE}_SOURCES} ${${TWX_MODULE}_HEADERS}
    "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.h"
  )
  twx_module_includes ( ${TWX_MODULE} IN_TARGETS test_${TWX_MODULE} )
  if ( NOT "${${TWX_MODULE}_MODULES}" STREQUAL "" )
    twx_module_add ( ${${TWX_MODULE}_MODULES} TO_TARGETS test_${TWX_MODULE} )
  endif ()
  include ( TwxTestLib )
  twx_test_case ( VAR twx_WorkingDirectory TARGET test_${TWX_MODULE} )
  twx_assert_non_void ( twx_WorkingDirectory )
  twx_assert_target ( test_${TWX_MODULE}.WorkingDirectory )
  target_compile_definitions (
    test_${TWX_MODULE}
    PRIVATE
      TWX_TEST
      ${TWX_MODULE}_TEST
  )
  include ( TwxQTLib )
  twx_Qt_fresh ( TEST )
  target_link_libraries (
    test_${TWX_MODULE}
    ${QT_LIBRARIES}
    ${${TWX_MODULE}_LIBRARIES}
  )
  include ( TwxWarning )
  twx_warning_target ( test_${TWX_MODULE} test_${TWX_MODULE}_macOS )
  add_test (
    NAME test_${TWX_MODULE}
    COMMAND test_${TWX_MODULE}
    WORKING_DIRECTORY
      "${twx_WorkingDirectory}"
  )
  target_compile_definitions (
    test_${TWX_MODULE}
    PRIVATE
      TwxAssets_TEST
      TwxLocate_TEST
  )
  set ( ${TWX_MODULE}_TEST_SUITE ${TWX_MODULE_NAME} ) 
  if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake" )
    include ( "${CMAKE_CURRENT_LIST_DIR}/TestSetup.cmake" )
  endif ()
  unset ( twx_WorkingDirectory )
  twx_module_summary ( NO_EOL )
endmacro ( twx_module_configure_test )

# ANCHOR: twx_module_summary
#[=======[*/
/** @brief Display summary of modules or test suites.
  *
  * Convenient method called from the main and test `CMakeLists.txt`
  *
  * @param NO_EOL is an optional flag passed to `twx_summary_end()`.
  */
twx_module_summary( [NO_EOL] ) {}
/*#]=======]
function ( twx_module_summary )
  message ( WARNING "DEBUG: ${TWX_MODULE}, ${${TWX_MODULE}_TEST_SUITE}")
  twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME )
  twx_parse_arguments ( "NO_EOL" "" "" ${ARGN} )
  twx_assert_parsed ()
  if ( "${${TWX_MODULE}_TEST_SUITE}" STREQUAL "" )
    set ( b_ "library" )
  else ()
    set ( b_ "test suite" )
  endif ()
  message ( "" )
  include ( TwxSummaryLib )
  twx_summary_begin (
    BOLD_GREEN
"${TWX_MODULE} module ${b_} has been configured \
(CMake ${CMAKE_VERSION}):\n"
    )
  twx_summary_section_compiler ()
  twx_summary_section_git ()
  twx_summary_begin ( BOLD_MAGENTA "Version info" )
  twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
  twx_summary_end ()
  if ( "${TWX_MODULE}_TEST_SUITE" STREQUAL "" )
    twx_summary_section_files ( ${TWX_MODULE_NAME} )
    twx_summary_section_build_settings ( ${TWX_MODULE_NAME} )
    twx_summary_section_libraries ( ${TWX_MODULE_NAME} )
  elseif ( "${${TWX_MODULE}_TEST_SUITE}" MATCHES ";" )
    foreach ( t_ ${${TWX_MODULE}_TEST_SUITE} )
      twx_summary_begin( BOLD_BLUE "Test ${t_}:" )
        twx_summary_section_files ( test_Twx${t_} )
        twx_summary_section_build_settings ( test_Twx${t_} )
        twx_summary_section_libraries ( test_Twx${t_} )
      twx_summary_end ()
    endforeach ()
  else ()
    twx_summary_section_files ( test_${TWX_MODULE} )
    twx_summary_section_build_settings ( test_${TWX_MODULE} )
    twx_summary_section_libraries ( test_${TWX_MODULE} )
  endif ()
  twx_pass_option ( NO_EOL )
  twx_summary_end ( ${twxR_NO_EOL} )
endfunction ( twx_module_summary )

# ANCHOR: twx_module_debug
#[=======[*/
/** @brief Display module properties.
  *
  * For debugging purposes
  *
  * @param ... is a list of module names or short names.
  */
twx_module_debug( ... ) {}
/*#]=======]
function ( twx_module_debug )
  foreach ( m_ ${ARGN})
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    twx_assert_target ( ${m_} )
    message ( "MODULE: ${m_}" )
#    twx_assert_module ( ${m_} )
    foreach ( p_ ${TWX_MODULE_TARGET_PROPERTIES} )
      get_target_property ( v_ ${m_} TWX_${p_} )
      message ( "  ${p_} => ${v_} == ${${m_}_${p_}}" )
    endforeach ()
  endforeach ()
endfunction ( twx_module_debug )

#*/
