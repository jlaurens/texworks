#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxMessageLib test suite.
  *
  *//*
#]===============================================]


if ( DEFINED //CMake/Include/Test/TwxMessageTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxMessageTest.cmake ON )

message ( STATUS "TwxMessageLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxMessageLib.cmake")

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Message )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_message_log_level_order" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT log_level_order )
twx_message_log_level_order ( NOTICE <=> TRACE IN_VAR ans )
twx_expect_equal_number ( "${ans}" -1 )
twx_message_log_level_order ( NOTICE <=> NOTICE IN_VAR ans )
twx_expect_equal_number ( "${ans}" 0 )
twx_message_log_level_order ( TRACE <=> NOTICE IN_VAR ans )
twx_expect_equal_number ( "${ans}" 1 )
twx_test_fatal ()
twx_message_log_level_order ( NoTICE <=> TRACE IN_VAR ans )
twx_test_fatal_assert_failed ()
twx_test_fatal ()
twx_message_log_level_order ( NOTICE <=> TRaCE IN_VAR ans )
twx_test_fatal_assert_failed ()
endblock ()

message ( STATUS "twx_message_log_level_compare" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT log_level_compare )

foreach ( level ${TWX_MESSAGE_LOG_LEVELS} )
  set ( op ">" )
  set ( after )
  set ( where "before" )
  foreach ( l ${TWX_MESSAGE_LOG_LEVELS} )
    if ( "${l}" STREQUAL "${level}" )
      twx_message_log_level_compare ( "${l}" "==" "${level}" IN_VAR ans )
      twx_assert_true ( ans )
      twx_message_log_level_compare ( "${l}" "="  "${level}" IN_VAR ans )
      twx_assert_true ( ans )
      twx_message_log_level_compare ( "${l}" "!=" "${level}" IN_VAR ans )
      twx_assert_true ( false )
      twx_message_log_level_compare ( "${l}" "<>" "${level}" IN_VAR ans )
      twx_assert_true ( false )
      set ( op "<" )
      continue ()
    endif ()
    list ( APPEND "${where}" "${l}" )
  endforeach ()

endforeach ()
endblock ()

endblock ()

message ( STATUS "TwxMessageLib test... DONE")

#/*
