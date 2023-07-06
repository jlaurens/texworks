#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Extension to the math command

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Include/TwxMathLib.cmake"
  )
*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_math )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_math_compare
#[=======[*/
/** @brief One comparison.
  *
  * The mathematical expression is allowed to contain one comparison binary operators.
  * A comparison is evaluated as 1 for true and 0 for false.
  * If there is no test, the result computed by `math()` is returned.
  *
  * @param expression, mathematical expression or test.
  * @param var for key IN_VAR, required outout variable name.
  */
twx_math_compare( expression IN_VAR var ) {}
/*#]=======]
function ( twx_math_compare expression_ .IN_VAR ans_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math_compare )
  if ( "${ARGC}" GREATER "3" )
    message ( FATAL_ERROR "Too many arguments." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Unexpected argument key \"${.IN_VAR}\"" )
  endif ()
  set ( n )
  set ( l )
  set ( o )
  set ( r )
  if ( expression_ MATCHES "^(.*)!=(.*)$" )
    set ( n "NOT" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "EQUAL" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)<>(.*)$" )
  set ( n "NOT" )
  set ( l "${CMAKE_MATCH_1}" )
  set ( o "EQUAL" )
  set ( r "${CMAKE_MATCH_2}" )
elseif ( expression_ MATCHES "^(.*)<=(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "LESS_EQUAL" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)<(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "LESS" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)>=(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "GREATER_EQUAL" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)>(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "GREATER" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)==(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "EQUAL" )
    set ( r "${CMAKE_MATCH_2}" )
  elseif ( expression_ MATCHES "^(.*)=(.*)$" )
    set ( l "${CMAKE_MATCH_1}" )
    set ( o "EQUAL" )
    set ( r "${CMAKE_MATCH_2}" )
  else ()
    set ( l "${expression_}" )
    unset ( o )
  endif ()
  # message ( TR&CE "${expression_} -> ${n} ${l} ${o} ${r}" )

  math ( EXPR l "${l}" )
  if ( DEFINED o )
    math ( EXPR r "${r}" )
    # message ( TR@CE "${l} ${o} ${r}" )
    if ( ${n} l ${o} r )
      set ( l 1 )
    else ()
      set ( l 0 )
    endif ()
  endif ()
  set ( "${ans_}" "${l}" PARENT_SCOPE )
endfunction ( twx_math_compare )

# ANCHOR: twx_math
#[=======[*/
/** @brief Add comparison support to `math()`.
  *
  * The mathematical expression is allowed to contain comparison binary operators.
  * A comparison is evaluated as 1 for true and 0 for false.
  *
  * @param EXPR literally
  * @param ans for the result
  * @param expression, extended mathematical expression.
  * @param format for key OUTPUT_FORMAT, optional
  */
twx_math(EXPR ans expression [OUTPUT_FORMAT format]) {}
/*#]=======]
function ( twx_math .EXPR ans_ expression_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math )
  # message ( TR@CE "expression_ => ${expression_}" )
  while ( expression_ MATCHES "^(.*)(!!)*!([+-]?(0x)?[0-9a-fA-F.]+)(.*)$" )
    set ( before  "${CMAKE_MATCH_1}" )
    set ( group   "${CMAKE_MATCH_3}" )
    set ( after   "${CMAKE_MATCH_5}" )
    math ( EXPR group "${group}" )
    if ( "${CMAKE_MATCH_2}" STREQUAL "" )
      set ( unnegate OFF )
    else ()
      set ( unnegate ON )
    endif ()
    if ( "${group}" EQUAL 0 )
      set ( group 1 )
    else ()
      set ( group 0 )
    endif ()
    set ( expression_ "${before}${group}${after}" )
  endwhile ()
  while ( expression_ MATCHES "^(.*)(!!)*(!?)\\(([^)]+)\\)(.*)$" )
    set ( before  "${CMAKE_MATCH_1}" )
    if ( "${CMAKE_MATCH_2}" STREQUAL "" )
      set ( unnegate OFF )
    else ()
      set ( unnegate ON )
    endif ()
    if ( "${CMAKE_MATCH_3}" STREQUAL "" )
      set ( negate OFF )
    else ()
      set ( negate ON )
    endif ()
    set ( group   "${CMAKE_MATCH_4}" )
    set ( after   "${CMAKE_MATCH_5}" )
    # message ( TR@CE "${expression_} => ${before} [ ${group} ] ${after}" )
    twx_math_compare ( "${group}" IN_VAR group )
    if ( negate )
      if ( "${group}" EQUAL 0 )
        set ( group 1 )
      else ()
        set ( group 0 )
      endif ()
    endif ()
    if ( unnegate )
      if ( NOT "${group}" EQUAL 0 )
        set ( group 1 )
      endif ()
    endif ()
    set ( expression_ "${before}${group}${after}" )
    # message ( TR@CE "${expression_}" )
  endwhile ()
  twx_math_compare ( "${expression_}" IN_VAR expression_ )
  math ( EXPR expression_ "${expression_}" ${ARGN} )
  # message ( TR@CE "${ans_} => ${expression_}" )
  set ( "${ans_}" "${expression_}" PARENT_SCOPE )
endfunction ( twx_math )

message ( DEBUG "TwxMathLib loaded" )

#*/
