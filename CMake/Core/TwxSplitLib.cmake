#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Split utility
  *
  *   include (
  *    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwSplitLib.cmake"
  *   )
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# ANCHOR: twx_split_assign
#[=======[
*/
/** @brief Split "<key>=<value>"
  *
  * Split "<key>=<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  *
  * @param kv, value to split when either key and value or var is provided,
  *   the name af the variable that contains the value otherwise.
  *   In that case, this is also the base name of the output variables.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return. Undefined when the entry does not match.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  * @param var for key `IN_VAR`, base name of the variables that
  *   will hold the key and the value on return.
  *   Either key and value or var must be provided.
  *   If var is provide, the key is stored in <var>.key
  *   and the value is stored in <key>.value.
  */
twx_split_assign(kv [IN_VAR var|IN_KEY key IN_VALUE value]) {}
/*
#]=======]
function ( twx_split_assign )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  # One of the arguments may be a variable name: avoid collisions
  cmake_parse_arguments (
    PARSE_ARGV 0 twx_split_assign.R
    "" "IN_VAR;IN_KEY;IN_VALUE" ""
  )
  list ( POP_FRONT twx_split_assign.R_UNPARSED_ARGUMENTS twx_split_assign.R_KV )
  twx_arg_assert_parsed ( PREFIX twx_split_assign.R )
  if ( DEFINED twx_split_assign.R_IN_VAR )
    # message ( TR@CE "1)" )
    twx_assert_undefined ( twx_split_assign.R_IN_KEY twx_split_assign.R_IN_VALUE )
    twx_var_assert_name ( "${twx_split_assign.R_IN_VAR}" )
    set ( twx_split_assign.R_IN_KEY ${twx_split_assign.R_IN_VAR}.key )
    set ( twx_split_assign.R_IN_VALUE ${twx_split_assign.R_IN_VAR}.value )
  elseif ( DEFINED twx_split_assign.R_IN_KEY )
    # message ( TR@CE "2)" )
    twx_assert_defined ( twx_split_assign.R_IN_VALUE )
    twx_assert_undefined ( twx_split_assign.R_IN_VAR )
    twx_var_assert_name ( "${twx_split_assign.R_IN_KEY}" "${twx_split_assign.R_IN_VALUE}" )
    twx_expect_unequal_string ( "${twx_split_assign.R_IN_KEY}" "${twx_split_assign.R_IN_VALUE}" )
  else ()
    # message ( TR@CE "3) twx_split_assign.R_KV => ``${twx_split_assign.R_KV}''" )
    twx_assert_undefined ( twx_split_assign.R_IN_VAR twx_split_assign.R_IN_VALUE )
    twx_var_assert_name ( "${twx_split_assign.R_KV}" )
    set ( twx_split_assign.R_IN_KEY ${twx_split_assign.R_KV}.key )
    set ( twx_split_assign.R_IN_VALUE ${twx_split_assign.R_KV}.value )
    set ( twx_split_assign.R_KV "${${twx_split_assign.R_KV}}")
  endif ()
  if ( twx_split_assign.R_KV MATCHES "^([^=]+)=(.*)$" )
    set ( ${twx_split_assign.R_IN_KEY} "${CMAKE_MATCH_1}" PARENT_SCOPE )
    set ( ${twx_split_assign.R_IN_VALUE} "${CMAKE_MATCH_2}" PARENT_SCOPE )
    # message ( TR@CE "${twx_split_assign.R_IN_KEY} => ``${CMAKE_MATCH_1}''" )
    # message ( TR@CE "${twx_split_assign.R_IN_VALUE} => ``${CMAKE_MATCH_2}''" )
  elseif ( twx_split_assign.R_KV MATCHES "^=" )
    twx_fatal ( "Unexpected argument: ${twx_split_assign.R_KV}" )
    return ()
  else ()
    set ( ${twx_split_assign.R_IN_KEY} "${twx_split_assign.R_KV}" PARENT_SCOPE )
    unset ( ${twx_split_assign.R_IN_VALUE} PARENT_SCOPE )
    # unset ( ${twx_split_assign.R_IN_VALUE} )
    # if ( DEFINED ${twx_split_assign.R_IN_VALUE} )
    #   message ( TR@CE "${twx_split_assign.R_IN_VALUE} DEFINED" )
    # else ()
    #   message ( TR@CE "${twx_split_assign.R_IN_VALUE} UNDEFINED" )
    # endif ()
    # message ( TR@CE "${twx_split_assign.R_IN_KEY} => ``${twx_split_assign.R_KV}''" )
    # message ( TR@CE "${twx_split_assign.R_IN_VALUE} => Unset" )
  endif ()
endfunction ()

# ANCHOR: twx_split_compare
#[=======[
*/
/** @brief Split "<lhs><op><rhs>"
  *
  * Split "<lhs>=<rhs>" arguments into "<lhs>", "<op>" and "<rhs>".
  *
  * @param comparison, value to split.
  * @param left for key `IN_LEFT`, name of the variable that
  *   will hold the left value on return.
  * @param op for key `IN_OP`, name of the variable that
  *   will hold the number operator name on return.
  * @param right for key `IN_RIGHT`, name of the variable that
  *   will hold the right value on return.
  * @param negate for key `IN_NEGATE`, name of the variable that
  *   will hold the negation on return. This is necessary because
  *   there is not `!=` comparison in CMake.
  */
twx_split_compare(comparison IN_LEFT left IN_OP op IN_RIGHT right IN_NEGATE negate) {}
/*
#]=======]
function ( twx_split_compare twx.R_COMPARISON )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  twx_arg_assert_count ( ${ARGC} = 9 )
  cmake_parse_arguments (
    PARSE_ARGV 1 twx.R
    "" "IN_LEFT;IN_OP;IN_RIGHT;IN_NEGATE" ""
  )
  twx_var_assert_name ( "${twx.R_IN_LEFT}" "${twx.R_IN_OP}" "${twx.R_IN_RIGHT}" "${twx.R_IN_NEGATE}" )
  twx_expect_unequal_string ( "${twx.R_IN_LEFT}"    "${twx.R_IN_OP}"     )
  twx_expect_unequal_string ( "${twx.R_IN_OP}"      "${twx.R_IN_RIGHT}"  )
  twx_expect_unequal_string ( "${twx.R_IN_RIGHT}"   "${twx.R_IN_NEGATE}" )
  twx_expect_unequal_string ( "${twx.R_IN_NEGATE}"  "${twx.R_IN_LEFT}"   )
  twx_expect_unequal_string ( "${twx.R_IN_LEFT}"    "${twx.R_IN_RIGHT}"  )
  twx_expect_unequal_string ( "${twx.R_IN_OP}"      "${twx.R_IN_NEGATE}" )
  if ( twx.R_COMPARISON MATCHES "^(!?)([^<>=!]+)([<>=!]+)([^<>=!]+)$"    )
    set ( ${twx.R_IN_LEFT} ${CMAKE_MATCH_2} PARENT_SCOPE )
    set ( ${twx.R_IN_RIGHT} ${CMAKE_MATCH_4} PARENT_SCOPE )
    if ( CMAKE_MATCH_1 )
      set ( ${twx.R_IN_NEGATE} ON PARENT_SCOPE )
    else ()
      set ( ${twx.R_IN_NEGATE} OFF PARENT_SCOPE )
    endif ()
    # message ( TR@CE "CMAKE_MATCH_3 => ``${CMAKE_MATCH_3}''" )
    if ( CMAKE_MATCH_3 STREQUAL "<=")
      set ( ${twx.R_IN_OP} LESS_EQUAL PARENT_SCOPE )
    elseif ( CMAKE_MATCH_3 STREQUAL ">=")
      set ( ${twx.R_IN_OP} GREATER_EQUAL PARENT_SCOPE )
    elseif ( CMAKE_MATCH_3 STREQUAL "==" OR CMAKE_MATCH_3 STREQUAL "=")
      set ( ${twx.R_IN_OP} EQUAL PARENT_SCOPE )
    elseif ( CMAKE_MATCH_3 STREQUAL "!=" OR CMAKE_MATCH_3 STREQUAL "<>")
      set ( ${twx.R_IN_OP} EQUAL PARENT_SCOPE )
      if ( CMAKE_MATCH_1 )
        set ( ${twx.R_IN_NEGATE} OFF PARENT_SCOPE )
      else ()
        set ( ${twx.R_IN_NEGATE} ON PARENT_SCOPE )
      endif ()
    elseif ( CMAKE_MATCH_3 STREQUAL "<")
      set ( ${twx.R_IN_OP} LESS PARENT_SCOPE )
    elseif ( CMAKE_MATCH_3 STREQUAL ">")
      set ( ${twx.R_IN_OP} GREATER PARENT_SCOPE )
    else ()
      twx_fatal ( "Bad comparison operator in ``${twx.R_COMPARISON}''")
    endif ()
  else ()
    twx_fatal ( "Missing comparison operator in ``${twx.R_COMPARISON}''")
  endif ()
endfunction ()

# ANCHOR: twx_split_append
#[=======[
*/
/** @brief Split "<key>=<<<value>"
  *
  * Split "<key>=<<<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  * "<key>" is the name of a list to which "<value>" is appended.
  * This name must not contain an `=` sign.
  *
  * @param ..., non empty list of values to split.
  */
twx_split_append(...) {}
/*
#]=======]
function ( twx_split_append .kv )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  set ( i 0 )
  set ( ARGV${ARGC} )
  while ( DEFINED ARGV${i} )
    if ( "${ARGV${i}}" MATCHES "^([^=]+)=<<(.*)$" )
    message ( DEBUG "${CMAKE_MATCH_1} =<< ``${CMAKE_MATCH_2}''" )
    list ( APPEND "${CMAKE_MATCH_1}" "${CMAKE_MATCH_2}" )
      set ( "${CMAKE_MATCH_1}" "${${CMAKE_MATCH_1}}" PARENT_SCOPE )
    else ()
      twx_fatal ( "Unexpected argument: ${twx.R_KV}" )
      return ()
    endif ()
    twx_increment ( VAR i )
  endwhile ()
endfunction ()

# ANCHOR: twx_split_prepend
#[=======[
*/
/** @brief Split "<key><<=<value>"
  *
  * Split "<key><<=<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  * "<key>" is the name of a list to which "<value>" is appended.
  * This name must not contain an `=` sign.
  *
  * @param ..., non empty list of values to split.
  */
twx_split_prepend(...) {}
/*
#]=======]
function ( twx_split_prepend .kv )
  twx_cmd_begin ( ${CMAKE_CURRENT_FUNCTION} )
  set ( i 0 )
  set ( ARGV${ARGC} )
  while ( DEFINED ARGV${i} )
    if ( "${ARGV${i}}" MATCHES "^([^=]+)=>>(.*)$" )
      message ( DEBUG "${CMAKE_MATCH_1} =>> ``${CMAKE_MATCH_2}''" )
      list ( PREPEND "${CMAKE_MATCH_1}" "${CMAKE_MATCH_2}" )
      set ( "${CMAKE_MATCH_1}" "${${CMAKE_MATCH_1}}" PARENT_SCOPE )
    else ()
      twx_fatal ( "Unexpected argument: ${twx.R_KV}" )
      return ()
    endif ()
    twx_increment ( VAR i )
  endwhile ()
endfunction ()

twx_lib_require ( "Fatal" "Expect" "Arg" )

twx_lib_did_load ()

#*/
