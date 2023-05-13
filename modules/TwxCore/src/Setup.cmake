#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
(C) 2023 JL
*//** @file
@brief Set variables to use the contents of this source folder

Not suitable outside of this module directory

Output:
- `TwxCore_RELATIVE_SOURCES`, a `;` separated list of relative paths to sources
- `TwxCore_RELATIVE_HEADERS`, a `;` separated list of relative paths to headers
- `TwxCore_SOURCES`, a `;` separated list of full paths to sources
- `TwxCore_HEADERS`, a `;` separated list of full paths to headers
- necessary `Qt` libs are appended

Files have been configured as necessary with `TwxCfgFileLib`.

Needs `TwxCfgPaths`.

@see
- `TwxCfgFileLib.cmake`
- `TwxCfgPaths.cmake`
*/
/*
#]===============================================]

set ( TwxCore_RELATIVE_SOURCES )
list (
	APPEND TwxCore_RELATIVE_SOURCES
	TwxAssets.cpp
	TwxAssetsTrackDB.cpp
	TwxConst.in.cpp
	TwxInfo.in.cpp
	TwxLocate.in.cpp
	TwxSettings.cpp
	TwxSetup.cpp
	TwxTool.cpp
)
set ( TwxCore_RELATIVE_HEADERS )
list (
	APPEND TwxCore_RELATIVE_HEADERS
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

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "TwxBase is not included")
endif ()

set ( TWX_MODULE_NAME TwxCore )

include (	TwxCfgPaths )

include ( TwxCfgFileLib )

twx_cfg_write_begin ( "Core_private" )
twx_cfg_set ( include_NamespaceTestMain "#include \"TwxNamespaceTestMain_private.h\"" )
twx_cfg_set ( include_Locate_private    "#include \"TwxLocate_private.h\"" )
twx_cfg_write_end ( "Core_private" )

# Default main ini file
twx_cfg_setup ()

twx_cfg_files (
	ID 			SOURCES
	FILES 	${TwxCore_RELATIVE_SOURCES}
	IN_DIR 	"${CMAKE_CURRENT_LIST_DIR}"
	OUT_DIR "${PROJECT_BINARY_DIR}/TwxBuild/src"
	EXPORT 	${TWX_MODULE_NAME}
	ESCAPE_QUOTES
)

twx_cfg_files (
	ID 			HEADERS
	FILES 	${TwxCore_RELATIVE_HEADERS}
	IN_DIR  "${CMAKE_CURRENT_LIST_DIR}"
	OUT_DIR "${PROJECT_BINARY_DIR}/TwxBuild/src"
	EXPORT 	${TWX_MODULE_NAME}
)

# No extra library
set ( TwxCore_LIBRARIES )

# No extra module
set ( TwxCore_MODULES )

if ( COMMAND twx_QT_append )
	twx_QT_append ( REQUIRED Widgets )
endif ()

#*/
