# OS X packaging tasks

# This file is processed by `CONFIGURE_FILE` in `../CMakeLists.txt` which inserts
# values for `@VARIABLE@` declarations. This is done to import values for some
# variables that would otherwise be undefined when CPack is running.

include (
  "${CMAKE_CURRENT_LIST_DIR}/../../CMake/Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)
twx_assert_non_void ( TWX_NAME )
twx_assert_non_void ( TWX_COMMAND )

SET(CMAKE_MESSAGE_LOG_LEVEL @CMAKE_MESSAGE_LOG_LEVEL@)
SET(TWX_PACKAGE_DIR @TWX_PACKAGE_DIR@)
SET(PROJECT_BINARY_DIR @PROJECT_BINARY_DIR@)
SET(TeXworks_LIB_DIRS @TeXworks_LIB_DIRS@)
SET(CMAKE_SHARED_LIBRARY_SUFFIX @CMAKE_SHARED_LIBRARY_SUFFIX@)
SET(QT_PLUGINS @QT_PLUGINS@)
SET(QT_VERSION_MAJOR @QT_VERSION_MAJOR@)
set(QT_LIBRARY_DIR @QT_LIBRARY_DIR@)

#[==[ Next does not work, why?
include ( TwxCfgLib )
twx_cfg_setup ()
#]==]

set(TWX_CFG_MANUAL_HTML_URL @TWX_CFG_MANUAL_HTML_URL@)
twx_assert_non_void ( TWX_CFG_MANUAL_HTML_URL )

# TeXworks HTML manual: version, matching hash, and derived variables.
if ( NOT "${TWX_CFG_MANUAL_HTML_URL}" MATCHES "/(([^/]+)[.]zip$)" )
  twx_fatal ( "Unexpected URL ${TWX_CFG_MANUAL_HTML_URL}" )
  return ()
endif ()
set (
  manual_archive_
  "${CMAKE_MATCH_1}"
)
set (
  manual_base_
  "${CMAKE_MATCH_2}"
)
# This `if` statement ensures that the following commands are executed only when
# CPack is running---i.e. when a user executes `make package` but not `make install`
if ( NOT "${CMAKE_INSTALL_PREFIX}" MATCHES ".*/_CPack_Packages/.*" )
  return ()
endif ()
# Download and install TeXworks manual
# ------------------------------------
if ( NOT EXISTS "${TWX_PACKAGE_DIR}${manual_archive_}" )
  message (
    STATUS
    "Downloading TeXworks HTML manual from ${TWX_CFG_MANUAL_HTML_URL}"
  )
  file (
    DOWNLOAD "${TWX_CFG_MANUAL_HTML_URL}"
    "${TWX_PACKAGE_DIR}${manual_archive_}"
    EXPECTED_HASH SHA256=${TWX_CFG_MANUAL_HTML_SHA256}
    SHOW_PROGRESS
  )
else ( )
  message (
    STATUS "Using manual files in '${TWX_PACKAGE_DIR}${manual_archive_}'"
  )
endif ()

if ( NOT EXISTS "${TWX_PACKAGE_DIR}${manual_base_}" )
  file (
    MAKE_DIRECTORY "${TWX_PACKAGE_DIR}${manual_base_}"
  )
  execute_process (
    COMMAND unzip "${TWX_PACKAGE_DIR}${manual_archive_}"
    WORKING_DIRECTORY "${TWX_PACKAGE_DIR}${manual_base_}"
  )
else ( )
  message (
    STATUS "'${TWX_PACKAGE_DIR}${manual_base_}' already present"
  )
endif ()

message (
  STATUS "Bundling manual files"
)
file (
  INSTALL "${TWX_PACKAGE_DIR}${manual_base_}/TeXworks-manual"
  DESTINATION "${CMAKE_INSTALL_PREFIX}/${TWX_NAME}.app/Contents/${TWX_COMMAND}-help/"
)


# Copy all runtime dependencies and rewrite loader paths
# ------------------------------------------------------

# Bring in `DeployQt5` a CMake module taken from the Charm application:
#
#   <https://github.com/KDAB/Charm>
#
# This module offers the `FIXUP_QT5_BUNDLE` function which wraps
# `FIXUP_BUNDLE` from CMake's `BundleUtilities` module and extends it with
# additional Qt5-specific goodies---such as installing Qt5 plugins.
#
# `FIXUP_BUNDLE` is a wonderful function that examines an executable, finds
# all non-system libraries it depends on, copies them into the `.app` bundle
# and then re-writes the necessary loader paths.
set ( CMAKE_MODULE_PATH @CMAKE_MODULE_PATH@ )
include ( DeployQt5 )

# Gather all TeXworks Plugin libraries.
file (
  GLOB TeXworks_PLUGINS
  "${CMAKE_INSTALL_PREFIX}/${TWX_NAME}.app/Contents/PlugIns/*${CMAKE_SHARED_MODULE_SUFFIX}"
)

# If `BU_CHMOD_BUNDLE_ITEMS` is not set, `install_name_tool` will fail to
# re-write some loader paths due to insufficiant permissions.
set ( BU_CHMOD_BUNDLE_ITEMS ON )

fixup_Qt5_executable (
  "${CMAKE_INSTALL_PREFIX}/${TWX_NAME}.app"
  "${QT_PLUGINS}"
  "${TeXworks_PLUGINS}"
  "${TeXworks_LIB_DIRS}"
)

# Remove unecessary architectures from universal binaries
# -------------------------------------------------------

# Some libraries copied from the OS X system, such as X11 libraries, may
# contain up to 4 different architectures. Here we will iterate over these
# libraries and use `lipo` to strip out un-needed architectures.

# Another useful function from `BundleUtilities`.
get_bundle_main_executable (
  "${CMAKE_INSTALL_PREFIX}/${TWX_NAME}.app"
  main_executable_
)
if ( NOT "${main_executable_}" STREQUAL "" )
  # We look at the TeXworks binary that was built rather than consulting the
  # value of the `CMAKE_OSX_ARCHITECTURES` because if the user did not set
  # `CMAKE_OSX_ARCHITECTURES`, then the variable will be an empty string and the
  # format of the resulting binary will depend on the versions of OS X and
  # XCode.
  message ( STATUS "Reducing the size of bundled libraries." )
  message ( STATUS "Scanning architectures of: ${main_executable_}" )
  execute_process (
    # `lipo -info` returns a list of the form:
    #
    #     <is universal binary?>: <program name>: <list of architectures>
    #
    # Piping this output to `cut -d : -f 3-` allows us to extract just the list
    # of architectures.
    COMMAND lipo -info "${main_executable_}"
    COMMAND cut -d : -f 3-
    OUTPUT_VARIABLE architectures_
  )

  # Strip leading and trailing whitespace.
  string ( STRIP ${architectures_} architectures_ )
  # Convert spaces to semicolons so CMake will interpret the string as a list.
  string ( REPLACE " " ";" architectures_ ${architectures_})

  message ( STATUS "Will reduce bundled libraries to: ${architectures_}" )

  foreach ( ARCH IN LISTS architectures_ )
    set ( ARCHS_TO_EXTRACT "${ARCHS_TO_EXTRACT} -extract ${ARCH}" )
  endforeach ()
endif ()

# __NOTE:__ This will not process any dylibs from Frameworks copied by
# `FIXUP_BUNDLE`, hence it may not touch any of the Qt libraries. Something to
# fix in the future.
file (
  GLOB bundles_dylibs_
  "${CMAKE_INSTALL_PREFIX}/${TWX_NAME}.app/Contents/MacOS/*${CMAKE_SHARED_LIBRARY_SUFFIX}"
)

foreach ( dylib_ ${bundles_dylibs_} )
  # `lipo` prints error messages when attempting to extract from a file that
  # is not a universal (fat) binary. Avoid this by checking first.
  execute_process (
    COMMAND lipo -info "${dylib_}"
    COMMAND cut -d : -f 1
    COMMAND grep -q "Non-fat file"
    RESULT_VARIABLE dylib_is_fat_
  )
  if ( NOT ${dylib_is_fat_} EQUAL 0 )
    message ( STATUS "Processing fat library: ${dylib_}" )
    # `lipo` is very very anal about how arguments get passed to it. So we
    # execute through bash to side-step the issue.
    execute_process (
      COMMAND bash -c "lipo ${ARCHS_TO_EXTRACT} ${dylib_} -output ${dylib_}"
    )
  else ()
    message ( STATUS "Skipping non-fat library: ${dylib_}" )
  endif()
endforeach ()

message ( STATUS "Finished stripping architectures from bundled libraries." )
