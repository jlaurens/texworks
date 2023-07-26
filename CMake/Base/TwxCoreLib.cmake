#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Collection of core utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxCoreLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_fatal()`
  * - `twx_regex_escape()`
  *
  * Testing utilities:
  * - `twx_fatal_catched()`
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# ANCHOR: twx_regex_escape ()
#[=======[
/** @brief Escape strings to be used in regular expression
  *
  * @param ... non empty list of strings
  * @param var for key `IN_VAR`, the variable named <var> will hold the result on return
  */
twx_regex_escape(... IN_VAR var ) {}
/*#]=======]

set ( twx_regex_escape_RE [=[[]()|?+*[\\.$^-]]=] )

function ( twx_regex_escape .text .IN_VAR .var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_regex_escape )
  cmake_parse_arguments ( PARSE_ARGV 1 twx.R "" "IN_VAR" "" )
  if ( NOT DEFINED twx.R_IN_VAR )
    twx_fatal ( "Missing IN_VAR argument.")
    return ()
  endif ()
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  set ( m )
  set ( i 0 )
  while ( TRUE )
    if ( "${ARGV${i}}" STREQUAL "IN_VAR" )
      math ( EXPR i "${i}+2" )
      if ( "${i}" LESS ${ARGC} )
        twx_fatal ( "Unexpected argument: ${ARGV${i}}")
        return ()
      endif ()
      break ()
    endif ()
    # message ( TR@CE "IN => ``${ARGV${i}}''" )
    string (
      REGEX REPLACE "([]()|?+*[\\\\.$^-])" "\\\\\\1"
      out_
      "${ARGV${i}}"
    )
    # message ( TR@CE "OUT => ``${out_}''" )
    list ( APPEND m "${out_}" )
    math ( EXPR i "${i}+1" )
    if ( "${i}" GREATER_EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ()
  set ( "${twx.R_IN_VAR}" "${m}" PARENT_SCOPE )
endfunction ()

#[=======[ Paths setup
This is called from various locations.
We cannot assume that `PROJECT_SOURCE_DIR` always represent
the same location, in particular when called from a module
or a sub code unit. The same holds for `CMAKE_SOURCE_DIR`.
`TWX_DIR` is always "at the top" because it is defined
relative to this included file.
#]=======]
get_filename_component (
  TWX_DIR
  "${CMAKE_CURRENT_LIST_DIR}/../../"
  REALPATH
)

# ANCHOR: twx_complete_dir_var
#[=======[*/
/** @brief Complete dir variables contents.
  *
  * When the variable is not empty, ensures that it ends with a `/`.
  * The resulting path may not exists though.
  *
  * @param ..., non empty list of string variables containing locations of directories.
  *
  */
twx_complete_dir_var(...) {}
/*
Implementation details:
The argument are IO variable names, such that we must name local variables with great care,
otherwise there might be a conflict.
#]=======]
function ( twx_complete_dir_var twx_complete_dir_var.var )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_complete_dir_var )
  set ( twx_complete_dir_var.i 0 )
  while ( TRUE )
    set ( twx_complete_dir_var.v "${ARGV${twx_complete_dir_var.i}}" )
    # message ( TR@CE "v => ``${twx_complete_dir_var.v}''")
    twx_assert_variable_name ( "${twx_complete_dir_var.v}" )
    twx_assert_defined ( "${twx_complete_dir_var.v}" )
    set ( twx_complete_dir_var.w "${${twx_complete_dir_var.v}}" )
    if ( NOT "${twx_complete_dir_var.w}" STREQUAL "" AND NOT "${twx_complete_dir_var.w}" MATCHES "/$" )
      set ( "${twx_complete_dir_var.v}" "${twx_complete_dir_var.w}/" PARENT_SCOPE )
    endif ()
    math ( EXPR twx_complete_dir_var.i "${twx_complete_dir_var.i}+1" )
    if ( twx_complete_dir_var.i GREATER_EQUAL ${ARGC} )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_complete_dir_var )

twx_lib_require ( "Fatal" "Assert" "Expect" )

twx_complete_dir_var ( TWX_DIR )

#[=======[ setup `CMAKE_MODULE_PATH`
Make the contents of `CMake/Base` and `CMake/Modules` available.
The former contains tools and utilities whereas
the latter only contains modules at a higher level.
]=======]
list (
  INSERT CMAKE_MODULE_PATH 0
  "${TWX_DIR}CMake/Base"
  "${TWX_DIR}CMake/Include"
  "${TWX_DIR}CMake/Modules"
)
list ( REMOVE_DUPLICATES CMAKE_MODULE_PATH )

twx_lib_did_load ()

#*/
