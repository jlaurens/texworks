#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxSplitLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxSplitTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxSplitTest.cmake ON )

message ( STATUS "TwxSplitLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxSplitLib.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArgTest.cmake" )

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Split )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

# message ( STATUS "ARGC" )
# block ()
# list ( APPEND CMAKE_MESSAGE_CONTEXT ARGC )
# function ( TwxSplitTest_ARGC a )
#   set ( b 4 )
#   if ( ${ARGC} GREATER a )
#     message ( STATUS "1) ARGC > ${a}")
#   else ()
#     message ( STATUS "1) ARGC <= ${a}")
#   endif ()
#   if ( ARGC GREATER a )
#     message ( STATUS "2) ARGC > ${a}")
#   else ()
#     message ( STATUS "2) ARGC <= ${a}")
#   endif ()
# endfunction ()
# set ( a b )
# set ( b 1 )
# TwxSplitTest_ARGC ( 1 2 3 )
# endblock()

message ( STATUS "twx_split" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_split )
# Failure: two many arguments
twx_test_fatal ()
twx_split ( 1 2 3 4 5 7 )
twx_test_fatal_assert_failed ()
# Failure: bad keyword 1
twx_test_fatal ()
twx_split ( kv IN_KEYx k IN_VALUE v )
twx_test_fatal_assert_failed ()
# Failure: bad keyword 2
twx_test_fatal ()
twx_split ( kv IN_KEY k IN_VALUEx v )
twx_test_fatal_assert_failed ()
# Failure: bad variable names
twx_test_fatal ()
twx_assert_variable ( <k> )
twx_test_fatal_assert_failed ()
twx_test_fatal ()
twx_assert_variable ( " " )
twx_test_fatal_assert_failed ()
twx_test_fatal ()
twx_split ( kv IN_KEY <k> IN_VALUE v )
twx_test_fatal_assert_failed ()
twx_test_fatal ()
twx_split ( kv IN_KEY k IN_VALUE <v> )
twx_test_fatal_assert_failed ()
# Failure: not the same variable names
twx_test_fatal ()
twx_split ( kv IN_KEY w IN_VALUE w )
twx_test_fatal_assert_failed ()
# Success: Normal call
twx_test_fatal ()
unset ( k )
unset ( v )
twx_assert_undefined ( k v )
twx_test_fatal_assert_passed ()
twx_test_fatal ()
twx_split ( key=value IN_KEY k IN_VALUE v )
twx_test_fatal_assert_passed ()
# Success: Normal call, value with "="
twx_test_fatal ()
set ( k )
set ( v )
twx_assert_undefined ( k v )
twx_test_fatal_assert_passed ()
twx_test_fatal ()
twx_split ( key=va=ue IN_KEY k IN_VALUE v )
twx_expect ( k key )
twx_expect ( v va=ue )
twx_test_fatal_assert_passed ()
# Failure: no key
twx_test_fatal ()
set ( k )
set ( v )
twx_split ( =value IN_KEY k IN_VALUE v )
twx_test_fatal_assert_failed ()
# Success: only key
twx_test_fatal ()
set ( k )
set ( v )
twx_assert_undefined ( k v )
twx_test_fatal ()
twx_split ( key IN_KEY k IN_VALUE v )
twx_expect ( k key )
twx_assert_undefined ( v )
twx_test_fatal_assert_passed ()
# twx_test_fatal_assert_passed ()
endblock ()

endblock ()

message ( STATUS "TwxSplitLib test... DONE")

#*/
