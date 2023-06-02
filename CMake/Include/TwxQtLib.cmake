#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Qt management utilities

Usage:
```
include ( TwxQtLib )
twx_Qt_fresh ()
...
```
The `TwxBase` is required.
*//**
@brief `5` or `6`.

Can be set from the command line to choose
between `Qt5` and `Qt6`.
When not provided, `Qt5` is chosen. 
*/
QT_DEFAULT_MAJOR_VERSION;
/*
#]===============================================]

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "TwxBase not included" )
endif ()

if ( NOT DEFINED QT_VERSION_MAJOR )
	if ( DEFINED QT_DEFAULT_MAJOR_VERSION )
		set ( QT_VERSION_MAJOR ${QT_DEFAULT_MAJOR_VERSION} )
	else ()
	  set ( QT_VERSION_MAJOR 5 )	  
	endif ()
endif ()

# Expose the major version number of Qt to the preprocessor. This is necessary
# to include the correct Qt headers (as QTVERSION is not defined before any Qt
# headers are included)
add_definitions (
	-DQT_VERSION_MAJOR=${QT_VERSION_MAJOR}
)

#[=======[
*//**
@brief `Qt` libraries

The list of `Qt` related libraries for some targets.
This is reset to basic values each time the script is included:
`Qt::Core`, `Qt::QTest` if `TWX_TEST` is set, 
`Qt::Core5Compat` for `Qt6`.
*/
QT_LIBRARIES;
/**
@brief `Qt5`, `Qt6`...

Convenience variable containing `Qt5`, `Qt6`...
according to the actual `Qt` version.
*/
QtMAJOR;
/**
@brief `Qt` major version

Defined the first time this script is included.

There is a corresponding `QT_VERSION_MAJOR`
preprocessor macro.
*/
QT_VERSION_MAJOR;
/**
@brief `Qt` minor version

Defined the first time this script is included.
*/
QT_VERSION_MINOR;
/**
@brief `Qt` patch version

Defined the first time this script is included.
*/
QT_VERSION_PATCH;
/*
#]=======]
set ( QtMAJOR "Qt${QT_VERSION_MAJOR}" )

if ( COMMAND twx_QT_append )
  # Already loaded, only initialize `QT_LIBRARIES`
	set ( QT_LIBRARIES )
	twx_QT_append ( REQUIRED Core )
	if ( QT_VERSION_MAJOR EQUAL 6 )
		twx_QT_append ( REQUIRED Core5Compat )
	endif ()
	if ( WITH_TEST OR TWX_TEST )
		twx_QT_append ( REQUIRED Test )
	endif ()
  return ()
endif ()

# 1 utilities to find a package and append a component to the given variable
# in general QT_LIBRARIES.

# ANCHOR: twx_QT_append
#[=======[
*//**
This function will load Qt components.
The libraries are collected in the `QT_LIBRARIES` variable.

Usage:
```
twx_QT_append (
	[REQUIRED required ...]
	[OPTIONAL optional ...]
)
```
@param required for key REQUIRED, component
@param optional for key OPTIONAL, component
*/
twx_QT_append(...) {}
/*
this must be a macro because the found packages are likely to
change variables within the caller's scope,
at least the "..._FOUND" ones.
#]=======]
macro ( twx_QT_append )
	twx_parse_arguments ( "" "" "REQUIRED;OPTIONAL" ${ARGN} )
	twx_assert_parsed ()
	# Find all the packages
	find_package (
		${QtMAJOR}
		REQUIRED COMPONENTS ${my_twx_REQUIRED}
		OPTIONAL_COMPONENTS ${my_twx_OPTIONAL} QUIET
	)
	# Record the libraries, when not already done.
	foreach ( TWX_comp IN LISTS my_twx_REQUIRED )
	  list ( FIND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} TWX_k )
		if ( ${TWX_k} LESS 0 )
		  list ( APPEND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} )
		endif ()
	endforeach ()
	foreach ( TWX_comp IN LISTS my_twx_OPTIONAL )
# TODO: move to CMake 3.3
		list ( FIND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} TWX_k )
		if ( ${TWX_k} LESS 0 )
   		list ( APPEND QT_LIBRARIES ${QtMAJOR}::${TWX_comp} )
		endif ()
	endforeach ()
	# unset local variables
	unset ( my_twx_REQUIRED )
	unset ( my_twx_OPTIONAL )
	unset ( TWX_comp )
	unset ( TWX_k )
endmacro ()

# ANCHOR: twx_Qt_target_guards
#[=======[
*//**
Add macro definition to the given target to 
disallow automatic casts from `char*` to `QString``
( enforcing the use of `tr( )` or explicitly specifying the string encoding)
@param target a valid target name
*/
twx_Qt_target_guards(target) {}
/*
#]=======]
function ( twx_Qt_target_guards _target )
	target_compile_definitions (
		${_target}
		PRIVATE QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII QT_NO_CAST_FROM_BYTEARRAY
	)
	if ( NOT MSVC )
	# Set QT_STRICT_ITERATORS everywhere except for MSVC ( QTBUG-78112 )
		target_compile_definitions (
			${_target}
			PRIVATE QT_STRICT_ITERATORS
		)
	endif ()
endfunction ()

if ( NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "5.6.0" )
	# Old Qt versions were heavily using 0 instead of nullptr, giving lots
	# of false positives
	include ( TwxWarning )
	twx_warning_add (
		-Wzero-as-null-pointer-constant
	)
endif ()
set ( QT_LIBRARIES )

twx_QT_append ( REQUIRED Core )

set ( QT_VERSION_MINOR "${${QtMAJOR}_VERSION_MINOR}" )
set ( QT_VERSION_PATCH "${${QtMAJOR}_VERSION_PATCH}" )

#[=======[
*//**
@brief Setup a fresh `Qt` state.

@param TEST optional key, when provided and `TWX_TEST` is not set
  raise an error.
*/
twx_Qt_fresh ( [TEST] ) {}
/*
#]=======]
macro ( twx_Qt_fresh )
	set ( QT_LIBRARIES )
	twx_QT_append ( REQUIRED Core )
	if ( QT_VERSION_MAJOR EQUAL 6 )
		twx_QT_append ( REQUIRED Core5Compat )
	endif ()
	if ( WITH_TESTS OR TWX_TEST OR "${ARGN}" STREQUAL "TEST" )
		twx_QT_append ( OPTIONAL Test )
		if ( NOT ${QtMAJOR}Test_FOUND )
			set ( WITH_TESTS OFF )
			set ( TWX_TEST OFF )
		endif ()
	endif ()
	if ( "${ARGN}" STREQUAL "TEST" AND NOT WITH_TESTS AND NOT TWX_TEST )
		twx_fatal ( "QTest is not available" )
	endif ()
endmacro ()

# ANCHOR: twx_Qt_link_libraries
#[=======[
*//**
@brief Link the current Qt libraries to the given target.

@param ... list of targets.
*/
twx_Qt_link_libraries ( ... ) {}
/*
#]=======]
macro ( twx_Qt_link_libraries )
  foreach ( target_ ${ARGN} )
	  twx_assert_target ( ${target_} )
		target_link_libraries (
			${target_}
			${QT_LIBRARIES}
		)
	endforeach ()
endmacro ()

#*/