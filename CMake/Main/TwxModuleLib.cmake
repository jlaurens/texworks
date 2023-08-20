#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Helpers for module
  * 
  * Usage:
  *   include ( TwxModuleLib )
  * 
  * The modules are expected to share the same structure.
  * See the `/modules/TwxCore` directory for an example.
  * 
  * A module is a set of data and informations associate to one target.
  * It is uniquely identified by its short name `<name>` or full name `Twx<name>`.
  * The full name is exactly one of the `modules` subfolder.
  * The short name is used for better readability.
  *
  * A module comes in two flavours: one for testing purposes
  * and one for normal use.
  *
  * On normal use, a static library target is created by calls to
  * `twx_module_load()`. In order to allow such calls to happen in blocks,
  * we record the informations related to the module into the target,
  * without the need to export them before returning from functions.
  * Later, the `twx_module_expose()` ensures that variables are properly set.
  *
  * The data available correspond to the custom `TWX_...` property names defined below.
  * The `TWX_MODULE_TARGET_PROPERTIES` is the list of such property names.
  *
  * On test use, the information is available at the current test level and
  * there is no need to use the target as global storage.
  *
  * See @ref CMake/README.md.
  * 
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_module_guess
#[=======[*/
/** @brief Get the module name.
  *
  * This function allows to share a great amount of code between modules.
  * Used in various `/modules/Twx.../CMakeLists.txt`, indirectly in general.
  * This MUST be called from either the directory of the module
  * or its test subdirectory.
  *
  * For example, the simple instruction `twx_module_guess()` used
  * from a module folder defines `TWX_MODULE` and `TWX_MODULE_NAME`.
  *
  * @param prefix for key `VAR_PREFIX`, on return,
  *   the variable named `<prefix>_MODULE` holds the full module name and
  *   the variable named `<prefix>_MODULE_NAME` holds the short module name.
  * @param module_var for key `IN_VAR_MODULE`, on return, holds the full module name.
  *
  * Without arguments, `TWX_MODULE` and `TWX_MODULE_NAME` are set.
  */
twx_module_guess ( [VAR_PREFIX prefix] [IN_VAR_MODULE var_module] ) {}
/*#]=======]
function ( twx_module_guess )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "VAR_PREFIX;IN_VAR_MODULE" "" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( TWX_DIR )
  if ( "${CMAKE_CURRENT_LIST_DIR}" MATCHES "${TWX_DIR}modules/Twx([^/]+)(/.*)?$" )
    set ( module_name_ "${CMAKE_MATCH_1}" )
    set ( module_ "Twx${module_name_}" )
  else ()
    twx_fatal ( " Bad usage: ${CMAKE_CURRENT_LIST_DIR}" )
    return ()
  endif ()
  if ( NOT "${twx.R_VAR_PREFIX}" STREQUAL "" )
    twx_var_assert_name ( "${twx.R_VAR_PREFIX}" )
    set ( ${twx.R_VAR_PREFIX}_MODULE "${module_}" PARENT_SCOPE )
    set ( ${twx.R_VAR_PREFIX}_MODULE_NAME "${module_name_}" PARENT_SCOPE )
  endif ()
  if ( "${twx.R_IN_VAR_MODULE}" STREQUAL "" )
    if ( "${twx.R_VAR_PREFIX}" STREQUAL "" )
      set ( TWX_MODULE      "${module_}"      PARENT_SCOPE )
      set ( TWX_MODULE_NAME "${module_name_}" PARENT_SCOPE )
    else ()
      set ( ${twx.R_VAR_PREFIX}_MODULE       "${module_}"      PARENT_SCOPE )
      set ( ${twx.R_VAR_PREFIX}_MODULE_NAME  "${module_name_}" PARENT_SCOPE )
    endif ()
  else ()
    twx_var_assert_name ( "${twx.R_IN_VAR_MODULE}" )
    set ( ${twx.R_IN_VAR_MODULE} "${module_}" PARENT_SCOPE )
    if ( "${twx.R_VAR_PREFIX}" STREQUAL "" )
      set ( twx.R_MODULE       "${module_}"      PARENT_SCOPE )
      set ( twx.R_MODULE_NAME  "${module_name_}" PARENT_SCOPE )
    endif ()
  endif ()
endfunction ()

# SECTION: Directories
# ANCHOR: twx_module_dir
#[=======[*/
/** @brief The location of a module.
  *
  * Global function that returns the location of a module in the source tree.
  * This does not load the module
  * but it may raise if the module does not exist.
  * On return the `ans` variable is empty when the module does not exist.
  *
  * @param `module` for key `MODULE`, optional module name or short name (without leading `Twx`).
  *   When not provided, guessed from the file system.
  * @param `ans` for key `IN_VAR`, is the name of a variable holding the result.
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_dir( [MODULE module] IN_VAR ans [REQUIRED] [OPTIONAL] ) {}
/*#]=======]
function ( twx_module_dir )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "REQUIRED;OPTIONAL" "IN_VAR;MODULE" ""
  )
  twx_arg_assert_parsed ()
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  if ( "${twx.R_MODULE}" STREQUAL "" )
    twx_module_guess ( IN_VAR_MODULE twx.R_MODULE )
  endif ()
  twx_assert_non_void ( twx.R_MODULE )
  if ( NOT twx.R_MODULE MATCHES "^Twx" )
    set ( twx.R_MODULE Twx${twx.R_MODULE} )
  endif ()
  set ( ${twx.R_IN_VAR} "${TWX_DIR}modules/${twx.R_MODULE}" )
  if ( NOT EXISTS "${${twx.R_IN_VAR}}" )
    if ( twx.R_REQUIRED AND NOT twx.R_OPTIONAL )
      twx_fatal ( "No module named ${twx.R_MODULE} (${ARGV})" )
      return ()
    else ()
      set ( ${twx.R_IN_VAR} )  
    endif ()
  endif ()
  twx_export ( ${twx.R_IN_VAR} )
endfunction ()

# ANCHOR: twx_module_src_in_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param module for key `MODULE`, is a module name or short name (without leading `Twx`).
  *   When not provided, it is guessed from the file system.
  * @param ans for key `VAR`, is the name of a variable holding the result.
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_src_in_dir( [MODULE module] IN_VAR ans [REQUIRED] [OPTIONAL] ) {}
/*#]=======]
function ( twx_module_src_in_dir )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "IN_VAR" "" )
  twx_module_dir ( ${ARGV} )
  set ( ${twx.R_IN_VAR} "${${twx.R_IN_VAR}}/src/" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_ui_dir
#[=======[*/
/** @brief Get the location of ui files.
  *
  * This does not load the module
  * but it may raise if the module does not exist.
  *
  * @param module for key `MODULE`, optional module name or short name (without leading `Twx`).
  *   When not provided, guessed from the file system.
  * @param ans for key `VAR`, is the name of a variable holding the result.
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_ui_dir( [MODULE module] IN_VAR ans [REQUIRED] [OPTIONAL] ) {}
/*#]=======]
function ( twx_module_ui_dir )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "IN_VAR" "" )
  twx_module_dir ( ${ARGV} )
  set ( ${twx.R_IN_VAR} "${${twx.R_IN_VAR}}/ui/" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_Test_dir
#[=======[*/
/** @brief Get the location of source files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param module for key `MODULE`, optional module name or short name (without leading `Twx`).
  *   When not provided, guessed from the file system.
  * @param ans for key `IN_VAR`, is the name of a variable holding the result.
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_test_dir( [MODULE module] IN_VAR ans [REQUIRED] [OPTIONAL] ) {}
/*#]=======]
function ( twx_module_Test_dir )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "IN_VAR" "" )
  twx_module_dir ( ${ARGV} )
  set ( ${twx.R_IN_VAR} "${${twx.R_IN_VAR}}/Test/" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_module_CMake_dir
#[=======[*/
/** @brief Get the location of CMake files.
  *
  * This does not load the module
  * but it raises if the module does not exist.
  *
  * @param module for key `MODULE`, optional module name or short name (without leading `Twx`).
  *   When not provided, guessed from the file system.
  * @param ans for key `VAR`, is the name of a variable holding the result.
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_test_dir( [MODULE module] IN_VAR ans [REQUIRED] [OPTIONAL] ) {}
/*#]=======]
function ( twx_module_CMake_dir )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "IN_VAR" "" )
  twx_module_dir ( ${ARGV} )
  set ( ${twx.R_IN_VAR} "${${twx.R_IN_VAR}}/CMake/" PARENT_SCOPE )
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
  * - `TWX_MODULES_INCLUDE_SOURCES` is the list of shared source and header files.
  * - `TWX_MODULES_INCLUDE_IN_DIR` is the location of shared source and header files in the source tree.
  * - `TWX_MODULES_INCLUDE_OUT_DIR` is the location of shared source and header files in the build tree.
  * - The target named `TwxCfgFile_${PROJECT_NAME}_MODULES_INCLUDE` created by `twx_cfg_files()`
  *
#]=======]
function ( twx_module_after_project )
  twx_assert_non_void ( PROJECT_NAME )
  set ( TWX_MODULES_DIR "${TWX_DIR}modules/" )
  set ( TWX_MODULES_INCLUDE_IN_DIR "${TWX_MODULES_DIR}include/" )
  set ( TWX_MODULES_INCLUDE_OUT_DIR "${TWX_PROJECT_BUILD_DIR}modules/include/" )
  file ( GLOB privates_ "${TWX_MODULES_INCLUDE_IN_DIR}*_private.h" )
  set ( includes_ )
  foreach ( p_ ${privates_} )
    if ( "${p_}" MATCHES "^${TWX_MODULES_INCLUDE_IN_DIR}(.+)$")
      set ( n_ "${CMAKE_MATCH_1}" )
    else ()
      # Very unlikely to happen...
      get_filename_component ( n_ "${p_}" NAME )
    endif ()
    list ( APPEND includes_ "${n_}" )
  endforeach ()
  twx_assert_non_void ( includes_ )
  include ( TwxCfgFileLib )
  twx_cfg_files (
    TYPE		    MODULES_INCLUDE_SOURCES
    FILES 	    ${includes_}
    IN_DIR 	    "${TWX_MODULES_INCLUDE_IN_DIR}"
    OUT_DIR     "${TWX_MODULES_INCLUDE_OUT_DIR}"
    VAR_PREFIX  TWX
  )
  twx_assert_target ( TwxCfgFile_${PROJECT_NAME}_MODULES_INCLUDE_SOURCES )
  twx_export (
    TWX_MODULES_DIR
    TWX_MODULES_INCLUDE_SOURCES
    TWX_MODULES_INCLUDE_IN_DIR
    TWX_MODULES_INCLUDE_OUT_DIR
  )
endfunction ( twx_module_after_project )

# ANCHOR: twx_module_setup
#[=======[*/
/** @brief Setup a module or a list of modules.
  *
  * Reads the `src/Setup.cmake` file of the given modules.
  * All modules will share the current project source build directory
  * to store their configured files.
  *
  * Input state:
  * - `TWX_FACTORY_INI`: the default factory data
  * - `TWX_CFG_INI_DIR`: the location of Cfg ini files
  *
  * Output state:
  * - `<module>_<property>`: for properties in `TWX_TARGET_PROPERTIES`
  *   First of all, the values are reset.
  *   Then `twx_module_declare()` sets some values,
  *   and finally the next properties are initialized.
  *   - `CFG_INI_DIR`
  *   - `FACTORY_INI`
  *   - `SRC_IN_DIR`
  *   - `SRC_OUT_DIR`
  *
  * @see
  * - `TwxCfgFileLib.cmake`
  * - `TwxCfgPATHLib.cmake`
  *
  * @param ... is a list of names or short names
  * of the modules to setup
  * When empty, a module is guessed from the caller location.
  * @param target for key `TARGET` is an optional target.
  */
twx_module_setup( ... [TARGET target]) {}
/*#]=======]
function ( twx_module_setup )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TARGET" "" )
  if ( "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    twx_module_guess ( IN_VAR_MODULE twx.R_UNPARSED_ARGUMENTS )
  endif ()
  if ( TARGET "${twx.R_TARGET}" )
    twx_target_expose ( "${twx.R_TARGET}" )
    set (
      TWX_PROJECT_BUILD_DIR "${${twx.R_TARGET}_BUILD_DIR}"
    )
    set (
      TWX_PROJECT_BUILD_DATA_DIR "${${twx.R_TARGET}_BUILD_DATA_DIR}"
    )
    if ( NOT "${${twx.R_TARGET}_BINARY_DIR}" STREQUAL "" )
      set (
        TWX_PROJECT_BUILD_DIR "${${twx.R_TARGET}_BINARY_DIR}TwxBuild/"
      )
      set (
        TWX_PROJECT_BUILD_DATA_DIR "${${twx.R_TARGET}_BINARY_DIR}TwxBuildData/"
      )
    endif ()
  endif ()
  twx_assert_non_void (
    TWX_DIR
    TWX_PROJECT_BUILD_DIR
    TWX_PROJECT_BUILD_DATA_DIR
  )
  twx_cfg_setup ()
  foreach ( TWX_MODULE ${twx.R_UNPARSED_ARGUMENTS} )
    twx_module_complete ( "${TWX_MODULE}" )
    twx_message_log ( VERBOSE "twx_module_setup: ${TWX_MODULE_NAME}" "-----------------")
    foreach ( p_ ${TWX_TARGET_PROPERTIES} )
      set ( ${TWX_MODULE}_${p_} )
    endforeach ()
    set ( ${TWX_MODULE}_CFG_INI_DIR "${TWX_CFG_INI_DIR}" )
    set ( ${TWX_MODULE}_FACTORY_INI "${TWX_FACTORY_INI}" )
    twx_module_src_in_dir ( MODULE ${TWX_MODULE} IN_VAR ${TWX_MODULE}_SRC_IN_DIR )
    twx_assert_non_void ( ${TWX_MODULE}_SRC_IN_DIR )
    include ( "${${TWX_MODULE}_SRC_IN_DIR}Setup.cmake" )
    twx_cfg_write_begin ( ID "${TWX_MODULE_NAME}_private" )
    file ( GLOB includes_ "${TWX_DIR}modules/include/*_private.h" )
    foreach ( f_ ${${TWX_MODULE}_IN_SOURCES} ${${TWX_MODULE}_IN_HEADERS} ${includes_} )
      get_filename_component ( f_ "${f_}" NAME )
      if ( "${f_}" MATCHES "^(.*_private)[.](in[.])?([^.]+)$" )
        twx_cfg_set (
          "include_${CMAKE_MATCH_1}_${CMAKE_MATCH_3}=#include ``${f_}''"
        )
      endif ()
    endforeach ( f_ )
    twx_cfg_write_end ()
    include ( TwxCfgFileLib )
    set ( ${TWX_MODULE}_SRC_OUT_DIR "${TWX_PROJECT_BUILD_DIR}src/" )
    twx_cfg_files (
      MODULE 	${TWX_MODULE}
      TARGET  ${twx.R_TARGET}
      TYPE		SOURCES
      ESCAPE_QUOTES
    )
    if ( NOT "${${TWX_MODULE}_IN_SOURCES}" STREQUAL "" )
      message ( DEBUG "MODULE 	${TWX_MODULE}
      TARGET  ${twx.R_TARGET}")
      twx_assert_non_void ( ${TWX_MODULE}_OUT_SOURCES )
    endif ()
    twx_cfg_files (
      MODULE 	${TWX_MODULE}
      TARGET  ${twx.R_TARGET}
      TYPE		HEADERS
    )
    if ( NOT "${${TWX_MODULE}_IN_HEADERS}" STREQUAL "" )
      twx_assert_non_void ( ${TWX_MODULE}_OUT_HEADERS )
    endif ()
    # In progress:
    # twx_cfg_files (
    #   MODULE 	    ${TWX_MODULE}
    #   TYPE		    UIS
    #   FILES 	    ${${TWX_MODULE}_IN_UIS}
    #   IN_DIR      "${${TWX_MODULE}_SRC_IN_DIR}" OR /ui?
    #   OUT_DIR     "${${TWX_MODULE}_SRC_OUT_DIR}"
    #   VAR_PREFIX  ${TWX_MODULE}
    # )
    set ( ${TWX_MODULE}_QT_LIBRARIES )
    twx_Qt_fresh ( VAR ${TWX_MODULE}_QT_LIBRARIES REQUIRED ${${TWX_MODULE}_QT_COMPONENTS} )
    set (
      ${TWX_MODULE}_LIBRARIES
      ${${TWX_MODULE}_QT_LIBRARIES}
      ${${TWX_MODULE}_OTHER_LIBRARIES}
    )
    list (
      INSERT
      ${TWX_MODULE}_INCLUDE_DIRS
      0
      "${TWX_DIR}modules/include/"
    )
    set ( ${TWX_MODULE}_IS_SETUP ON )
    twx_assert_non_void ( TWX_TARGET_CUSTOM_PROPERTIES )
    twx_export (
      ${TWX_TARGET_CUSTOM_PROPERTIES}
      IS_SETUP
      VAR_PREFIX ${TWX_MODULE}
    )
    twx_export (
      CMAKE_MODULE_PATH
    )
    twx_message_log ( VERBOSE "twx_module_setup: ${TWX_MODULE_NAME} DONE" "-----------------")
  endforeach ( TWX_MODULE )
endfunction ( twx_module_setup )

# ANCHOR: twx_module_declare
#[=======[*/
/** @brief Declare a module.
  *
  * Setup the files for the current module.
  * The module name is guessed from the file location.
  * The module is not yet configured.
  * This must be called from inside the `src` folder
  * of a module folder.
  * This can be called multiple times to declare the same module,
  * in particular to adapt to the host.
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
  * - `<module>_INCLUDE_DIRS`: arguments of `include_directories`
  *
  * @param sources for key `SOURCES`
  * @param headers for key `HEADERS`
  * @param uis for key `UIS`
  * @param `Qt` components for key `QT_COMPONENTS`
  * @param libraries for key `OTHER_LIBRARIES`
  * @param modules for key `MODULES`
  * @param include_directories for key `INCLUDE_DIRS`
  */
twx_module_declare( SOURCES sources ... ) {}
/*#]=======]
function ( twx_module_declare )
  twx_module_guess ()
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "" "SOURCES;HEADERS;UIS;OTHER_LIBRARIES;MODULES;QT_COMPONENTS;INCLUDE_DIRS" )
  twx_arg_assert_parsed ()
  foreach ( t_ SOURCES HEADERS UIS )
    list ( APPEND "${TWX_MODULE}_IN_${t_}" "${twx.R_${t_}}" )
    twx_export ( "${TWX_MODULE}_IN_${t_}" )
  endforeach ()
  foreach ( t_ OTHER_LIBRARIES MODULES QT_COMPONENTS INCLUDE_DIRS )
    list ( APPEND "${TWX_MODULE}_${t_}" "${twx.R_${t_}}" )
    twx_export ( "${TWX_MODULE}_${t_}" )
  endforeach ()
  twx_assert_non_void ( TWX_DIR )
  set ( ${TWX_MODULE}_DIR "${TWX_DIR}modules/${TWX_MODULE}/" )
  twx_export ( ${TWX_MODULE}_DIR )
  if ( EXISTS "${${TWX_MODULE}_DIR}/CMake/" )
    list (
      INSERT CMAKE_MODULE_PATH 0
      "${${TWX_MODULE}_DIR}/CMake/"
    )
    list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )
    twx_export ( CMAKE_MODULE_PATH )
  endif ()
endfunction ( twx_module_declare )

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
  twx_arg_assert_count ( ${ARGC} == 0 )
  twx_assert_non_void (
    "${TWX_DIR}"
    "${TWX_PROJECT_PRODUCT_DIR}"
    "${TWX_PROJECT_BUILD_DIR}"
    "${TWX_PROJECT_BUILD_DATA_DIR}"
  )
  twx_message_log ( VERBOSE "DEBUG: TWX_CFG_INI_DIR => ${TWX_CFG_INI_DIR}" )
  twx_module_guess ()
  twx_assert_non_void (
    "${TWX_MODULE}"
    "${TWX_MODULE_NAME}"
  )
  if ( TARGET "${TWX_MODULE}" )
    return ()
  endif ()
  twx_message_log ( VERBOSE "twx_module_configure: ${TWX_MODULE_NAME}" "---------------------" )
  if ( DEFINED ${TWX_MODULE}__twx_module_configure )
    twx_fatal ( "Module ${TWX_MODULE_NAME} indirectly depends on itself." )
    return ()
  endif ()
  set ( ${TWX_MODULE}__twx_module_configure ON )
  twx_module_setup ( "${TWX_MODULE}" )
  twx_assert_non_void (
    "{${TWX_MODULE}_DIR"
    "${${TWX_MODULE}_SRC_IN_DIR"
    "{${TWX_MODULE}_SRC_OUT_DIR"
    "${${TWX_MODULE}_CFG_INI_DIR"
    "${${TWX_MODULE}_FACTORY_INI"
  )
  twx_message_log ( VERBOSE "DEBUG: ${TWX_MODULE}_DIR => ${${TWX_MODULE}_DIR}" )
  set ( TWX_CFG_INI_DIR "${${TWX_MODULE}_CFG_INI_DIR}" )
  set ( TWX_FACTORY_INI "${${TWX_MODULE}_FACTORY_INI}" )
  twx_message_log ( VERBOSE "DEBUG: 1: ${TWX_CFG_INI_DIR}" )
  twx_message_log ( VERBOSE "DEBUG: 1: ${TWX_FACTORY_INI}" )
  add_library (
    ${TWX_MODULE}
    STATIC
    ${${TWX_MODULE}_OUT_SOURCES}
    ${${TWX_MODULE}_OUT_HEADERS}
  )
  set ( ${TWX_MODULE}_IS_MODULE "ON" )
  twx_module_add ( ${${TWX_MODULE}_MODULES} TO_TARGETS ${TWX_MODULE} )
  set (
    libraries_
    ${${TWX_MODULE}_LIBRARIES}
  )
  if ( NOT "${libraries_}" STREQUAL "" )
    target_link_libraries (
      ${TWX_MODULE}
      ${libraries_}
    )
  endif ()
  set (
    ${TWX_MODULE}_SRC_OUT_DIR
    "${TWX_PROJECT_BUILD_DIR}src/"
  )
  target_include_directories (
    ${TWX_MODULE}
    PRIVATE
      "${${TWX_MODULE}_SRC_OUT_DIR}"
      ${${TWX_MODULE}_INCLUDE_DIRS}
  )
  set_target_properties (
    ${TWX_MODULE}
    PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
  )
  set (
    ${TWX_MODULE}_INCLUDE_DIR
    "${TWX_PROJECT_PRODUCT_DIR}include/"
  )
  twx_message_log ( VERBOSE "DEBUG: ${TWX_MODULE}_DIR => ${${TWX_MODULE}_DIR}" )
  twx_module_synchronize ( ${TWX_MODULE} )
  twx_cfg_files (
    MODULE 	${TWX_MODULE}
    TYPE		INCLUDE_HEADERS
    FILES 	${${TWX_MODULE}_IN_HEADERS}
    OUT_DIR	"${${TWX_MODULE}_INCLUDE_DIR}"
    NO_PRIVATE
  )
  set (
    ${TWX_MODULE}_INCLUDE_FOR_TESTING_DIR
    "${TWX_PROJECT_PRODUCT_DIR}include_for_testing/"
  )
  twx_cfg_files (
    MODULE 	${TWX_MODULE}
    TYPE		INCLUDE_HEADERS_PRIVATE
    FILES 	${${TWX_MODULE}_IN_HEADERS}
    OUT_DIR	"${${TWX_MODULE}_INCLUDE_FOR_TESTING_DIR}"
  )
  include ( TwxWarningLib )
  twx_warning_target ( ${TWX_MODULE} )

  if ( NOT TARGET Twx::${TWX_MODULE_NAME} )
    add_library ( Twx::${TWX_MODULE_NAME} ALIAS ${TWX_MODULE} )
  endif ()
  # store the properties
  twx_message_log ( VERBOSE "DEBUG: ${TWX_MODULE}_DIR => ${${TWX_MODULE}_DIR}" )
  twx_export (
    CMAKE_MODULE_PATH
    TWX_CFG_INI_DIR
  )
  twx_message_log ( VERBOSE "twx_module_configure: ${TWX_MODULE_NAME} DONE" "---------------------" )
  twx_message_log ( VERBOSE "DEBUG: ${TWX_CFG_INI_DIR}" )
endfunction ( twx_module_configure )

# ANCHOR: twx_module_synchronize
#[=======[*/
/** @brief Synchronize a target with the current state.
  *
  * Ensure that all the variables associate to a module are properly
  * recorded in the target.
  *
  * @param module is a module name or short name
  */
twx_module_synchronize( module) {}
/*#]=======]
function ( twx_module_synchronize module_ )
  twx_arg_assert_count ( ${ARGC} == 0 )
  twx_module_complete ( ${module_} )
  twx_target_synchronize ( ${TWX_MODULE} )
endfunction ()

# ANCHOR: twx_module_complete
#[=======[*/
/** @brief Complete module name.
  *
  * Adds a `Twx` prefix if not there.
  * This is purely formal.
  *
  * @param `module` is a module name or short name, when void nothing happens,
  * @param `var_prefix` for key `VAR_PREFIX`, on return the variable named
  *   `<var_prefix>_MODULE` contains the (long) module name, and the variable named
  *   `<var_prefix>_MODULE_NAME` contains the short module name.
  *   If no `var` is provided, it defaults to `twx`.
  */
twx_module_complete ( module [VAR_PREFIX var_] ) {}
/*#]=======]
function ( twx_module_complete twx.R_MODULE )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "VAR_PREFIX" "" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_VAR_PREFIX}" STREQUAL "" )
    set ( twx.R_VAR_PREFIX TWX )
  endif ()
  if ( "${twx.R_MODULE}" MATCHES "^Twx(.+)$" )
    set ( "${twx.R_VAR_PREFIX}_MODULE" "${twx.R_MODULE}" PARENT_SCOPE )
    set ( "${twx.R_VAR_PREFIX}_MODULE_NAME" "${CMAKE_MATCH_1}" PARENT_SCOPE )
  elseif ( NOT "${twx.R_MODULE}" STREQUAL "" )
    set ( "${twx.R_VAR_PREFIX}_MODULE" "Twx${twx.R_MODULE}" PARENT_SCOPE )
    set ( "${twx.R_VAR_PREFIX}_MODULE_NAME" "${twx.R_MODULE}" PARENT_SCOPE )
  endif ()
endfunction ( twx_module_complete )

# ANCHOR: twx_module_expose
#[=======[*/
/** @brief Expose modules.
  *
  * Ensure that all the variables associated to a module are properly set.
  * Load the module if necessary.
  *
  * @param module is an optional module name. When not provided,
  * `twx_module_guess()` is used.
  * @param ... for key `PROPERTIES` is an optional list of property names to expose.
  * Passed to `twx_target_expose()`.
  * @param `OPTIONAL` optional flag to not raise when a module does not exist.
  */
twx_module_expose( module [PROPERTIES ...] OPTIONAL ) {}
/*#]=======]
function ( twx_module_expose )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "OPTIONAL" "VAR_PREFIX" "PROPERTIES" )
  set ( twx.R_MODULE "${twx.R_UNPARSED_ARGUMENTS}" )
  if ( "${twx.R_MODULE}" STREQUAL "" )
    twx_module_guess ( VAR_PREFIX twx.R )
  endif ()
  twx_module_complete ( ${twx.R_MODULE} VAR_PREFIX twx.R )
  twx_arg_pass_option ( OPTIONAL )
  twx_module_load ( ${twx.R_MODULE} ${twx.R_OPTIONAL} )
  if ( TARGET ${twx.R_MODULE} )
    if ( "${twx.R_PROPERTIES}" STREQUAL "" )
      set ( twx.R_PROPERTIES "${TWX_TARGET_PROPERTIES}" )
    endif ()
    twx_target_expose ( ${twx.R_MODULE} PROPERTIES ${twx.R_PROPERTIES} )
    twx_export ( ${twx.R_PROPERTIES} VAR_PREFIX "${twx.R_MODULE}" )
    set ( ${twx.R_MODULE}_IS_MODULE "ON" PARENT_SCOPE )
    if ( NOT "${twx.R_VAR_PREFIX}" STREQUAL "" )
      set ( ${twx.R_VAR_PREFIX}_MODULE      "${twx.R_MODULE}"      PARENT_SCOPE )
      set ( ${twx.R_VAR_PREFIX}_MODULE_NAME "${twx.R_MODULE_NAME}" PARENT_SCOPE )
    endif ()
  endif ()
endfunction ( twx_module_expose )

# ANCHOR: twx_module_load
#[=======[*/
/** @brief Load and setup a module.
  *
  * If the module is already loaded, do nothing.
  * Elseways add the appropriate subdirectory.
  * The `twx_module_configure()` should be used there.
  *
  * Raises if the module does not exist and without the `OPTIONAL` flag set.
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
  * Its custom properties TWX_INCLUDE_DIR and TWX_INCLUDE_FOR_TESTING_DIR
  * point to the location of the corresponding headers.
  *
  * @param modules is a possibly empty list of existing module names or short names
  * @param `REQUIRED` optional flag to raise if the module does not exist
  * @param `OPTIONAL` optional flag to not raise if the module does not exist.
  * Takes precedence over `REQUIRED` .
  */
twx_module_load( modules ... ) {}
/*#]=======]
function ( twx_module_load twx.R_name )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "REQUIRED;OPTIONAL" "" "" )
  twx_arg_pass_option ( REQUIRED OPTIONAL )
  set ( already_ )
  foreach ( m_ ${twx.R_UNPARSED_ARGUMENTS} )
    twx_module_complete ( ${m_} )
    if ( TARGET ${TWX_MODULE} )
      set ( ${TWX_MODULE}_IS_MODULE "ON" PARENT_SCOPE )
      continue ()
    endif ()
    twx_module_dir ( MODULE ${TWX_MODULE} IN_VAR module_DIR_ ${TWX_REQUIRED} ${TWX_OPTIONAL} )
    if ( NOT "${module_DIR_}" STREQUAL "" )
      if ( NOT already_ )
        set ( already_ ON )
        twx_message_log ( VERBOSE "twx_module_load:" DEEPER )
      endif ()
      twx_message_log ( VERBOSE "Loading ${TWX_MODULE_NAME}" )
      add_subdirectory ( "${module_DIR_}" "TwxModules/${TWX_MODULE}" )
      if ( NOT TARGET Twx::${TWX_MODULE_NAME} )
        twx_fatal ( "Failed to load module ${TWX_MODULE_NAME}" )
        return ()
      endif ()
      twx_expect_equal_string ( "${${TWX_MODULE}__twx_module_load}" "" )
      set ( ${twx_MODULE}_IS_MODULE "ON" PARENT_SCOPE )
    endif ()
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
  * @param module for key `MODULE`, optional name or short name of a module, like Core, Typeset...
  *   When not provided, guessed from the file system.
  * @param dir for key `IN_VAR` is the name of a variable holding the result
  * @param `TEST` is a flag to choose between normal and testing headers
  */
twx_module_include_dir( [MODULE module] IN_VAR dir [TEST]) {}
/*#]=======]
function ( twx_module_include_dir )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "TEST" "IN_VAR;MODULE" "" )
  twx_arg_assert_parsed ()
  twx_var_assert_name ( "${twx.R_IN_VAR}")
  if ( "${twx.R_MODULE}" STREQUAL "" )
    twx_module_guess ( IN_VAR_MODULE twx.R_MODULE )
  endif ()
  twx_assert_non_void ( twx.R_MODULE )
  twx_module_complete ( ${twx.R_MODULE} VAR_PREFIX twx.R )
  twx_module_load ( ${twx.R_MODULE} )
  twx_module_expose ( ${twx.R_MODULE} )
  if ( twx.R_TEST )
    set ( p_ INCLUDE_FOR_TESTING_DIR )
  else ()
    set ( p_ INCLUDE_DIR )
  endif ()
  set (
    ${twx.R_VAR}
    ${${twx.R_MODULE}_${p_}}
  )
  twx_export ( ${twx.R_IN_VAR} )
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
  * @param to_targets for key `TO_TARGETS` is a list of existing target names
  * @param `TEST` is a flag to choose between normal and testing headers.
  * Ignored for module targets.
  */
twx_module_add ( modules ... TO_TARGETS targets ... [TEST] ) {}
/*#]=======]
function ( twx_module_add )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "TEST" "" "TO_TARGETS" )
  if ( "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    return ()
  endif ()
  twx_arg_pass_option ( TEST )
  set ( modules_to_add_ )
  # change short module names to long ones
  foreach ( m_ ${twx.R_UNPARSED_ARGUMENTS} )
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    list ( APPEND modules_to_add_ ${m_} )
  endforeach ()
  # load all the modules
  twx_module_load ( ${modules_to_add_} )
  # Add the modules to the targets
  foreach ( target_ ${twx.R_TO_TARGETS} )
    twx_assert_target ( "${target_}" )
    if ( ${target_}_IS_MODULE )
      set ( mode_ )
      set ( test_ )
    else ()
      set ( mode_ PRIVATE )
      set ( test_ ${twx.R_TEST} )
    endif ()
    foreach ( m_ ${modules_to_add_} )
      target_link_libraries (
        ${target_}
        ${mode_} ${m_}
      )
      # Now target_ depends on m_ and will link against m_
      # and all the libraries linked with m_
      twx_module_include_dir (
        MODULE "${m_}"
        IN_VAR include_dir_
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
  * @param targets for key `IN_TARGETS` is a list of existing target names
  */
twx_module_includes(modules ... IN_TARGETS targets ... ) {}
/*#]=======]
function ( twx_module_includes )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "" "IN_TARGETS" )
  foreach ( target_ ${twx.R_IN_TARGETS} )
    twx_assert_target ( "${target_}" )
    foreach ( module_ ${twx.R_UNPARSED_ARGUMENTS} )
      if ( NOT module_ MATCHES "^Twx" )
        set ( module_ Twx${module_} )
      endif ()
      twx_module_setup ( ${module_} )
      twx_assert_non_void (
        "${${module_}_IS_SETUP"
        "${${module_}_SRC_OUT_DIR"
      )
      twx_message_log ( VERBOSE "twx_module_includes: ${target_} <= ${module_}" )
      add_dependencies ( ${target_} ${module_} )
      target_include_directories (
        ${target_}
        PRIVATE
          "${${module_}_SRC_OUT_DIR}"
          "${${module_}_INCLUDE_DIRS}"
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
  twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME )
  twx_message_log ( VERBOSE "twx_module_configure_main: ${TWX_MODULE_NAME}" DEEPER )
  include ( TwxQTLib )
  twx_Qt_fresh ()
  twx_module_configure ()
  include ( TwxDoxydocLib )
  twx_doxydoc ()
  twx_module_test ()
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
  twx_message_log ( VERBOSE "${TWX_MODULE} test suite:" DEEPER )
  include ( TwxQTLib )
  include ( TwxModuleLib )
  set ( TWX_NO_TEST ON )
  twx_module_load ( ${TWX_MODULE} )
  set ( TWX_TEST ON )
  enable_testing ()
  set ( TWX_NAME "${TWX_MODULE_TEST}" )
  if ( EXISTS "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.ini" )
    set (
      TWX_FACTORY_INI
      "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.ini"
    )
  endif ()
  add_executable (
    test_${TWX_MODULE}
    "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.cpp"
    "${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE_TEST}.h"
  )
  twx_module_setup ( ${TWX_MODULE} TARGET test_${TWX_MODULE} )
  twx_assert_non_void (
    "${${TWX_MODULE}_SOURCES}"
    "${${TWX_MODULE}_HEADERS}"
  )
  target_sources (
    test_${TWX_MODULE}
    PRIVATE ${${TWX_MODULE}_SOURCES} ${${TWX_MODULE}_HEADERS}
  )
  twx_module_includes ( ${TWX_MODULE} IN_TARGETS test_${TWX_MODULE} )
  twx_module_add ( ${${TWX_MODULE}_MODULES} TO_TARGETS test_${TWX_MODULE} )
  include ( TwxTestLib )
  twx_unit_case ( VAR twx_WorkingDirectory TARGET test_${TWX_MODULE} )
  twx_assert_non_void ( twx_WorkingDirectory )
  twx_assert_target ( test_${TWX_MODULE}.WorkingDirectory )
  target_compile_definitions (
    test_${TWX_MODULE}
    PRIVATE
      TWX_TEST
      ${TWX_MODULE}_TEST
  )
  twx_Qt_fresh ( TEST )
  target_link_libraries (
    test_${TWX_MODULE}
    ${QT_LIBRARIES}
    ${${TWX_MODULE}_LIBRARIES}
  )
  include ( TwxWarningLib )
  twx_warning_target ( test_${TWX_MODULE} )
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
  * @param `NO_EOL` is an optional flag passed to `twx_summary_end()`.
  */
twx_module_summary( [NO_EOL] ) {}
/*#]=======]
function ( twx_module_summary )
  twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "NO_EOL" "" "" )
  twx_arg_assert_parsed ()
  if ( "${${TWX_MODULE}_TEST_SUITE}" STREQUAL "" )
    set ( b_ "library" )
  else ()
    set ( b_ "test suite" )
  endif ()
  message ( "" )
  twx_message_log ( VERBOSE "DEBUG: TWX_CFG_INI_DIR => ${TWX_CFG_INI_DIR}" )
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
  elseif ( NOT "${${TWX_MODULE}_TEST_SUITE}" STREQUAL "" )
    foreach ( t_ ${${TWX_MODULE}_TEST_SUITE} )
      twx_summary_begin( BOLD_BLUE "Test ${t_}:" )
        twx_summary_section_files ( test_Twx${t_} )
        twx_summary_section_build_settings ( test_Twx${t_} )
        twx_summary_section_libraries ( test_Twx${t_} )
      twx_summary_end ()
    endforeach ()
  elseif ( TARGET test_${TWX_MODULE} )
    twx_summary_section_files ( test_${TWX_MODULE} )
    twx_summary_section_build_settings ( test_${TWX_MODULE} )
    twx_summary_section_libraries ( test_${TWX_MODULE} )
  else ()
    twx_summary_section_files ( ${TWX_MODULE_NAME} )
    twx_summary_section_build_settings ( ${TWX_MODULE_NAME} )
    twx_summary_section_libraries ( ${TWX_MODULE_NAME} )
  endif ()
  twx_arg_pass_option ( NO_EOL )
  twx_summary_end ( ${twx.R_NO_EOL} )
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
  foreach ( m_ ${ARGV})
    if ( NOT m_ MATCHES "^Twx" )
      set ( m_ Twx${m_} )
    endif ()
    twx_assert_target ( "${m_}" )
    message ( "MODULE: ${m_}" )
#    twx_expect_module ( ${m_} )
    foreach ( p_ ${TWX_MODULE_TARGET_PROPERTIES} )
      get_target_property ( v_ ${m_} TWX_${p_} )
      message ( "  ${p_} => ${v_} == ${${m_}_${p_}}" )
    endforeach ()
  endforeach ()
endfunction ( twx_module_debug )

# ANCHOR: twx_module_shorten
#[=======[*/
/** @brief Shorten messages.
  *
  * Shorten messages by replacing some paths by a description.
  * In place replacements.
  *
  * @param `modules` for key `MODULE` is an optional list of module names or short names.
  * When not provided, we only consider the paths concerning the current project.
  * @param ... for key VAR is a non empty list of variable names.
  */
twx_module_shorten( VAR ... MODULE ... ) {}
/*#]=======]
function ( twx_module_shorten )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "" "VAR;MODULE" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twx.R_VAR )
  foreach ( v_ ${twx.R_VAR} )
    foreach ( m_ ${twx.R_MODULE} )
      twx_module_expose ( "${m_}" )
      string (
        REPLACE
        "${${twx_MODULE}_BUILD_DIR}"
        "<${twx_MODULE_NAME} build dir>/"
        ${v_}
        "${${v_}}"
      )
      string (
        REPLACE
        "${${twx_MODULE}_SRC_DIR}"
        "<${twx_MODULE_NAME} src dir>/"
        ${v_}
        "${${v_}}"
      )
    endforeach ()
    string (
      REPLACE
      "${CMAKE_PROJECT_BINARY_DIR}"
      "<${PROJECT_NAME} binary dir>"
      ${v_}
      "${${v_}}"
    )
    string (
      REPLACE
      "${CMAKE_PROJECT_SOURCE_DIR}"
      "<${PROJECT_NAME} source dir>"
      ${v_}
      "${${v_}}"
    )
    string (
      REPLACE
      "${TWX_BUILD_DIR}"
      "<build dir>/"
      ${v_}
      "${${v_}}"
    )
    string (
      REPLACE
      "${TWX_DIR}"
      "<root dir>/"
      ${v_}
      "${${v_}}"
    )
    twx_export ( ${v_} )
  endforeach ()
endfunction ( twx_module_shorten )

twx_lib_require ( Target CfgFile )

twx_lib_did_load ()

#*/
