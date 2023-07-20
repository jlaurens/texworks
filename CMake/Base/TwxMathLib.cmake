#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Extension to the math command
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxMathLib.cmake"
  *   )
  *
  * NB: only integral results.
  */
/*#]===============================================]

include_guard ( GLOBAL )

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
function ( twx_math_compare expression_ .IN_VAR twx.R_IN_VAR )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math_compare )
  if ( ${ARGC} GREATER "3" )
    message ( FATAL_ERROR "Too many arguments." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Unexpected argument key \"${.IN_VAR}\"" )
  endif ()
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  # message ( TR@CE "1) ${expression_} => ${twx.R_IN_VAR}" )
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
  # message ( TR@CE "2) ${expression_} -> ${n} ${l} ${o} ${r}" )
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
  set ( "${twx.R_IN_VAR}" "${l}" PARENT_SCOPE )
endfunction ( twx_math_compare )

# ANCHOR: twx_math_not
#[=======[*/
/** @brief To add `!` support to `math()`.
  *
  * Negates a signed number, after truncation.
  * `!<non zero>` gives 0, `!<zero>` gives 1.
  *
  * @param expression, extended mathematical expression.
  * @param IN_VAR literally
  * @param ans for the result
  */
twx_math_not(expression IN_VAR var) {}
/*#]=======]
function ( twx_math_not expression_ .IN_VAR twx.R_IN_VAR )
  if ( ${ARGC} GREATER "3" )
    message ( FATAL_ERROR "Too many arguments: ARGV => \"${ARGV}\"." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Unexpected argument key \"${.IN_VAR}\"" )
  endif ()
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  while ( TRUE )
    if ( expression_ MATCHES "^(.*)(!+)[+-]?(0x[0-9a-fA-F]+)(.*)$" )
      # Hexadecimal integer
      set ( before  "${CMAKE_MATCH_1}" )
      set ( marks   "${CMAKE_MATCH_2}" )
      set ( group   "${CMAKE_MATCH_3}" )
      set ( after   "${CMAKE_MATCH_4}" )
    elseif ( expression_ MATCHES "^(.*)(!+)[+-]?([0-9a-fA-F]+)(\\.[0-9]*)?(.*)$" )
      # decimal float 
      set ( before  "${CMAKE_MATCH_1}" )
      set ( marks   "${CMAKE_MATCH_2}" )
      set ( group   "${CMAKE_MATCH_3}" )
      set ( after   "${CMAKE_MATCH_5}" )
    elseif ( expression_ MATCHES "^(.*)(!+)[+-]?(\\.[0-9]+)(.*)$" )
      # decimal integer with optional dot
      set ( before  "${CMAKE_MATCH_1}" )
      set ( marks   "${CMAKE_MATCH_2}" )
      set ( group   "0${CMAKE_MATCH_3}" )
      set ( after   "${CMAKE_MATCH_4}" )
    else ()
      break ()
    endif ()
    # message ( TR@CE "group => \"${group}\"" )
    math ( EXPR group "${group}" )
    if ( "${marks}" MATCHES "^(!!)*!$" )
      if ( "${group}" EQUAL 0 )
        set ( group 1 )
      else ()
        set ( group 0 )
      endif ()
    elseif ( "${marks}" MATCHES "^(!!)+$" )
      if ( NOT "${group}" EQUAL 0 )
        set ( group 1 )
      endif ()
    endif ()
    set ( expression_ "${before}${group}${after}" )
    # message ( TR@CE "${expression_}" )
  endwhile ()
  set ( ${twx.R_IN_VAR} "${expression_}" PARENT_SCOPE )
endfunction ( twx_math_not )

# ANCHOR: twx_math
#[=======[*/
/** @brief Add comparison support to `math()`.
  *
  * Evaluates an expression with no parenthesis.
  *
  * @param expression, extended mathematical expression.
  * @param IN_VAR literally
  * @param ans for the result
  */
twx_math_evaluate(expression IN_VAR var) {}
/*#]=======]
function ( twx_math_evaluate expression .IN_VAR twx.R_IN_VAR )
  if ( ${ARGC} GREATER "3" )
    message ( FATAL_ERROR "Too many arguments: ARGV => \"${ARGV}\"." )
  endif ()
  if ( NOT .IN_VAR STREQUAL "IN_VAR" )
    message ( FATAL_ERROR "Unexpected argument key \"${.IN_VAR}\"" )
  endif ()
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  twx_math_not ( "${expression}" IN_VAR expression )
  twx_math_compare ( "${expression}" IN_VAR expression )
  set ( "${twx.R_IN_VAR}" "${expression}" PARENT_SCOPE )
endfunction ( twx_math_evaluate )

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
function ( twx_math .EXPR twx.R_IN_VAR expression_ )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math )
  twx_assert_variable_name ( "${twx.R_IN_VAR}" )
  while ( expression_ MATCHES "^(.*[^!-]|)(!*)(-)?\\(([^)]+)\\)(.*)$" )
    set ( before  "${CMAKE_MATCH_1}" )
    set ( marks   "${CMAKE_MATCH_2}" )
    set ( minus   "${CMAKE_MATCH_3}" )
    set ( group   "${CMAKE_MATCH_4}" )
    set ( after   "${CMAKE_MATCH_5}" )
    # message ( TR@CE "3) ${expression_} => ${before} ${marks}[ ${group} ] ${after}" )
    twx_math_evaluate ( "${group}" IN_VAR group )
    if ( NOT "${minus}" STREQUAL "" )
    endif ()
    math ( EXPR group "-(${group})")
    # message ( TR@CE "4) group => ${group}" )
    if ( "${marks}" MATCHES "^(!!)*!$" )
      # message ( TR@CE "4) NEGATE" )
      if ( "${group}" EQUAL 0 )
        set ( group 1 )
      else ()
        set ( group 0 )
      endif ()
    elseif ( "${marks}" MATCHES "^(!!)+$" )
      # message ( TR@CE "4) DOUBLE NEGATE" )
      if ( NOT "${group}" EQUAL 0 )
        set ( group 1 )
      endif ()
    else ()
      # message ( TR@CE "4) NO CHANGE" )
    endif ()
    # message ( TR@CE "4) group => ${group}" )
    set ( expression_ "${before}${group}${after}" )
    # message ( TR@CE "5) ${expression_}" )
  endwhile ()
  twx_math_evaluate ( "${expression_}" IN_VAR expression_ )
  math ( "${.EXPR}" expression_ "${expression_}" ${ARGN} )
  # message ( TR@CE "${twx.R_IN_VAR} => ${expression_}" )
  set ( "${twx.R_IN_VAR}" "${expression_}" PARENT_SCOPE )
endfunction ( twx_math )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectLib.cmake" )

message ( DEBUG "TwxMathLib loaded" )

#*/
