#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Return multiple values from functions.

`TWX_ANS` is a local state variable that is exported from a function to the caller.
The caller does not need to know exactly what is exported.
When the ans is exposed, we have all the contributions so far.

*//*
#]===============================================]

if ( DEFINED TWX_ANS )
  return ()
endif ()

# ANCHOR: twx_ans_clear
#[=======[
*//**
  * @brief Clear the ans state
  *
  * Used when loading the library.
  * In general we do not cll this because append to the inherited ans state.
  */
twx_ans_clear () {}
/*
#]=======]
function ( twx_ans_clear )
  twx_tree_clear ( TWX_ANS )
  twx_ans_export ()
endfunction ()

twx_ans_clear ()

# ANCHOR: twx_ans_assert_key
#[=======[*/
/**
  * @brief Raise when not a valid key.
  *
  * @param ..., non empty list of candidate values.
  * Support `$|` syntax.
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
    twx_assert_variable ( "${ARGV${i}}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
endfunction ()

# ANCHOR: twx_ans_add
#[=======[*/
/**
  * @brief Add a key=value pair.
  *
  * @param ... non empty list of key=value arguments.
  *   Support `$|` syntax for both key and value.
  *   When no value is provided, this is "${<key>}"
  */
twx_ans_add(...) {}
/*
#]=======]
function ( twx_ans_add .kv )
  set ( i 0 )
  while ( TRUE )
    twx_split ( "${ARGV${i}}" IN_KEY twx_ans_add.k IN_VALUE twx_ans_add.v )
    if ( "${twx_ans_add.k}" STREQUAL "" )
      twx_fatal ( "Unexpected argument: \"${ARGV${i}}\"")
      return ()
    endif ()
    twx_ans_assert_key ( "${twx_ans_add.k}" )
    if ( NOT DEFINED twx_ans_add.v )
      set ( twx_ans_add.v "${${twx_ans_add.k}}" )
    endif ()
    twx_tree_set ( TWX_ANS ""${twx_ans_add.k=$|twx_ans_add.v"}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_ans_export ()
endfunction ()

# ANCHOR: twx_ans_remove
#[=======[*/
/**
  * @brief Remove a key.
  *
  * @param ... a non empty list of key names.
  * Support `$|` syntax.
  */
twx_ans_remove(...) {}
/*
#]=======]
function ( twx_ans_remove .k )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    twx_ans_assert_key ( "${k}" )
    twx_tree_remove ( TWX_ANS "${k}" )
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_ans_export ()
endfunction ()

# ANCHOR: twx_ans_export
#[=======[
*/
/** @brief Export the answer.
  *
  * Export the variable `TWX_ANS` and its contents to the parent scope.
  */
twx_ans_export () {}
/*
Beware of regular expression syntax.
#]=======]
macro ( twx_ans_export )
  twx_export ( TWX_ANS )
endmacro ()

 ANCHOR: twx_ans_expose
#[=======[
*/
/** @brief Expose the answer.
  *
  * Expose the content of `TWX_ANS`.
  */
twx_ans_expose () {}
/*
Beware of regular expression syntax.
#]=======]
macro ( twx_ans_expose )
  twx_tree_expose ( TWX_ANS )
endmacro ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTreeLib.cmake" )

#*/
