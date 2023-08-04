#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Convenient shortcuts to manage warnings.
  *
  * Usage:
  *
  *   include ( TwxWarningLib )
  *
  * Warnings are target compile options.
  * They make sense for executable and libraries.
  * We have different targets that may share the same compile options.
  * CMake offers different designs for that:
  * - add compile options to directories
  * - manage a global list and add it to the target
  * In the first case, the "when" is not documented AFAIK:
  * when does a target queries enclosing directories for compile options?
  * at declaration time? at build time?
  * 
  * Actually, things are straightforward: we define compile options
  * and we add them to the target at declaration time.
  * Adding options to directory has not been explored.
  */
/** @brief Adapted to each compiler.
  *
  * Values are reset to factory defaults
  * each time the script is included.
*/
TWX_WARNING_OPTIONS;
/*
#]===============================================]

# ANCHOR: twx_warning_add
#[=======[
*/
/** @brief add the given warning options
  *
  * When a target is not provided, the list of warnings is appended
  * to the recoreded warnings. When a target is provided:
  * - if the list of warnings is not empty, add it to the target
  * - if the list is empty, add to the target all the recorded warnings so far.
  * 
  * @param ... list of warning options like `-W...`
  * @param target for key `TARGET`, optional existing target.
  */
twx_warning_add ( ... [TARGET target]) {}
/*
#]=======]
function ( twx_warning_add )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_warning_contains" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "TARGET" ""
  )
  if ( DEFINED twx.R_TARGET )
    twx_assert_target ( "${twx.R_TARGET}" )
    if ( NOT twx.R_UNPARSED_ARGUMENTS STREQUAL "" )
      set ( TWX_WARNING_OPTIONS "${twx.R_UNPARSED_ARGUMENTS}" )
    endif ()
    target_compile_options (
      ${twx.R_TARGET}
      PRIVATE ${TWX_WARNING_OPTIONS}
    )
    return ()
  endif ()
  twx_arg_assert_count ( ${ARGC} > 0 )
  list (
    APPEND TWX_WARNING_OPTIONS
    ${ARGN}
  )
  list ( REMOVE_DUPLICATES TWX_WARNING_OPTIONS )
  return ( PROPAGATE TWX_WARNING_OPTIONS )
endfunction ()

# ANCHOR: TWX_WARNING_OPTIONS
#[=======[
# Initialize `TWX_WARNING_OPTIONS`
#]=======]
if ( NOT DEFINED TWX_WARNING_OPTIONS )
  if (MSVC)
    twx_warning_add ( /W4 )
  else ()
    twx_warning_add (
      -Wall -Wpedantic -Wextra -Wconversion
      -Wold-style-cast -Woverloaded-virtual
    )
  endif ()
endif ()

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_warning_remove
#[=======[
*/
/** @brief Remove the given warning options
  *
  * @param ... list of warning options like `-W...`.
  *   When this list is empty, all options are removed.
  */
twx_warning_remove ( ... ) {}
/*
#]=======]
function ( twx_warning_remove )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_warning_contains" )
  if ( ARGN STREQUAL "" )
    set ( TWX_WARNING_OPTIONS )
  else ()
    list (
      REMOVE_ITEM TWX_WARNING_OPTIONS
      ${ARGN}
    )
  endif ()
  return ( PROPAGATE TWX_WARNING_OPTIONS )
endfunction ()

# ANCHOR: twx_warning_contains
#[=======[
*/
/** @brief Whether a warning option was added
  *
  * Mainly for testing purposes.
  *
  * @param warning, the actual warning to test
  * @param target for key `TARGET`, optional existing target.
  * @param var for key `IN_VAR`, on return holds `TRUE`
  *  if the warning was added to <target> or globally, `FALSE` otherwise.
  */
twx_warning_contains(warning [TARGET target] IN_VAR var) {}
/*
#]=======]
function ( twx_warning_contains )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_warning_contains" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "TARGET;IN_VAR" ""
  )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  if ( NOT "${twx.R_TARGET}" STREQUAL "" )
    twx_assert_target ( "${twx.R_TARGET}" )
    get_target_property( TWX_WARNING_OPTIONS "${twx.R_TARGET}" COMPILE_OPTIONS )
    if ( TWX_WARNING_OPTIONS MATCHES "NOTFOUND$" )
      set ( TWX_WARNING_OPTIONS )
    endif ()
  endif ()
  set ( ${twx.R_IN_VAR} TRUE PARENT_SCOPE )
  if ( NOT "${twx.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    foreach ( option_ ${twx.R_UNPARSED_ARGUMENTS} )
      if ( NOT option_ IN_LIST TWX_WARNING_OPTIONS )
        set ( ${twx.R_IN_VAR} FALSE PARENT_SCOPE )
        return ()
      endif ()
    endforeach ()
  endif ()
endfunction ()

# ANCHOR: twx_warning_target
#[=======[
*/
/** @brief Set warning options to the given target
  *
  * @param target the name of an existing target
  */
twx_warning_target(target) {}
/*
#]=======]
function ( twx_warning_target target_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_warning_contains" )
  twx_assert_target ( "${target_}" )
  target_compile_options (
    ${target_}
    PRIVATE ${TWX_WARNING_OPTIONS}
  )
endfunction ()

twx_lib_require ( Assert )

twx_lib_did_load ()

#*/
