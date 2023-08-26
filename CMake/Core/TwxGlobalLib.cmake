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

# ANCHOR: twx_global_append
#[=======[
*/
/** @brief Append some values to a global list.
  *
  * @param id for key `ID`, identifier of the list to modify.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  * @param msg for key `DUPLICATE`, optional message. When provided,
  *   raises with the given message when the list contain duplicate entries before the return statement.
  * @param ..., list of values.
  *
  */
twx_global_append(... ID id [REQUIRED] [DUPLICATE msg]){}
/*
#]=======]
function ( twx_global_append )
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "ID;DUPLICATE" ""
  )
  twx_var_assert_name ( "${twx.R_ID}" )
  get_property (
    list_
    GLOBAL
    PROPERTY "${twx.R_ID}"
  )
  if ( DEFINED twx.R_DUPLICATE )
    foreach ( item_ ${twx.R_UNPARSED_ARGUMENTS} )
      if ( item_ IN_LIST list_ )
        message ( FATAL_ERROR "${twx.R_CIRCULAR}" )
      else ()
        list ( APPEND list_ "${item_}" )
      endif ()
    endforeach ()
  else ()
    list ( list_ ${twx.R_UNPARSED_ARGUMENTS} )
  endif ()
  set_property (
    GLOBAL
    PROPERTY "${twx.R_ID}" "${list_}"
  )
endfunction ( twx_global_append )

# ANCHOR: twx_global_pop_back
#[=======[
*/
/** @brief Pop the last value of a global list.
  *
  * @param id for key `ID`, identifier of the list to modify.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  *
  */
twx_global_pop_back(... ID id []){}
/*
#]=======]
function ( twx_global_pop_back )
  twx_cmd_begin ( ${CMAKE_FUNCTION_NAME} )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "REQUIRED" "ID;IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS => ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_ID}" )
  get_property (
    ${TWX_CMD}.LIST
    GLOBAL
    PROPERTY "${${TWX_CMD}.R_ID}"
  )
  if ( ${TWX_CMD}.R_REQUIRED AND NOT DEFINED ${TWX_CMD}.LIST )
    message ( FATAL_ERROR "Missing global ``${${TWX_CMD}.R_ID}''" )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_IN_VAR )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  endif ()
  list ( POP_BACK ${TWX_CMD}.LIST ${TWX_CMD}.R_IN_VAR )
  set_property (
    GLOBAL
    PROPERTY "${${TWX_CMD}.R_ID}" "${${TWX_CMD}.LIST}"
  )
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
endfunction ( twx_global_pop_back )

twx_lib_require ( Var Cmd )

twx_lib_did_load ()

#*/
