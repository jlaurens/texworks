#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
	* @brief Qt management utilities
	*
	* Usage:
	* ```
	* include ( TwxQtLib )
	* twx_Qt_fresh ()
	* ...
	* ```
	* The `TwxBase` is required.
	*/
/**
	* @brief `5` or `6`.
	* 
	* Can be set from the command line to choose
	* between `Qt5` and `Qt6`.
	* When not provided, `Qt5` is chosen.
	*/
QT_DEFAULT_MAJOR_VERSION;
/*
#]===============================================]

include_guard ( GLOBAL )

if ( NOT DEFINED /TWX/IS_BASED )
  message ( FATAL_ERROR "TwxBase not included" )
endif ()

if ( COMMAND twx_Qt_find )
  # Already loaded, only initialize `QT_LIBRARIES`
	set ( QT_LIBRARIES )
	twx_Qt_find ( REQUIRED Core )
	if ( "${QT_VERSION_MAJOR}" EQUAL "6" )
		twx_Qt_find ( REQUIRED Core5Compat )
	endif ()
	if ( WITH_TEST OR /TWX/TESTING )
		twx_Qt_find ( REQUIRED Test )
	endif ()
  return ()
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
*/
/**
	* @brief `Qt` libraries
	*
	* The list of `Qt` related libraries for some targets.
	* This is reset to basic values each time the script is included:
	* `Qt::Core`, `Qt::QTest` if `/TWX/TESTING` is set,
	* `Qt::Core5Compat` for `Qt6`.
	*/
QT_LIBRARIES;
/** @brief `Qt5`, `Qt6`...
	*
	* Convenience variable containing `Qt5`, `Qt6`...
	* according to the actual `Qt` version.
	*/
QtMAJOR;
/** @brief `Qt` major version
	*
	* Defined the first time this script is included.
	*
	* There is a corresponding `QT_VERSION_MAJOR`
	* preprocessor macro.
	*/
QT_VERSION_MAJOR;
/** @brief `Qt` minor version
	* 
	* Defined the first time this script is included.
	*/
QT_VERSION_MINOR;
/** @brief `Qt` patch version
	*
	* Defined the first time this script is included.
	*/
QT_VERSION_PATCH;
/*
#]=======]
set ( QtMAJOR "Qt${QT_VERSION_MAJOR}" )

# 1 utility to find a package and append a component to the given variable
# in general QT_LIBRARIES.

# ANCHOR: twx_Qt_find
#[=======[
*/
/** @brief Loads Qt components.
	*
	* The libraries are possibly collected in the `QT_LIBRARIES` variable
	* or in a variable provided by the caller.
	* Modules will provide the variable.
	* 
	* Usage:
	* ```
	* twx_Qt_find (
	* 	[IN_VAR components]
	* 	[REQUIRED required ...]
	* 	[OPTIONAL optional ...]
	* )
	* ```
	* @param found for key `IN_VAR` is an optional list var name that
	* 	will hold on return the list of found components at its end.
	* 	When no variable name is provided, the found components are collected
	* 	in list variable `QT_LIBRARIES`.
	* @param required for key `REQUIRED`, optional list of component
	* @param optional for key `OPTIONAL`, optional list of component
	*/
twx_Qt_find([VAR name] [REQUIRED ...] [OPTIONAL ...]) {}
/*
This must be a macro because the found packages are likely to
change variables within the caller's scope,
at least the "..._FOUND" ones.
And this must be called from the scope where the components are used.
#]=======]
macro ( twx_Qt_find )
	cmake_parse_arguments (
		twx_Qt_find
		"" "IN_VAR" "REQUIRED;OPTIONAL"
		${ARGV}
	)
	twx_arg_assert_parsed ( PREFIX twx_Qt_find )
	# Find all the components
	if ( NOT "${twx_Qt_find_REQUIRED}" STREQUAL "" )
		find_package (
			${QtMAJOR}
			REQUIRED COMPONENTS ${twx_Qt_find_REQUIRED}
		)
	endif ()
	if ( NOT "${twx_Qt_find_OPTIONAL}" STREQUAL "" )
		find_package (
			${QtMAJOR}
			OPTIONAL_COMPONENTS ${twx_Qt_find_OPTIONAL} QUIET
		)
	endif ()
	if ( "${twx_Qt_find_IN_VAR}" STREQUAL "" )
		set ( twx_Qt_find_IN_VAR QT_LIBRARIES )
	endif ()
	# Record the libraries, when not already done.
	foreach ( twx_Qt_find.COMPONENT ${twx_Qt_find_REQUIRED} ${twx_Qt_find_OPTIONAL} )
		if ( NOT ${QtMAJOR}::${twx_Qt_find.COMPONENT} IN_LIST ${twx_Qt_find_VAR} )
			list ( APPEND ${twx_Qt_find_IN_VAR} ${QtMAJOR}::${twx_Qt_find.COMPONENT} )
		endif ()
	endforeach ()
	# unset local variables
	unset ( twx_Qt_find_REQUIRED )
	unset ( twx_Qt_find_OPTIONAL )
	unset ( twx_Qt_find.COMPONENT )
endmacro ()

# ANCHOR: twx_Qt_target_guards
#[=======[
*/
/** @brief Add macro definitions to targets
	*
	* To disallow automatic casts from `char*` to `QString``
	* ( enforcing the use of `tr( )` or explicitly specifying the string encoding)
	* @param ... non empty list of valid target names
	*/
twx_Qt_target_guards(target ...) {}
/*
#]=======]
function ( twx_Qt_target_guards _target )
	target_compile_definitions (
		${_target}
		PRIVATE
			QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII QT_NO_CAST_FROM_BYTEARRAY
	)
	if ( NOT MSVC )
	# Set QT_STRICT_ITERATORS everywhere except for MSVC ( QTBUG-78112 )
		target_compile_definitions (
			${_target}
			PRIVATE
				QT_STRICT_ITERATORS
		)
	endif ()
endfunction ()

#[=======[
*/
/** @brief Setup a fresh `Qt` state.
	*
	* Calls at the end `twx_Qt_find()`
	* @param found for key `IN_VAR` is an optional list var name that
	* 	will hold on return the list of found components at its end.
	* 	When no variable name is provided, the found components are collected
	* 	in list variable `QT_LIBRARIES`.
	* @param `TEST` optional key, when provided and `/TWX/TESTING` is not set
	*   raise an error.
	*/
twx_Qt_fresh ( [IN_VAR found] [TEST] ) {}
/*
#]=======]
macro ( twx_Qt_fresh )
  cmake_parse_arguments ( twx_Qt_fresh "TEST" "IN_VAR" "" ${ARGN} )
	if ( "${twx_Qt_fresh_IN_VAR}" STREQUAL "" )
	  set ( twx_Qt_fresh_IN_VAR QT_LIBRARIES )
	endif ()
	set ( twx_Qt_fresh_UNPARSED_ARGUMENTS "${twx.R_UNPARSED_ARGUMENTS}" )
	set ( ${twx_Qt_fresh_IN_VAR} )
	twx_Qt_find ( REQUIRED Core IN_VAR ${twx_Qt_fresh_IN_VAR} )
	if ( "${QT_VERSION_MAJOR}" EQUAL "6" )
		twx_Qt_find ( REQUIRED Core5Compat IN_VAR ${twx_Qt_fresh_IN_VAR} )
	endif ()
	if ( WITH_TESTS OR /TWX/TESTING OR ${twx_Qt_fresh_TEST} )
		twx_Qt_find ( OPTIONAL Test IN_VAR ${twx_Qt_fresh_IN_VAR} )
		if ( NOT ${QtMAJOR}Test_FOUND )
			set ( WITH_TESTS OFF )
			set ( /TWX/TESTING OFF )
		endif ()
	endif ()
	if ( ${twx_Qt_fresh_TEST} AND NOT WITH_TESTS AND NOT /TWX/TESTING )
		twx_fatal ( "QTest is not available" )
	endif ()
	twx_Qt_find ( ${twx_Qt_fresh_UNPARSED_ARGUMENTS} IN_VAR ${twx_Qt_fresh_IN_VAR} )
	unset ( twx_Qt_fresh_IN_VAR )
	unset ( twx_Qt_fresh_TEST )
	unset ( twx_Qt_fresh_UNPARSED_ARGUMENTS )
endmacro ()

# ANCHOR: twx_Qt_link_libraries
#[=======[
*/
/** @brief Link the current Qt libraries to the given target.
	*
	* @param ... non empty list of valid target names.
	* @param PUBLIC, optional flag.
	*/
twx_Qt_link_libraries ( target ... [PUBLIC|INTERFACE|PRIVATE] ) {}
/*
#]=======]
function ( twx_Qt_link_libraries target_ )
	cmake_parse_arguments (
		PARSE_ARGV 1 twx.R
		"PUBLIC;PRIVATE;INTERFACE" "" ""
	)
	if ( twx.R_PUBLIC )
		twx_assert_false ( twx.R_PRIVATE )
		twx_assert_false ( twx.R_INTERFACE )
		set ( TYPE_ PUBLIC)
	elseif ( twx.R_PRIVATE )
		twx_assert_false ( twx.R_INTERFACE )
		twx_assert_false ( twx.R_PUBLIC )
		set ( TYPE_ PRIVATE )
	elseif ( twx.R_INTERFACE )
		twx_assert_false ( twx.R_PUBLIC )
		twx_assert_false ( twx.R_PRIVATE )
		set ( TYPE_ INTEFACE )
	endif ()
  foreach ( target_ IN LISTS twx.R_UNPARSED_ARGUMENTS )
	  twx_assert_target ( "${target_}" )
		target_link_libraries (
			"${target_}"
			${TYPE_} ${QT_LIBRARIES}
		)
	endforeach ()
endfunction (twx_Qt_link_libraries)

twx_Qt_find ( REQUIRED Core )

set ( QT_VERSION_MINOR "${${QtMAJOR}_VERSION_MINOR}" )
set ( QT_VERSION_PATCH "${${QtMAJOR}_VERSION_PATCH}" )

if ( NOT "${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}.${QT_VERSION_PATCH}" VERSION_LESS "5.6.0" )
	# Old Qt versions were heavily using 0 instead of nullptr, giving lots
	# of false positives
	include ( TwxWarningLib )
	twx_warning_add (
		-Wzero-as-null-pointer-constant
	)
endif ()
set ( QT_LIBRARIES )

message ( STATUS "TwxQtLib: Qt version ${QT_VERSION_MAJOR}" )
#*/
