#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
(C) 2023 JL
*//** @file
@brief Set variables to use the contents of this source folder

Usage:

  twx_module_setup ( NAME Core )

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
		TwxAssets.h
		TwxAssetsTrackDB.h
		TwxConst.h
		TwxInfo.h
		TwxLocate_private.h
		TwxLocate.in.h
		TwxNamespaceTestMain_private.h
		TwxSettings.h
		TwxSetup.h
		TwxTool.h
)

if ( COMMAND twx_QT_append )
	twx_QT_append ( REQUIRED Widgets )
endif ()

#*/
