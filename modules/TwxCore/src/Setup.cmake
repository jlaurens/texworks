#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
(C) 2023 JL
*//** @file
@brief Set variables to use the contents of this source folder

Usage:

  twx_module_setup ( Core )

Not suitable outside of this module directory.

Output:
- necessary `Qt` libs are appended

*/
/*
#]===============================================]

twx_module_declare (
	SOURCES
		TwxAssets.cpp
		TwxAssetsTrackDB.cpp
		TwxConst.in.cpp
		TwxInfo.in.cpp
		TwxLocate.in.cpp
		TwxSettings.cpp
		TwxSetup.cpp
		TwxTool.cpp
	HEADERS
		TwxAssets_private.h
		TwxAssets.in.h
		TwxAssetsTrackDB_private.h
		TwxAssetsTrackDB.in.h
		TwxConst.h
		TwxInfo.in.h
		TwxLocate_private.h
		TwxLocate.in.h
		TwxSettings.in.h
		TwxSetup.h
		TwxTool.h
	QT_COMPONENTS
		Widgets
)

if ( APPLE )
	twx_module_declare (
		SOURCES
			TwxInfoMacOSVersion.mm
		OTHER_LIBRARIES
			"-framework Foundation"
	)
endif ()

#*/
