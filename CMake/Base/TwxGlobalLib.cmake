#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Global storage.
  *
  * A layer above the tree.
  *
  * Usage:
  *
  *  include ( TwxGlobalLib )
  *
  * This is a partial answer to the problem of returned values.
  * That way we can store data in custom target properties with dynamic keys.
  * We can also return values from functions in a more friendly way.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

if ( TARGET TwxGlobalLib.cmake )
  return ()
elseif ( CMAKE_SCRIPT_MODE_FILE )
  message ( DEBUG "TwxGlobalLib not available in script mode" )
  return ()
endif ()

add_custom_target (
  TwxGlobalLib.cmake
)

define_property (
  TARGET PROPERTY TWX_GLOBAL_TREE/
)

# ANCHOR: twx_global_save
#[=======[
*/
/** @brief Save the current tree to the global storage
  *
  * Mainly for internal use.
  *
  * @param tree for key TREE, the required name of a tree.
  *   The variable must refer to a tree. Its contents will replace
  *   the whole previously stored values.
  */
twx_global_save(TREE tree) {}
/*
#]=======]
function ( twx_global_save .TREE twx.R_TREE )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_save )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_arg_assert_keyword ( .TREE )
  twx_tree_assert ( "${twx.R_TREE}" )
  set_target_properties (
    TwxGlobalLib.cmake
    PROPERTIES
      TWX_GLOBAL_TREE/ "${${twx.R_TREE}}"
  )
  # twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m ) 
  # message ( TR@CE "${twx.R_TREE} => \"${m}\"" )
endfunction ()

# ANCHOR: twx_global_clear
#[=======[
*/
/** @brief Clear the global storage
  *
  * Mainly for internal use.
  *
  */
twx_global_clear() {}
/*
#]=======]
function ( twx_global_clear )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_clear )
  twx_arg_assert_count ( ${ARGC} == 0 )
  twx_tree_init ( tree/ )
  set_target_properties (
    TwxGlobalLib.cmake
    PROPERTIES
      TWX_GLOBAL_TREE/ "${tree/}"
  )
endfunction ()

# ANCHOR: twx_global_restore
#[=======[
*/
/** @brief Restore the global storage
  *
  * @param tree for key IN_TREE, the required name for a tree.
  * Define properly variables:
  *
  * - `<tree>`
  * - `TWX_IS_TREE_<tree>` is set to `ON`.
  *
  */
twx_global_restore(IN_TREE tree) {}
/*
#]=======]
function ( twx_global_restore .IN_TREE twx.R_IN_TREE )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_restore )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_arg_assert_keyword ( .IN_TREE )
  twx_assert_variable_name ( "${twx.R_IN_TREE}" )
  get_target_property (
    ${twx.R_IN_TREE}
    TwxGlobalLib.cmake
    TWX_GLOBAL_TREE/
  )
  twx_export (
    ${twx.R_IN_TREE}
    TWX_IS_TREE_${twx.R_IN_TREE}=ON
  )
endfunction ()

# ANCHOR: twx_global_get
#[=======[
*/
/** @brief Get a value of the global tree
  *
  * Retrieve a value from the global tree.
  *
  * @param tree for key IN_TREE, the required name for a tree.
  * @param key for key `KEY`, is the required key.
  *   On return, the variable `<IN_TREE>/<key>` holds the result.
  *   Moreover, `TWX_IS_TREE_<IN_TREE>/<key>` is set if the result is a tree,
  *   unset otherwise.
  */
twx_global_get(IN_TREE tree KEY key) {}
/*
#]=======]
function ( twx_global_get .IN_TREE twx.R_IN_TREE .KEY twx.R_KEY )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_get )
  twx_arg_assert_count ( ${ARGC} == 4 )
  twx_global_restore ( "${.IN_TREE}" "${twx.R_IN_TREE}" )
  # twx_tree_prettify ( "${${twx.R_IN_TREE}}" IN_VAR m )
  # message ( TR@CE "${twx.R_IN_TREE} => \"${m}\"" )
  set ( v "${twx.R_IN_TREE}" )
  twx_complete_dir_var ( v )
  string ( APPEND v "${twx.R_KEY}" )
  twx_tree_get (
    TREE "${twx.R_IN_TREE}"
    "${.KEY}" "${twx.R_KEY}"
    IN_VAR "${v}"
  )
  # message ( TR@CE "Export: ${v} => \"${${v}}\"" )
  twx_export ( "${v}" "TWX_IS_TREE_${v}" )
endfunction ()

# ANCHOR: twx_global_set
#[=======[
*/
/** @brief Set a value in the global storage
  *
  * Retrieve a value from a tree
  *
  * @param ... non empty list of `<key path>=<value>` formatted strings.
  *   A key path takes the form `<key_1>[/<key_i>]*`
  *   Enclose these arguments into quotes if they should contain spaces.
  */
twx_global_set(...) {}
/*
#]=======]
function ( twx_global_set .kv )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_set )
  twx_global_restore ( IN_TREE tree/ )
  set ( i 0 )
  while ( TRUE )
    twx_tree_set (
      TREE tree/
      "${ARGV${i}}"
    )
    # message ( TR@CE "AFTER set: tree/ => \"${tree}\"/")
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_global_save ( TREE tree/ )
endfunction ()

# ANCHOR: twx_global_remove
#[=======[
*/
/** @brief Remove values for given keys
  *
  * Remove values from a tree.
  * If you remove all the values, you obtain a void tree.
  *
  * @param ... non empty list of keys.
  */
twx_global_remove(... ) {}
/*
#]=======]
function ( twx_global_remove .key )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_remove )
  twx_global_restore ( IN_TREE tree/ )
  twx_tree_remove ( TREE tree/ KEY ${ARGV} )
  twx_global_save ( TREE tree/ )
endfunction ()

# ANCHOR: twx_global_expose
#[=======[
*/
/** @brief Expose the global state
  *
  * For each top level key value pair,
  * define the variable named `TWX_GLOBAL_TREE/<key>` to have the value.
  *
  * @param tree for key TREE, the required name of a tree.
  * It is highly recommanded to expose the global tree within a local scope.
  */
twx_global_expose() {}
/*
#]=======]
macro ( twx_global_expose .IN_TREE twx.R_IN_TREE )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_expose )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_global_restore ( "${.IN_TREE}" "${twx.R_IN_TREE}" )
  twx_tree_expose ( TREE "${twx.R_IN_TREE}" )
endmacro ()

# ANCHOR: twx_global_log
#[=======[
*/
/** @brief Log the global storage
  *
  * @param `NO_BANNER`, optional flag to suppress the banner.
  */
twx_global_log(tree) {}
/*
#]=======]
function ( twx_global_log )
  if ( ${ARGC} EQUAL 1 )
    twx_expect ( ARGV0 STREQUAL "NO_BANNER" )
    set ( twx.R_NO_BANNER "NO_BANNER" )
  else ()
    twx_arg_assert_count ( ${ARGC} == 0 )
    set ( twx.R_NO_BANNER )
  endif ()
  twx_global_restore ( IN_TREE tree/ )
  twx_tree_log (
    TREE tree/
    ${twx.R_NO_BANNER}
  )
endfunction ()

# ANCHOR: twx_tree_prettify
#[=======[
*/
/** @brief Turn a tree content into human readable
  *
  * @param message, string to manipulate.
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_tree_prettify(message IN_VAR var) {}
/*
#]=======]
function ( twx_global_prettify .IN_VAR twx.R_IN_VAR )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_prettify )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  twx_global_restore ( IN_TREE tree_ )
  twx_tree_prettify ( "${tree_}" "${.IN_VAR}" "${twx.R_IN_VAR}" )
  twx_export ( "${twx.R_IN_VAR}" )
endfunction ()

twx_lib_require ( "Expect" "Arg" "Tree" "Export" "Util" "Increment" )

block ()
twx_tree_init ( tree/ )
twx_tree_assert ( tree/ )
twx_global_save ( TREE tree/ )
endblock ()

twx_lib_did_load ()

#*/
