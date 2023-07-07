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

if ( COMMAND twx_tree_init )
  return ()
endif ()

string(ASCII 27 TWX_TREE_ESC          )
string(ASCII 28 TWX_TREE_FILE_SEP     )
string(ASCII 29 TWX_TREE_GROUP_SEP    )
string(ASCII 30 TWX_TREE_RECORD_SEP   )
string(ASCII 31 TWX_TREE_UNIT_SEP     )

set ( TWX_TREE_HEADER "${TWX_CHAR_SOH}TwxTree${TWX_CHAR_STX}" )

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
  if ( ARGC EQUAL 0 )
    set ( tree_ TWX_TREE )
  else ()
    set ( tree_ "${ARGV0}" )
    twx_arg_assert_count ( "${ARGC}" == 1 )
  endif ()
  if ( NOT "${${tree_}}" MATCHES "^${TWX_TREE_HEADER}" )
    twx_fatal ( "Not a tree ${tree_} (\"${${tree_}}\")" )
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
  * @param tree for key TREE, an optional tree name. Defaults to `TWX_TREE`.
  */
twx_tree_init( tree ) {}
/*
#]=======]
function ( twx_tree_init )
  if ( ARGC STREQUAL 0 )
    set ( tree_ TWX_TREE )
  elseif ( "${ARGC}" GREATER "1" )
    twx_fatal ( "Unexpected argument: \"${ARGV1}\"" )
    return ()
  else ()
    set ( tree_ "${ARGV0}" )
  endif ()
  twx_assert_variable ( "${tree_}" )
  twx_export (
    "${tree_}=${TWX_TREE_HEADER}"
    "TWX_IS_TREE_${tree_}=ON"
  )
endfunction ()

twx_tree_init ()
twx_tree_assert ()

# ANCHOR: twx_tree_assert_key
#[=======[
*/
/** @brief Raise if one argument is not a suitable key name
  *
  * Actually a key is just a variable name, but it may chnage in the future.
  * @param ... non empty list of candidates.
  * Support `$|` syntax.
  */
twx_tree_assert_key(key ...) {}
/*
#]=======]
function ( twx_tree_assert_key key_ )
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    if ( NOT k MATCHES "${TWX_CORE_VARIABLE_RE}" )
      twx_fatal ( "Forbidden key: ${k}" )
      return ()
    endif ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
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
  *   If var is not provided, `<tree*>[<key>]` is used instead,
  *   where `<tree*>` is `<tree>` minus all trailing `/`.
  * @param tree for key TREE, optional name of a tree. Defaults to `TWX_TREE`.
  *   When not a tree, the result value is not defined.
  */
twx_tree_get([TREE tree] KEY key [IN_VAR var]) {}
/*
#]=======]
function ( twx_tree_get .KEY .key )
# TODO: More list ( APPEND CMAKE_MESSAGE_CONTEXT ... )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_get )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "TREE;KEY;IN_VAR" "" )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED "${twxR_TREE}" )
    set ( twxR_TREE TWX_TREE )
  endif ()
  twx_assert_non_void ( twxR_TREE )
  twx_tree_assert_key ( "${twxR_KEY}" )
  if ( "${twxR_IN_VAR}" STREQUAL "" )
    set ( v "${twxR_TREE}" )
    while ( v MATCHES "^(.*)/$" )
      set ( v "${CMAKE_MATCH_1}" )
    endwhile ()
    string ( APPEND v ".${twxR_KEY}" )
  else ()
    set ( v "${twxR_IN_VAR}" )
  endif ()
  twx_assert_variable ( v )
  # twx_message ( TR@CE "${twxR_TREE}[${twxR_KEY}] => ${v}")
  set ( tree_ "${${twxR_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    # twx_message ( TR@CE "Not a tree ${tree_}")
    twx_export ( "${v}" "TWX_IS_TREE_${v}" UNSET )
    return ()
  endif ()
  twx_regex_escape ( "${twxR_KEY}" IN_VAR scpd_ )
  if ( tree_ MATCHES "${TWX_TREE_GROUP_SEP}${scpd_}${TWX_TREE_RECORD_SEP}([^${TWX_TREE_GROUP_SEP}]*)" )
    twx_export ( "${v}=${CMAKE_MATCH_1}" )
    twx_export ( "TWX_IS_TREE_${v}" UNSET )
    return ()
  endif ()
  set ( re "^(.*)${TWX_TREE_GROUP_SEP}${scpd_}/(([^${TWX_TREE_RECORD_SEP}]*)${TWX_TREE_RECORD_SEP}[^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
  if ( tree_ MATCHES "${re}" )
    if ( "${twxR_IN_VAR}" STREQUAL "" )
      string ( APPEND VS_GLOBAL_<variable> / )
    endif ()
    twx_export ( "TWX_IS_TREE_${v}=ON" )
    set ( value_ "${TWX_TREE_HEADER}" )
    while ( TRUE )
      set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
      if ( NOT "${CMAKE_MATCH_3}" STREQUAL "" )
        string ( APPEND value_ "${TWX_TREE_GROUP_SEP}${CMAKE_MATCH_2}")
      endif ()
      if ( NOT tree_ MATCHES "${re}" )
        break ()
      endif ()
    endwhile ()
    twx_export ( "${v}=${value_}" )
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
  * Retrieve a value from a tree
  *
  * @param tree for key TREE, optional name of a tree. Defaults to `TWX_TREE`.
  * The variable must be defined.
  * @param ... non empty list of `<key path>=<value>` formatted strings.
  *   A key path takes the form `<key_1>[/<key_i>]*`
  *   Enclose these arguments into quotes if they should contain spaces.
  */
twx_tree_set(tree ... ) {}
/*
#]=======]
function ( twx_tree_set )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_set )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "TREE" "" )
  if ( "${twxR_TREE}" STREQUAL "" )
    set ( twxR_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twxR_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    if ( NOT "${tree_}" STREQUAL "" )
      twx_fatal ( "Not a tree: ${twxR_TREE}" )
      return ()
    endif ()
    set ( tree_ "${TWX_TREE_HEADER}" )
  endif ()
  foreach ( kv_ ${twxR_UNPARSED_ARGUMENTS} )
    twx_split ( "${kv_}" IN_KEY key_ IN_VALUE value_ )
    if ( NOT DEFINED value_ )
      twx_fatal ( "Unexpected argument: ${kv_}" )
      return ()
    endif ()
    block ()
      twx_tree_prettify ( "${value_}" IN_VAR value_ )
      # message ( TR@CE "${twxR_TREE}[${key_}] <= ${value_}")
    endblock ()
    twx_tree_remove ( TREE tree_ KEYS "${key_}" )
    if ( value_ MATCHES "^${TWX_TREE_HEADER}" )
      while ( value_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}([^${TWX_TREE_RECORD_SEP}]+)${TWX_TREE_RECORD_SEP}([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
        set ( value_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
        string ( APPEND tree_ "${TWX_TREE_GROUP_SEP}${key_}/${CMAKE_MATCH_2}${TWX_TREE_RECORD_SEP}${CMAKE_MATCH_3}" )
      endwhile ()
    elseif ( value_ MATCHES "[${TWX_TREE_GROUP_SEP}${TWX_CHAR_STX}${TWX_TREE_RECORD_SEP}]" )
      if ( NOT value_ MATCHES "^${TWX_TREE_HEADER}" )
        twx_tree_prettify ( "${value_}" IN_VAR value_ )
        twx_fatal ( "WTH: ${value_}" )
        return ()
      endif ()
      twx_tree_prettify ( "${value_}" IN_VAR value_ )
      twx_fatal ( "Unexpected value: ${value_}" )
      return ()
    else ()
      string ( APPEND tree_ "${TWX_TREE_GROUP_SEP}${key_}${TWX_TREE_RECORD_SEP}${value_}" )
    endif ()
    while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}${key_}/${TWX_TREE_RECORD_SEP}(.*)$" )
      set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
    endwhile ()
    # message ( "DEBUG: key_ => ${key_}")
  endforeach ()
  twx_export (
    "${twxR_TREE}=${tree_}"
    "TWX_IS_TREE_${twxR_TREE}=ON"
  )
endfunction ()

# ANCHOR: twx_tree_remove
#[=======[
*/
/** @brief Remove values for given keys
  *
  * Remove values from a tree.
  * If you remove all the values, you obtain a void tree.
  *
  * @param tree for key TREE, the optional name of a tree. Defaults to `TWX_TREE`.
  *   The variable must be defined.
  * @param ... for key KEYS non empty list of keys.
  */
twx_tree_remove(tree ... ) {}
/*
#]=======]
function ( twx_tree_remove )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_tree_remove )
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "REMEMBER" "TREE" "KEYS" )
  twx_arg_assert_parsed ()
  if ( "${twxR_TREE}" STREQUAL "" )
    set ( twxR_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twxR_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    return ( )
  endif ()
  foreach ( key_ ${twxR_KEYS} )
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
  endforeach ()
  twx_export (
    "${twxR_TREE}=${tree_}"
    "TWX_IS_TREE_${twxR_TREE}=ON"
  )
endfunction ()

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
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "" "TREE;PREFIX" "" )
  twx_arg_assert_parsed ()
  if ( "${twxR_TREE}" STREQUAL "" )
    set ( twxR_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twxR_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    return ( )
  endif ()
  twx_arg_assert_parsed ()
  if ( "${twxR_PREFIX}" STREQUAL ""  )
    set ( p_ )
  else ()
    set ( p_ "${twxR_PREFIX}_" )
  endif ()
  # simple values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}([^/${TWX_TREE_RECORD_SEP}]+)${TWX_TREE_RECORD_SEP}([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    twx_export (
      "${p_}${CMAKE_MATCH_2}=${CMAKE_MATCH_3}"
      "TWX_IS_TREE_${p_}${CMAKE_MATCH_2}" UNSET
    )
  endwhile ()
  # Tree values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}([^${TWX_TREE_RECORD_SEP}]+)/([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    set ( key_ "${CMAKE_MATCH_2}" )
    set ( value_ "${TWX_TREE_HEADER}${TWX_TREE_GROUP_SEP}${CMAKE_MATCH_3}" )
    while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}${key_}/([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
      set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
      string ( APPEND value_ "${TWX_TREE_GROUP_SEP}${CMAKE_MATCH_2}" )
    endwhile ()
    twx_export ( VAR ${p_}${CMAKE_MATCH_2} VALUE "${CMAKE_MATCH_3}" )
    twx_export ( VAR TWX_IS_TREE_${p_}${CMAKE_MATCH_2} VALUE ON )
  endwhile ()
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
  cmake_parse_arguments ( PARSE_ARGV 0 twxR "NO_BANNER" "TREE" "" )
  twx_arg_assert_parsed ()
  if ( "${twxR_TREE}" STREQUAL "" )
    set ( twxR_TREE TWX_TREE )
  endif ()
  set ( tree_ "${${twxR_TREE}}" )
  if ( NOT tree_ MATCHES "^${TWX_TREE_HEADER}" )
    return ()
  endif ()
  if ( NOT twxR_NO_BANNER )
    message ( "${twxR_TREE}:" )
  endif ()
  set ( CMAKE_MESSAGE_CONTEXT_SHOW OFF )
  list ( APPEND CMAKE_MESSAGE_INDENT "  " )
  # simple values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}([^/${TWX_TREE_RECORD_SEP}]+)${TWX_TREE_RECORD_SEP}([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    message ( "${CMAKE_MATCH_2}: ${CMAKE_MATCH_3}" )
  endwhile ()
  # Tree values
  while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}([^${TWX_TREE_RECORD_SEP}]+)/([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
    set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
    set ( key_ "${CMAKE_MATCH_2}" )
    set ( value_ "${TWX_TREE_HEADER}${TWX_TREE_GROUP_SEP}${CMAKE_MATCH_3}" )
    while ( tree_ MATCHES "^(.*)${TWX_TREE_GROUP_SEP}${key_}/([^${TWX_TREE_GROUP_SEP}]*)(.*)$" )
      set ( tree_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
      string ( APPEND value_ "${TWX_TREE_GROUP_SEP}${CMAKE_MATCH_2}" )
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
function ( twx_tree_prettify twxR_MSG .IN_VAR twxR_IN_VAR )
  twx_arg_assert_count ( "${ARGC}" == 3 )
  twx_arg_assert_keyword ( .IN_VAR )
  twx_assert_variable ( "${twxR_IN_VAR}" )
  string ( REPLACE "${TWX_TREE_ESC}"        "<ESC>"   twxR_MSG "${twxR_MSG}" )
  string ( REPLACE "${TWX_TREE_FILE_SEP}"   "<FS/>"   twxR_MSG "${twxR_MSG}" )
  string ( REPLACE "${TWX_TREE_GROUP_SEP}"  "<GS/>"   twxR_MSG "${twxR_MSG}" )
  string ( REPLACE "${TWX_TREE_RECORD_SEP}" "<RS/>"   twxR_MSG "${twxR_MSG}" )
  string ( REPLACE "${TWX_TREE_UNIT_SEP}"   "<US/>"   twxR_MSG "${twxR_MSG}" )
  set ( ${twxR_IN_VAR} "${twxR_MSG}" PARENT_SCOPE )
endfunction ()

# TODO: at the end of each library, list the twx functions and constants used
#[=======[
Used
twx_arg_assert_parsed
twx_fatal
TWX_CORE_VARIABLE_RE
twx_export
twx_regex_escape
twx_arg_assert_keyword
#]=======]

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMessageLib.cmake" )

message ( VERBOSE "Loaded: TwxTreeLib" )

#*/
