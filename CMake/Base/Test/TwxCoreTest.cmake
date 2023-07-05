#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxCoreLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxCoreTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxCoreTest.cmake ON )

message ( "TwxCoreLib testing")

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Core )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( "twx_regex_escape" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_regex_escape )
unset ( actual )
twx_regex_escape ( "" IN_VAR actual )
twx_expect_equal_string ( actual "" )
twx_regex_escape ( "^" IN_VAR actual )
message ( "DEBUG: twx_regex_escape: actual => ${actual}" )
foreach ( c_ "^" "$"
# "." 
# "\\"
# "["
# "]"
# "-"
# "*"
# "+"
# "?"
# "|"
#"(" ")"
)
  message ( "DEBUG: c_ => \"${c_}\"")
  twx_regex_escape ( "${c_}" IN_VAR actual )
  twx_expect_equal_string ( actual "\\${c_}" )
endforeach ()

twx_regex_escape ( "\\\\" IN_VAR actual )
twx_expect_equal_string ( actual "\\\\" )

endblock ()

message ( "*********************" )
message ( FATAL_ERROR "" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_ )
endblock ()

message ( "twx_increment" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_increment )
set ( i 666 )
twx_increment ( i )
twx_expect_equal_number ( i 667 )
endblock ()

message ( "*********************" )
message ( FATAL_ERROR "" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT test_ )
endblock ()

endblock ()