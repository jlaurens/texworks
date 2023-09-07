#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Core/Const.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()

block ()

# ANCHOR: en-de/code
twx_test_unit_push ( NAME en-de/code )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Undefined encode " )
  set ( FOO )
  twx_assert_undefined ( FOO )
  twx_const_empty_string_encode ( VAR FOO )
  twx_assert_undefined ( FOO )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Undefined decode " )
  set ( FOO )
  twx_assert_undefined ( FOO )
  twx_const_empty_string_decode ( VAR FOO )
  twx_assert_undefined ( FOO )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Defined encode meme" )
  set ( FOO "Dummy" )
  twx_expect ( FOO "Dummy" )
  twx_const_empty_string_encode ( VAR FOO )
  twx_expect ( FOO "Dummy" )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Defined decode meme" )
  set ( FOO "Dummy" )
  twx_expect ( FOO "Dummy" )
  twx_const_empty_string_decode ( VAR FOO )
  twx_expect ( FOO "Dummy" )
  twx_test_simple_pass ()
  
  macro ( TwxConstTest_code X what_ )
    twx_test_simple_check ( "``${X}''" )
    set ( FOO "${X}" )
    twx_expect ( FOO "${X}" )
    twx_const_empty_string_encode ( VAR FOO )
    twx_unexpect ( FOO "${X}" )
    twx_const_empty_string_decode ( VAR FOO )
    twx_expect ( FOO "${X}" )
    cmake_language ( CALL "twx_test_simple_${what_}" )
  endmacro ()

  TwxConstTest_code ( "" pass )
  TwxConstTest_code ( "A" fail )
  TwxConstTest_code ( ";" pass )
  TwxConstTest_code ( "A;" pass )
  TwxConstTest_code ( ";B" pass )
  TwxConstTest_code ( "A;B" fail )
  TwxConstTest_code ( ";;" pass )
  TwxConstTest_code ( "A;;" pass )
  TwxConstTest_code ( ";B;" pass )
  TwxConstTest_code ( ";;C" pass )
  TwxConstTest_code ( "A;B;" pass )
  TwxConstTest_code ( "A;;C" pass )
  TwxConstTest_code ( ";B;C" pass )
  TwxConstTest_code ( "A;B;C" fail )
  TwxConstTest_code ( ";;;" pass )
  TwxConstTest_code ( ";;;;" pass )
  
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
