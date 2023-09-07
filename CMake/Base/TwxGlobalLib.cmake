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

define_property (
  TARGET PROPERTY /TWX/GLOBAL/TREE
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
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "TREE" ""
  )
  twx_arg_assert_parsed ()
  twx_tree_assert ( TREE "${twx.R_TREE}" )
  twx_global_set__ ( "${${twx.R_TREE}}" KEY /TWX/GLOBAL/TREE )
  # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m ) 
  # message ( TR@CE "${twx.R_TREE} => ``${m}''" )
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
  twx_function_begin ()
  twx_arg_assert_count ( ${ARGC} == 0 )
  twx_tree_init ( TREE /tree )
  twx_global_set__ ( "${/tree}" KEY /TWX/GLOBAL/TREE )
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
  * - `/TWX/IS_TREE/<tree>` is set to `ON`.
  *
  */
twx_global_restore(IN_TREE tree) {}
/*
#]=======]
function ( twx_global_restore )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "IN_TREE" ""
  )
  twx_arg_assert_parsed ( PREFIX )
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_TREE}" )
  twx_global_get__ ( IN_VAR ${${TWX_CMD}.R_IN_TREE} KEY /TWX/GLOBAL/TREE )
  twx_export (
    ${${TWX_CMD}.R_IN_TREE}
    /TWX/IS_TREE/${${TWX_CMD}.R_IN_TREE}=ON
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
  *   Moreover, `/TWX/IS_TREE/<IN_TREE>/<key>` is set if the result is a tree,
  *   unset otherwise.
  */
twx_global_get(IN_TREE tree KEY key) {}
/*
#]=======]
function ( twx_global_tree_get )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "IN_TREE;KEY" ""
  )
  twx_arg_assert_parsed ( PREFIX )
  twx_global_restore ( IN_TREE "${${TWX_CMD}.R_IN_TREE}" )
  # block ()
  # twx_tree_prettify ( MSG "${${${TWX_CMD}.R_IN_TREE}}" IN_VAR m )
  # message ( TR@CE "${${TWX_CMD}.R_IN_TREE} => ``${m}''" )
  # endblock ()
  set ( ${TWX_CMD}.V "${${TWX_CMD}.R_IN_TREE}/${${TWX_CMD}.R_KEY}" )
  twx_tree_get (
    TREE "${${TWX_CMD}.R_IN_TREE}"
    KEY "${${TWX_CMD}.R_KEY}"
    IN_VAR "${${TWX_CMD}.V}"
  )
  # twx_var_log ( TR@CE ${${TWX_CMD}.V} MSG "Export" )
  twx_export ( "${${TWX_CMD}.V}" "/TWX/IS_TREE/${${TWX_CMD}.V}" )
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
function ( twx_global_tree_set .kv )
  twx_function_begin ()
  twx_global_restore ( IN_TREE /tree )
  set ( i 0 )
  while ( TRUE )
    twx_tree_set (
      TREE /tree
      "${ARGV${i}}"
    )
    # message ( TR@CE "AFTER set: /tree => ``${tree}''/")
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_global_save ( TREE /tree )
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
  twx_function_begin ()
  twx_global_restore ( IN_TREE /tree )
  twx_tree_remove ( TREE /tree KEY ${ARGV} )
  twx_global_save ( TREE /tree )
endfunction ()

# ANCHOR: twx_global_expose
#[=======[
*/
/** @brief Expose the global state
  *
  * For each top level key value pair,
  * define the variable named `/TWX/GLOBAL/TREE<key>` to have the value.
  *
  * @param tree for key IN_TREE, the required name of a tree.
  * It is highly recommanded to expose the global tree within a local scope.
  */
twx_global_expose(IN_TREE tree) {}
/*
#]=======]
macro ( twx_global_expose )
  cmake_parse_arguments (
    twx_global_expose.R
    "" "IN_TREE" ""
    ${ARGV}
  )
  twx_var_assert_name ( "${twx_global_expose.R_IN_TREE}" )
  twx_global_restore ( IN_TREE "${twx_global_expose.R_IN_TREE}" )
  twx_tree_expose ( TREE "${twx_global_expose.R_IN_TREE}" )
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
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "NO_BANNER" "" ""
  )
  twx_arg_assert_parsed ()
  twx_arg_pass_option ( NO_BANNER )
  twx_global_restore ( IN_TREE /tree )
  twx_tree_log (
    TREE /tree
    ${twx.R_NO_BANNER}
  )
endfunction ()

# ANCHOR: twx_global_prettify
#[=======[
*/
/** @brief Turn a tree content into human readable
  *
  * @param message, string to manipulate.
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_global_prettify(IN_VAR var) {}
/*
#]=======]
function ( twx_global_prettify .IN_VAR twx.R_IN_VAR )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "IN_VAR" ""
  )
  twx_arg_assert_parsed ( PREFIX )
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  twx_global_restore ( IN_TREE ${TWX_CMD}.TREE )
  twx_tree_prettify ( MSG "${${TWX_CMD}.TREE}" IN_VAR "${${TWX_CMD}.R_IN_VAR}" )
  twx_export ( "${${TWX_CMD}.R_IN_VAR}" )
endfunction ()

twx_lib_require ( "Tree" "Util" )

block ()
twx_tree_init ( TREE /tree )
twx_tree_assert ( TREE /tree )
twx_global_save ( TREE /tree )
endblock ()

twx_lib_did_load ()

#*/
