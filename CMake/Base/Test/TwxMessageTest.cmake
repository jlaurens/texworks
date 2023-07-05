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

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Message )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_message_log_level_order" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT log_level_order )
twx_message_log_level_order ( NOTICE <=> TRACE IN_VAR ans )
twx_assert_true ( "${ans}" )

unset ( actual )

endblock ()

endblock ()

message ( STATUS "TwxMessageLib test... DONE")
