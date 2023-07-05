#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  State

  include (
    "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxStateLib.cmake"
  )

*/
/*#]===============================================]

# Full include only once
if ( COMMAND twx_state_serialize )
  return ()
endif ()
# This has already been included

# ANCHOR: twx_state_serialize ()
#[=======[
/** @brief Serialize the current state
  *
  * Serialize the current state into variable `TWX-D_STATE`.
  * To forward the current state to CMake `-P` commands.
  * See the balancing `twx_state_deserialize ()`.
  * @param var for key IN_VAR, optional var holding the result
  */
twx_state_serialize([IN_VAR var]) {}
/*#]=======]
set (
  TWX_STATE_KEYS
  TEST DEV
)
function ( twx_state_serialize )
  # NO list ( APPEND CMAKE_MESSAGE_CONTEXT twx_state_serialize )
  unset ( twxR_IN_VAR )
  if ( "${ARGC}" EQUAL "2" )
    twx_arg_expect_keyword ( "${ARGV0}" "IN_VAR" )
    twx_assert_variable ( "${ARGV1}" )
    set ( twxR_IN_VAR "${ARGV1}" )
  elseif ( NOT "${ARGC}" EQUAL "0")
    twx_fatal ( "Too many arguments: got \"${ARGV}\"" )
    return ()
  endif ()
  set ( state_ )
  foreach ( k_ ${TWX_STATE_KEYS} )
    string ( JSON state_ SET "${state_}" "{k_}" "${TWX_${k_}}" )
  endforeach ()
  foreach ( k_ BINARY SOURCE )
    string ( JSON state_ SET "${state_}" "CMAKE_${k_}_DIR" "${CMAKE_${k_}_DIR}" )
  endforeach ()
  cmake_language ( GET_MESSAGE_LOG_LEVEL CMAKE_MESSAGE_LOG_LEVEL )
  foreach ( k_ INDENT LOG_LEVEL CONTEXT CONTEXT_SHOW )
    string ( JSON state_ SET "${state_}" "CMAKE_MESSAGE_${k_}" "${CMAKE_MESSAGE_${k_}}" )
  endforeach ()
  if ( DEFINED twxR_IN_VAR )
    set ( ${twxR_IN_VAR} "${state_}" PARENT_SCOPE )
  endif ()
  set ( TWX-D_STATE "-DTWX_STATE=\"${state_}\"" PARENT_SCOPE )
endfunction ()

# ANCHOR: twx_state_deserialize ()
#[=======[
/** @brief Deserialize to the current state
  *
  * To forward the current state to CMake `-P` commands.
  * Deserialize the `TWX_STATE` variable into the current state.
  * See the balancing `twx_state_serialize ()`.
  * @param state, optional string modelling the state.
  * Defaults to the contents of the `TWX_STATE` variable.
  */
twx_state_deserialize([state]) {}
/*#]=======]
function ( twx_state_deserialize )  
  # NO list ( APPEND CMAKE_MESSAGE_CONTEXT twx_state_deserialize )
  if ( "${ARGC}" EQUAL "1" )
    set ( state_ "${ARGV0}" )
  else ()
    set ( state_ "${TWX_STATE}")
  endif ()
  foreach ( k_ ${TWX_STATE_KEYS} )
    string( JSON out_ GET "${state_}" "${k_}" )
    set ( TWX_${k_} "${out_}" PARENT_SCOPE )
  endforeach ()
  foreach ( k_ BINARY SOURCE )
    string( JSON out_ GET "${state_}" "${k_}" )
    set ( CMAKE_${k_}_DIR "${out_}" PARENT_SCOPE )
  endforeach ()
  foreach ( k_ INDENT LOG_LEVEL )
    string ( JSON out_ GET "${state_}" "CMAKE_MESSAGE_${k_}" )
    set ( CMAKE_MESSAGE_${k_} "${out_}" PARENT_SCOPE )
  endforeach ()
endfunction ()

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxFatalLib.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgLib.cmake" )

message ( DEBUG "TwxStateLib loaded" )

#*/
