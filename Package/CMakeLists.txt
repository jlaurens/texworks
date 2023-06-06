#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks

*//** @file
@brief The packaging CMakeLists file

This is not the top level CMakeLists file.
This is called by the 

*//*
#]===============================================]

# Packaging Tasks
# ===============

if ( NOT TWX_IS_BASED )
  include (
		"${CMAKE_CURRENT_LIST_DIR}/CMake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()

include ( TwxCfgLib )
twx_cfg_update_factory()
twx_cfg_update_git()
twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )

# Create a CMake script containing packaging tasks specific to Apple. All
# variables of the form `@VARIABLE@` will be replaced, while variables of the
# form `${VARIABLE}` will be left untouched.
set (
	packagingTasks.cmake
	"${TWX_PACKAGE_DIR}/CPackPackagingTasks.cmake"
)
if ( APPLE )
  configure_file (
    "${TWX_DIR}/Distribute/mac/MacPackagingTasks.in.cmake"
    "${packagingTasks.cmake}"
    @ONLY
  )
else ()
  # Create a dummy script for other platforms.
  file (
		WRITE "${packagingTasks.cmake}"
		""
	)
endif ()

# Execute the packaging tasks. `install(SCRIPT ...)` is used so that these tasks
# executing during `make install` rather than `make` or `cmake`.
install (
	SCRIPT "${packagingTasks.cmake}"
)

set (
	CPACK_PROJECT_CONFIG_FILE
	"${TWX_DIR}/Distribute/CPackProjectConfig.txt"
)

# Set custom CPack variables
set ( CPACK_GIT_HASH "${TWX_CFG_GIT_HASH}" )

if ( WIN32 )
	set ( CPACK_TARGET_OS "win" )
	set ( CPACK_GENERATOR "ZIP" )
	set ( CPACK_STRIP_FILES ON )
	set ( CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF )
	include ( ExternalProject )
	ExternalProject_Add (
		poppler-data
		URL "${TWX_CFG_POPPLER_DATA_URL}"
		URL_HASH SHA256=${TWX_CFG_POPPLER_DATA_SHA256}
		CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:STRING=${TWX_BUILD_DATA_DIR}
		DOWNLOAD_DIR "${TWX_DOWNLOAD_DIR}"
	)
	file (
		COPY "${TWX_DIR}/win32/fonts"
		DESTINATION "${TWX_PACKAGE_DIR}/share"
	)
	install (
		DIRECTORY "${TWX_PACKAGE_DIR}/share"
		DESTINATION "."
		PATTERN pkgconfig EXCLUDE
	)
	install (
		FILES "${TWX_DIR}/COPYING"
		DESTINATION "."
	)
	install (
		SCRIPT
	)
	install (
		FILES "${TWX_DIR}/win32/README.win.txt"
		DESTINATION "."
		RENAME "README.txt"
	)
	ExternalProject_Add (
		texworks-help
		URL "${TWX_CFG_MANUAL_HTML_URL}"
		URL_HASH SHA256=${TWX_CFG_MANUAL_HTML_SHA256}
		DOWNLOAD_DIR "${TWX_DOWNLOAD_DIR}"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E copy_directory
				"."
				"${TWX_PACKAGE_DIR}/texworks-help/TeXworks-manual"
	)
	install (
		DIRECTORY "${TWX_PACKAGE_DIR}/texworks-help"
		DESTINATION "."
	)
elseif (APPLE)
	set ( CPACK_TARGET_OS "macos" )
	set ( Contents_DIR "${CMAKE_BINARY_DIR}/${TWX_NAME}.app/Contents" )
	
	include ( ExternalProject )
	ExternalProject_Add (
		poppler-data
		URL "${TWX_CFG_POPPLER_DATA_URL}"
		URL_HASH SHA256=${TWX_CFG_POPPLER_DATA_SHA256}
		PREFIX "${TWX_BUILD_DIR}/poppler-data/"
		CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:STRING="${Contents_DIR}/"
	)
	file ( REMOVE_RECURSE "${Contents_DIR}/share/pkgconfig" )

	ExternalProject_Add (
		texworks-help
		URL "${TWX_CFG_MANUAL_HTML_URL}"
		URL_HASH SHA256=${TWX_CFG_MANUAL_HTML_SHA256}
		PREFIX "${TWX_BUILD_DIR}/texworks-help/"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E copy_directory
			"."
			"${Contents_DIR}/${TWX_COMMAND}-help/${TWX_NAME}-manual"
	)
	ExternalProject_Add (
		urw35-fonts
		URL https://mirrors.ctan.org/fonts/urw/base35.zip
		PREFIX "${TWX_BUILD_DIR}/urw35-fonts/"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E make_directory "${Contents_DIR}/share/fonts"
		COMMAND
			${CMAKE_COMMAND} -E copy_if_different
				pfb/ucrb8a.pfb pfb/ucrbo8a.pfb pfb/ucrr8a.pfb pfb/ucrro8a.pfb pfb/uhvb8a.pfb pfb/uhvbo8a.pfb pfb/uhvr8a.pfb pfb/uhvro8a.pfb pfb/usyr.pfb pfb/utmb8a.pfb pfb/utmbi8a.pfb pfb/utmr8a.pfb pfb/utmri8a.pfb pfb/uzdr.pfb
				"${Contents_DIR}/share/fonts"
	)
	file (
		COPY "${CMAKE_SOURCE_DIR}/Distribute/mac/fonts.conf"
		DESTINATION "${Contents_DIR}/etc/fonts"
	)
endif ()

# Set CPack variables.
set ( CPACK_PACKAGE_VERSION_MAJOR ${TWX_CFG_VERSION_MAJOR} )
set ( CPACK_PACKAGE_VERSION_MINOR ${TWX_CFG_VERSION_MINOR} )
set ( CPACK_PACKAGE_VERSION_PATCH ${TWX_CFG_VERSION_PATCH} )
set ( CPACK_PACKAGE_VERSION ${TWX_CFG_VERSION} )

set ( CPACK_PACKAGE_NAME ${TWX_NAME} )

# Configure Drag N' Drop installer.
if ( APPLE )
  set ( mac_DIR_tws "${TWX_DIR}/Distribute/mac" )
  set ( CPACK_GENERATOR DragNDrop )
  set ( CPACK_DMG_BACKGROUND_IMAGE "${mac_DIR_tws}/texworks_dmg_background.png" )
  # Configure an AppleScript for applying a nice window layout to Drag N' Drop disk
  # image.
  twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
  configure_file (
    "${mac_DIR_tws}/DMGSetup.in.scpt"
    "${TWX_BUILD_DATA_DIR}/DMGSetup.scpt"
    @ONLY
  )
  set (
		CPACK_DMG_DS_STORE_SETUP_SCRIPT
		"${TWX_BUILD_DATA_DIR}/DMGSetup.scpt"
	)
  unset ( mac_DIR_tws )
endif ()

include ( CPack )

#*/
