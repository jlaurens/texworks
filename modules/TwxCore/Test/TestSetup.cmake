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

twx_assert_non_void ( TWX_MODULE TWX_MODULE_NAME )
twx_assert_target ( test_${TWX_MODULE} )

target_compile_definitions (
	test_${TWX_MODULE}
	PRIVATE
		TwxAssets_TEST
		TwxLocate_TEST
)

add_executable (
	test_${TWX_MODULE}_macOS
	${${TWX_MODULE}_SOURCES} ${${TWX_MODULE}_HEADERS}
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}Test_macOS.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}Test_macOS.h"
)
list (
  APPEND ${TWX_MODULE}_TEST_SUITE
  ${TWX_MODULE_NAME}_macOS
)
add_dependencies ( test_${TWX_MODULE}_macOS test_${TWX_MODULE} )
twx_module_includes ( ${TWX_MODULE} IN_TARGETS test_${TWX_MODULE}_macOS )
include ( TwxWarning )
twx_warning_target ( test_${TWX_MODULE}_macOS )
target_compile_definitions (
	test_${TWX_MODULE}_macOS
	PRIVATE TWX_TEST ${TWX_MODULE}_TEST TwxAssets_TEST
)

target_link_libraries (
	test_${TWX_MODULE}_macOS
	${QT_LIBRARIES}
	${${TWX_MODULE}_LIBRARIES}
)

set_target_properties (
	test_${TWX_MODULE}_macOS
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY
			"${twx_WorkingDirectory}/ExpectedDirName_macOS/Fake.app/Contents/MacOS"
)

add_test (
	NAME test_${TWX_MODULE}_macOS
	COMMAND test_${TWX_MODULE}_macOS
	WORKING_DIRECTORY
	"${twx_WorkingDirectory}"
)

# define executables, with or without extension.
# in the working directory or below
set ( main.cpp ${CMAKE_CURRENT_LIST_DIR}/main.cpp )
add_executable ( ${TWX_MODULE}_auxiliary           ${main.cpp} )
add_dependencies ( ${TWX_MODULE}_auxiliary test_${TWX_MODULE} )
add_executable ( ${TWX_MODULE}_auxiliary_program   ${main.cpp} )
add_dependencies ( ${TWX_MODULE}_auxiliary_program test_${TWX_MODULE} )
set_target_properties (
	${TWX_MODULE}_auxiliary   ${TWX_MODULE}_auxiliary_program
  PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}/Locate/A"
)
set_target_properties (
	${TWX_MODULE}_auxiliary ${TWX_MODULE}_auxiliary_program
  PROPERTIES
	OUTPUT_NAME "program"
)
set_target_properties (
	${TWX_MODULE}_auxiliary_program
  PROPERTIES
		SUFFIX ".program"
)
add_executable (
	${TWX_MODULE}_Locate_absoluteProgramPath_program ${main.cpp}
)
add_dependencies ( ${TWX_MODULE}_Locate_absoluteProgramPath_program test_${TWX_MODULE} )
set_target_properties (
	${TWX_MODULE}_Locate_absoluteProgramPath_program
	PROPERTIES
		OUTPUT_NAME "program"
		SUFFIX ".program"
		RUNTIME_OUTPUT_DIRECTORY "${twx_WorkingDirectory}/Locate/absoluteProgramPath"
)
if ( NOT UNIX )
  set ( .exe_twx .exe )
endif ()
add_custom_command (
	TARGET ${TWX_MODULE}_Locate_absoluteProgramPath_program POST_BUILD
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
	${TWX_MODULE}_Locate_appendListPATH_tex ${main.cpp}
)
add_dependencies (
	${TWX_MODULE}_Locate_absoluteProgramPath_program
	test_${TWX_MODULE}.WorkingDirectory
)
set_target_properties (
	${TWX_MODULE}_Locate_appendListPATH_tex
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
			TARGET ${TWX_MODULE}_Locate_appendListPATH_tex POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E copy
				${input_twx}
				${output_twx}
		)
	endforeach ()
endforeach ()

# Finally the library test

add_executable (
	test_${TWX_MODULE}Lib
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.h"
)
set_target_properties (
	test_${TWX_MODULE}Lib
	PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
)
list (
  APPEND ${TWX_MODULE}_TEST_SUITE
  ${TWX_MODULE_NAME}Lib
)
twx_Qt_link_libraries ( TARGETS test_${TWX_MODULE}Lib )
target_link_libraries (
	test_${TWX_MODULE}Lib
	PRIVATE TwxCore
)
twx_module_add ( Core TO_TARGETS test_${TWX_MODULE}Lib )

target_compile_definitions ( 
  test_${TWX_MODULE}Lib
  PRIVATE ${TWX_MODULE}Lib_TEST
)

add_test (
	NAME test_${TWX_MODULE}Lib
	COMMAND test_${TWX_MODULE}Lib
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)

# add_executable (
# 	test_${TWX_MODULE}Lib2
# 	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.cpp"
# 	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.h"
# )

# twx_Qt_fresh ( TEST )
# #twx_Qt_link_libraries ( TARGETS test_${TWX_MODULE}Lib2 )
# target_link_libraries (
# 	test_${TWX_MODULE}Lib
# 	PRIVATE Qt5::Core Qt5::Test
# )
# twx_module_add ( Core TO_TARGETS test_${TWX_MODULE}Lib2 )

# # target_compile_definitions ( 
# #   test_${TWX_MODULE}Lib2
# #   PRIVATE ${TWX_MODULE}Lib2_TEST
# # )

# add_test (
# 	NAME test_${TWX_MODULE}Lib2
# 	COMMAND test_${TWX_MODULE}Lib2
# 	WORKING_DIRECTORY
# 		"${twx_WorkingDirectory}"
# )

add_executable (
	test_${TWX_MODULE}Lib2
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.cpp"
	"${CMAKE_CURRENT_LIST_DIR}/${TWX_MODULE}LibTest.h"
)
list (
  APPEND ${TWX_MODULE}_TEST_SUITE
  ${TWX_MODULE_NAME}Lib2
)
set_target_properties (
	test_${TWX_MODULE}Lib2
	PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY "${TWX_PROJECT_PRODUCT_DIR}"
)
twx_Qt_fresh ( TEST )
# twx_Qt_link_libraries ( TARGETS test_${TWX_MODULE}Lib )
target_link_libraries (
	test_${TWX_MODULE}Lib2
	PRIVATE Qt5::Core Qt5::Test
)
twx_module_add ( Core TO_TARGETS test_${TWX_MODULE}Lib2 TEST )

target_compile_definitions ( 
  test_${TWX_MODULE}Lib2
  PRIVATE ${TWX_MODULE}Lib2_TEST
)

add_test (
	NAME test_${TWX_MODULE}Lib2
	COMMAND test_${TWX_MODULE}Lib2
	WORKING_DIRECTORY
		"${twx_WorkingDirectory}"
)
