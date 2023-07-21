#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  State
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxStateLib.cmake"
  *   )
  *
  * or
  *
  *   include ( TwxStateLib )
  *
  * when based.
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

# ANCHOR: twx_state_key_add ()
#[=======[
/** @brief Register state keys
  *
  * @param ... for key KEY, non empty list of keys.
  */
twx_state_key_add(KEY ...) {}
/*#]=======]
set (
  TWX_STATE_KEYS
  TWX_TEST TWX_DEV
)
function ( twx_state_key_add .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_assert_variable_name ( "${k}" )
    list ( APPEND TWX_STATE_KEYS "${k}" )
    twx_increment_and_break_if ( VAR i == ${ARGC} )
  endwhile ()
  list ( REMOVE_DUPLICATES TWX_STATE_KEYS )
  twx_export ( TWX_STATE_KEYS )
endfunction ()

# ANCHOR: twx_state_key_remove ()
#[=======[
/** @brief Unregister state keys
  *
  * @param ... for key KEY, non empty list of keys.
  */
twx_state_key_remove(KEY ...) {}
/*#]=======]
function ( twx_state_key_remove .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_assert_variable_name ( "${k}" )
    list ( REMOVE_ITEM TWX_STATE_KEYS "${k}" )
    twx_increment_and_break_if ( VAR i == ${ARGC} )
  endwhile ()
  twx_export ( TWX_STATE_KEYS )
endfunction ()

# ANCHOR: twx_state_will_serialize_register ()
#[=======[
/** @brief Register a preparation.
  *
  * @param ... non empty list of command names.
  * These commands will be called before each serialization.
  * No argument.
  */
twx_state_will_serialize_register(...) {}
/*#]=======]
set ( TWX_STATE_PREPARATION )
function ( twx_state_will_serialize_register .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_assert_variable_name ( "${k}" )
    twx_hook_register ( ID TwxStateLib_will_serialize "${k}" )
    twx_increment_and_break_if ( VAR i == ${ARGC} )
  endwhile ()
  twx_hook_export ()
endfunction ()

# ANCHOR: twx_state_serialize ()
#[=======[
/** @brief Serialize the current state
  *
  * Serialize the current state into variable `-DTWX_STATE`.
  * To forward the current state to CMake `-P` commands.
  * See the balancing `twx_state_deserialize ()`.
  *
  * @param var for key IN_VAR, optional var holding the result
  */
twx_state_serialize([IN_VAR var]) {}
/*#]=======]
function ( twx_state_serialize )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_state_serialize )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "IN_VAR" ""
  )
  twx_arg_assert_parsed ()
  twx_tree_init ( state_ )
  twx_hook_call ( ID TwxStateLib_will_serialize )
  foreach ( k_ ${TWX_STATE_KEYS} )
    twx_tree_set ( TREE state_ "${k_}=${${k_}}" )
  endforeach ()
  if ( DEFINED twx.R_IN_VAR )
    set ( ${twx.R_IN_VAR} "${state_}" PARENT_SCOPE )
  endif ()
  set ( -DTWX_STATE "-DTWX_STATE=${state_}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_state_deserialize ()
#[=======[
/** @brief Deserialize to the current state
  *
  * To forward the current state to CMake `-P` commands.
  * Deserialize the `TWX_STATE` variable into the current state.
  * See the balancing `twx_state_serialize ()`.
  * @param state, optional string modelling the state.
  * Defaults to the contents of the `TWX_STATE` variable.
  */
twx_state_deserialize([state]) {}
/*#]=======]
macro ( twx_state_deserialize )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_state_deserialize )
  if ( ${ARGC} EQUAL "1" )
    set ( twx_state_deserialize.name "${ARGV0}" )
  else ()
    twx_arg_assert_count ( ${ARGC} == 0 )
    set ( twx_state_deserialize.name "TWX_STATE" )
  endif ()
  # message ( TR@CE "WILL DESERIALIZE" )
  twx_tree_expose ( TREE "${twx_state_deserialize.name}" )
  set ( twx_state_deserialize.name )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

twx_lib_require ( "Core" "Tree" "Hook" "Arg" )

twx_state_key_add (
  TWX_TEST_SUITE_LIST
)
if ( COMMAND TwxTestLib_state_prepare )
  twx_state_will_serialize_register ( TwxTestLib_state_prepare )
endif ()

twx_state_key_add (
  CMAKE_MESSAGE_INDENT
  CMAKE_MESSAGE_LOG_LEVEL
  CMAKE_MESSAGE_CONTEXT
  CMAKE_MESSAGE_CONTEXT_SHOW
)

function ( TwxInclude_state_prepare )
  cmake_language ( GET_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  twx_export ( CMAKE_MESSAGE_LOG_LEVEL )
endfunction ()

message ( DEBUG "TwxStateLib loaded" )

#*/
