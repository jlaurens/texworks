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

if ( NOT DEFINED TWX_IS_BASED )
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

if ( COMMAND twx_Qt_find )
  # Already loaded, only initialize `QT_LIBRARIES`
	set ( QT_LIBRARIES )
	twx_Qt_find ( REQUIRED Core )
	if ( QT_VERSION_MAJOR EQUAL 6 )
		twx_Qt_find ( REQUIRED Core5Compat )
	endif ()
	if ( WITH_TEST OR TWX_TEST )
		twx_Qt_find ( REQUIRED Test )
	endif ()
  return ()
endif ()

# 1 utilities to find a package and append a component to the given variable
# in general QT_LIBRARIES.

# ANCHOR: twx_Qt_find
#[=======[
*//**
This function will load Qt components.

The libraries are possibly collected in the `QT_LIBRARIES` variable
or in a variable provided by the caller.
Modules will provide the variable.

Usage:
```
twx_Qt_find (
	[VAR components]
	[REQUIRED required ...]
	[OPTIONAL optional ...]
)
```
@param found for key VAR is an optional list var name that
	will hold on return the list of found components at its end.
	When no variable name is provided, the found components are collected
	in list variable `QT_LIBRARIES`.
@param required for key REQUIRED, optional list of component
@param optional for key OPTIONAL, optional list of component
*/
twx_Qt_find([VAR name] [REQUIRED ...] [OPTIONAL ...]) {}
/*
This must be a macro because the found packages are likely to
change variables within the caller's scope,
at least the "..._FOUND" ones.
And this must be called from the scope where the components are used.
#]=======]
macro ( twx_Qt_find )
	twx_parse_arguments ( "" "VAR" "REQUIRED;OPTIONAL" ${ARGN} )
	twx_assert_parsed ()
	# Find all the components
	if ( NOT "${twxR_REQUIRED}" STREQUAL "" )
		find_package (
			${QtMAJOR}
			REQUIRED COMPONENTS ${twxR_REQUIRED}
		)
	endif ()
	if ( NOT "${twxR_OPTIONAL}" STREQUAL "" )
		find_package (
			${QtMAJOR}
			OPTIONAL_COMPONENTS ${twxR_OPTIONAL} QUIET
		)
	endif ()
	if ( "${twxR_VAR}" STREQUAL "" )
		set ( twxR_VAR QT_LIBRARIES )
	endif ()
	# Record the libraries, when not already done.
	foreach ( component_twx ${twxR_REQUIRED} ${twxR_OPTIONAL} )
		if ( NOT ${QtMAJOR}::${component_twx} IN_LIST ${twxR_VAR} )
			list ( APPEND ${twxR_VAR} ${QtMAJOR}::${component_twx} )
		endif ()
	endforeach ()
	# unset local variables
	unset ( twxR_REQUIRED )
	unset ( twxR_OPTIONAL )
	unset ( component_twx )
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

twx_Qt_find ( REQUIRED Core )

set ( QT_VERSION_MINOR "${${QtMAJOR}_VERSION_MINOR}" )
set ( QT_VERSION_PATCH "${${QtMAJOR}_VERSION_PATCH}" )

#[=======[
*//**
@brief Setup a fresh `Qt` state.

Calls at the end `twx_Qt_find()`
@param TEST optional key, when provided and `TWX_TEST` is not set
  raise an error.
*/
twx_Qt_fresh ( [TEST] ) {}
/*
#]=======]
macro ( twx_Qt_fresh )
message ( "twx_Qt_fresh: A" )
  twx_parse_arguments ( "TEST" "VAR" "" ${ARGN} )
	if ( "${twxR_VAR}" STREQUAL "" )
	  set ( twxR_VAR QT_LIBRARIES )
	endif ()
	set ( twx_Qt_fresh_UNPARSED_ARGUMENTS "${twxR_UNPARSED_ARGUMENTS}" )
	set ( ${twxR_VAR} )
	message ( "twx_Qt_fresh: B" )
	twx_Qt_find ( VAR ${twxR_VAR} REQUIRED Core )
	if ( QT_VERSION_MAJOR EQUAL 6 )
		twx_Qt_find ( VAR ${twxR_VAR} REQUIRED Core5Compat )
	endif ()
	message ( "twx_Qt_fresh: ${twxR_VAR} => ${${twxR_VAR}}" )
	if ( WITH_TESTS OR TWX_TEST OR ${twxR_TEST} )
		twx_Qt_find ( VAR ${twxR_VAR} OPTIONAL Test )
		message ( "twx_Qt_fresh: ${twxR_VAR} => ${${twxR_VAR}}" )
		if ( NOT ${QtMAJOR}Test_FOUND )
			set ( WITH_TESTS OFF )
			set ( TWX_TEST OFF )
		endif ()
	endif ()
	if ( ${twxR_TEST} AND NOT WITH_TESTS AND NOT TWX_TEST )
		twx_fatal ( "QTest is not available" )
	endif ()
	twx_Qt_find ( VAR ${twxR_VAR} ${twx_Qt_fresh_UNPARSED_ARGUMENTS} )
	message ( "twx_Qt_fresh: ${twxR_VAR} => ${${twxR_VAR}}" )
	unset ( twxR_VAR )
	unset ( twxR_TEST )
	unset ( twx_Qt_fresh_UNPARSED_ARGUMENTS )
endmacro ()

# ANCHOR: twx_Qt_link_libraries
#[=======[
*//**
@brief Link the current Qt libraries to the given target.

@param ... for key TARGETS, list of targets.
*/
twx_Qt_link_libraries ( ... ) {}
/*
#]=======]
function ( twx_Qt_link_libraries )
  twx_parse_arguments ( "" "" "TARGETS" ${ARGN} )
	twx_assert_parsed ()
  foreach ( target_ ${twxR_TARGETS} )
	  twx_assert_target ( ${target_} )
		target_link_libraries (
			${target_}
			PRIVATE ${QT_LIBRARIES}
		)
	endforeach ()
endfunction (twx_Qt_link_libraries)

message ( STATUS "TwxQtLib: Qt version ${QT_VERSION_MAJOR}" )
#*/
