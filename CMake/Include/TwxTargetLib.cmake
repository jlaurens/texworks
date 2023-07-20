#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
* @brief Helpers for targets
*
* Usage:
*   include ( TwxTargetLib )
*
* TeXworks is using different kinds of targets for building and testing purposes.
* Each target defined by CMake is uniquely identified by its name.
* Moreover the targets live in a global scope, such that target attributes
* should also be defined in the global scope.
* If we define such custom attributes in functions, these definitions should
* propagate up to the global scope through any intermediate caller.
* This is not practical at all.
* Instead we heavily use target properties.
*
* For an existing target, the workflow is:
*
*   twx_target_expose ( <name> )
*   define variables <name>_<property>
*   twx_target_synchronize ( <name> )
*
* otherwise it is
*
*   define target <name>
*   define variables <name>_<property>
*   twx_target_synchronize ( <name> )
*
* Some `<name>_<property>` variables are read only in the sense
* that `twx_target_synchronize` will ignore them.
*
* All custom properties `TWX_<property>` defined for targets are not meant
* to be used directly by `set_target_properties()` except in `twx_target_synchronize()`.
*/
/*#]===============================================]

include_guard ( GLOBAL )

# Full include only once
if ( COMMAND twx_target_expose )
# This has already been included
  return ()
endif ()

# SECTION: Variables
# ANCHOR: TYPE
#[=======[*/
/** @brief Target property: TYPE
  *
  * The type.
  * Readonly.
  */
<target_name>_TYPE;
/*#]=======]
# ANCHOR: SOURCE_DIR
#[=======[*/
/** @brief Target property: SOURCE_DIR
  *
  * The sources directory.
  * Readonly.
  */
<target_name>_SOURCE_DIR;
/*#]=======]
# ANCHOR: BINARY_DIR
#[=======[*/
/** @brief Target property: BINARY_DIR
  *
  * The binary directory.
  * Readonly.
  */
<target_name>_BINARY_DIR;
/*#]=======]
# ANCHOR: SOURCES
#[=======[*/
/** @brief Target property: sources
  *
  * The sources.
  * Readonly.
  */
<target_name>_SOURCES;
/*#]=======]
# ANCHOR: COMPILE_DEFINITIONS
#[=======[*/
/** @brief Target property: COMPILE_DEFINITIONS
  *
  * The compile definitions.
  * Readonly.
  */
<target_name>_COMPILE_DEFINITIONS;
/*#]=======]
# ANCHOR: LINK_LIBRARIES
#[=======[*/
/** @brief Target property: LINK_LIBRARIES
  *
  * The link libraries.
  * Readonly.
  */
<target_name>_LINK_LIBRARIES;
/*#]=======]
# ANCHOR: LINK_DIRECTORIES
#[=======[*/
/** @brief Target property: LINK_DIRECTORIES
  *
  * The link directories.
  * Readonly.
  */
<target_name>_LINK_DIRECTORIES;
/*#]=======]
# ANCHOR: INCLUDE_DIRECTORIES
#[=======[*/
/** @brief Target property: INCLUDE_DIRECTORIES
  *
  * The include directories.
  * Readonly.
  */
<target_name>_INCLUDE_DIRECTORIES;
/*#]=======]
# !SECTION
# SECTION: Properties
# ANCHOR: VERSION_MAJOR
#[=======[*/
/** @brief Target property: version major
  *
  * Version major: The M in M.m.p.t
  */
TWX_VERSION_MAJOR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_VERSION_MAJOR
)
# ANCHOR: VERSION_MINOR
#[=======[*/
/** @brief Target property: version minor
  *
  * Version minor: The m in M.m.p.t
  */
TWX_VERSION_MINOR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_VERSION_MINOR
)
# ANCHOR: VERSION_PATCH
#[=======[*/
/** @brief Target property: version patch
  *
  * Version patch: The p in M.m.p.t
  */
TWX_VERSION_PATCH;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_VERSION_PATCH
)
# ANCHOR: VERSION_TWEAK
#[=======[*/
/** @brief Target property: version tweak
  *
  * Version tweak: the t in M.m.p.t
  */
TWX_VERSION_TWEAK;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_VERSION_TWEAK
)
# ANCHOR: DIR
#[=======[*/
/** @brief Target property: main directory
  *
  * The location in the main tree of all the files and folders related to the target.
  * Absolute path.
  */
TWX_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_DIR
)
# ANCHOR: SRC_IN_DIR
#[=======[*/
/** @brief Target property: src input directory
  *
  * The location in the main tree of all the source files related to the target.
  * Absolute path.
  */
TWX_SRC_IN_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_SRC_IN_DIR
)
# ANCHOR: BUILD_DIR
#[=======[*/
/** @brief Target property: build directory
  *
  * The location in the main binary tree of all the files and folders related to the target.
  * Absolute path.
  */
TWX_BUILD_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_BUILD_DIR
)
# ANCHOR: SRC_OUT_DIR
#[=======[*/
/** @brief Target property: src output directory
  *
  * The location in the main binary tree of all the source files related to the target.
  * Absolute path.
  */
TWX_SRC_OUT_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_SRC_OUT_DIR
)
# ANCHOR: INCLUDE_DIR
#[=======[*/
/** @brief Target property:  directory
  *
  * For libraries, location of the headers.
  * Used by modules.
  * Absolute path.
  */
TWX_INCLUDE_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_INCLUDE_DIR
)
# ANCHOR: INCLUDE_FOR_TESTING_DIR
#[=======[*/
/** @brief Target property:  directory
  *
  * For libraries, location of the headers, including testing facilities.
  * Used by modules.
  * Absolute path.
  */
TWX_INCLUDE_FOR_TESTING_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_INCLUDE_FOR_TESTING_DIR
)
# ANCHOR: IN_SOURCES
#[=======[*/
/** @brief Target property: input sources
  *
  * List of input sources (before configure_file).
  * Relative to the scr input dir.
  */
TWX_IN_SOURCES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_IN_SOURCES
)
# ANCHOR: IN_HEADERS
#[=======[*/
/** @brief Target property: input headers
  *
  * List of input headers (before configure_file).
  * Relative to the scr input dir.
  */
TWX_IN_HEADERS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_IN_HEADERS
)
# ANCHOR: IN_UIS
#[=======[*/
/** @brief Target property: input UIs
  *
  * List of input UIs (after configure_file).
  * In progress.
  */
TWX_IN_UIS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_IN_UIS
)
# ANCHOR: OUT_SOURCES
#[=======[*/
/** @brief Target property: output sources
  *
  * List of output sources (after configure_file).
  * Relative to the scr output dir.
  */
TWX_OUT_SOURCES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_OUT_SOURCES
)
# ANCHOR: OUT_HEADERS
#[=======[*/
/** @brief Target property: output headers
  *
  * List of output headers (after configure_file).
  * Relative to the scr output dir.
  */
TWX_OUT_HEADERS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_OUT_HEADERS
)
# ANCHOR: OUT_UIS
#[=======[*/
/** @brief Target property: output UIs
  *
  * List of output UIs (after configure_file).
  * In progress.
  */
TWX_OUT_UIS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_OUT_UIS
)
# ANCHOR: CFG_INI_DIR
#[=======[*/
/** @brief Target property: Cfg ini directory
  *
  * Directory containing the Cfg ini files.
  * Absolute path.
  */
TWX_CFG_INI_DIR;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_CFG_INI_DIR
)
# ANCHOR: FACTORY_INI
#[=======[*/
/** @brief Target property: factory ini
  *
  * The location of the ini file containing factory defaults.
  * Absolute path.
  */
TWX_FACTORY_INI;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_FACTORY_INI
)
# ANCHOR: QT_COMPONENTS
#[=======[*/
/** @brief Target property: list of Qt components
  *
  * List of supplemental required Qt components.
  * Example: Widget, Test...
  */
TWX_QT_COMPONENTS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_QT_COMPONENTS
)
# ANCHOR: QT_LIBRARIES
#[=======[*/
/** @brief Target property: Qt libraries
  *
  * List of required Qt libraries, from base components and supplemental components
  */
TWX_QT_LIBRARIES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_QT_LIBRARIES
)
# ANCHOR: OTHER_LIBRARIES
#[=======[*/
/** @brief Target property: other libraries
  *
  * List of required libraries and frameworks not related to Qt
  */
TWX_OTHER_LIBRARIES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_OTHER_LIBRARIES
)
# ANCHOR: LIBRARIES
#[=======[*/
/** @brief Target property: libraries
  *
  * List of all required libraries and frameworks, except modules.
  */
TWX_LIBRARIES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_LIBRARIES
)
# ANCHOR: MODULES
#[=======[*/
/** @brief Target property: modules
  *
  * List of required modules.
  * Short or full module names.
  */
TWX_MODULES;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_MODULES
)
# ANCHOR: INCLUDE_DIRS
#[=======[*/
/** @brief Target property: declared include directory
  *
  * List of declared directories to include.
  * Absolute paths.
  */
TWX_INCLUDE_DIRS;
/*#]=======]
define_property (
  TARGET PROPERTY TWX_INCLUDE_DIRS
)
# !SECTION
set (
  TWX_TARGET_CUSTOM_PROPERTIES
  VERSION_MAJOR
  VERSION_MINOR
  VERSION_PATCH
  VERSION_TWEAK
  DIR
  SRC_IN_DIR
  BUILD_DIR
  SRC_OUT_DIR
  CFG_INI_DIR
  FACTORY_INI
  INCLUDE_DIR
  INCLUDE_FOR_TESTING_DIR
  IN_SOURCES
  IN_HEADERS
  IN_UIS
  OUT_SOURCES
  OUT_HEADERS
  OUT_UIS
  QT_COMPONENTS
  QT_LIBRARIES
  OTHER_LIBRARIES
  LIBRARIES
  MODULES
  INCLUDE_DIRS
)
# We only expose a subset of all the CMake properties.
# FOLDER might be interesting to use, as well as LABELS
set (
  TWX_TARGET_EXPOSED_CMAKE_PROPERTIES
  TYPE
  SOURCE_DIR
  BINARY_DIR
  SOURCES
  COMPILE_DEFINITIONS
  LINK_LIBRARIES
  LINK_DIRECTORIES
  INCLUDE_DIRECTORIES
  ARCHIVE_OUTPUT_DIRECTORY
)

if ( APPLE )
  set (
    TWX_TARGET_EXPOSED_CMAKE_PROPERTIES_OS_DARWIN
    OSX_ARCHITECTURES
    MACOSX_BUNDLE
    MACOSX_BUNDLE_INFO_PLIST
    RESOURCE
  )
else ()
  set (
    TWX_TARGET_EXPOSED_CMAKE_PROPERTIES_OS_DARWIN
  )
endif ()

set (
  TWX_TARGET_EXPOSED_PROPERTIES
  BUILD_DIR
  BUILD_DATA_DIR
  CFG_INI_DIR
  PRODUCT_DIR
  DOC_DIR
  DOWNLOAD_DIR
  PACKAGE_DIR
  EXTERNAL_DIR
)

set (
  TWX_TARGET_PROPERTIES
  ${TWX_TARGET_CUSTOM_PROPERTIES}
  ${TWX_TARGET_EXPOSED_PROPERTIES}
  ${TWX_TARGET_EXPOSED_CMAKE_PROPERTIES}
  ${TWX_TARGET_EXPOSED_CMAKE_PROPERTIES_OS_DARWIN}
)
# ANCHOR: twx_target_synchronize
#[=======[*/
/** @brief Synchronize a target with the current state.
  *
  * Ensure that all the variables associate to a module are properly
  * recorded in the given target.
  *
  * @param target if the name of a target to synchronize.
  * Raise when not defined.
  * @param ... for key `PROPERTIES` is a list of properties to be synchronized.
  * By default all the custom properties are synchronized.
  */
twx_target_synchronize( target [PROPERTIES ...] ) {}
/*#]=======]
function ( twx_target_synchronize twx.R_target )
  twx_assert_target ( "${twx.R_target}" )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "" "PROPERTIES" )
  twx_arg_assert_parsed ()
  set ( properties_ )
  foreach ( p_ ${twx.R_PROPERTIES} )
    if ( p_ ${TWX_TARGET_CUSTOM_PROPERTIES} )
      list ( APPEND properties_ "${p_}" )
    else ()
      twx_fatal ( "Unknown read/write property: ${p_}" )
      return ()
    endif ()
  endforeach ()
  if ( "${properties_}" STREQUAL "" )
    set (
      properties_
      "${TWX_TARGET_CUSTOM_PROPERTIES}"
    )
  endif ()
  foreach ( p_ ${properties_} )
    set ( v_ "${${twx.R_target}_${p_}}" )
    if ( p_ MATCHES "DIR$" OR p_ MATCHES "DIRECTORY$" )
      twx_complete_dir_var ( "${v_}" )
    endif ()
    set_target_properties ( ${twx.R_target} PROPERTIES TWX_${p_} "${v_}" )
  endforeach ()
endfunction ( twx_target_synchronize )

# ANCHOR: twx_target_expose
#[=======[*/
/** @brief Expose target properties.
  *
  * Supported CMake properties:
  *
  * - `SOURCE_DIR`
  * - `SOURCES`
  * - `BINARY_DIR`
  * - `COMPILE_DEFINITIONS`
  * - `TYPE`
  * - `LINK_LIBRARIES`
  * - `LINK_DIRECTORIES`
  * - `INCLUDE_DIRECTORIES`
  * - Apple properties:
  *   - `OSX_ARCHITECTURES`
  *   - `MACOSX_BUNDLE`
  *   - `MACOSX_BUNDLE_INFO_PLIST`
  *   - `RESOURCE`
  *
  * Other exposed properties:
  * - `BUILD_DIR`
  * - `BUILD_DATA_DIR`
  * - `CFG_INI_DIR`
  * - `PRODUCT_DIR`
  * - `DOC_DIR`
  * - `DOWNLOAD_DIR`
  * - `PACKAGE_DIR`
  * - `EXTERNAL_DIR`
  *
  * @param target is the name of a target to synchronize.
  * Raise when not yet defined.
  * @param ... for key PROPERTIES is a list of properties to be synchronized.
  * By default all the custom properties are exposed
  * as well as the supported CMake properties.
  */
twx_target_expose( ... ) {}
/*#]=======]
function ( twx_target_expose twx.R_target )
  twx_assert_target ( "${twx.R_target}" )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "" "PROPERTIES" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_PROPERTIES}" STREQUAL "" )
    set (
      twx.R_PROPERTIES
      ${TWX_TARGET_PROPERTIES}
    )
  endif ()
  set ( exposed_ )
  foreach ( p_ ${twx.R_PROPERTIES} )
    if ( p_ IN_LIST TWX_TARGET_EXPOSED_PROPERTIES )
      list ( APPEND exposed_ "${p_}" )
      continue ()
    endif ()
    if ( p_ IN_LIST TWX_TARGET_CUSTOM_PROPERTIES )
      get_target_property ( v_ ${twx.R_target} TWX_${p_} )
    else ()
      get_target_property ( v_ ${twx.R_target} ${p_} )
    endif ()
    if ( v_ MATCHES "NOTFOUND$" )
      twx_fatal ( "UNKNOWN PROPERTY ${twx.R_target}: ${p_}")
      return ()
    endif ()
    twx_message ( DEBUG "twx_target_expose: ${twx.R_target}_${p_} => ${v_}")
    if ( p_ MATCHES "DIR$" OR p_ MATCHES "DIRECTORY$" )
      twx_complete_dir_var ( "${v_}" )
    elseif ( p_ MATCHES "DIRECTORIES$" OR p_ MATCHES "DIRS$" )
      set ( v__ )
      foreach ( w_ ${v_} )
        twx_complete_dir_var ( "${w_}" )
        list ( APPEND v__ "${${w_}}" )
      endforeach ()
      set (v_ "${v__}" )
    endif ()
    set ( ${twx.R_target}_${p_} "${v_}" PARENT_SCOPE )
  endforeach ()
  if ( BINARY_DIR IN_LIST twx.R_PROPERTIES )
    twx_dir_configure (
      BINARY_DIR "${${twx.R_target}_BINARY_DIR}"
      VAR_PREFIX ${twx.R_target}
      PARENT_SCOPE
    )
  elseif ( NOT "${exposed_}" STREQUAL "" )
    get_target_property ( BINARY_DIR_ ${twx.R_target} BINARY_DIR )
    twx_dir_configure (
      BINARY_DIR "${BINARY_DIR_}"
      VAR_PREFIX twx
    )
    foreach ( p_ ${exposed_} )
      set ( ${twx.R_target}_${p_} "${twx_${p_}}" PARENT_SCOPE )
    endforeach ()
  endif ()
endfunction ( twx_target_expose )

# ANCHOR: twx_target_summary
#[=======[*/
/** @brief Display summary of a target.
  *
  * Convenient method called from the main and test `CMakeLists.txt`
  *
  * @param target is the name of a target.
  * @param `NO_EOL` is an optional flag passed to `twx_summary_end()`.
  */
twx_target_summary( target[NO_EOL] ) {}
/*#]=======]
function ( twx_target_summary twx.R_target )
  twx_target_expose ( "${twx.R_target}" )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "NO_EOL" "" "" )
  twx_arg_assert_parsed ()
  message ( "" )
  include ( TwxSummaryLib )
  twx_summary_begin (
    BOLD_GREEN
"${twx.R_target} has been configured \
(CMake ${CMAKE_VERSION}):\n"
  )
  twx_summary_section_compiler ()
  twx_summary_section_git ()
  twx_summary_begin ( BOLD_MAGENTA "Version info" )
  if ( NOT "${${twx.R_target}_VERSION_MAJOR}" STREQUAL "" )
    twx_summary_log ( "${twx.R_target}" ${${twx.R_target}_VERSION_MAJOR}.${${twx.R_target}_VERSION_MINOR}.${${twx.R_target}_VERSION_PATCH} )
  endif ()
  twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
  twx_summary_end ()
  twx_summary_section_files ( ${twx.R_target} )
  twx_summary_section_build_settings ( ${twx.R_target} )
  twx_summary_section_libraries ( ${twx.R_target} )
  twx_arg_pass_option ( NO_EOL )
  twx_summary_end ( ${twx.R_NO_EOL} )
endfunction ( twx_target_summary )

# ANCHOR: twx_target_debug
#[=======[*/
/** @brief Display target properties.
  *
  * For debugging purposes.
  *
  * @param target is the name of a target.
  */
twx_target_debug( target ) {}
/*#]=======]
function ( twx_target_debug twx.R_target )
  twx_arg_assert_count ( ${ARGC} == 1 )
  twx_expose_target ( ${twx.R_target} )
  message ( "Target: ${twx.R_target}" )
  foreach ( p_ ${TWX_TARGET_PROPERTIES} )
    message ( "  ${p_} => ${${m_}_${p_}}" )
  endforeach ()
endfunction ( twx_target_debug )

# ANCHOR: twx_target_include_src
#[=======[*/
/** @brief Include `src` directories.
  *
  * Add the main `.../src` directory as well the `src`
  * subdirectory of the project binary directory to
  * the list of include directories of the given target.
  *
  * Obsolete.
  *
  * @param ... is a list of existing target names
  */
twx_target_include_src (...) {}
/*#]=======]
function ( twx_target_include_src )
  # TODO: twx_assert_non_void ( PROJECT_SOURCE_DIR )
  twx_assert_non_void (
    "${PROJECT_SOURCE_DIR}"
    "${PROJECT_BINARY_DIR}"
    "${TWX_PROJECT_BUILD_DIR}"
  )
  if ( EXISTS "${PROJECT_SOURCE_DIR}/src" )
    foreach ( target_ ${ARGN} )
      twx_assert_target ( "${target_}" )
      target_include_directories (
        "${target_}"
        PRIVATE
          "${PROJECT_SOURCE_DIR}/src/"
          "${TWX_PROJECT_BUILD_DIR}src/"
      )
    endforeach ()
  else ()
    foreach ( target_ ${ARGN} )
    target_include_directories (
        ${target_}
        PRIVATE
          "${TWX_DIR}src/"
          "${PROJECT_BINARY_DIR}/src/"
      )
    endforeach ()
  endif ()
endfunction ( twx_target_include_src )

# ANCHOR: twx_target_shorten
#[=======[*/
/** @brief Shorten messages.
  *
  * Shorten messages by replacing some paths by a description.
  * In place replacements.
  *
  * @param target is the required name of an existing target.
  * @param ... for key VAR is a list of variable names.
  */
twx_target_shorten( target VAR ... ) {}
/*#]=======]
function ( twx_target_shorten twx.R_target )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "" "VAR" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( VAR )
  twx_target_expose (
    ${twx.R_target}
    VARS
      BUILD_DIR
      SRC_DIR
      SOURCE_DIR
      BINARY_DIR
      DIR
  )
  foreach ( v ${twx.R_VAR} )
    foreach (
      what_
      BUILD_DIR SRC_DIR SOURCE_DIR BINARY_DIR DIR
      TWX_BUILD_DIR TWX_DIR
    )
      string (
        REPLACE
        "${${twx_MODULE}_${what_}}"
        "<${twx_MODULE_NAME}_${what_}>/"
        ${v}
        "${${v}}"
      )
    endforeach ()
    twx_export ( ${v} )
  endforeach ()
endfunction ( twx_target_shorten )

# ANCHOR: twx_summary_section_files
#[=======[
*/
/** @brief Log target files info
  *
  * @param ... are target names with
  * `..._SOURCES`, `..._HEADERS`, `..._UIS`.
  */
twx_summary_section_files( target ) {}
/*
#]=======]
function ( twx_target_summary_section_files twx.R_target )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "VERBOSE;EOL" "" "" )
  twx_arg_pass_option ( VERBOSE EOL )
  if ( NOT TARGET "${twx.R_target}" )
    string ( PREPEND twx.R_target "Twx" )
    if ( NOT TARGET "${twx.R_target}" )
      message ( WARNING "Unknown target: ${twx.R_target}" )
      continue( )
    endif ()
  endif ()
  twx_target_expose ( ${twx.R_target} PROPERTIES SOURCES )
  twx_target_shorten ( ${twx.R_target} VAR ${twx.R_target}_SOURCES )
  set ( built_ )
  set ( raw_ )
  foreach ( f_ ${${twx.R_target}_SOURCES} )
    if ( "${f_}" MATCHES "/TwxBuild/" )
      list ( APPEND built_ "${f_}" )
    else ()
      list ( APPEND raw_ "${f_}" )
    endif ()
  endforeach ()
  set ( Private_ )
  set ( SOURCES_ )
  set ( HEADERS_ )
  set ( Other_ )
  foreach ( f_ ${built_rel_} ${raw_rel_} )
    get_filename_component ( n_ "${f_}" NAME )
    if ( "${n_}" MATCHES "_private" )
      list ( APPEND Private_ "${n_}" )
    elseif ( "${n_}" MATCHES "[.](c|m)" )
      list ( APPEND SOURCES_ "${n_}" )
    elseif ( "${n_}" MATCHES "[.]h" )
      list ( APPEND HEADERS_ "${n_}" )
    else ()
      list ( APPEND Other_ "${n_}" )
    endif ()
  endforeach ()
  if (  "${Private_}" STREQUAL ""
    AND "${SOURCES_}" STREQUAL ""
    AND "${HEADERS_}" STREQUAL ""
    AND "${Other_}"   STREQUAL "" )
    continue ()
  endif ()
  twx_summary_begin ( BOLD_BLUE "${twx.R_target} files" )
  foreach ( t_ SOURCES HEADERS Other Private )
    if ( NOT "${${t_}_}" STREQUAL "" )
      twx_summary_log_kv ( "${t_}" VAR ${t_}_ )
    endif ()
  endforeach ()
  twx_summary_end ( ${twx.R_EOL} )
endfunction ( twx_target_summary_section_files )

#*/
