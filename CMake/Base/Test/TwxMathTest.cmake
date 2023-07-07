#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxMathLib test suite.
  *
  *//*
#]===============================================]

if ( DEFINED //CMake/Include/Test/TwxMathTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxMathTest.cmake ON )

message ( STATUS "TwxMathLib test...")

include ( "${CMAKE_CURRENT_LIST_DIR}/../TwxMathLib.cmake")

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCoreTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssertTest.cmake")
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpectTest.cmake")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
list ( APPEND CMAKE_MESSAGE_CONTEXT Math )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "twx_math_compare" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math_compare )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_math_compare ( "2+2" IN_VAR ans )
  twx_expect_equal_number ( "${ans}" "4" )
  twx_math_compare ( "1<2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "1<=2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "1=2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "1==2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "1>=2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "1>2" IN_VAR ans )
  twx_assert_false ( ans )

  twx_math_compare ( "2<2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "2<=2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "2=2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "2==2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "2>=2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "2>2" IN_VAR ans )
  twx_assert_false ( ans )

  twx_math_compare ( "3<2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "3<=2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "3=2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "3==2" IN_VAR ans )
  twx_assert_false ( ans )
  twx_math_compare ( "3>=2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_math_compare ( "3>2" IN_VAR ans )
  twx_assert_true ( ans )
  twx_test_fatal_assert_passed ()
endif ()
twx_test_fatal ()
endblock ()

set (
  twx_math_not_DATA_expect_0
  0
  0x0
  0x0000
  !1
  !!!1
  !2
  !!!2
  !1.
  !!!1.
  !2.
  !!!2.
  !1.1
  !!!1.1
  !2.1
  !!!2.1
  +0
  -0
  +0x0
  -0x0
  !+1
  !-1
  !+0x1
  !-0x1
)
set (
  twx_math_not_DATA_expect_1
  1
  0x1
  !0
  !0.
  !0.5
  !!1
  !!!!1
  !!2
  !!!!2
  !!!0
  !!!0.
  !!!0.5
  !!2.
  !!2.1
  +1
  +0x1
  !+0
  !-0
  !+0.
  !-0.
  !+0.5
  !-0.5
  !+0x0
  !-0x0
)
message ( STATUS "twx_math_not" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT evaluate_not )
twx_test_fatal_assert_passed ()
if ( TRUE )
  foreach ( xpr ${twx_math_not_DATA_expect_0} )
    twx_math_not ( "${xpr}" IN_VAR ans )
    # message ( TRACE "\"${xpr}\" -> \"${ans}\"")
    if ( NOT ans EQUAL 0 )
      message ( FATAL_ERROR "FAILED" )
    endif ()
  endforeach ()
  foreach ( xpr ${twx_math_not_DATA_expect_1} )
    twx_math_not ( "${xpr}" IN_VAR ans )
    #message ( TRACE "\"${xpr}\" -> \"${ans}\"")
    if ( NOT ans EQUAL 1 )
      message ( FATAL_ERROR "FAILED" )
    endif ()
  endforeach ()
endif ()
twx_test_fatal ()
endblock ()

message ( STATUS "twx_math[1]" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math[1] )
twx_test_fatal_assert_passed ()
if ( TRUE )
  foreach ( xpr ${twx_math_not_DATA_expect_0} )
    twx_math ( EXPR ans "${xpr}"  )
    # message ( TRACE "\"${xpr}\" -> \"${ans}\"")
    if ( NOT ans EQUAL 0 )
      message ( FATAL_ERROR "FAILED" )
    endif ()
  endforeach ()
  foreach ( xpr ${twx_math_not_DATA_expect_1} )
    twx_math ( EXPR ans "${xpr}" )
    #message ( TRACE "\"${xpr}\" -> \"${ans}\"")
    if ( NOT ans EQUAL 1 )
      message ( FATAL_ERROR "FAILED" )
    endif ()
  endforeach ()
endif ()
twx_test_fatal ()
endblock ()

message ( STATUS "twx_math[2]" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT twx_math[2] )
twx_test_fatal_assert_passed ()
if ( TRUE )
  twx_math ( EXPR ans "2+2" )
  twx_expect_equal_number ( "${ans}" "4" )
  twx_expect_equal_string ( "${ans}" "4" )
  twx_math ( EXPR ans "2+2" OUTPUT_FORMAT HEXADECIMAL )
  twx_expect_equal_number ( "${ans}" "4" )
  twx_expect_equal_string ( "${ans}" "0x4" )
  twx_expect_unequal_string ( "${ans}" "4" )
  twx_math ( EXPR ans "-(-1)" )
  twx_expect_equal_number ( "${ans}" "1" )
  foreach ( xpr
    "1<2" "(1<2)" "((1<2))"
    "(1<2)&(2<3)"
    "(1<2)|(2>3)"
    "!(0)"
    "!!(1)"
    "!(!(1))"
    "!!!(0)"
    "!(!!(0))"
    "!!(!(0))"
    "!(!(!(0)))"
  )
    twx_math ( EXPR ans "${xpr}" )
    # message ( TR@CE "${xpr} => \"${xpr}\" (expected true)" )
    twx_assert_true ( ans )
  endforeach ()
  foreach ( xpr
    "1>2" "(1>2)" "((1>2))"
    "(1>2)&(2<3)"
    "(1>2)|(2>3)"
    "!(1)"
    "!!(0)"
    "!(!(0))"
    "!!!(1)"
    "!(!!(1))"
    "!!(!(1))"
    "!(!(!(1)))"
    "!!!!(0)"
  )
    twx_math ( EXPR ans "${xpr}" )
    # message ( TR@CE "${xpr} => \"${xpr}\" (expected false)" )
    twx_assert_false ( ans )
  endforeach ()
  twx_test_fatal_assert_passed ()
endif ()
twx_test_fatal ()
endblock ()

endblock ()

message ( STATUS "TwxMathLib test... DONE")

#/*
