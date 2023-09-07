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

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

# ANCHOR: compare
twx_test_unit_push ( CORE compare )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "2+2" )
  twx_math_compare ( "2+2" IN_VAR ans )
  twx_expect ( ans 4 NUMBER )
  twx_test_simple_pass ()
  function ( TwxMathTest_compare what_ status_ )
    if ( status_ )
      twx_test_simple_check ( "${what_}" )
    else ()
      twx_test_simple_check ( "!(${what_})" )
    endif ()
    twx_math_compare ( "${what_}" IN_VAR ans )
    cmake_language ( CALL "twx_assert_${status_}" ans )
    twx_test_simple_pass ()
  endfunction ()
  TwxMathTest_compare ( "1<2"  "true" )
  TwxMathTest_compare ( "1<=2" "true" )
  TwxMathTest_compare ( "1=2"  "false" )
  TwxMathTest_compare ( "1==2" "false" )
  TwxMathTest_compare ( "1>=2" "false" )
  TwxMathTest_compare ( "1>2"  "false" )

  TwxMathTest_compare ( "2<2" "false" )
  TwxMathTest_compare ( "2<=2" "true" )
  TwxMathTest_compare ( "2=2"  "true" )
  TwxMathTest_compare ( "2==2" "true" )
  TwxMathTest_compare ( "2>=2" "true" )
  TwxMathTest_compare ( "2>2"  "false" )

  TwxMathTest_compare ( "3<2"  "false" )
  TwxMathTest_compare ( "3<=2" "false" )
  TwxMathTest_compare ( "3=2"  "false" )
  TwxMathTest_compare ( "3==2" "false" )
  TwxMathTest_compare ( "3>=2" "true" )
  TwxMathTest_compare ( "3>2"  "true" )
  endblock ()
endif ()
twx_test_unit_pop ()

set (
  twx_math_evaluate_not_DATA_expect_0
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
  twx_math_evaluate_not_DATA_expect_1
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
# ANCHOR: not
twx_test_unit_push ( CORE not )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  foreach ( xpr ${twx_math_evaluate_not_DATA_expect_0} )
    twx_test_simple_check ( "${xpr}" )
    twx_math_evaluate_not ( "${xpr}" IN_VAR ans )
    twx_expect ( ans 0 NUMBER )
    twx_test_simple_pass ()
  endforeach ()
  foreach ( xpr ${twx_math_evaluate_not_DATA_expect_1} )
    twx_test_simple_check ( "${xpr}" )
    twx_math_evaluate_not ( "${xpr}" IN_VAR ans )
    twx_expect ( ans 1 NUMBER )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: twx_math[1]
twx_test_unit_push ( NAME "twx_math[1]" CORE twx_math-1 )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  foreach ( xpr ${twx_math_evaluate_not_DATA_expect_0} )
    twx_test_simple_check ( "${xpr}" )
    twx_math ( EXPR ans "${xpr}" )
    twx_expect ( ans 0 NUMBER )
    twx_test_simple_pass ()
  endforeach ()
  foreach ( xpr ${twx_math_evaluate_not_DATA_expect_1} )
    twx_test_simple_check ( "${xpr}" )
    twx_math ( EXPR ans "${xpr}" )
    twx_expect ( ans 1 NUMBER )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: twx_math[2]
twx_test_unit_push ( NAME "twx_math[2]" CORE twx_math-2 )
if ( /TWX/TEST/UNIT.RUN )
  block ()
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
    twx_test_simple_check ( "${xpr}" )
    twx_math ( EXPR ans "${xpr}" )
    twx_assert_true ( ans )
    twx_test_simple_pass ()
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
    twx_test_simple_check ( "${xpr}" )
    twx_math ( EXPR ans "${xpr}" )
    twx_assert_false ( ans )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#/*
