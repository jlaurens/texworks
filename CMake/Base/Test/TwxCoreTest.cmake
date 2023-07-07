#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Core.
  *
  * First test.
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxCoreTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxCoreTest.cmake ON )

message ( STATUS "TwxCoreLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxCoreLib.cmake")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Core )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_regex_escape" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_regex_escape )
if ( TRUE )
  unset ( actual )
  twx_regex_escape ( "" IN_VAR actual )
  if ( NOT "${actual}" STREQUAL "" )
    message ( FATAL_ERROR "FAILED: ")
  endif ()
  twx_regex_escape ( "^" IN_VAR actual )
  # message ( "DEBUG: twx_regex_escape: actual => ${actual}" )
  foreach ( c_ "^" "$"
  "." 
  "\\"
  "["
  "]"
  "-"
  "*"
  "+"
  "?"
  "|"
  "(" ")"
  )
    # message ( "DEBUG: c_ => \"${c_}\"")
    twx_regex_escape ( "${c_}" IN_VAR actual )
    # message ( "DEBUG: actual => \"${actual}\"")
    if ( NOT "${actual}" STREQUAL "\\${c_}" )
      message ( FATAL_ERROR "FAILED (\"${actual}\" instead of \"\\${c_}\")")
    endif ()
  endforeach ()
endif ()
endblock ()

message ( STATUS "assert_variable" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT assert_variable )
if ( TRUE )
  set ( TWX_FATAL_CATCH ON )
  twx_fatal_clear ()
  twx_assert_variable ( "Ç" )
  twx_fatal_catched ( IN_VAR v )
  if ( v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_assert_variable ( "a_1" )
  twx_fatal_clear ()
endif ()
endblock ()

message ( STATUS "fatal_catch" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT fatal_catch )
if ( TRUE )
  set ( TWX_FATAL_CATCH ON )
  twx_fatal ( "ABCDE" )
  twx_fatal_catched ( IN_VAR v )
  if ( NOT v STREQUAL "ABCDE" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  twx_fatal_clear ()
  twx_fatal_catched ( IN_VAR v )
  if ( NOT v STREQUAL "" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
endif ()
twx_fatal_clear ()
endblock ()

endblock ()

message ( STATUS "TwxCoreLib test... DONE")

#*/
