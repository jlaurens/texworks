#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/Typeset/Setup.cmake`

Usage from an external build directory:
```
include ( .../Setup.cmake )
```
Output:
* `TwxTypeset_SOURCES`, a `;` separated list of full paths
* `TwxTypeset_HEADERS`, a `;` separated list of full paths

Includes `TwxConfigureFilePaths`. The `TWX_TEST_PATHS` variable
must be defined beforehands for testing the path manager.
#]===============================================]

set ( TwxTypeset_SOURCES )
set ( TwxTypeset_HEADERS )

# if ( NOT TWX_IS_BASED )
#   message ( FATAL_ERROR "TwxBase is not included")
# endif ()

list (
	APPEND TwxTypeset_SOURCES
	"${CMAKE_CURRENT_LIST_DIR}/TwxEngine.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxEngineManager.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetManager.cpp"
)

list (
	APPEND TwxTypeset_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/TwxEngine.h"
	"${CMAKE_CURRENT_LIST_DIR}/TwxEngineManager.h"
	"${CMAKE_CURRENT_LIST_DIR}/TwxTypesetManager.h"
)
