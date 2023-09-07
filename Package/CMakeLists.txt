#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks

*//** @file
@brief The packaging CMakeLists file

This is not the top level CMakeLists file.
This is called by the

*//*
#]===============================================]

include_guard ( GLOBAL )

# Packaging Tasks
# ===============

if ( NOT DEFINED /TWX/IS_BASED )
	cmake_minimum_required ( VERSION 3.25 )
  include (
		"${CMAKE_CURRENT_LIST_DIR}/../CMake/Base/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
	project ( TwxPackageTest )
	twx_base_after_project ()
	include ( TwxQtLib )
	twx_Qt_fresh ( REQUIRED Widgets )

	if ( APPLE )
	  set ( icns Test/res/os_darwin/TwxPackageTest.icns )
		set_source_files_properties (
			${icns}
			PROPERTIES
				MACOSX_PACKAGE_LOCATION Resources
		)	
		add_executable (
			TwxPackageTest
			MACOSX_BUNDLE
			Test/src/main.cpp
			Test/src/TwxPackageTest.cpp
			${icns}
		)
		twx_Qt_link_libraries ( TARGETS TwxPackageTest )
	endif ()
endif ()

include ( TwxCfgLib )
twx_cfg_setup()
twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )

set ( TWX_NAME TwxPackageTest )

# Create a CMake script containing packaging tasks specific to Apple. All
# variables of the form `@VARIABLE@` will be replaced, while variables of the
# form `${VARIABLE}` will be left untouched.
set (
	packagingTasks.cmake
	"${TWX_BUILD_DATA_DIR}CPackPackagingTasks.cmake"
)
if ( APPLE )
  configure_file (
    "${TWX_DIR}Package/os_darwin/CPackPackagingTasks.in.cmake"
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
	"${TWX_DIR}Package/CPackProjectConfig.txt"
)

if ( WIN32 )
	set ( CPACK_GENERATOR "ZIP" )
	set ( CPACK_STRIP_FILES ON )
	set ( CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF )
	include ( ExternalProject )
	ExternalProject_Add (
		poppler-data
		URL "${/TWX/CFG/POPPLER_DATA_URL}"
		URL_HASH SHA256=${/TWX/CFG/POPPLER_DATA_SHA256}
		CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:STRING=${TWX_BUILD_DATA_DIR}
		DOWNLOAD_DIR "${TWX_EXTERNAL_DIR}"
	)
	file (
		COPY "${TWX_DIR}win32/fonts"
		DESTINATION "${TWX_PACKAGE_DIR}share"
	)
	install (
		DIRECTORY "${TWX_PACKAGE_DIR}share"
		DESTINATION "."
		PATTERN pkgconfig EXCLUDE
	)
	install (
		FILES "${TWX_DIR}COPYING"
		DESTINATION "."
	)
	install (
		FILES "${TWX_DIR}win32/README.win.txt"
		DESTINATION "."
		RENAME "README.txt"
	)
	ExternalProject_Add (
		texworks-help
		URL "${/TWX/CFG/MANUAL_HTML_URL}"
		URL_HASH SHA256=${/TWX/CFG/MANUAL_HTML_SHA256}
		DOWNLOAD_DIR "${TWX_EXTERNAL_DIR}"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E copy_directory
				"."
				"${TWX_PACKAGE_DIR}texworks-help/TeXworks-manual"
	)
	install (
		DIRECTORY "${TWX_PACKAGE_DIR}texworks-help"
		DESTINATION "."
	)
elseif (APPLE)
	set ( Contents_DIR "${CMAKE_BINARY_DIR}/${TWX_NAME}.app/Contents" )
	
	include ( ExternalProject )
	ExternalProject_Add (
		poppler-data
		URL "${/TWX/CFG/POPPLER_DATA_URL}"
		URL_HASH SHA256=${/TWX/CFG/POPPLER_DATA_SHA256}
		PREFIX "${TWX_BUILD_DIR}poppler-data/"
		CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:STRING=${Contents_DIR}/
	)
	file ( REMOVE_RECURSE "${Contents_DIR}/share/pkgconfig" )
	set ( target_twx texworks-help )
	set ( prefix_Dir_twx "${TWX_BUILD_DIR}${target_twx}/" )
	set ( manual_Dir_twx "${prefix_Dir_twx}/src/${target_twx}/" )
	ExternalProject_Add (
		${target_twx}
		URL "${/TWX/CFG/MANUAL_HTML_URL}"
		URL_HASH SHA256=${/TWX/CFG/MANUAL_HTML_SHA256}
		PREFIX "${prefix_Dir_twx}/"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E copy_directory
			"${manual_Dir_twx}"
			"${Contents_DIR}/${TWX_COMMAND}-help/${TWX_NAME}-manual"
	)
	set ( prefix_DIR_tws "${TWX_BUILD_DIR}urw35-fonts/" )
	set ( pfb_DIR_tws "${prefix_DIR_tws}/src/urw35-fonts/pfb" )
	ExternalProject_Add (
		urw35-fonts
		URL "${/TWX/CFG/URW35_FONTS_URL}"
		PREFIX "${prefix_DIR_tws}/"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND
			${CMAKE_COMMAND} -E make_directory "${Contents_DIR}/share/fonts"
		COMMAND
			${CMAKE_COMMAND} -E copy_if_different
				${pfb_DIR_tws}/ucrb8a.pfb
				${pfb_DIR_tws}/ucrbo8a.pfb
				${pfb_DIR_tws}/ucrr8a.pfb
				${pfb_DIR_tws}/ucrro8a.pfb
				${pfb_DIR_tws}/uhvb8a.pfb
				${pfb_DIR_tws}/uhvbo8a.pfb
				${pfb_DIR_tws}/uhvr8a.pfb
				${pfb_DIR_tws}/uhvro8a.pfb
				${pfb_DIR_tws}/usyr.pfb
				${pfb_DIR_tws}/utmb8a.pfb
				${pfb_DIR_tws}/utmbi8a.pfb
				${pfb_DIR_tws}/utmr8a.pfb
				${pfb_DIR_tws}/utmri8a.pfb
				${pfb_DIR_tws}/uzdr.pfb
				"${Contents_DIR}/share/fonts"
	)
	file (
		COPY "${TWX_DIR}Package/os_darwin/fonts.conf"
		DESTINATION "${Contents_DIR}/etc/fonts"
	)
endif ()

# Set CPack variables.
set ( CPACK_PACKAGE_VERSION_MAJOR ${/TWX/CFG/VERSION_MAJOR} )
set ( CPACK_PACKAGE_VERSION_MINOR ${/TWX/CFG/VERSION_MINOR} )
set ( CPACK_PACKAGE_VERSION_PATCH ${/TWX/CFG/VERSION_PATCH} )
set ( CPACK_PACKAGE_VERSION ${/TWX/CFG/VERSION} )

set ( CPACK_PACKAGE_NAME ${TWX_NAME} )

# Configure Drag N' Drop installer.
if ( APPLE )
  set ( darwin_DIR_tws "${TWX_DIR}Package/os_darwin" )
  set ( CPACK_GENERATOR DragNDrop )
  set ( CPACK_DMG_BACKGROUND_IMAGE "${mac_DIR_tws}/texworks_dmg_background.png" )
  # Configure an AppleScript for applying a nice window layout to Drag N' Drop disk
  # image.
  twx_cfg_read ( NO_PRIVATE ONLY_CONFIGURE )
  configure_file (
    "${darwin_DIR_tws}/DMGSetup.in.scpt"
    "${TWX_BUILD_DATA_DIR}DMGSetup.scpt"
    @ONLY
  )
  set (
		CPACK_DMG_DS_STORE_SETUP_SCRIPT
		"${TWX_BUILD_DATA_DIR}DMGSetup.scpt"
	)
  unset ( darwin_DIR_tws )
endif ()

include ( CPack )

#*/
