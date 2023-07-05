#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/ui/CMakeLists.txt`

It can be used as standalone testing project,
testing auxiliary or source provider.

## Standalone testing project

When used as primary `CMakeLists.txt` it defines
a standalone test suite for `Tw` namespace.

Usage from an external build directory:
```
cmake .../src/ui
cmake --build .
ctest .
```

## Subdirectory

When loaded by `add_subdirectory`.

### In testing context

It defines a test suite as part of a more general test.
See `/unit-tests/CMakeLists.txt`.

### In normal context

Output:
* `TwxUI_SOURCES`, a `;` separated list of full paths
* `TwxUI_HEADERS`, a `;` separated list of full paths

NB: The transition to Twx is not complete
#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )

	# This file is primary
	cmake_minimum_required ( VERSION 3.25 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Base/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
	project ( TwxUI_Test )
	twx_base_after_project ()

  set ( TWX_TEST ON	)
  set ( TwxUI_TEST ON	)
	set ( TwxUI_TEST_IS_ROOT ON )
	enable_testing ()
	include ( TwxQTLib )
	twx_Qt_fresh ( TEST )
	include ( TwxDoxydocLib )
  twx_doxydoc ()
elseif ( TWX_TEST )
	project ( TwxUI_Test )
	twx_base_after_project ()
  set ( TwxUI_TEST ON	)
endif ()

include ( SrcTwxUISetup )

if ( NOT TWX_TEST )
	twx_export ( TwxUI_SOURCES )
	twx_export ( TwxUI_HEADERS )
	twx_export ( TwxUI_UIS )
	return ()
endif ()

add_subdirectory ( Test )
