#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/src/Core/CMakeLists.txt`

When used as primary `CMakeLists.txt` it defines
a standalone test suite for `Twx::Core` namespace.

When used when `TWX_TEST` is on, it defines a test suite
as part of a more general test.
It is also included by `/unit-tests/CMakeLists.txt`.

Otherwise, it defines the sources and headers.

Usage:

From an external binary directory
```
cmake .../Core
cmake --build .
ctest .
```

#]===============================================]

if ( NOT TWX_IS_BASED )
	# This file is primary
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
	project ( TwxCoreTest )
	# Include the base once again to finish setup
	include ( TwxBase )
	set (
		TWX_PROJECT.ini
		"${CMAKE_CURRENT_LIST_DIR}/Test/${PROJECT_NAME}.ini"
	)
	include ( TwxPrepareConfigureFile )
	
  include ( withQT )
	if ( QT_VERSION_MAJOR EQUAL 6 )
		# Check for Qt6
		twx_append_QT ( REQUIRED Core5Compat )
	else ()
		if ( WIN32 AND NOT BUILD_SHARED_LIBS )
			twx_append_QT ( REQUIRED WindowsPlatformSupport )
		endif ()
	endif ()

	include ( InitWARNING )

	enable_testing ()

	set ( TWX_TEST ON	)
	set ( TwxCore_TEST_IS_ROOT ON )
  
	# add_custom_target (
	# 	TwxSetupConfigureFile_target
	# 	ALL

	# 	] [command1 [args1...]]
  #                 [COMMAND command2 [args2...] ...]
  #                 [DEPENDS depend depend depend ... ]
  #                 [WORKING_DIRECTORY dir]
  #                 [COMMENT comment] [VERBATIM]
  #                 [SOURCES src1 [src2...]]
	# )
	# add_custom_target (
	# 	TwxSetupConfigureFile_target
	# 	ALL
	# 	] [command1 [args1...]]
  #                 [COMMAND command2 [args2...] ...]
  #                 [DEPENDS depend depend depend ... ]
  #                 [WORKING_DIRECTORY dir]
  #                 [COMMENT comment] [VERBATIM]
  #                 [SOURCES src1 [src2...]]
	# )
endif ()

twx_configure_file_add (
	out_twx
  "${CMAKE_CURRENT_LIST_DIR}/TwxInfo.in.cpp"
)
twx_configure_file_proceed ( )
include ( TwxSrc )

set (
	TwxCore_SOURCES
	${out_twx}
)
twx_src_list_append (
	TwxCore_SOURCES
	"${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.cpp"
)
set (
	TwxCore_HEADERS
)
twx_src_list_append (
	TwxCore_HEADERS
	"${CMAKE_CURRENT_LIST_DIR}/TwxInfo.h"
	"${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.h"
)

if ( TWX_TEST )
# Add a test target for primary or secondary
# `CMakeLists`.

	add_executable (
		test_TwxCore
	)
	target_include_directories (
		test_TwxCore
		PRIVATE "${TWX_DIR}/src"
		PRIVATE "${PROJECT_BINARY_DIR}/src"
	)
	# The sources need the include directories
	target_sources (
		test_TwxCore
		PRIVATE "${CMAKE_CURRENT_LIST_DIR}/TwxInfo.h"
		PRIVATE "${PROJECT_BINARY_DIR}/src/Core/TwxInfo.cpp"
		PRIVATE "${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.h"
		PRIVATE "${CMAKE_CURRENT_LIST_DIR}/Test/TwxCoreTest.cpp"
		# PRIVATE ${TwxCore_SOURCES} 
		# PRIVATE ${TwxCore_HEADERS}
	)
	target_compile_options (
		test_TwxCore
		PRIVATE ${WARNING_OPTIONS}
	)
	target_link_libraries (
		test_TwxCore
		${QT_LIBRARIES}
	)
	target_compile_definitions (
		test_TwxCore
		PRIVATE TwxCore_TEST
	)
	add_test (
		NAME test_TwxCore
		COMMAND test_TwxCore
		WORKING_DIRECTORY
		"${CMAKE_CURRENT_LIST_DIR}/TestCase"
	)
endif ( TWX_TEST )

# ANCHOR - Summary
# =======

if ( TwxCore_TEST_IS_ROOT )

message ( "" )

include ( TwxConfigLog )
include ( TwxInfoGitUpdate )
twx_info_read ( GIT )

twx_config_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}, \
${CMAKE_CXX_COMPILER_ID} \
${CMAKE_CXX_COMPILER_VERSION}):\n"
	)
twx_config_begin ( BOLD_MAGENTA "Git info" )
twx_config_log ( "Hash" "${TWX_INFO_GIT_HASH}" )
twx_config_log ( "Date" "${TWX_INFO_GIT_DATE}" )
twx_config_log ( "Branch" "${TWX_INFO_GIT_BRANCH}" )
twx_config_end ()

twx_config_begin ( BOLD_MAGENTA "Version info" )
twx_config_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_config_end ()

twx_config_log ( "Compiler optimization:" ${CMAKE_BUILD_TYPE} )
twx_config_log ( "" )

twx_config_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_config_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_config_end ()

twx_config_begin ( BOLD_BLUE "Build settings" VERBOSE )
twx_config_log_kv ( "Compile definitions" VAR COMPILE_DEFINITIONS )
twx_config_log_kv ( "Compile options" VAR COMPILE_OPTIONS )
twx_config_end ()

twx_config_begin ( BOLD_BLUE "Files" VERBOSE )
twx_config_log_kv ( "SOURCES" VAR TwxCore_SOURCES )
twx_config_log_kv ( "HEADERS" VAR TwxCore_HEADERS )
twx_config_end ()

twx_config_end ( NO_EOL )

endif ()
