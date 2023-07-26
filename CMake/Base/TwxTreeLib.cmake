#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Support for a poor man tree structure.
  *
  * A solution based on JSON might not be strong enough.
  *
  * Usage:
  *
  *  include ( TwxTreeLib )
  *
  * This is a partial answer to the problem of returned values.
  * That way we can store data in custom target properties with dynamic keys.
  * We can also return values from functions in a more friendly way.
  *
  * Functions:
  * - `twx_tree_assert()`
  * - `twx_tree_assert_key()`
  * - `twx_tree_init()`
  * - `twx_tree_clear()`
  * - `twx_tree_get()`
  * - `twx_tree_set()`
  * - `twx_tree_remove()`
  * - `twx_tree_expose()`
  * - `twx_tree_log()`
  * - `twx_tree_prettify()`
  *
  * Limitations:
  *
  * - keys and values must not contain the 4 charecters with ascii code 28 to 31
  * - keys must not contain any character of `=;/`
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

string ( ASCII 01 TWX_TREE_MARK   )
string ( ASCII 02 TWX_TREE_START  )
string ( ASCII 29 TWX_TREE_RECORD )
string ( ASCII 30 TWX_TREE_SEP    )
string ( ASCII 26 TWX_TREE_PLACEHOLDER_START )
string ( ASCII 27 TWX_TREE_PLACEHOLDER_END   )

set ( TWX_TREE_HEADER "${TWX_TREE_MARK}TwxTree${TWX_TREE_START}" )

# ANCHOR: twx_tree_assert
#[=======[
*/
/** @brief Raises when the argument is not a tree
  *
  * @param tree is an optional tree name that defaults to `TWX_TREE`.
  */
twx_tree_assert([tree]) {}
/*
#]=======]
function ( twx_tree_assert )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_assert )
  if ( ${ARGC} EQUAL 0 )
    set ( tree_ "TWX_TREE" )
  else ()
    set ( tree_ "${ARGV0}" )
    twx_arg_assert_count ( ${ARGC} == 1 )
  endif ()
  twx_assert_defined ( "${tree_}" )
  if ( NOT "${${tree_}}" MATCHES "^${TWX_TREE_HEADER}" )
    twx_fatal ( "Not a tree ${tree_} (=> ``${${tree_}}'')" )
    return ()
  endif ()
endfunction ()

# ANCHOR: twx_tree_init
#[=======[
*/
/** @brief Initialize a tree
  *
  * Put the tree variable in an initial tree state.
  * The corresponding `TWX_IS_TREE_...` variable is also set.
  *
  * @param tree, an optional tree name. Defaults to `TWX_TREE`.
  */
twx_tree_init([tree]) {}
/*
#]=======]
function ( twx_tree_init )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_init )
  if ( ${ARGC} EQUAL 0 )
    set ( tree_ TWX_TREE )
  else ()
    twx_arg_assert_count ( ${ARGC} == 1 )
    set ( tree_ "${ARGV0}" )    
  endif ()
  twx_assert_variable_name ( "${tree_}" )
  twx_export (
    "${tree_}=${TWX_TREE_HEADER}"
    "TWX_IS_TREE_${tree_}=ON"
  )
endfunction ()

# ANCHOR: TWX_TREE_KEY_RE
#[=======[*/
/** @brief Regular expression for keys
  *
  * Quoted CMake documentation:
  *   > Literal variable references may consist of
  *   > alphanumeric characters,
  *   > the characters _.+-,
  *   > and Escape Sequences.
  * where "An escape sequence is a \ followed by one character:"
  *   > escape_sequence  ::=  escape_identity | escape_encoded | escape_semicolon
  *   > escape_identity  ::=  '\' <match '[^A-Za-z0-9;]'>
  *   > escape_encoded   ::=  '\t' | '\r' | '\n'
  *   > escape_semicolon ::=  '\;'
  */
TWX_TREE_KEY_RE;
/*#]=======]
set (
  TWX_TREE_KEY_RE
  "([a-zA-Z_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9_.+-]|\\[^a-zA-Z0-9;]|\\[trn]|\\;)*"
)

# ANCHOR: twx_tree_assert_key
#[=======[
*/
/** @brief Raise if one argument is not a suitable key name
  *
  * Actually a key is just a variable name, but it may chnage in the future.
  * @param ... non empty list of candidates.
  */
twx_tree_assert_key(key ...) {}
/*
#]=======]
function ( twx_tree_assert_key .key )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_assert_key )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    if ( NOT "${k}" MATCHES "^(${TWX_TREE_KEY_RE}/)*${TWX_TREE_KEY_RE}$" )
      twx_fatal ( "Forbidden key: ${k}" )
      return ()
    endif ()
    if ( "${k}" MATCHES "[=${TWX_TREE_SEP}]" )
      twx_fatal ( "Unexpected key: ${k}" )
      return ()
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
endfunction ()

# ANCHOR: twx_tree_get_keys
#[=======[
*/
/** @brief Get all the keys
  *
  * @param tree for key TREE, the optional name of a tree. Defaults to `TWX_TREE`.
  *   The variable must be defined.
  * @param var for key IN_VAR, will hold the result on return.
  *   The result is a list of keys separated by the `TWX_TREE_RECORD`
  *   character.
  * @param prefix for key PREFIX, optional text. When provided, only keys
  *   starting with that prefix are returned.
  * @param RELATIVE, optional flag. When set, only the part of the key
  *   relative to the prefix is returned.
  * @param matches for key MATCHES, optional regular expression. When provided, only keys
  *   matching that regular expression are returned. The match is evaluated
  *   after the prefix is managed, in particular after the `RELATIVE` option applies.
  */
twx_tree_get_keys([TREE tree] IN_VAR var [PREFIX prefix] [RELATIVE] [MATCHES matches]) {}
/*
#]=======]
function ( twx_tree_get_keys )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "RELATIVE" "TREE;IN_VAR;PREFIX;MATCHES" "" )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED "twx.R_TREE" )
    set ( twx.R_TREE "TWX_TREE" )
  endif ()
  twx_tree_assert ( "${twx.R_TREE}" )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  set ( "${twx.R_IN_VAR}" )
  if ( twx.R_PREFIX )
    twx_regex_escape ( "${twx.R_PREFIX}" IN_VAR prefix_ )
  else ()
    set ( prefix_ )
  endif ()
  while ( "${${twx.R_TREE}}" MATCHES "^(.*)${TWX_TREE_RECORD}(.*)${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*(.*)$" )
    set ( "${twx.R_TREE}" "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
    set ( k_ "${CMAKE_MATCH_2}" )
    if ( prefix_ )
      if ( "${k_}" MATCHES "^${prefix_}(.*)$" )
        if ( twx.R_RELATIVE )
          set ( k_ "${CMAKE_MATCH_1}" )
        endif ()
      else ()
        # message ( TR@CE "IGNORING: ``${k_}'' without prefix ``${prefix_}''" )
        continue ()
      endif ()
    endif ()
    if ( twx.R_MATCHES AND NOT "${k_}" MATCHES "${twx.R_MATCHES}" )
      # message ( TR@CE "IGNORING: ``${k_}'' not matching ``${twx.R_MATCHES}''" )
      continue ()
    endif ()
    # message ( TR@CE "APPEND: ``${k_}''" )
    list ( APPEND "${twx.R_IN_VAR}" "${k_}" )
  endwhile ()
  return ( PROPAGATE "${twx.R_IN_VAR}" )
endfunction ()

# ANCHOR: twx_tree_get
#[=======[
*/
/** @brief Get a value
  *
  * Retrieve a value from a tree.
  *
  * @param key for key `KEY`, is the required key.
  * @param var for key `IN_VAR`, will hold the result on return.
  *   Moreover, `TWX_IS_TREE_<var>` is set if the result is a tree,
  *   unset otherwise.
  *   If var is not provided, `<tree*>/<key>` is used instead,
  *   where `<tree*>` is `<tree>` minus all trailing `/`.
  * @param tree for key TREE, optional name of a tree. Defaults to `TWX_TREE`.
  *   Raise when not a tree.
  */
twx_tree_get([TREE tree] KEY key [IN_VAR var]) {}
/*
#]=======]
function ( twx_tree_get .KEY .key )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_get )
# TODO: More list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE;KEY;IN_VAR" "" )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED "twx.R_TREE" )
    set ( twx.R_TREE "TWX_TREE" )
  endif ()
  twx_tree_assert ( "${twx.R_TREE}" )
  twx_tree_assert_key ( "${twx.R_KEY}" )
  if ( "${twx.R_IN_VAR}" STREQUAL "" )
    set ( v "${twx.R_TREE}" )
    while ( v MATCHES "^(.*)/$" )
      set ( v "${CMAKE_MATCH_1}" )
    endwhile ()
    string ( APPEND v "/${twx.R_KEY}" )
  else ()
    set ( v "${twx.R_IN_VAR}" )
  endif ()
  twx_assert_variable_name ( "${v}" )
  # message ( TR@CE "${twx.R_TREE}[${twx.R_KEY}] => ${v}")
  set ( "tree_" "${${twx.R_TREE}}" )
  twx_regex_escape ( "${twx.R_KEY}" IN_VAR get_scpd_ )
  # message ( TR@CE "0) ``${twx.R_KEY}'' => ``${get_scpd_}''" )
  if ( "${tree_}" MATCHES "${TWX_TREE_RECORD}${get_scpd_}${TWX_TREE_SEP}([^${TWX_TREE_RECORD}]*)" )
    # message ( TR@CE "0) ``v => ''${v}\"" )
    # message ( TR@CE "0) ``CMAKE_MATCH_1 => ''${CMAKE_MATCH_1}\"" )
    twx_export ( "${v}=${CMAKE_MATCH_1}" )
    twx_export ( "TWX_IS_TREE_${v}" UNSET )
    return ()
  endif ()
  twx_tree_prettify ( "${tree_}" IN_VAR pretty )
  # message ( TR@CE "SUBTREE/ tree_ => ``${tree_}'' => ``${pretty}''" )
  set ( re "^(.*)${TWX_TREE_RECORD}${get_scpd_}/(([^${TWX_TREE_SEP}]*)${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*)(.*)$" )
  # message ( TR@CE "0) ${k_} ${get_scpd_}" )
  # if ( "${tree_}" MATCHES "^(.*)${TWX_TREE_RECORD}" )
  #   # message ( TR@CE "1)" )
  # endif ()
  # if ( "${tree_}" MATCHES "^(.*)${TWX_TREE_RECORD}${get_scpd_}" )
  #   # message ( TR@CE "2)" )
  # endif ()
  # if ( "${tree_}" MATCHES "^(.*)${TWX_TREE_RECORD}${get_scpd_}/" )
  #   # message ( TR@CE "3)" )
  # endif ()
  if ( "${tree_}" MATCHES "${re}" )
    # message ( TR@CE "EXPORT TWX_IS_TREE_${v}=ON" )
    twx_export ( "TWX_IS_TREE_${v}=ON" )
    set ( value_ "${TWX_TREE_HEADER}" )
    while ( TRUE )
      set ( "tree_" "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
      twx_tree_prettify ( "${tree_}" IN_VAR pretty )
      # message ( TR@CE "WHILE: tree_ => ``${tree_}'' => ``${pretty}''" )
      if ( NOT "${CMAKE_MATCH_3}" STREQUAL "" )
        string ( APPEND value_ "${TWX_TREE_RECORD}${CMAKE_MATCH_2}")
      endif ()
      if ( NOT "${tree_}" MATCHES "${re}" )
        break ()
      endif ()
    endwhile ()
    twx_export (
      "${v}=${value_}"
      "TWX_IS_TREE_${v}=ON"
    )
    # message ( TR@CE "TREE RETURN: " )
    return ()
  endif ()
  # message ( TR@CE "VOID RETURN (${v})" )
  twx_export ( "${v}" "TWX_IS_TREE_${v}" UNSET )
endfunction ()

# ANCHOR: twx_tree_set
#[=======[
*/
/** @brief Set a value
  *
  * Set a value into a tree
  *
  * @param tree for key TREE, optional name of a tree. Defaults to `TWX_TREE`.
  * The variable must be defined.
  * @param ... non empty list of `<key path>[=<value>]` formatted strings.
  *   A key path takes the form `<key_1>[/<key_i>]*`
  *   Enclose these arguments into quotes if they should contain spaces.
  */
twx_tree_set([TREE tree] ... ) {}
/*
#]=======]
function ( twx_tree_set )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_set )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE" "" )
  # message ( TR@CE "Parsed: twx.R_TREE => ``${twx.R_TREE}''")
  if ( DEFINED "twx.R_TREE" )
    set ( i 2 )
  else ()
    set ( twx.R_TREE "TWX_TREE" )
    set ( i 0 )
  endif ()
  twx_tree_assert ( "${twx.R_TREE}" )
  twx_arg_assert_count ( ${ARGC} > "${i}" )
  while ( TRUE )
    set ( kv_ "${ARGV${i}}" )
    # message ( TR@CE "kv_ => ``${kv_}''")
    twx_split_assign ( "${kv_}" IN_KEY key_ IN_VALUE value_ )
    # message ( TR@CE "key_ => ``${key_}''")
    # message ( TR@CE "value_ => ``${value_}''")

    # block ()
    #   twx_tree_prettify ( "${value_}" IN_VAR value_ )
    #   message ( TRACE "WILL REMOVE ``${key_}'': ${twx.R_TREE}[${key_}] <= ${value_}")
    # endblock ()
    twx_tree_remove ( TREE "${twx.R_TREE}"  KEY "${key_}" )
    # block ()
    #   twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR value_ )
    #   message ( TRACE "DID REMOVE ``${key_}'': ${twx.R_TREE} => ${value_}")
    # endblock ()
    if ( NOT DEFINED value_ )
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
      continue ()
    endif ()
    if ( "${value_}" MATCHES "^${TWX_TREE_HEADER}" )
      twx_tree_assert ( value_ )
      twx_tree_get_keys ( TREE "value_" IN_VAR "keys_" )
      if ( keys_ )
        foreach ( k_ ${keys_} )
          twx_tree_get ( TREE "value_" KEY "${k_}" IN_VAR v_ )
          string ( APPEND "${twx.R_TREE}" "${TWX_TREE_RECORD}${key_}/${k_}${TWX_TREE_SEP}${v_}" )
          # message ( TR@CE "${twx.R_TREE}[``${key_}/${k_}''] <= ``${v_}''")
          twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR pretty )
          # message ( TR@CE "``${twx.R_TREE}'' => ``${pretty}''" )
        endforeach ()
      else ()
        string ( APPEND "${twx.R_TREE}" "${TWX_TREE_RECORD}${key_}/${TWX_TREE_SEP}" )
      endif ()
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
      continue ()
    elseif ( value_ MATCHES "[${TWX_TREE_RECORD}${TWX_CHAR_STX}${TWX_TREE_SEP}]" )
      twx_tree_prettify ( "${value_}" IN_VAR value_ )
      twx_fatal ( "Unexpected value: ${value_}" )
      return ()
    else ()
      string ( APPEND "${twx.R_TREE}" "${TWX_TREE_RECORD}${key_}${TWX_TREE_SEP}${value_}" )
    endif ()
    # block ()
    #   twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
    #   # message ( TR@CE "tree_ => ``${m}''")
    # endblock ()
    twx_regex_escape ( "${key_}" IN_VAR scpd_key_ )
    while ( "${${twx.R_TREE}}" MATCHES "^(.*)${TWX_TREE_RECORD}${scpd_key_}/${TWX_TREE_SEP}(.*)$" )
      set ( ${twx.R_TREE} "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
    endwhile ()
    # block ()
    #   twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR pretty )
    #   message ( TRACE "twx.R_TREE => ``${pretty}''")
    # endblock ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_export (
    "${twx.R_TREE}=${${twx.R_TREE}}"
    "TWX_IS_TREE_${twx.R_TREE}=ON"
  )
endfunction ( twx_tree_set )

# ANCHOR: twx_tree_remove
#[=======[
*/
/** @brief Remove values for given keys
  *
  * Remove values from a tree.
  *
  * @param tree for key TREE, the optional name of a tree. Defaults to `TWX_TREE`.
  *   The variable must be defined.
  * @param ... for key KEY, non empty list of keys.
  * When the key matches `^m(.)(.*)\1$` then the key is in fact a regular
  * expression corresponding to the second capturing group.
  */
twx_tree_remove(TREE tree KEY ...) {}
/*
#]=======]
function ( twx_tree_remove )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_remove )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE" "KEY" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_TREE}" STREQUAL "" )
    set ( twx.R_TREE TWX_TREE )
  endif ()
  twx_tree_assert ( "${twx.R_TREE}" )
  block ()
    twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
    # message ( TR@CE "${twx.R_TREE} => ``${m}''" )
  endblock ()
  # message ( TR@CE "ARGV => ${ARGV}" )
  twx_assert_non_void ( twx.R_KEY )
  twx_tree_get_keys ( TREE "${twx.R_TREE}" IN_VAR keys_ )
  foreach ( removed_key_ ${twx.R_KEY} )
    if ( "${removed_key_}" MATCHES "^m(.)(.+)(.)$" )
      if ( "${CMAKE_MATCH_1}" STREQUAL "${CMAKE_MATCH_3}" )
        # A regular expression was given
        set ( re_ "${CMAKE_MATCH_2}" )
        foreach ( k_ ${keys_} )
          if ( "${k_}" MATCHES "${re_}" )
            twx_regex_escape ( "${k_}" IN_VAR removed_scpd_ )
            string (
              REGEX REPLACE
              "${TWX_TREE_RECORD}${removed_scpd_}${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*"
              ""
              "${twx.R_TREE}"
              "${${twx.R_TREE}}"
            )
          endif ()
        endforeach ()
        continue ()
      endif ()
    endif ()
    # normal key
    # message ( TR@CE "NORMAL KEY: ${removed_key_}" )
    twx_tree_assert_key ( "${removed_key_}" )
    twx_regex_escape ( "${removed_key_}" IN_VAR removed_scpd_ )
    if ( "${removed_key_}" MATCHES "^(.*)/[^/]+$" )
      set ( parent_ "${CMAKE_MATCH_1}" )
    else ()
      set ( parent_ )
    endif ()
    foreach ( k_ ${keys_} )
      # message ( TR@CE "KNOWN KEY: ${k_} / REMOVED KEY= ${removed_key_}")
      if ( "${k_}" STREQUAL "${removed_key_}" )
        string (
          REGEX REPLACE
          "${TWX_TREE_RECORD}${removed_scpd_}${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "A) ${twx.R_TREE} => ``${m}''" )
      endif ()
      if ( "${k_}" MATCHES "^${removed_scpd_}/" )
        # message ( TR@CE "B0) removed_key_ => ``${removed_key_}''" )
        # message ( TR@CE "B0) parent_ => ``${parent_}''" )
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B0) ${twx.R_TREE} => ``${m}''" )
        string (
          REGEX REPLACE
          "${TWX_TREE_RECORD}${removed_scpd_}/[^${TWX_TREE_SEP}]*${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B1) ${twx.R_TREE} => ``${m}''" )
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B2) ${twx.R_TREE} => ``${m}''" )
        if ( NOT "${parent_}" STREQUAL "" )
          string ( APPEND "${twx.R_TREE}" "${TWX_TREE_RECORD}${parent_}/${TWX_TREE_SEP}")
        endif ()
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B3) ${twx.R_TREE} => ``${m}''" )
      elseif ( "${k_}" MATCHES "^${removed_scpd_}$" )
        string (
          REPLACE
          "${TWX_TREE_RECORD}${k_}${TWX_TREE_SEP}[^${TWX_TREE_RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "C1) ${twx.R_TREE} => ``${m}''" )
        if ( NOT "${parent_}" STREQUAL "" )
          string ( APPEND "${twx.R_TREE}" "${TWX_TREE_RECORD}${parent_}/${TWX_TREE_SEP}")
        endif ()
        twx_tree_prettify ( "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "C2) ${twx.R_TREE} => ``${m}''" )
      endif ()
    endforeach ()
  endforeach ()
  twx_export ( "${twx.R_TREE}" )
endfunction ( twx_tree_remove )

# ANCHOR: twx_tree_expose
#[=======[
*/
/** @brief Expose a tree
  *
  * For each top level key value pair,
  * define the variable named key to have value.
  *
  * @param tree for key TREE, the optional name of a tree. Defaults to `TWX_TREE`.
  *   The variable must be defined.
  * @param prefix for key `PREFIX` optional output value prefix.
  */
twx_tree_expose(TREE tree [PREFIX prefix]) {}
/*
#]=======]
function ( twx_tree_expose )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_expose )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE;PREFIX" "" )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED  twx.R_TREE )
    set ( twx.R_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twx.R_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    message ( STATUS "******************** Not a tree ${twx.R_TREE} => ``${${twx.R_TREE}}''" )
    return ( )
  endif ()
  twx_arg_assert_parsed ()
  if ( twx.R_PREFIX )
    set ( p_ "${twx.R_PREFIX}_" )
  else ()
    set ( p_ )
  endif ()
#  twx_tree_log ( TREE "${twx.R_TREE}" )
  twx_tree_get_keys ( TREE "${twx.R_TREE}" IN_VAR keys_ )
  set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
  foreach ( key_ ${keys_} )
    # message ( TR@CE "1) key_ => ``${key_}''" )
    if ( "${key_}" MATCHES "^([^/]*)/" )
      set ( base_ "${CMAKE_MATCH_1}" )
      # Tree values
      if ( "twx_tree_get_keys.${base_}.DONE" )
        # message ( TR@CE "2) continue" )
        continue ()
      endif ()
      set ( "twx_tree_get_keys.${base_}.DONE" "ON" )
      twx_tree_get_keys ( TREE "${twx.R_TREE}" IN_VAR subkeys_ PREFIX "${base_}/" RELATIVE )
      # message ( TR@CE "3) subkeys_ => ``${subkeys_}''" )
      twx_tree_init ( twx_tree_expose.tree )
      foreach ( subkey_ ${subkeys_} )
        # twx_tree_log ( TREE "${twx.R_TREE}" )
        twx_tree_get ( TREE "${twx.R_TREE}" IN_VAR v KEY "${base_}/${subkey_}" )
        # message ( TR@CE "4) ${twx.R_TREE}[``${subkeys_}''] => ``${v}''" )
        twx_tree_set ( TREE twx_tree_expose.tree "${subkey_}=${v}")
        # message ( TR@CE "5) subkey_ => ``${base_}/${subkey_}'' -> ``${v}''" )
      endforeach ()
      # message ( TR@CE "6) ${base_} =>" )
      # twx_tree_log ( TREE "twx_tree_expose.tree" )
      twx_export (
        "${p_}${base_}=${twx_tree_expose.tree}"
        "TWX_IS_TREE_${p_}${base_}=ON"
      ) 
    else ()
      # Flat value
      twx_tree_get ( TREE "${twx.R_TREE}" KEY "${key_}" IN_VAR v )
      # message ( TR@CE "4) ``${key_}'' -> ``${v}''" )
      twx_export (
        "${p_}${key_}=${v}"
        "TWX_IS_TREE_${p_}${key_}" UNSET
      )
    endif ()
  endforeach ()
endfunction ()

# ANCHOR: twx_tree_log
#[=======[
*/
/** @brief Log a tree
  *
  * @param tree for key `TREE`, the optional name of a tree.
  *   Defaults toe `TWX_TREE`. The variable must be defined.
  * @param `NO_BANNER`, optional flag to suppress the banner.
  */
twx_tree_log(tree) {}
/*
#]=======]
function ( twx_tree_log )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_log )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "NO_BANNER" "TREE" "" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_TREE}" STREQUAL "" )
    set ( twx.R_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twx.R_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    return ()
  endif ()
  if ( NOT twx.R_NO_BANNER )
    message ( "${twx.R_TREE}:" )
  endif ()
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  list ( APPEND CMAKE_MESSAGE_INDENT "  " )
  # simple values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_RECORD}([^/${TWX_TREE_SEP}]+)${TWX_TREE_SEP}([^${TWX_TREE_RECORD}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    message ( "${CMAKE_MATCH_2}: ${CMAKE_MATCH_3}" )
  endwhile ()
  # Tree values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_RECORD}([^${TWX_TREE_SEP}]+)/([^${TWX_TREE_RECORD}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    set ( key_ "${CMAKE_MATCH_2}" )
    set ( value_ "${TWX_TREE_HEADER}${TWX_TREE_RECORD}${CMAKE_MATCH_3}" )
    while ( tree_ MATCHES "^(.*)${TWX_TREE_RECORD}${key_}/([^${TWX_TREE_RECORD}]*)(.*)$" )
      set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
      string ( APPEND value_ "${TWX_TREE_RECORD}${CMAKE_MATCH_2}" )
    endwhile ()
    message ( "${key_}:" )
    twx_tree_log ( TREE value_ NO_BANNER )
  endwhile ()
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
function ( twx_tree_prettify twx.R_MSG .IN_VAR twx.R_IN_VAR )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_prettify )
  twx_arg_assert_count ( ${ARGC} == 3 )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  string ( REPLACE "${TWX_TREE_MARK}"   "<SOH>" twx.R_MSG "${twx.R_MSG}" )
  string ( REPLACE "${TWX_TREE_START}"  "<STX>" twx.R_MSG "${twx.R_MSG}" )
  string ( REPLACE "${TWX_TREE_RECORD}" "<GS/>" twx.R_MSG "${twx.R_MSG}" )
  string ( REPLACE "${TWX_TREE_SEP}"    "<RS/>" twx.R_MSG "${twx.R_MSG}" )
  set ( ${twx.R_IN_VAR} "${twx.R_MSG}" PARENT_SCOPE )
endfunction ()

# TODO: at the end of each library, list the twx functions and constants used
#[=======[
Used
twx_arg_assert_parsed
twx_fatal
twx_export
twx_regex_escape
twx_arg_assert_keyword
#]=======]

twx_lib_require ( "Fatal" "Arg" "Export" "Core" )

twx_tree_init ()
twx_tree_assert ()

twx_lib_did_load ()

#*/
