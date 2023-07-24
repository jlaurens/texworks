#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Split utility
  *
  * include (
  *  "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwSplitLib.cmake"
  *  )
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
  * @param kv, value to split.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return. Undefined when the entry does not match.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  */
twx_split_assign(kv IN_KEY key IN_VALUE value) {}
/*
#]=======]
function ( twx_split_assign .kv .IN_KEY .key .IN_VALUE .value )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split_assign )
  # message ( TR@CE ".kv => \"${.kv}\"" )
  twx_arg_assert_count ( ${ARGC} = 5 )
  twx_arg_assert_keyword ( .IN_KEY .IN_VALUE )
  twx_assert_variable_name ( "${.key}" "${.value}" )
  twx_expect_unequal_string ( "${.key}" "${.value}" )
  if ( .kv MATCHES "^([^=]+)=(.*)$" )
    set ( ${.key} "${CMAKE_MATCH_1}" PARENT_SCOPE )
    set ( ${.value} "${CMAKE_MATCH_2}" PARENT_SCOPE )
    # message ( TR@CE "${.key} => \"${CMAKE_MATCH_1}\"" )
    # message ( TR@CE "${.value} => \"${CMAKE_MATCH_2}\"" )
  elseif ( .kv MATCHES "^=" )
    twx_fatal ( "Unexpected argument: ${.kv}" )
    return ()
  else ()
    set ( ${.key} "${.kv}" PARENT_SCOPE )
    unset ( ${.value} PARENT_SCOPE )
    unset ( ${.value} )
    # if ( DEFINED ${.value} )
    #   message ( TR@CE "${.value} DEFINED" )
    # else ()
    #   message ( TR@CE "${.value} UNDEFINED" )
    # endif ()
    # message ( TR@CE "${.key} => \"${.kv}\"" )
    # message ( TR@CE "${.value} => Unset" )
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
  *
  * @param kv, value to split.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return. Undefined when the entry does not match.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  */
twx_split_append(kv IN_KEY key IN_VALUE value) {}
/*
#]=======]
function ( twx_split_append .kv .IN_KEY .key .IN_VALUE .value )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split_append )
  # message ( TR@CE ".kv => \"${.kv}\"" )
  twx_arg_assert_count ( ${ARGC} = 5 )
  twx_arg_assert_keyword ( .IN_KEY .IN_VALUE )
  twx_assert_variable_name ( "${.key}" "${.value}" )
  twx_expect_unequal_string ( "${.key}" "${.value}" )
  if ( .kv MATCHES "^([^=]+)=<<(.*)$" )
    set ( ${.key} "${CMAKE_MATCH_1}" PARENT_SCOPE )
    set ( ${.value} "${CMAKE_MATCH_2}" PARENT_SCOPE )
  elseif ( .kv MATCHES "^=" )
    twx_fatal ( "Unexpected argument: ${.kv}" )
    return ()
  else ()
    set ( ${.key} "${.kv}" PARENT_SCOPE )
    unset ( ${.value} PARENT_SCOPE )
    unset ( ${.value} )
  endif ()
endfunction ()

# ANCHOR: twx_split_prepend
#[=======[
*/
/** @brief Split "<key><<=<value>"
  *
  * Split "<key><<=<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  * "<key>" is the name of a list to which "<value>" is appended.
  *
  * @param kv, value to split.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return. Undefined when the entry does not match.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  */
twx_split_prepend(kv IN_KEY key IN_VALUE value) {}
/*
#]=======]
function ( twx_split_prepend .kv .IN_KEY .key .IN_VALUE .value )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split_prepend )
  # message ( TR@CE ".kv => \"${.kv}\"" )
  twx_arg_assert_count ( ${ARGC} = 5 )
  twx_arg_assert_keyword ( .IN_KEY .IN_VALUE )
  twx_assert_variable_name ( "${.key}" "${.value}" )
  twx_expect_unequal_string ( "${.key}" "${.value}" )
  if ( .kv MATCHES "^([^=]+)<<=(.*)$" )
    set ( ${.key} "${CMAKE_MATCH_1}" PARENT_SCOPE )
    set ( ${.value} "${CMAKE_MATCH_2}" PARENT_SCOPE )
    # message ( TR@CE "${.key} => \"${CMAKE_MATCH_1}\"" )
    # message ( TR@CE "${.value} => \"${CMAKE_MATCH_2}\"" )
  elseif ( .kv MATCHES "^=" )
    twx_fatal ( "Unexpected argument: ${.kv}" )
    return ()
  else ()
    set ( ${.key} "${.kv}" PARENT_SCOPE )
    unset ( ${.value} PARENT_SCOPE )
    unset ( ${.value} )
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
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split_compare )
  twx_arg_assert_count ( ${ARGC} = 9 )
  cmake_parse_arguments (
    PARSE_ARGV 1 twx.R
    "" "IN_LEFT;IN_OP;IN_RIGHT;IN_NEGATE" ""
  )
  twx_assert_variable_name ( "${twx.R_IN_LEFT}" "${twx.R_IN_OP}" "${twx.R_IN_RIGHT}" "${twx.R_IN_NEGATE}" )
  twx_expect_unequal_string ( "${twx.R_IN_LEFT}"    "${twx.R_IN_OP}"      )
  twx_expect_unequal_string ( "${twx.R_IN_OP}"      "${twx.R_IN_RIGHT}"   )
  twx_expect_unequal_string ( "${twx.R_IN_RIGHT}"   "${twx.R_IN_NEGATE}"  )
  twx_expect_unequal_string ( "${twx.R_IN_NEGATE}"  "${twx.R_IN_LEFT}"    )
  twx_expect_unequal_string ( "${twx.R_IN_LEFT}"    "${twx.R_IN_RIGHT}"   )
  twx_expect_unequal_string ( "${twx.R_IN_OP}"      "${twx.R_IN_NEGATE}"  )
  if ( twx.R_COMPARISON MATCHES "^(!?)([^<>=!]+)([<>=!]+)([^<>=!]+)$" )
    set ( ${twx.R_IN_LEFT} ${CMAKE_MATCH_2} PARENT_SCOPE )
    set ( ${twx.R_IN_RIGHT} ${CMAKE_MATCH_4} PARENT_SCOPE )
    if ( CMAKE_MATCH_1 )
      set ( ${twx.R_IN_NEGATE} ON PARENT_SCOPE )
    else ()
      set ( ${twx.R_IN_NEGATE} OFF PARENT_SCOPE )
    endif ()
    message ( TRACE "CMAKE_MATCH_3 => \"${CMAKE_MATCH_3}\"" )
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
      twx_fatal ( "Bad comparison operator in \"${twx.R_COMPARISON}\"")
    endif ()
  else ()
    twx_fatal ( "Missing comparison operator in \"${twx.R_COMPARISON}\"")
  endif ()
endfunction ()

twx_lib_require ( "Fatal" "Expect" "Arg" )

twx_lib_did_load ()

#*/
