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
twx_lib_will_load ()

# block ( PROPAGATE /TWX/STATE/PLACEHOLDER/SEMI_COLON /TWX/STATE/PLACEHOLDER/SOLIDUS ) 
#   string(ASCII 02 /TWX/CHAR/STX )
#   string(ASCII 03 /TWX/CHAR/ETX )
#   set (
#     /TWX/STATE/PLACEHOLDER/SEMI_COLON
#     "${/TWX/CHAR/STX}SEMI_COLON${/TWX/CHAR/ETX}"
#   )
#   set (
#     /TWX/STATE/PLACEHOLDER/SOLIDUS
#     "${/TWX/CHAR/STX}SOLIDUS${/TWX/CHAR/ETX}"
#   )
# endblock ()

# ANCHOR: twx_state_key_add ()
#[=======[
/** @brief Register state keys
  *
  * @param ... for key KEY, non empty list of keys.
  */
twx_state_key_add(KEY ...) {}
/*#]=======]
set (
  /TWX/STATE/KEYS
  ${/TWX/STATE/PLACEHOLDER/SOLIDUS}TWX${/TWX/STATE/PLACEHOLDER/SOLIDUS}TESTING
  ${/TWX/STATE/PLACEHOLDER/SOLIDUS}TWX${/TWX/STATE/PLACEHOLDER/SOLIDUS}DEV
)
function ( twx_state_key_add .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_var_assert_name ( "${k}" )
    string ( REPLACE "/" "${/TWX/STATE/PLACEHOLDER/SOLIDUS}" k "${k}" )
    list ( APPEND /TWX/STATE/KEYS "${k}" )
    twx_increment_and_break_if ( VAR i == ${ARGC} )
  endwhile ()
  list ( REMOVE_DUPLICATES /TWX/STATE/KEYS )
  twx_export ( /TWX/STATE/KEYS )
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
    twx_var_assert_name ( "${k}" )
    string ( REPLACE "/" "${/TWX/STATE/PLACEHOLDER/SOLIDUS}" k "${k}" )
    list ( REMOVE_ITEM /TWX/STATE/KEYS "${k}" )
    twx_increment_and_break_if ( VAR i == ${ARGC} )
  endwhile ()
  twx_export ( /TWX/STATE/KEYS )
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
function ( twx_state_will_serialize_register .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_var_assert_name ( "${k}" )
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
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_state_serialize.R
    "" "IN_VAR" ""
  )
  twx_arg_assert_parsed ()
  twx_tree_init ( TREE state_ )
  twx_hook_call ( ID TwxStateLib_will_serialize )
  foreach ( k_ ${/TWX/STATE/KEYS} )
    twx_tree_set ( TREE state_ "${k_}=${${k_}}" )
  endforeach ()
  # string ( REPLACE ";" "${/TWX/STATE/PLACEHOLDER/SEMI_COLON}" state_ "${state_}" )
  if ( DEFINED twx_state_serialize.R_IN_VAR )
    set ( ${twx_state_serialize.R_IN_VAR} "${state_}" PARENT_SCOPE )
  endif ()
  set ( -D/TWX/STATE "-D/TWX/STATE=${state_}" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_state_deserialize ()
#[=======[
/** @brief Deserialize to the current state
  *
  * To forward the current state to CMake `-P` commands.
  * Deserialize the `TWX_STATE` variable into the current state.
  * See the balancing `twx_state_serialize ()`.
  * @param state, optional name of a variable modelling the state.
  *   Defaults to `TWX_STATE`.
  */
twx_state_deserialize([state]) {}
/*#]=======]
macro ( twx_state_deserialize )
  twx_function_begin ()
  # Argument may be a variable name: avoid collision
  if ( ${ARGC} EQUAL "1" )
    set ( twx_state_deserialize.x "${ARGV0}" )
  else ()
    twx_arg_assert_count ( ${ARGC} == 0 )
    set ( twx_state_deserialize.x "TWX_STATE" )
  endif ()
  # message ( TR@CE "WILL DESERIALIZE" )
  # string ( REPLACE "${/TWX/STATE/PLACEHOLDER/SEMI_COLON}" ";" twx_state_deserialize.x "${${twx_state_deserialize.x}}" )
  twx_tree_assert ( TREE "${twx_state_deserialize.x}" )
  twx_tree_expose ( TREE "${twx_state_deserialize.x}" )
  set ( twx_state_deserialize.x )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

twx_lib_require ( "Core" "Tree" "Hook" "Arg" )

twx_state_key_add (
  /TWX/TEST/DOMAIN.NAME
  /TWX/TEST/SUITE_STACK
  /TWX/TEST/UNIT.NAME
  CMAKE_MESSAGE_INDENT
  CMAKE_MESSAGE_LOG_LEVEL
  CMAKE_MESSAGE_CONTEXT
  CMAKE_MESSAGE_CONTEXT_SHOW
)

if ( COMMAND TwxTestLib_state_prepare )
  twx_state_will_serialize_register ( TwxTestLib_state_prepare )
endif ()

function ( TwxInclude_state_prepare )
  cmake_language ( GET_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  twx_export ( CMAKE_MESSAGE_LOG_LEVEL )
endfunction ()

twx_lib_did_load ()

#*/
