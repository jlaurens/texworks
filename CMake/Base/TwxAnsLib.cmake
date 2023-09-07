#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Return multiple values from functions.

`/TWX/ANS` is a local state variable that is exported from a function to the caller.
The caller does not need to know exactly what is exported.
When the ans is exposed, we have all the contributions so far.

*//*
#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_ans_clear
#[=======[
*/
/** @brief Clear the ans tree
  *
  * Used when loading the library.
  * In general we do not cll this because append to the inherited ans state.
  */
twx_ans_clear () {}
/*
#]=======]
function ( twx_ans_clear )
  twx_tree_init ( TREE /TWX/ANS )
  twx_ans_export ()
endfunction ()

# ANCHOR: twx_ans_assert_key
#[=======[*/
/**
  * @brief Raise when not a valid key.
  *
  * @param ..., non empty list of candidate values.
  */
twx_ans_assert_key ( key ... ) {}
/*
#]=======]
# TODO: non empty list of values => 1 argument before ellispis ...
# TODO: verify that argument won't hide an inherited variable
# TODO: local arguments of the form <function name>.<identifier>
function ( twx_ans_assert_key twx_ans_assert_key.KEY )
  set ( i 0 )
  while ( TRUE )
    twx_var_assert_name ( "${ARGV${i}}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
endfunction ()

# ANCHOR: twx_ans_set
#[=======[*/
/**
  * @brief Add a key=value pair.
  *
  * @param ONLY_ON_TEST, optional flag to execute the instruction only when
  *   `/TWX/TESTING` is truthy.
  * @param ... non empty list of key[=value] arguments.
  *   When no value is provided, this is equivalent to "${<key>}"
  */
twx_ans_set([ONLY_ON_TEST] ...) {}
/*
#]=======]
function ( twx_ans_set .kv )
  if ( ARGV0 STREQUAL "ONLY_ON_TEST" )
    if ( NOT /TWX/TESTING )
      return ()
    endif ()
    set ( i 1 )
  else ()
    set ( i 0 )
  endif ()
  while ( TRUE )
    twx_tree_set ( TREE /TWX/ANS "${ARGV${i}}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_ans_export ()
endfunction ()

# ANCHOR: twx_ans_get_keys
#[=======[
*/
/** @brief Get all the keys of the answer tree
  *
  * @param var for key IN_VAR, will hold the result on return.
  *   The result is a list of keys separated by the `/TWX/TREE/RECORD`
  *   character.
  * @param prefix for key PREFIX, optional text. When provided, only keys
  *   starting with that prefix are returned.
  * @param matches for key MATCHES, optional regular expression. When provided, only keys
  *   matching that regular expression are returned.
  */
twx_ans_get_keys(IN_VAR var [PREFIX prefix] [MATCHES matches]) {}
/*
#]=======]
macro ( twx_ans_get_keys )
  twx_tree_get_keys ( TREE /TWX/ANS ${ARGV} )
endmacro ()

# ANCHOR: twx_ans_get
#[=======[
*/
/** @brief Get a value from the answer tree.
  *
  * Retrieve a value from the answer tree.
  *
  * @param key for key `KEY`, is the required key.
  * @param var for key `IN_VAR`, will hold the result on return.
  *   Moreover, `/TWX/IS_TREE/<var>` is set if the result is a tree,
  *   unset otherwise.
  *   If var is not provided, `/TWX/ANS/<key>` is used instead.
  */
twx_ans_get(KEY key [IN_VAR var]) {}
/*
#]=======]
macro ( twx_ans_get )
  twx_tree_get ( TREE /TWX/ANS ${ARGV} )
endmacro ()

# ANCHOR: twx_ans_remove
#[=======[*/
/**
  * @brief Remove a key from the answer tree.
  *
  * @param ... a non empty list of key names.
  */
twx_ans_remove(...) {}
/*
#]=======]
macro ( twx_ans_remove )
  twx_tree_remove ( TREE /TWX/ANS ${ARGV} )
endmacro ()

# ANCHOR: twx_ans_export
#[=======[
*/
/** @brief Export the answer.
  *
  * Export the variable `/TWX/ANS` and its contents to the parent scope.
  */
twx_ans_export () {}
/*
Beware of regular expression syntax.
#]=======]
macro ( twx_ans_export )
  twx_export ( /TWX/ANS )
endmacro ()

# ANCHOR: twx_ans_expose
#[=======[
*/
/** @brief Expose the answer.
  *
  * Expose the content of `/TWX/ANS`.
  * Forward to `twx_tree_expose()`, which arguments are supported.
  *
  * @param prefix for key `PREFIX` optional output value prefix.
  */
twx_ans_expose ([PREFIX prefix]) {}
/*
#]=======]
macro ( twx_ans_expose )
  twx_tree_expose ( TREE /TWX/ANS ${ARGV} )
endmacro ()

# ANCHOR: twx_ans_log
#[=======[
*/
/** @brief Display the answer.
  *
  * Display the content of `/TWX/ANS` tree.
  * Forward to `twx_tree_log()`, which arguments are supported.
  */
twx_ans_log () {}
/*
Beware of regular expression syntax.
#]=======]
function ( twx_ans_log )
  twx_function_begin ()
  if ( ARGV0 IN_LIST /TWX/CONST/MESSAGE/MODES )
    list ( POP_FRONT ARGV mode_)
  else ()
    set ( mode_ )
  endif ()
  twx_tree_log ( ${mode_} TREE /TWX/ANS ${ARGV} )
endfunction ()

# ANCHOR: twx_ans_prettify
#[=======[
*/
/** @brief Turn ans contents into human readable
  *
  * Forward to `twx_tree_prettify()`, which arguments are supported.
  *
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_tree_prettify(message IN_VAR var) {}
/*
#]=======]
macro ( twx_ans_prettify )
  twx_tree_prettify ( MSG "${/TWX/ANS}" ${ARGV} )
endmacro ()

twx_lib_require ( "Tree" "Export" "Increment" )

twx_ans_clear ()

twx_lib_did_load ()
#*/
