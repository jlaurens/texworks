#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Global utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxGlobalLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_global_append()`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_global_set
#[=======[
*/
/** @brief Set some global value.
  *
  * @param key for key `KEY`, identifier of the value to modify.
  * @param ..., list of values concatenated in one string.
  *
  */
twx_global_set(... KEY key){}
/*
#]=======]
function ( twx_global_set )
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "KEY" ""
  )
  twx_var_assert_name ( "${twx.R_KEY}" )
  set ( value_ )
  foreach ( v ${twx.R_UNPARSED_ARGUMENTS})
    string ( APPEND value_ "${v}" )
  endforeach ()
  set_property (
    GLOBAL
    PROPERTY "${twx.R_KEY}" ${value_}
  )
endfunction ( twx_global_set )

# ANCHOR: twx_global_increment
#[=======[
*/
/** @brief Set some global value.
  *
  * @param key for key `KEY`, identifier of the value to modify.
  *
  */
twx_global_increment(KEY key){}
/*
#]=======]
function ( twx_global_increment )
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "KEY" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_global_get ( KEY ${twx.R_KEY} IN_VAR v )
  if ( DEFINED v )
    math ( EXPR v "${v}+1" )
  else ()
    set ( v 1 )
  endif ()
  twx_global_set ( "${v}" KEY ${twx.R_KEY} )
endfunction ( twx_global_increment )

# ANCHOR: twx_global_get
#[=======[
*/
/** @brief Get a global value.
  *
  * @param key for key `KEY`, identifier of the value to retrieve.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  *
  */
twx_global_get(IN_VAR var KEY key){}
/*
#]=======]
function ( twx_global_get )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_KEY AND NOT DEFINED ${TWX_CMD}.R_IN_VAR )
    message ( FATAL_ERROR "Missing argument for key `KEY` or `IN_VAR`" )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_IN_VAR )
    set ( ${TWX_CMD}.R_IN_VAR ${${TWX_CMD}.R_KEY} )
  elseif ( NOT DEFINED ${TWX_CMD}.R_KEY )
    set ( ${TWX_CMD}.R_KEY ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  get_property (
    ${${TWX_CMD}.R_IN_VAR}
    GLOBAL
    PROPERTY "${${TWX_CMD}.R_KEY}"
  )
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
endfunction ( twx_global_get )


# ANCHOR: twx_global_append
#[=======[
*/
/** @brief Append some values to a global list.
  *
  * @param key for key `KEY`, identifier of the list to modify.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  * @param msg for key `DUPLICATE`, optional message. When provided,
  *   raises with the given message when the list contain duplicate entries before the return statement.
  * @param ..., list of values.
  *
  */
twx_global_append(... KEY key [REQUIRED] [DUPLICATE msg]){}
/*
#]=======]
function ( twx_global_append )
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "KEY;DUPLICATE" ""
  )
  twx_var_assert_name ( "${twx.R_KEY}" )
  get_property (
    list_
    GLOBAL
    PROPERTY "${twx.R_KEY}"
  )
  if ( DEFINED twx.R_DUPLICATE )
    foreach ( item_ ${twx.R_UNPARSED_ARGUMENTS} )
      if ( item_ IN_LIST list_ )
        message ( FATAL_ERROR "${twx.R_CIRCULAR}" )
      else ()
        list ( APPEND list_ "${item_}" )
      endif ()
    endforeach ()
  elseif ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    list ( APPEND list_ ${twx.R_UNPARSED_ARGUMENTS} )
  endif ()
  set_property (
    GLOBAL
    PROPERTY "${twx.R_KEY}" "${list_}"
  )
endfunction ( twx_global_append )

# ANCHOR: twx_global_get_back
#[=======[
*/
/** @brief Get the last value of a global list.
  *
  * @param key for key `KEY`, identifier of the list to modify.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  *
  */
twx_global_get_back(IN_VAR var KEY key [REQUIRED]){}
/*
#]=======]
function ( twx_global_get_back )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "REQUIRED" "KEY;IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  get_property (
    ${TWX_CMD}.LIST
    GLOBAL
    PROPERTY "${${TWX_CMD}.R_KEY}"
  )
  if ( "${${TWX_CMD}.LIST}" STREQUAL "" )
    if ( ${TWX_CMD}.R_REQUIRED )
      message ( FATAL_ERROR "Missing global ``${${TWX_CMD}.R_KEY}''" )
    endif ()
    set ( ${${TWX_CMD}.R_IN_VAR} )
  else ()
    list ( GET ${TWX_CMD}.LIST -1 ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
endfunction ( twx_global_get_back )

# ANCHOR: twx_global_pop_back
#[=======[
*/
/** @brief Pop the last value of a global list.
  *
  * @param key for key `KEY`, identifier of the list to retrieve.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  *
  */
twx_global_pop_back(IN_VAR var KEY key [REQUIRED]){}
/*
#]=======]
function ( twx_global_pop_back )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "REQUIRED" "KEY;IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_global_get (
    IN_VAR ${TWX_CMD}.LIST
    KEY "${${TWX_CMD}.R_KEY}"
  )
  if ( "${${TWX_CMD}.LIST}" STREQUAL "" )
    if ( ${TWX_CMD}.R_REQUIRED )
      message ( FATAL_ERROR "Missing global ``${${TWX_CMD}.R_KEY}''" )
    endif ()
    if ( DEFINED ${TWX_CMD}.R_IN_VAR )
      twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
      set ( ${${TWX_CMD}.R_IN_VAR} )
    endif ()
  else ()
    if ( DEFINED ${TWX_CMD}.R_IN_VAR )
      twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
    endif ()
    list ( POP_BACK ${TWX_CMD}.LIST ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  twx_global_set (
    "${${TWX_CMD}.LIST}"
    KEY "${${TWX_CMD}.R_KEY}"
  )
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
endfunction ( twx_global_pop_back )

twx_lib_require ( Var Cmd )

twx_lib_did_load ()

#*/
