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

if ( COMMAND twx_global_init )
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
  */
twx_global_save() {}
/*
#]=======]
function ( twx_global_save )
# TODO: More list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_restore )
  set_target_properties (
    TwxGlobalLib.cmake
    PROPERTIES
      TWX_GLOBAL_TREE/ "${TWX_GLOBAL_TREE/}"
  )
endfunction ()

twx_global_init ( TWX_GLOBAL_TREE/ )
twx_global_assert ( TWX_GLOBAL_TREE/ )
twx_global_save ()

# ANCHOR: twx_global_restore
#[=======[
*/
/** @brief Restore the global storage
  *
  * Define properly variables:
  * - `TWX_GLOBAL_TREE/`
  * - `TWX_IS_TREE_TWX_GLOBAL_TREE/` is set to `ON`.
  *
  */
twx_global_restore() {}
/*
#]=======]
function ( twx_global_restore )
# TODO: More list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_restore )
  get_target_property (
    TWX_GLOBAL_TREE/
    TwxGlobalLib.cmake
    TWX_GLOBAL_TREE/
  )
  twx_export (
    "TWX_GLOBAL_TREE/"
    "TWX_IS_TREE_TWX_GLOBAL_TREE/=ON"
  )
endfunction ()

# ANCHOR: twx_global_get
#[=======[
*/
/** @brief Get a value of the global tree
  *
  * Retrieve a value from the global tree.
  *
  * @param key for key `KEY`, is the required key.
  *   On return, the variable `TWX_GLOBAL_TREE/<key>` holds the result.
  *   Moreover, `TWX_IS_TREE_TWX_GLOBAL_TREE/<key>` is set if the result is a tree,
  *   unset otherwise.
  */
twx_global_get(KEY key) {}
/*
#]=======]
function ( twx_global_get .KEY .key )
# TODO: More list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_get )
  twx_global_restore ()
  twx_global_get (
    TREE TWX_GLOBAL_TREE/
    "${.KEY}" "${.key}"
    IN_VAR "TWX_GLOBAL_TREE/${.key}"
  )
  twx_export (
    "TWX_GLOBAL_TREE/${.key}"
    "TWX_IS_TREE_TWX_GLOBAL_TREE/${.key}"
  )
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
twx_global_restore ()
set ( i 0 )
  while ( TRUE )
    twx_global_set (
      TREE TWX_GLOBAL_TREE/
      "${ARGV${i}}"
    )
    twx_increment_and_break_if ( VAR i >= "${ARGC}" )
  endwhile ()
  twx_global_save ()
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
  twx_global_restore ()
  set ( i 0 )
  while ( TRUE )
    set ( key_ "${ARGV${i}}" )
    if ( key_ MATCHES "^[^=${TWX_TREE_RECORD_SEP}]+$" )
      if ( key_ MATCHES "//" )
        twx_fatal ( "Unexpected key: ${key_}" )
        return ()
      endif ()
      # twx_message ( TRACE "Remove ${twxR_TREE}[${key_}]" )
      twx_regex_escape ( "${key_}" IN_VAR scp_key_ )
      if ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}${scp_key_}(/)[^${TWX_TREE_RECORD_SEP}]+${TWX_TREE_RECORD_SEP}[^${TWX_TREE_GROUP_SEP}]*(.*)$" )
        set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
        while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}${scp_key_}(/[^${TWX_TREE_RECORD_SEP}]+)?${TWX_TREE_RECORD_SEP}[^${TWX_TREE_GROUP_SEP}]*(.*)$" )
          set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
        endwhile ()
        set ( r "${TWX_TREE_GROUP_SEP}${scp_key_}/${TWX_TREE_RECORD_SEP}" )
        if ( NOT tree_ MATCHES "${r}" )
          string ( APPEND tree_ "${TWX_TREE_GROUP_SEP}${key_}/${TWX_TREE_RECORD_SEP}" )
        endif ()
      elseif ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}(${scp_key_})${TWX_TREE_RECORD_SEP}[^${TWX_TREE_GROUP_SEP}]*(.*)$" )
        set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
      endif ()
    else ()
      twx_fatal ( "Unexpected key: ${key_}" )
      return ()
    endif ()
    twx_increment_and_break_if ( VAR i >= "${ARGC}" )
  endwhile ()
  twx_global_save ()
endfunction ()

# ANCHOR: twx_global_expose
#[=======[
*/
/** @brief Expose the global state
  *
  * For each top level key value pair,
  * define the variable named `TWX_GLOBAL_TREE/<key>` to have the value.
  *
  * It is highly recommanded to expose the global tree within a local scope.
  */
twx_global_expose() {}
/*
#]=======]
macro ( twx_global_expose )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_global_expose )
  twx_arg_assert_count ( "${ARGC}" == 0 )
  twx_global_restore ()
  twx_tree_expose (
    TREE TWX_GLOBAL_TREE/
    VAR_PREFIX TWX_GLOBAL_TREE/
  )
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
    set ( twxR_NO_BANNER "NO_BANNER" )
  else ()
    twx_arg_assert_count ( ${ARGC} == 0 )
    set ( twxR_NO_BANNER )
  endif ()
  twx_global_restore ()
  twx_global_log (
    TREE TWX_GLOBAL_TREE/
    ${twxR_NO_BANNER}
  )
endfunction ()

# ANCHOR: twx_global_prettify
#[=======[
*/
/** @brief Turn some text into human readable
  *
  * @param ... a list of strings to manipulate.
  * @param var for key `IN_VAR` holds the human readable string on return.
  */
twx_global_prettify(IN_VAR var) {}
/*
#]=======]
function ( twx_global_prettify .IN_VAR twxR_IN_VAR )
  twx_arg_assert_count ( ${ARGC} == 2 )
  twx_global_restore ()
  twx_global_prettify (
    TREE TWX_GLOBAL_TREE/
    "${.IN_VAR}" "${twxR_IN_VAR}"
  )
  twx_export ( "${twxR_IN_VAR}" )
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTreeLib.cmake" )

message ( VERBOSE "Loaded: TwxGlobalLib" )

#*/
