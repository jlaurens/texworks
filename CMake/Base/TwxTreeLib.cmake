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
  * - keys and values must not contain the 4 characters with ascii code 28 to 31
  * - keys must not contain any character of `=;/`
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

string ( ASCII 01 /TWX/TREE/MARK   )
string ( ASCII 02 /TWX/TREE/START  )
string ( ASCII 29 /TWX/TREE/RECORD )
string ( ASCII 30 /TWX/TREE/SEP    )
string ( ASCII 26 /TWX/TREE/PLACEHOLDER_START )
string ( ASCII 27 /TWX/TREE/PLACEHOLDER_END   )

set ( /TWX/TREE/HEADER "${/TWX/TREE/MARK}/TWX/TREE${/TWX/TREE/START}" )

# ANCHOR: twx_tree_assert
#[=======[
*/
/** @brief Raises when the argument is not a tree name
  *
  * @param ... for key TREE, optional list of variable names that defaults to `/TWX/TREE/DEFAULT` when empty.
  */
twx_tree_assert(...) {}
/*
#]=======]
macro ( twx_tree_assert )
  # One of the arguments can be a variable name: avoid collision
  cmake_parse_arguments ( twx_tree_assert.R "BREAK;RETURN" "" "TREE" ${ARGV} )
  if ( DEFINED twx_tree_assert.R_UNPARSED_ARGUMENTS )
    foreach (twx_tree_assert.x IN LISTS twx_tree_assert.R_UNPARSED_ARGUMENTS )
      if ( NOT "${twx_tree_assert.x}" MATCHES "^${/TWX/TREE/HEADER}" )
        twx_fatal ( "Not a tree content: ``${twx_tree_assert.x}''" )
        if (twx_tree_assert.R_BREAK )
          set ( twx_tree_assert.BREAK ON )
          break ()
        elseif (twx_tree_assert.R_RETURN )
          return ()
        endif ()
      endif ()
    endforeach ()
    if (twx_tree_assert.BREAK )
      break ()
    endif ()
  elseif ( NOT DEFINED twx_tree_assert.R_TREE )
    set ( twx_tree_assert.R_TREE "/TWX/TREE/DEFAULT" )
  endif ()
  foreach (twx_tree_assert.x ${twx_tree_assert.R_TREE} )
    if ( NOT "${${twx_tree_assert.x}}" MATCHES "^${/TWX/TREE/HEADER}" )
      twx_fatal ( "Not a tree" VAR ${twx_tree_assert.x} )
      if (twx_tree_assert.R_BREAK )
        set ( twx_tree_assert.BREAK ON )
        break ()
      elseif (twx_tree_assert.R_RETURN )
        return ()
      endif ()
    endif ()
  endforeach ()
  if (twx_tree_assert.BREAK )
    break ()
  endif ()
  foreach ( twx_tree_assert.x TREE BREAK RETURN UNPARSED_ARGUMENTS KEYWORDS_MISSING_VALUES)
    set ( twx_tree_assert.R_${twx_tree_assert.x} )
  endforeach ()
  set ( twx_tree_assert.R_${twx_tree_assert.x} )

endmacro ()

# ANCHOR: twx_tree_init
#[=======[
*/
/** @brief Initialize a tree
  *
  * Put the tree variable in an initial tree state.
  * The corresponding `/TWX/IS_TREE/...` variable is also set.
  *
  * @param tree for key TREE, an optional list of tree name.
  *   Defaults to `/TWX/TREE/DEFAULT`.
  */
twx_tree_init([tree]) {}
/*
#]=======]
function ( twx_tree_init )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "" "TREE"
  )
  twx_arg_assert_parsed ( PREFIX )
  if ( NOT DEFINED ${TWX_CMD}.R_TREE )
    set ( ${TWX_CMD}.R_TREE /TWX/TREE/DEFAULT )
  endif ()
  foreach ( ${TWX_CMD}.T ${${TWX_CMD}.R_TREE} )
    twx_var_assert_name ( "${${TWX_CMD}.T}" )
    twx_export (
      "${${TWX_CMD}.T}=${/TWX/TREE/HEADER}"
      "/TWX/IS_TREE/${${TWX_CMD}.T}=ON"
    )
  endforeach ()
endfunction ( twx_tree_init )

# ANCHOR: /TWX/TREE/KEY_RE
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
/TWX/TREE/KEY_RE;
/*#]=======]
set (
  /TWX/TREE/KEY_RE
  "([a-zA-Z_.+-]|\\[^a-zA-Z;]|\\[trn]|\\;)([a-zA-Z0-9_.+-]|\\[^a-zA-Z0-9;]|\\[trn]|\\;)*"
)

# ANCHOR: twx_tree_assert_key
#[=======[
*/
/** @brief Raise if one argument is not a suitable key name
  *
  * Actually a key is just a variable name, but this may change in the future.
  * @param ... non empty list of candidates.
  */
twx_tree_assert_key(key ...) {}
/*
#]=======]
function ( twx_tree_assert_key .key )
  twx_function_begin ()
  set ( i 0 )
  while ( TRUE )
    set ( k "${ARGV${i}}" )
    if ( NOT "${k}" MATCHES "^/?(${/TWX/TREE/KEY_RE}/)*${/TWX/TREE/KEY_RE}$" )
      twx_fatal ( "Forbidden key: ${k}" )
      return ()
    endif ()
    if ( "${k}" MATCHES "[=${/TWX/TREE/SEP}]" )
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
  * @param tree for key TREE, the optional name of a tree. Defaults to `/TWX/TREE/DEFAULT`.
  *   The variable must be defined.
  * @param var for key IN_VAR, will hold the result on return.
  *   The result is a list of keys separated by the `/TWX/TREE/RECORD`
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
    set ( twx.R_TREE "/TWX/TREE/DEFAULT" )
  endif ()
  twx_tree_assert ( TREE "${twx.R_TREE}" )
  twx_var_assert_name ( "${twx.R_IN_VAR}" )
  set ( "${twx.R_IN_VAR}" )
  if ( twx.R_PREFIX )
    twx_regex_escape ( "${twx.R_PREFIX}" IN_VAR prefix_ )
  else ()
    set ( prefix_ )
  endif ()
  while ( "${${twx.R_TREE}}" MATCHES "^(.*)${/TWX/TREE/RECORD}(.*)${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*(.*)$" )
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
  *   Moreover, `/TWX/IS_TREE/<var>` is set if the result is a tree,
  *   unset otherwise.
  *   If var is not provided, `<tree>/<key>` is used instead.
  * @param tree for key TREE, optional name of a tree. Defaults to `/TWX/TREE/DEFAULT`.
  *   Raise when not a tree.
  */
twx_tree_get([TREE tree] KEY key [IN_VAR var]) {}
/*
#]=======]
function ( twx_tree_get )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "TREE;KEY;IN_VAR" ""
  )
  twx_arg_assert_parsed ( PREFIX )
  if ( NOT DEFINED "${TWX_CMD}.R_TREE" )
    set ( ${TWX_CMD}.R_TREE "/TWX/TREE/DEFAULT" )
  endif ()
  twx_tree_assert_key ( "${${TWX_CMD}.R_KEY}" )
  if ( NOT DEFINED ${TWX_CMD}.R_IN_VAR )
    set ( ${TWX_CMD}.R_IN_VAR "${${TWX_CMD}.R_TREE}/${${TWX_CMD}.R_KEY}" )
  endif ()
  twx_var_assert_name ( "${${TWX_CMD}.R_IN_VAR}" )
  twx_tree_assert ( TREE "${${TWX_CMD}.R_TREE}" )
  # message ( TR@CE "${${TWX_CMD}.R_TREE}[${${TWX_CMD}.R_KEY}] => ${${TWX_CMD}.R_IN_VAR}")
  set ( ${TWX_CMD}.TREE "${${${TWX_CMD}.R_TREE}}" )
  twx_regex_escape ( "${${TWX_CMD}.R_KEY}" IN_VAR ${TWX_CMD}.GET_SCPD )
  # message ( TR@CE "0) ``${${TWX_CMD}.R_KEY}'' => ``${${TWX_CMD}.GET_SCPD}''" )
  if ( "${${TWX_CMD}.TREE}" MATCHES "${/TWX/TREE/RECORD}${${TWX_CMD}.GET_SCPD}${/TWX/TREE/SEP}([^${/TWX/TREE/RECORD}]*)" )
    # message ( TR@CE "0) ``${TWX_CMD}.R_IN_VAR => ''${${TWX_CMD}.R_IN_VAR}\"" )
    # message ( TR@CE "0) ``CMAKE_MATCH_1 => ''${CMAKE_MATCH_1}\"" )
    twx_export ( "${${TWX_CMD}.R_IN_VAR}=${CMAKE_MATCH_1}" )
    twx_export ( "/TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR}" UNSET )
    return ()
  endif ()
  # twx_tree_prettify ( MSG "${${TWX_CMD}.TREE}" IN_VAR pretty_ )
  # message ( TR@CE "SUBTREE/ ${TWX_CMD}.TREE => ``${${TWX_CMD}.TREE}'' => ``${pretty_}''" )
  set ( ${TWX_CMD}.RE "^(.*)${/TWX/TREE/RECORD}${${TWX_CMD}.GET_SCPD}/(([^${/TWX/TREE/SEP}]*)${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*)(.*)$" )
  # message ( TR@CE "0) ${k_} ${${TWX_CMD}.GET_SCPD}" )
  # if ( "${${TWX_CMD}.TREE}" MATCHES "^(.*)${/TWX/TREE/RECORD}" )
  #   # message ( TR@CE "1)" )
  # endif ()
  # if ( "${${TWX_CMD}.TREE}" MATCHES "^(.*)${/TWX/TREE/RECORD}${${TWX_CMD}.GET_SCPD}" )
  #   # message ( TR@CE "2)" )
  # endif ()
  # if ( "${${TWX_CMD}.TREE}" MATCHES "^(.*)${/TWX/TREE/RECORD}${${TWX_CMD}.GET_SCPD}/" )
  #   # message ( TR@CE "3)" )
  # endif ()
  if ( "${${TWX_CMD}.TREE}" MATCHES "${${TWX_CMD}.RE}" )
    # message ( TR@CE "EXPORT /TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR}=ON" )
    twx_export ( "/TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR}=ON" )
    set ( ${TWX_CMD}.VALUE "${/TWX/TREE/HEADER}" )
    while ( TRUE )
      set ( "${TWX_CMD}.TREE" "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
      # twx_tree_prettify ( MSG "${${TWX_CMD}.TREE}" IN_VAR pretty_ )
      # message ( TR@CE "WHILE: ${TWX_CMD}.TREE => ``${${TWX_CMD}.TREE}'' => ``${pretty_}''" )
      if ( NOT "${CMAKE_MATCH_3}" STREQUAL "" )
        string ( APPEND ${TWX_CMD}.VALUE "${/TWX/TREE/RECORD}${CMAKE_MATCH_2}")
      endif ()
      if ( NOT "${${TWX_CMD}.TREE}" MATCHES "${${TWX_CMD}.RE}" )
        break ()
      endif ()
    endwhile ()
    twx_export (
      "${${TWX_CMD}.R_IN_VAR}=${${TWX_CMD}.VALUE}"
      "/TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR}=ON"
    )
    # message ( TR@CE "TREE RETURN: " )
    return ()
  endif ()
  # message ( TR@CE "VOID RETURN (${${TWX_CMD}.R_IN_VAR})" )
  set ( /TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR} )
  twx_export (
    ${${TWX_CMD}.R_IN_VAR}
    /TWX/IS_TREE/${${TWX_CMD}.R_IN_VAR}
    UNSET
  )
endfunction ( twx_tree_get )

# ANCHOR: twx_tree_set
#[=======[
*/
/** @brief Set a value
  *
  * Set a value into a tree
  *
  * @param tree for key TREE, optional name of a tree. Defaults to `/TWX/TREE/DEFAULT`.
  * The variable must be defined.
  * @param ... non empty list of `<key path>[=<value>]` formatted strings.
  *   A key path takes the form `<key_1>[/<key_i>]*`
  *   Enclose these arguments into quotes if they should contain spaces.
  */
twx_tree_set([TREE tree] ... ) {}
/*
#]=======]
function ( twx_tree_set )
  twx_function_begin ()
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE" "" )
  # message ( TR@CE "Parsed: twx.R_TREE => ``${twx.R_TREE}''")
  if ( DEFINED "twx.R_TREE" )
    set ( i 2 )
  else ()
    set ( twx.R_TREE "/TWX/TREE/DEFAULT" )
    set ( i 0 )
  endif ()
  twx_tree_assert ( TREE "${twx.R_TREE}" )
  twx_arg_assert_count ( ${ARGC} > "${i}" )
  while ( TRUE )
    set ( kv_ "${ARGV${i}}" )
    # message ( TR@CE "kv_ => ``${kv_}''")
    twx_split_assign ( "${kv_}" IN_KEY key_ IN_VALUE value_ )
    # message ( TR@CE "key_ => ``${key_}''")
    # message ( TR@CE "value_ => ``${value_}''")

    # block ()
    #   twx_tree_prettify ( MSG "${value_}" IN_VAR value_ )
    #   message ( TRACE "WILL REMOVE ``${key_}'': ${twx.R_TREE}[${key_}] <= ${value_}")
    # endblock ()
    twx_tree_remove ( TREE "${twx.R_TREE}"  KEY "${key_}" )
    # block ()
    #   twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR value_ )
    #   message ( TRACE "DID REMOVE ``${key_}'': ${twx.R_TREE} => ${value_}")
    # endblock ()
    if ( NOT DEFINED value_ )
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
      continue ()
    endif ()
    if ( "${value_}" MATCHES "^${/TWX/TREE/HEADER}" )
      twx_tree_assert ( TREE value_ )
      twx_tree_get_keys ( TREE "value_" IN_VAR "keys_" )
      if ( keys_ )
        foreach ( k_ ${keys_} )
          twx_tree_get ( TREE "value_" KEY "${k_}" IN_VAR v_ )
          string ( APPEND "${twx.R_TREE}" "${/TWX/TREE/RECORD}${key_}/${k_}${/TWX/TREE/SEP}${v_}" )
          # message ( TR@CE "${twx.R_TREE}[``${key_}/${k_}''] <= ``${v_}''")
          twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR pretty )
          # message ( TR@CE "``${twx.R_TREE}'' => ``${pretty}''" )
        endforeach ()
      else ()
        string ( APPEND "${twx.R_TREE}" "${/TWX/TREE/RECORD}${key_}/${/TWX/TREE/SEP}" )
      endif ()
      twx_increment_and_break_if ( VAR i >= ${ARGC} )
      continue ()
    elseif ( value_ MATCHES "[${/TWX/TREE/RECORD}${/TWX/CHAR/STX}${/TWX/TREE/SEP}]" )
      twx_tree_prettify ( MSG "${value_}" IN_VAR value_ )
      twx_fatal ( "Unexpected value: ${value_}" )
      return ()
    else ()
      string ( APPEND "${twx.R_TREE}" "${/TWX/TREE/RECORD}${key_}${/TWX/TREE/SEP}${value_}" )
    endif ()
    # block ()
    #   twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
    #   # message ( TR@CE "tree => ``${m}''")
    # endblock ()
    twx_regex_escape ( "${key_}" IN_VAR scpd_key_ )
    while ( "${${twx.R_TREE}}" MATCHES "^(.*)${/TWX/TREE/RECORD}${scpd_key_}/${/TWX/TREE/SEP}(.*)$" )
      set ( ${twx.R_TREE} "${CMAKE_MATCH_1}${CMAKE_MATCH_2}" )
    endwhile ()
    # block ()
    #   twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR pretty )
    #   message ( TRACE "twx.R_TREE => ``${pretty}''")
    # endblock ()
    twx_increment_and_break_if ( VAR i >= ${ARGC} )
  endwhile ()
  twx_export (
    "${twx.R_TREE}=${${twx.R_TREE}}"
    "/TWX/IS_TREE/${twx.R_TREE}=ON"
  )
endfunction ( twx_tree_set )

# ANCHOR: twx_tree_remove
#[=======[
*/
/** @brief Remove values for given keys
  *
  * Remove values from a tree.
  *
  * @param tree, the optional name of a tree. Defaults to `/TWX/TREE/DEFAULT`.
  *   The variable must be defined.
  * @param ... for key KEY, non empty list of keys.
  * When the key matches `^m(.)(.*)\1$` then the key is in fact a regular
  * expression corresponding to the second capturing group.
  */
twx_tree_remove(TREE tree KEY ...) {}
/*
#]=======]
function ( twx_tree_remove )
  twx_function_begin ()
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "TREE" "KEY" )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED twx.R_TREE )
    set ( twx.R_TREE /TWX/TREE/DEFAULT )
  endif ()
  twx_tree_assert ( TREE "${twx.R_TREE}" )
  # block ()
  #   twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
  #   message ( TR@CE "${twx.R_TREE} => ``${m}''" )
  # endblock ()
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
              "${/TWX/TREE/RECORD}${removed_scpd_}${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*"
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
          "${/TWX/TREE/RECORD}${removed_scpd_}${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "A) ${twx.R_TREE} => ``${m}''" )
      endif ()
      if ( "${k_}" MATCHES "^${removed_scpd_}/" )
        # message ( TR@CE "B0) removed_key_ => ``${removed_key_}''" )
        # message ( TR@CE "B0) parent_ => ``${parent_}''" )
        twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B0) ${twx.R_TREE} => ``${m}''" )
        string (
          REGEX REPLACE
          "${/TWX/TREE/RECORD}${removed_scpd_}/[^${/TWX/TREE/SEP}]*${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B1) ${twx.R_TREE} => ``${m}''" )
        # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B2) ${twx.R_TREE} => ``${m}''" )
        if ( NOT "${parent_}" STREQUAL "" )
          string ( APPEND "${twx.R_TREE}" "${/TWX/TREE/RECORD}${parent_}/${/TWX/TREE/SEP}")
        endif ()
        # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "B3) ${twx.R_TREE} => ``${m}''" )
      elseif ( "${k_}" MATCHES "^${removed_scpd_}$" )
        string (
          REPLACE
          "${/TWX/TREE/RECORD}${k_}${/TWX/TREE/SEP}[^${/TWX/TREE/RECORD}]*"
          ""
          "${twx.R_TREE}"
          "${${twx.R_TREE}}"
        )
        # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
        # message ( TR@CE "C1) ${twx.R_TREE} => ``${m}''" )
        if ( NOT "${parent_}" STREQUAL "" )
          string ( APPEND "${twx.R_TREE}" "${/TWX/TREE/RECORD}${parent_}/${/TWX/TREE/SEP}")
        endif ()
        # twx_tree_prettify ( MSG "${${twx.R_TREE}}" IN_VAR m )
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
  * define the variable named `<prefix><key>` to have <value>.
  *
  * @param tree, the optional name of a tree. Defaults to `/TWX/TREE/DEFAULT`.
  *   The variable must be defined.
  * @param prefix for key `PREFIX` optional non empty key prefix,
  *   defaults to `/TWX/TREE/EXPOSED/`.
  */
twx_tree_expose(TREE tree [PREFIX prefix]) {}
/*
#]=======]
function ( twx_tree_expose )
  twx_function_begin ()
  # twx_var_log ( DEBUG ARGC )
  # twx_var_log ( DEBUG ARGV )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "PREFIX;TREE" "" )
  twx_arg_assert_parsed ()
  twx_var_log ( DEBUG twx.R_PREFIX )
  if ( NOT DEFINED twx.R_TREE )
    set ( twx.R_TREE /TWX/TREE/DEFAULT )
  endif ()
  twx_var_log ( DEBUG twx.R_TREE )
  twx_tree_assert ( TREE ${twx.R_TREE} RETURN )
  twx_tree_log ( DEBUG TREE "${twx.R_TREE}" )
  twx_arg_assert_parsed ()
  if ( "${twx.R_PREFIX}" MATCHES "_$" )
    set ( p_ "${twx.R_PREFIX}" )
  elseif ( "${twx.R_PREFIX}" MATCHES "^(.*[^/])/*$" )
    set ( p_ "${CMAKE_MATCH_1}/" )
  elseif ( DEFINED twx.R_PREFIX )
    set ( p_ "${twx.R_PREFIX}/" )
  else ()
    set ( p_ )
  endif ()
  if ( DEFINED p_ )
    string ( REPLACE "${/TWX/PLACEHOLDER/EMPTY_STRING}" "" p_ "${p_}" )
  else ()
    set ( p_ "${twx.R_TREE}/" )
  endif ()
  twx_var_log ( DEBUG twx.R_PREFIX MSG "Prefix" )
  twx_var_log ( DEBUG p_ MSG "Real prefix" )
  twx_tree_get_keys ( TREE "${twx.R_TREE}" IN_VAR keys_ )
  set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
  foreach ( key_ ${keys_} )
    message ( TRACE "1) key_ => ``${key_}''" )
    if ( "${key_}" MATCHES "^([^/]*)/" )
      set ( base_ "${CMAKE_MATCH_1}" )
      # Tree values
      if ( "twx_tree_get_keys.${base_}.DONE" )
        message ( TRACE "2) continue" )
        continue ()
      endif ()
      set ( "twx_tree_get_keys.${base_}.DONE" "ON" )
      twx_tree_get_keys ( TREE "${twx.R_TREE}" IN_VAR subkeys_ PREFIX "${base_}/" RELATIVE )
      message ( TRACE "3) subkeys_ => ``${subkeys_}''" )
      twx_tree_init ( TREE twx_tree_expose.tree )
      foreach ( subkey_ ${subkeys_} )
        twx_tree_log ( TREE "${twx.R_TREE}" )
        twx_tree_get ( TREE "${twx.R_TREE}" IN_VAR v KEY "${base_}/${subkey_}" )
        message ( TRACE "4) ${twx.R_TREE}[``${subkeys_}''] => ``${v}''" )
        twx_tree_set ( TREE twx_tree_expose.tree "${subkey_}=${v}")
        message ( TRACE "5) subkey_ => ``${base_}/${subkey_}'' -> ``${v}''" )
      endforeach ()
      message ( TRACE "6) ${base_} =>" )
      twx_tree_log ( TREE "twx_tree_expose.tree" )
      twx_export (
        "${p_}${base_}=${twx_tree_expose.tree}"
        "/TWX/IS_TREE/${p_}${base_}=ON"
      ) 
    else ()
      # Flat value
      twx_tree_get ( TREE "${twx.R_TREE}" KEY "${key_}" IN_VAR v )
      message ( TRACE "4) ``${key_}'' -> ``${v}''" )
      twx_export (
        "${p_}${key_}=${v}"
        "/TWX/IS_TREE/${p_}${key_}" UNSET
      )
    endif ()
  endforeach ()
endfunction ()

# ANCHOR: twx_tree_log
#[=======[
*/
/** @brief Log a tree
  *
  * @param ..., the optional list of tree names.
  *   Defaults to `/TWX/TREE/DEFAULT`. The variable must be defined.
  * @param `NO_BANNER`, optional flag to suppress the banner.
  * @param var for key `IN_VAR`, optional name of the variable
  *   containing the resulting string on return.
  */
twx_tree_log(TREE tree ... [NO_BANNER] [IN_VAR var ...]) {}
/*
#]=======]
function ( twx_tree_log twx_tree_log.R_MODE )
  twx_function_begin ()
  if ( twx_tree_log.R_MODE IN_LIST /TWX/CONST/MESSAGE/MODES )
    set ( ${TWX_CMD}.FIRST_ARG 1 )
  else ()
    set ( twx_tree_log.R_MODE )
    set ( ${TWX_CMD}.FIRST_ARG 0 )
  endif ()
  cmake_parse_arguments (
    PARSE_ARGV ${${TWX_CMD}.FIRST_ARG} ${TWX_CMD}.R
    "NO_BANNER" "INDENT" "TREE;IN_VAR"
  )
  twx_arg_assert_parsed ()
  if ( NOT DEFINED ${TWX_CMD}.R_TREE )
    set ( ${TWX_CMD}.R_TREE /TWX/TREE/DEFAULT )
  endif ()
  foreach ( ${TWX_CMD}.T ${TWX_CMD}.V IN ZIP_LISTS ${TWX_CMD}.R_TREE ${TWX_CMD}.R_VAR )
    if ( NOT DEFINED ${TWX_CMD}.T )
      twx_var_log ( FATAL_ERROR ${TWX_CMD}.V MSG "Too many variables" )
    endif ()
    twx_tree_assert ( TREE "${${TWX_CMD}.T}" )
    block ( PROPAGATE ${TWX_CMD}.M )
      if ( NOT ${TWX_CMD}.R_NO_BANNER )
        set ( m_ "${${TWX_CMD}.R_INDENT}${${TWX_CMD}.T}:\n" )
        list ( APPEND ${TWX_CMD}.R_INDENT "  " )
      else ()
        set ( m_ )
      endif ()
      set ( t_ "${${${TWX_CMD}.T}}" )
      # simple values
      while ( t_ MATCHES "^(.*)${/TWX/TREE/RECORD}([^/${/TWX/TREE/SEP}]+)${/TWX/TREE/SEP}([^${/TWX/TREE/RECORD}]*)(.*)$" )
        set ( t_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
        string ( APPEND m_ "${${TWX_CMD}.R_INDENT}${CMAKE_MATCH_2}: ${CMAKE_MATCH_3}" )
      endwhile ()
      # Tree values
      while ( t_ MATCHES "^(.*)${/TWX/TREE/RECORD}([^${/TWX/TREE/SEP}]+)/([^${/TWX/TREE/RECORD}]*)(.*)$" )
        set ( t_ "${CMAKE_MATCH_1}${CMAKE_MATCH_4}" )
        set ( k_ "${CMAKE_MATCH_2}" )
        set ( v_ "${/TWX/TREE/HEADER}${/TWX/TREE/RECORD}${CMAKE_MATCH_3}" )
        while ( t_ MATCHES "^(.*)${/TWX/TREE/RECORD}${${TWX_CMD}.K}/([^${/TWX/TREE/RECORD}]*)(.*)$" )
          set ( t_ "${CMAKE_MATCH_1}${CMAKE_MATCH_3}" )
          string ( APPEND v_ "${/TWX/TREE/RECORD}${CMAKE_MATCH_2}" )
        endwhile ()
        string ( APPEND m_ "${${TWX_CMD}.R_INDENT}${k_}:" )
        twx_tree_log ( TREE v_ NO_BANNER IN_VAR m_ INDENT "${${TWX_CMD}.R_INDENT}  " )
      endwhile ()
      set ( ${TWX_CMD}.M "${m_}" )
    endblock ()
    if ( DEFINED ${TWX_CMD}.V )
      set ( ${${TWX_CMD}.V} "${m_}" PARENT_SCOPE )
    else ()
      message ( ${${TWX_CMD}.R_MODE} "${m_}" )
    endif ()
  endforeach ()
endfunction ()

# ANCHOR: twx_tree_prettify
#[=======[
*/
/** @brief Turn a tree content into human readable
  *
  * @param message, list of strings to manipulate.
  * @param var for key `IN_VAR` list of variable names.
  *   Each variable holds on return the human readable string
  *   for the corresponding message.
  */
twx_tree_prettify(MSG message IN_VAR var) {}
/*
#]=======]
function ( twx_tree_prettify )
  twx_function_begin ()
  cmake_parse_arguments (
    PARSE_ARGV 0 ${TWX_CMD}.R
    "" "" "MSG;IN_VAR"
  )
  twx_arg_assert_parsed ( PREFIX )
  foreach ( ${TWX_CMD}.M ${TWX_CMD}.V IN ZIP_LISTS ${TWX_CMD}.R_MSG ${TWX_CMD}.R_IN_VAR )
    if ( NOT DEFINED ${TWX_CMD}.M )
      twx_fatal ( "Unexpected variable" VAR ${TWX_CMD}.V RETURN )
    endif ()
    if ( NOT DEFINED ${TWX_CMD}.V )
      twx_fatal ( "Unexpected message" VAR ${TWX_CMD}.M RETURN )
    endif ()
    twx_var_assert_name ( "${${TWX_CMD}.V}" )
    string ( REPLACE "${/TWX/TREE/MARK}"   "<SOH>" ${TWX_CMD}.M "${${TWX_CMD}.M}" )
    string ( REPLACE "${/TWX/TREE/START}"  "<STX>" ${TWX_CMD}.M "${${TWX_CMD}.M}" )
    string ( REPLACE "${/TWX/TREE/RECORD}" "<GS/>" ${TWX_CMD}.M "${${TWX_CMD}.M}" )
    string ( REPLACE "${/TWX/TREE/SEP}"    "<RS/>" ${TWX_CMD}.M "${${TWX_CMD}.M}" )
    set ( ${${TWX_CMD}.V} "${${TWX_CMD}.M}" PARENT_SCOPE )
  endforeach ()
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
