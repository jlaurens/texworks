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
  * @param value, list of values concatenated in one list.
  * @param var for key `IN_VAR`, optional identifier of the var that will contain the result on return.
  *
  */
twx_global_set(value KEY key [IN_VAR var]){}
/*
#]=======]
function ( twx_global_set__ )
  twx_function_begin ()
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;IN_VAR" ""
  )
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  if ( ${TWX_CMD}.R_UNPARSED_ARGUMENTS STREQUAL "" )
    set_property (
      GLOBAL
      PROPERTY "${${TWX_CMD}.R_KEY}" "${/TWX/PLACEHOLDER/EMPTY_STRING}"
    )
  elseif ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS AND "${${TWX_CMD}.R_UNPARSED_ARGUMENTS}" STREQUAL "" )
    set_property (
      GLOBAL
      PROPERTY "${${TWX_CMD}.R_KEY}" "${/TWX/PLACEHOLDER/EMPTY_STRING}"
    )
  else ()
    set_property (
      GLOBAL
      PROPERTY "${${TWX_CMD}.R_KEY}" ${${TWX_CMD}.R_UNPARSED_ARGUMENTS}
    )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_IN_VAR )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
    set ( ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_UNPARSED_ARGUMENTS} PARENT_SCOPE )
  endif ()
endfunction ( twx_global_set__ )
macro ( twx_global_set )
  twx_global_set__ ( ${ARGV} ) 
endmacro ( twx_global_set )

# ANCHOR: twx_global_increment
#[=======[
*/
/** @brief Increment some global value.
  *
  * All values are meant to be integers.
  * The initial value is 0.
  *
  * @param key for key `KEY`, identifier of the value to modify.
  * @param step for key `STEP`, optional step, defaults to 1.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  *
  */
twx_global_increment(KEY key [STEP step] [IN_VAR var]){}
/*
#]=======]
function ( twx_global_increment )
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "KEY;STEP;IN_VAR" ""
  )
  if ( DEFINED twx.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${twx.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED twx.R_STEP )
    set ( twx.R_STEP 1 )
  endif ()
  twx_global_get__ ( KEY ${twx.R_KEY} IN_VAR v )
  if ( DEFINED v )
    math ( EXPR v "${v}+(${twx.R_STEP})" )
  else ()
    math ( EXPR v "${twx.R_STEP}" )
  endif ()
  twx_global_set__ ( "${v}" KEY ${twx.R_KEY} )
  if ( DEFINED twx.R_IN_VAR )
    twx_var_assert_name ( "${twx.R_IN_VAR}" )
    set ( ${twx.R_IN_VAR} "${v}" )
    return ( PROPAGATE ${twx.R_IN_VAR} )
  endif ()
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
twx_global_get([IN_VAR var] [KEY key]){}
/*
#]=======]
function ( twx_global_get__ )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;IN_VAR" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_IN_VAR )
    set ( ${TWX_CMD}.R_IN_VAR ${${TWX_CMD}.R_KEY} )
  elseif ( NOT DEFINED ${TWX_CMD}.R_KEY )
    set ( ${TWX_CMD}.R_KEY ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_KEY )
    twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
    get_property (
      ${${TWX_CMD}.R_IN_VAR}
      GLOBAL
      PROPERTY "${${TWX_CMD}.R_KEY}"
    )
    if ( ${${TWX_CMD}.R_IN_VAR} STREQUAL "" )
      set ( ${${TWX_CMD}.R_IN_VAR} )
    elseif ( DEFINED ${${TWX_CMD}.R_IN_VAR} )
      twx_const_empty_string_decode ( VAR ${${TWX_CMD}.R_IN_VAR} )
    endif ()
    return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} )
  else ()
    message ( FATAL_ERROR "Missing argument for key `KEY` or `IN_VAR`" )
  endif ()
endfunction ( twx_global_get__ )
macro ( twx_global_get )
  twx_global_get__ ( ${ARGV} )
endmacro ( twx_global_get )

# ANCHOR: twx_global_append
#[=======[
*/
/** @brief Append some values to a global list.
  *
  * @param ..., list of values.
  * @param key for key `KEY`, identifier of the list to modify.
  * @param NO_DUPLICATE, optional flag, raises the element is already in the list.
  * @param msg for key `ERROR_MSG`, optional message. More specific error message used when raising.
  * @param var for key `IN_LIST`, optional name of a variable where the resulting list
  *   is stored.
  *
  */
twx_global_append(... KEY key [NO_DUPLICATE] [ERROR_MSG msg] [IN_LIST var]){}
/*
#]=======]
function ( twx_global_append )
  twx_function_begin ()
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;NO_DUPLICATE;ERROR_MSG;IN_LIST" ""
  )
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_global_get__ (
    IN_VAR ${TWX_CMD}.LIST
    KEY "${${TWX_CMD}.R_KEY}"
  )
  if ( DEFINED ${TWX_CMD}.R_NO_DUPLICATE )
    foreach ( X IN LISTS ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
      if ( X IN_LIST ${TWX_CMD}.LIST )
        if ( DEFINED ${TWX_CMD}.R_ERROR_MSG )
          message ( FATAL_ERROR "${${TWX_CMD}.R_ERROR_MSG}" )
        else ()
          message ( FATAL_ERROR "No duplicate: ${X}" )
        endif ()
      else ()
        list ( APPEND ${TWX_CMD}.LIST "${X}" )
      endif ()
    endforeach ()
  elseif ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    list ( APPEND ${TWX_CMD}.LIST ${${TWX_CMD}.R_UNPARSED_ARGUMENTS} )
  endif ()
  twx_global_set__ (
    "${${TWX_CMD}.LIST}"
    KEY "${${TWX_CMD}.R_KEY}"
  )
  if ( DEFINED ${TWX_CMD}.R_IN_LIST )
    set ( ${${TWX_CMD}.R_IN_LIST} "${${TWX_CMD}.LIST}" PARENT_SCOPE )
  endif ()
endfunction ( twx_global_append )

# ANCHOR: twx_global_remove
#[=======[
*/
/** @brief Remove some values from a global list.
  *
  * @param ..., list of values to remove.
  * @param key for key `KEY`, identifier of the list to modify.
  * @param var for key `IN_LIST`, optional name of a variable where the resulting list
  *   is stored.
  *
  */
twx_global_remove(... KEY key [IN_LIST var]){}
/*
#]=======]
function ( twx_global_remove )
  twx_function_begin ()
  # NO: list ( APPEND CMAKE_MESSAGE_CONTEXT "twx_fatal" )
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "KEY;IN_LIST" ""
  )
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_global_get__ (
    IN_VAR ${TWX_CMD}.LIST
    KEY "${${TWX_CMD}.R_KEY}"
  )
  foreach ( X IN LISTS ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    list ( REMOVE_ITEM ${TWX_CMD}.LIST ${X} )
  endforeach ()
  if ( DEFINED ${TWX_CMD}.LIST )
    twx_global_set__ (
      "${${TWX_CMD}.LIST}"
      KEY "${${TWX_CMD}.R_KEY}"
    )
  else ()
    twx_global_set__ (
      KEY "${${TWX_CMD}.R_KEY}"
    )
  endif ()

  twx_global_get__ (
    IN_VAR ${TWX_CMD}.X
    KEY "${${TWX_CMD}.R_KEY}"
  )
  if ( DEFINED ${TWX_CMD}.R_IN_LIST )
    set ( ${${TWX_CMD}.R_IN_LIST} ${${TWX_CMD}.LIST} PARENT_SCOPE )
  endif ()
endfunction ( twx_global_remove )

# ANCHOR: twx_global_get_back
#[=======[
*/
/** @brief Get the last value of a global list.
  *
  * @param key for key `KEY`, identifier of the list to modify.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  * @param list for key `IN_LIST`, optional name of a variable where the whole list
  *   is stored.
  *
  */
twx_global_get_back([IN_VAR var] [KEY key] [REQUIRED] [IN_LIST list]){}
/*
#]=======]
function ( twx_global_get_back )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "REQUIRED" "KEY;IN_VAR;IN_LIST" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  if ( NOT DEFINED ${TWX_CMD}.R_IN_VAR )
    set ( ${TWX_CMD}.R_IN_VAR ${${TWX_CMD}.R_KEY} )
  elseif ( NOT DEFINED ${TWX_CMD}.R_KEY )
    set ( ${TWX_CMD}.R_KEY ${${TWX_CMD}.R_IN_VAR} )
  endif ()
  if ( DEFINED ${TWX_CMD}.R_KEY )
    twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
    twx_global_get__ (
      IN_VAR ${TWX_CMD}.LIST
      KEY "${${TWX_CMD}.R_KEY}"
    )
    if ( "${${TWX_CMD}.LIST}" STREQUAL "" )
      if ( ${TWX_CMD}.R_REQUIRED )
        message ( FATAL_ERROR "Missing global ``${${TWX_CMD}.R_KEY}''" )
      endif ()
      set ( ${${TWX_CMD}.R_IN_VAR} )
    else ()
      list ( GET ${TWX_CMD}.LIST -1 ${${TWX_CMD}.R_IN_VAR} )
    endif ()
    if ( DEFINED ${TWX_CMD}.R_IN_LIST )
      twx_var_assert_name ( "${${TWX_CMD}.R_IN_LIST}" )
      set ( ${${TWX_CMD}.R_IN_LIST} "${TWX_CMD}.LIST" )
    endif ()
    return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_IN_LIST} )
  else ()
    message ( FATAL_ERROR "Missing argument for key `KEY` or `IN_VAR`" )
  endif ()
endfunction ( twx_global_get_back )

# ANCHOR: twx_global_pop_back
#[=======[
*/
/** @brief Pop the last value of a global list.
  *
  * @param key for key `KEY`, identifier of the list to retrieve.
  * @param var for key `IN_VAR`, identifier of the var that will contain the result on return.
  * @param REQUIRED, optional flag, raises when set and the property does not exist.
  * @param list for key `IN_LIST`, optional name of a variable where the whole list
  *   is stored.
  *
  */
twx_global_pop_back(IN_VAR var KEY key [REQUIRED]){}
/*
#]=======]
function ( twx_global_pop_back )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "REQUIRED" "KEY;IN_VAR;IN_LIST" ""
  )
  if ( DEFINED ${TWX_CMD}.R_UNPARSED_ARGUMENTS )
    message ( FATAL_ERROR "Bad usage: UNPARSED_ARGUMENTS -> ``${${TWX_CMD}.R_UNPARSED_ARGUMENTS}''" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_KEY}" )
  twx_global_get__ (
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
  twx_global_set__ (
    "${${TWX_CMD}.LIST}"
    KEY "${${TWX_CMD}.R_KEY}"
  )
  if ( DEFINED ${TWX_CMD}.R_IN_LIST )
    twx_var_assert_name ( "${${TWX_CMD}.R_IN_LIST}" )
    set ( ${${TWX_CMD}.R_IN_LIST} "${TWX_CMD}.LIST" )
  endif ()
  return ( PROPAGATE ${${TWX_CMD}.R_IN_VAR} ${${TWX_CMD}.R_IN_LIST} )
endfunction ( twx_global_pop_back )

twx_lib_require ( Var Cmd )

twx_lib_did_load ()

#*/
