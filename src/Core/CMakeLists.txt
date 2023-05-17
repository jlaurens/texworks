#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//** @file
@brief TwxCore Cmake file

This file can be used as standalone testing project or
testing subdirectory auxiliary.

## Standalone testing project

When used as primary `CMakeLists.txt` it defines
a standalone test suite for `Twx::Core` namespace.

Usage from an external build directory:
```
cmake .../Core
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
* `TwxCore_SOURCES`, a `;` separated list of full paths
* `TwxCore_HEADERS`, a `;` separated list of full paths
*/
/*
#]===============================================]

# Will be unset below when testing
set ( TWX_TEST_PATHS "<<<pwd>>>/A;<<<pwd>>>/B;<<<pwd>>>/C;" )

if ( NOT TWX_IS_BASED )

	# This file is primary
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
	project ( TwxCoreTest ) # Don't change this name just here
	include ( TwxBase )
	set ( TWX_TEST ON	)
	set ( TwxCore_TEST_IS_ROOT ON )
	enable_testing ()
	include ( TwxQTLib )
	twx_fresh_Qt ( TEST )

	include ( TwxDoxydocLib )
	twx_doxydoc ( ${CMAKE_CURRENT_BINARY_DIR} )
	
elseif ( TWX_TEST )
	project ( TwxCoreTest ) # Don't change this name just here
	include ( TwxBase )
else ()
  unset ( TWX_TEST_PATHS )
endif ()

include ( SrcTwxCoreSetup )

if ( NOT TWX_TEST OR TARGET test_TwxCore )
	twx_export ( TwxCore_SOURCES )
	twx_export ( TwxCore_HEADERS )
	return ()
endif ()

add_executable ( test_TwxCore )

twx_target_include_src ( test_TwxCore )

target_compile_definitions (
	test_TwxCore
	PRIVATE TWX_TEST TwxCore_TEST TwxAssets_TEST
)
# Testing the path manager is special
if ( DEFINED TWX_TEST_PATHS )
	target_compile_definitions (
		test_TwxCore
		PRIVATE TwxPathManager_TEST
	)
endif ()

# if ( QT_VERSION_MAJOR EQUAL 6 )
# 	# Check for Qt6
# 	twx_append_QT ( REQUIRED Core5Compat )
# else ()
# 	if ( WIN32 AND NOT BUILD_SHARED_LIBS )
# 		twx_append_QT ( REQUIRED WindowsPlatformSupport )
# 	endif ()
# endif ()

target_link_libraries (
	test_TwxCore
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning_target ( test_TwxCore )

list (
	APPEND
	TwxCore_SOURCES
	"${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.cpp"
)
list (
	APPEND
	TwxCore_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.h"
)

target_sources (
	test_TwxCore
	PRIVATE ${TwxCore_SOURCES} ${TwxCore_HEADERS}
)

include ( TwxTestCase )
twx_test_case ( test_TwxCore tws_working_directory )

add_test (
	NAME test_TwxCore
	COMMAND test_TwxCore
	WORKING_DIRECTORY
		"${tws_working_directory}"
)

# define executables, with or without extension.
# in the working directory or below
set ( main.cp ${CMAKE_CURRENT_LIST_DIR}/Test/main.cpp )
add_executable ( TwxCore_auxiliary           ${main.cp} )
add_executable ( TwxCore_auxiliary_program   ${main.cp} )
set_target_properties (
	TwxCore_auxiliary   TwxCore_auxiliary_program
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${tws_working_directory}/A"
)
set_target_properties (
 	TwxCore_auxiliary TwxCore_auxiliary_program
  PROPERTIES
	OUTPUT_NAME "program"
)
set_target_properties (
	TwxCore_auxiliary_program
  PROPERTIES
		SUFFIX ".program"
)

unset ( tws_working_directory )

# ANCHOR - Summary
# =======

if ( TwxCore_TEST_IS_ROOT )

	message ( "" )

	include ( TwxConfigLog )
	include ( TwxCfgLib )
	twx_cfg_update ()
	twx_cfg_read ( "git" )

	twx_config_begin (
		BOLD_GREEN
	"${PROJECT_NAME} test suite has been configured \
	(CMake ${CMAKE_VERSION}, \
	${CMAKE_CXX_COMPILER_ID} \
	${CMAKE_CXX_COMPILER_VERSION}):\n"
		)
	twx_config_begin ( BOLD_MAGENTA "Git info" )
	twx_config_log ( "Hash" "${TWX_CFG_GIT_HASH}" )
	twx_config_log ( "Date" "${TWX_CFG_GIT_DATE}" )
	twx_config_log ( "Branch" "${TWX_CFG_GIT_BRANCH}" )
	twx_config_end ()

	twx_config_begin ( BOLD_MAGENTA "Version info" )
	twx_config_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
	twx_config_end ()

	twx_config_log ( "Compiler optimization" ${CMAKE_BUILD_TYPE} )
	twx_config_log ( "" )

	twx_config_begin ( BOLD_BLUE "Libraries" VERBOSE )
	twx_config_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
	twx_config_end ()

	twx_config_begin ( BOLD_BLUE "Build settings" VERBOSE )
	get_target_property (
		COMPILE_DEFINITIONS
		test_TwxCore
		COMPILE_DEFINITIONS
	)
	twx_config_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
	get_target_property (
		COMPILE_OPTIONS
		test_TwxCore
		COMPILE_OPTIONS
	)
	twx_config_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
	twx_config_end ()

	twx_config_begin ( BOLD_BLUE "Files" VERBOSE )
	twx_config_log_kv ( "SOURCES" VAR TwxCore_SOURCES )
	twx_config_log_kv ( "HEADERS" VAR TwxCore_HEADERS )
	twx_config_end ()

	twx_config_end ( NO_EOL )

endif ()
#*/
