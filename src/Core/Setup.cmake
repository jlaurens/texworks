#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/Core/Setup.cmake`

Usage from an external build directory:
```
include ( .../Setup.cmake )
```
Output:
* `TwxCore_SOURCES`, a `;` separated list of full paths
* `TwxCore_HEADERS`, a `;` separated list of full paths

Includes `TwxConfigureFilePaths`. The `TWX_TEST_PATHS` variable
must be defined beforehands for testing the path manager.
#]===============================================]

set ( TwxCore_SOURCES )
set ( TwxCore_HEADERS )

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "TwxBase is not included")
endif ()

include (	TwxConfigureFilePaths )

include ( TwxConfigureFileLib )

# Default main ini file
twx_configure_file_default_ini (
	"${TWX_DIR}/src/Core/Test/TwxCoreTest.ini"
)

twx_configure_files (
	out_twx
	"${CMAKE_CURRENT_LIST_DIR}/TwxInfo.in.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxPathManager.in.cpp"
)

list (
	APPEND TwxCore_SOURCES
	"${CMAKE_CURRENT_LIST_DIR}/TwxConst.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxSettings.cpp"
	${out_twx}
)
unset ( out_twx )

list (
	APPEND TwxCore_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/TwxConst.h"
	"${CMAKE_CURRENT_LIST_DIR}/TwxSettings.h"
	"${CMAKE_CURRENT_LIST_DIR}/TwxInfo.h"
	"${CMAKE_CURRENT_LIST_DIR}/TwxPathManager.h"
)

twx_append_QT ( REQUIRED Widgets )
