#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*//**
@file
@brief TwxCore/Test Cmake file

Defines a test suite.

The test suite highly relies on the shape of the working directory.
In particular, changing names as well as removing folders can have dramatic consequences.

Input:
- `TwxCore_SOURCES`
- `TwxCore_HEADERS`
*/
/*
#]===============================================]

if ( TARGET test_TwxCore )
  return ()
endif ()

if ( NOT DEFINED TWX_IS_BASED )
	cmake_minimum_required ( VERSION 3.1 )
	include (
		"${CMAKE_CURRENT_LIST_DIR}/../../../Cmake/Include/TwxBase.cmake"
		NO_POLICY_SCOPE
	)
endif ()
project ( TwxCoreTest )
include ( TwxBase )

include ( TwxModuleLib )

set ( TWX_TEST ON )

include ( TwxQTLib )
twx_Qt_fresh()

set ( TWX_TEST ON	)

enable_testing ()

set (
	TWX_FACTORY_INI
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.ini"
)
set ( TWX_NAME TwxCoreTest )

twx_module_setup ( NAME Core )

twx_QT_append ( REQUIRED Test )

add_executable ( test_TwxCore )
twx_module_src_include ( Core TARGETS test_TwxCore )
include ( TwxTestLib )
twx_test_case ( twx_WorkingDirectory TARGET test_TwxCore )
twx_assert_target ( test_TwxCore.WorkingDirectory )

add_executable ( test_TwxCore_macOS )
add_dependencies ( test_TwxCore_macOS test_TwxCore )
twx_module_src_include ( Core TARGETS test_TwxCore_macOS )

target_compile_definitions (
	test_TwxCore
	PRIVATE TWX_TEST TwxCore_TEST TwxAssets_TEST
)
target_compile_definitions (
	test_TwxCore_macOS
	PRIVATE TWX_TEST TwxCore_TEST TwxAssets_TEST
)

target_compile_definitions (
	test_TwxCore
	PRIVATE TwxLocate_TEST
)

target_link_libraries (
	test_TwxCore
	${TwxCore_LIBRARIES}
	${QT_LIBRARIES}
)
target_link_libraries (
	test_TwxCore_macOS
	${TwxCore_LIBRARIES}
	${QT_LIBRARIES}
)

include ( TwxWarning )
twx_warning_target ( test_TwxCore test_TwxCore_macOS )

target_sources (
	test_TwxCore
	PRIVATE ${TwxCore_SOURCES} ${TwxCore_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.h"
)

target_sources (
	test_TwxCore_macOS
	PRIVATE	${TwxCore_SOURCES} ${TwxCore_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest_macOS.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest_macOS.h"
)

set_target_properties (
	test_TwxCore_macOS
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY
			"${twx_WorkingDirectory}/ExpectedDirName_macOS/Fake.app/Contents/MacOS"
)

add_test (
	NAME test_TwxCore
	COMMAND test_TwxCore
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)
add_test (
	NAME test_TwxCore_macOS
	COMMAND test_TwxCore_macOS
	WORKING_DIRECTORY
	"${twx_WorkingDirectory}"
)

# define executables, with or without extension.
# in the working directory or below
set ( main.cpp ${CMAKE_CURRENT_LIST_DIR}/main.cpp )
add_executable ( TwxCore_auxiliary           ${main.cpp} )
add_dependencies ( TwxCore_auxiliary test_TwxCore )
add_executable ( TwxCore_auxiliary_program   ${main.cpp} )
add_dependencies ( TwxCore_auxiliary_program test_TwxCore )
set_target_properties (
	TwxCore_auxiliary   TwxCore_auxiliary_program
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}/Locate/A"
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
add_executable (
	TwxCore_Locate_absoluteProgramPath_program ${main.cpp}
)
add_dependencies ( TwxCore_Locate_absoluteProgramPath_program test_TwxCore )
set_target_properties (
	TwxCore_Locate_absoluteProgramPath_program
	PROPERTIES
		OUTPUT_NAME "program"
		SUFFIX ".program"
		RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}/Locate/absoluteProgramPath"
)
if ( NOT UNIX )
  set ( .exe_twx .exe )
endif ()
add_custom_command (
	TARGET TwxCore_Locate_absoluteProgramPath_program POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy
		"${twx_WorkingDirectory}/Locate/absoluteProgramPath/program.program"
		"${twx_WorkingDirectory}/Locate/absoluteProgramPath/program${.exe_twx}"
)

#[=======[
For testing purposes, mimic a texlive distribution:
List of subdirectories of `bin`:
* 2023:
	- aarch64-linux
	- amd64-freebsd
	- amd64-netbsd
	- armhf-linux
	- i386-freebsd
	- i386-linux
	- i386-netbsd
	- i386-solaris
	- universal-darwin
	- windows
	- x86_64-cygwin
	- x86_64-darwinlegacy
	- x86_64-linux
	- x86_64-linuxmusl
	- x86_64-solaris
* Before 2023
	- i386-cygwin
	- win32
	- x86_64-darwin

#]=======]
add_executable (
	TwxCore_Locate_appendListPATH_tex ${main.cpp}
)
add_dependencies (
	TwxCore_Locate_absoluteProgramPath_program
	test_TwxCore.WorkingDirectory
)
set_target_properties (
	TwxCore_Locate_appendListPATH_tex
	PROPERTIES
		OUTPUT_NAME "tex"
		RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}/Locate/appendListPATH"
)
foreach ( year 1111 2222 3333 )
	foreach ( bin
			aarch64-linux amd64-freebsd amd64-netbsd armhf-linux
			i386-freebsd i386-linux i386-netbsd i386-solaris
			universal-darwin windows x86_64-cygwin x86_64-darwinlegacy
			x86_64-linux x86_64-linuxmusl x86_64-solaris i386-cygwin
			win32 x86_64-darwin )
		set (
			input_twx
			"${twx_WorkingDirectory}/Locate/appendListPATH/tex${.exe_twx}"
		)
		set (
			output_twx
			"${twx_WorkingDirectory}/Locate/usr/local/texlive/${year}/bin/${bin}/tex${.exe_twx}"
		)
		add_custom_command(
			TARGET TwxCore_Locate_appendListPATH_tex POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy
				${input_twx}
				${output_twx}
		)
	endforeach ()
endforeach ()

# Finally the library test

add_executable (
	test_TwxCoreLib
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreLibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreLibTest.h"
)

twx_module_add ( Core TARGETS test_TwxCoreLib )
twx_Qt_link_libraries ( test_TwxCoreLib )

target_compile_definitions ( 
  test_TwxCoreLib
  PRIVATE TwxCoreLib_TEST
)

add_test (
	NAME test_TwxCoreLib
	COMMAND test_TwxCoreLib
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

add_executable (
	test_TwxCoreLib2
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreLibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/TwxCoreLibTest.h"
)

twx_module_add ( Core TARGETS test_TwxCoreLib2 TEST )
twx_Qt_link_libraries ( test_TwxCoreLib2 )

add_test (
	NAME test_TwxCoreLib2
	COMMAND test_TwxCoreLib2
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

target_compile_definitions ( 
  test_TwxCoreLib2
  PRIVATE TwxCoreLib2_TEST
)

unset ( twx_WorkingDirectory )

# ANCHOR - Summary
# =======

message ( "" )

include ( TwxSummaryLib )

twx_summary_begin (
	BOLD_GREEN
"${PROJECT_NAME} test suite has been configured \
(CMake ${CMAKE_VERSION}):\n"
)

twx_summary_section_compiler ()

twx_summary_begin ( BOLD_MAGENTA "Tests" )
twx_summary_log ( "1" "test_TwxCore" )
twx_summary_log ( "2" "test_TwxCore_macOS" )
twx_summary_log ( "3" "test_TwxCoreLib" )
twx_summary_log ( "4" "test_TwxCoreLib2" )
twx_summary_end ()

twx_summary_section_git ()

twx_summary_begin ( BOLD_MAGENTA "Version info" )
twx_summary_log ( "Qt" ${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH} )
twx_summary_end ()

twx_summary_begin ( BOLD_BLUE "Libraries" VERBOSE )
twx_summary_log_kv ( "Qt${QT_VERSION_MAJOR}" VAR QT_LIBRARIES )
twx_summary_end ()

foreach ( t_ Core CoreLib CoreLib2 Core_macOS )
	twx_summary_section_build_settings ( test_Twx${t_} VERBOSE )
	twx_summary_section_files ( test_Twx${t_} VERBOSE )
endforeach ()

twx_summary_end ()

#*/
