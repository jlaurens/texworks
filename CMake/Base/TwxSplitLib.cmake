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

# Full include only once
if ( COMMAND twx_split )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_split
#[=======[
*/
/** @brief Split "key=value"
  *
  * Split "<key>=<value>" arguments into "<key>" and "<value>".
  * "<key>" must be a valid key name.
  *
  * @param kv, value to split.
  * @param key for key `IN_KEY`, name of the variable that
  *   will hold the key on return.
  * @param value for key `IN_VALUE`, name of the variable that
  *   will hold the value on return.
  */
twx_split(kv IN_KEY key IN_VALUE value) {}
/*
#]=======]
function ( twx_split .kv .IN_KEY .key .IN_VALUE .value )
  list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split )
  twx_arg_assert_count ( ${ARGC} = 5 )
  twx_arg_assert_keyword ( .IN_KEY .IN_VALUE )
  twx_assert_variable ( "${.key}" "${.value}" )
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
    if ( DEFINED ${.value} )
      # message ( TR@CE "${.value} DEFINED" )
    else ()
      # message ( TR@CE "${.value} UNDEFINED" )
    endif ()
    # message ( TR@CE "${.key} => \"${.kv}\"" )
    # message ( TR@CE "${.value} => Unset" )
  endif ()
endfunction ()


include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )

message ( VERBOSE "Loaded: TwxSplitLib" )

#*/
