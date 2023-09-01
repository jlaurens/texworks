#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Hook.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

twx_test_unit_push ( NAME "twx_hook_*" CORE "*" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  macro ( TwxHookTest_hooked counter step )
    math ( EXPR "${counter}" "${${counter}}+(${step})" )
    message ( TRACE "TwxHookTest_hooked: ${counter} => ``${${counter}}''" )
  endmacro ()
  set ( i 100 )
  TwxHookTest_hooked ( i 23 )
  twx_expect_equal_number ( ${i} 123 )
  twx_hook_register ( ID TwxHookTest TwxHookTest_hooked )
  twx_hook_call ( ID TwxHookTest i -23 )
  twx_expect_equal_number ( ${i} 100 )
  TwxHookTest_hooked ( i 23 )
  twx_expect_equal_number ( ${i} 123 )
  twx_hook_unregister ( ID TwxHookTest TwxHookTest_hooked )
  twx_hook_call ( ID TwxHookTest i -23 )
  twx_expect_equal_number ( ${i} 123 )
  endblock ()
endif ()
twx_test_unit_pop ()

twx_test_unit_push ( NAME "twx_hook_*/ordering" CORE "ordering" )
if ( TWX_TEST_UNIT.RUN )
  block ()
  macro ( TwxHookTest_hooked_plus counter step )
    message ( TRACE "TwxHookTest_hooked_plus: ${counter} => ``${${counter}}''" )
    math ( EXPR "${counter}" "${${counter}}+(${step})" )
    message ( TRACE "TwxHookTest_hooked_plus: ${counter} => ``${${counter}}''" )
  endmacro ()
  macro ( TwxHookTest_hooked_times counter step )
    message ( TRACE "TwxHookTest_hooked_times: ${counter} => ``${${counter}}''" )
    math ( EXPR "${counter}" "${${counter}}*(${step})" )
    message ( TRACE "TwxHookTest_hooked_times: ${counter} => ``${${counter}}''" )
  endmacro ()
  set ( i 100 )
  TwxHookTest_hooked_plus ( i 23 )
  twx_expect_equal_number ( ${i} 123 )
  set ( i 100 )
  TwxHookTest_hooked_times ( i 23 )
  twx_expect_equal_number ( ${i} 2300 )
  set ( i 1 )
  twx_hook_register ( ID TwxHookTest TwxHookTest_hooked_plus )
  twx_hook_register ( ID TwxHookTest TwxHookTest_hooked_times )
  twx_hook_call ( ID TwxHookTest i 10 )
  twx_expect_equal_number ( ${i} 110 )
  twx_hook_register ( ID TwxHookTest TwxHookTest_hooked_plus )
  set ( i 1 )
  twx_hook_call ( ID TwxHookTest i 10 )
  twx_expect_equal_number ( ${i} 20 )
  set ( i 1 )
  twx_hook_unregister ( ID TwxHookTest )
  twx_hook_call ( ID TwxHookTest i 10 )
  twx_expect_equal_number ( ${i} 1 )
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
