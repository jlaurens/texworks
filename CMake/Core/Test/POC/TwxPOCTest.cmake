#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Proof of concept test suite.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL DEBUG )

# ANCHOR: Misc
twx_test_unit_push ( CORE "Misc" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Macro/CMAKE_CURRENT_FUNTION" )
  set ( FUNCTION )
  macro ( TwxPOCTest_Misc )
    set ( FUNCTION ${CMAKE_CURRENT_FUNCTION} )
  endmacro ()
  TwxPOCTest_Misc ()
  twx_expect ( FUNCTION "TwxPOCTest_Misc" )
  twx_test_simple_fail ()

  twx_test_simple_check ( "Function/CMAKE_CURRENT_FUNTION" )
  set ( FUNCTION )
  function ( TwxPOCTest_Misc )
    set ( FUNCTION ${CMAKE_CURRENT_FUNCTION} PARENT_SCOPE )
  endfunction ()
  TwxPOCTest_Misc ()
  twx_expect ( FUNCTION "TwxPOCTest_Misc" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "foreach ( X \"\" )" )
  set ( Y )
  twx_assert_undefined ( Y )
  foreach ( X "" )
    set ( Y "Dummy" )
  endforeach ()
  twx_expect ( Y "Dummy" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "foreach ( X \\$\\{\\}->\"\" )" )
  set ( Y )
  twx_assert_undefined ( Y )
  set ( Z "" )
  foreach ( X ${Z} )
    set ( Y "Dummy" )
  endforeach ()
  twx_expect ( Y "Dummy" )
  twx_test_simple_fail ()

  twx_test_simple_check ( "foreach ( X \\$\\{\\}->\"\" ) IN LISTS" )
  set ( Y )
  twx_assert_undefined ( Y )
  set ( Z "" )
  foreach ( X IN LISTS Z )
    set ( Y "Dummy" )
  endforeach ()
  twx_expect ( Y "Dummy" )
  twx_test_simple_fail ()

  twx_test_simple_check ( "\"\" => b => a" )
  set ( a "" )
  twx_assert_defined ( a )
  set ( b "" )
  set ( a ${b} )
  twx_assert_undefined ( a )
  twx_test_simple_pass ()

  twx_test_simple_check ( "\"\" => X1 => Y1" )
  set ( Y1 "" )
  set ( X1 )
  twx_expect ( Y1 "" )
  set ( X1 ${Y1} )
  twx_test_simple_pass ()

  twx_test_simple_check ( "\"\" => X => Y" )
  set ( Y "" )
  set ( X )
  twx_var_log ( Y X MSG "*****" )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: ARGV${ARGC}
twx_test_unit_push ( NAME "After foreach loop" CORE "AfterForeach" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  # What is the looping variable value aftehr a foreach
  twx_test_simple_check ( "foreach ( x A )" )
  set ( x ABCD )
  foreach ( x A )
    twx_expect_equal_string ( "${x}" A )
  endforeach ()
  twx_expect_equal_string ( "${x}" ABCD )
  twx_test_simple_pass ()

  if ( POLICY CMP0124 )
    block ()
    cmake_policy ( SET CMP0124 OLD )
    twx_test_simple_check ( "OLD: foreach ( x A )" )
    set ( x ABCD )
    foreach ( x A )
      twx_expect_equal_string ( "${x}" A )
      set ( y "${x}" )
    endforeach ()
    twx_expect_equal_string ( "${x}" ABCD )
    twx_expect_equal_string ( "${y}" A )
    twx_test_simple_pass ()
    endblock ()
    block ()
    cmake_policy ( SET CMP0124 NEW )
    twx_test_simple_check ( "NEW: foreach ( x A )" )
    set ( x ABCD )
    foreach ( x A )
      twx_expect_equal_string ( "${x}" A )
      set ( y "${x}" )
    endforeach ()
    twx_expect_equal_string ( "${x}" ABCD )
    twx_expect_equal_string ( "${y}" A )
    twx_test_simple_pass ()
    endblock ()
  endif ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: ARGV${ARGC}
twx_test_unit_push ( NAME "ARGV${ARGC}" CORE "ARGV_ARGC" )
if ( /TWX/TEST/UNIT.RUN )
  # depending on the context, ARGV${ARGC} is defined or not
  block ()
  function ( TwxBase_argv_argc_1 )
    twx_assert_defined ( ARGV${ARGC} )
  endfunction ()
  function ( TwxBase_argv_argc_2 x )
    TwxBase_argv_argc_1 ( ${ARGN} )
  endfunction ()
  twx_test_simple_check ( "defined" )
  TwxBase_argv_argc_2 ( a b c )
  twx_test_simple_pass ()
  function ( TwxBase_argv_argc_3 )
    twx_assert_undefined ( ARGV${ARGC} )
  endfunction ()
  function ( TwxBase_argv_argc_4 )
    TwxBase_argv_argc_3 ( ${ARGV} x )
  endfunction ()
  twx_test_simple_check ( "undefined" )
  TwxBase_argv_argc_4 ( a b c )
  twx_test_simple_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Always evaluated OR
twx_test_unit_push ( NAME "Always evaluated OR" CORE "Always_OR" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check( ... )
  set ( CMAKE_MATCH_0 "" )
  if ( TRUE OR "a==b" MATCHES ".==." )
    twx_expect_equal_string ( "${CMAKE_MATCH_0}" "a==b" )
  endif ()
  twx_test_simple_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Global storage in custom target
twx_test_unit_push ( NAME "Global storage in custom target" CORE "Target_Storage" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( ... )
  add_custom_target ( TWX_TEST_BAZ )
  # define_property ( TARGET PROPERTY TWX_FOO )
  set_target_properties (
    TWX_TEST_BAZ
    PROPERTIES TWX_FOO "TWX_BAR"
  )
  set ( ans_ )
  twx_expect_unequal_string ( "${ans_}" "TWX_BAR" )
  get_target_property (
    ans_
    TWX_TEST_BAZ
    TWX_FOO
  )
  twx_expect_equal_string ( "${ans_}" "TWX_BAR" )
  twx_test_simple_pass ()

  # There is no track of TWX_FOO nor TWX_BAR in the build folder
  # `find . -exec grep "TWX_FOO" "{}" \; -print` returns nothing.
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: falsy variable name
twx_test_unit_push ( NAME "falsy variable name" CORE "Falsy" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "IGNORE" )
  if ( IGNORE )
    twx_fatal ( "FAILURE" )
  endif ()
  twx_test_simple_pass ()
  twx_test_simple_check ( "IGNORE => ``ON''" )
  set ( IGNORE ON )
  if ( IGNORE )
    twx_fatal ( "FAILURE" )
  endif ()
  twx_test_simple_pass ()
  twx_test_simple_check ( "IGNORE_ => ``ON''" )
  set ( IGNORE_ ON )
  if ( IGNORE_ )
    twx_fatal ( "FAILURE" )
  endif ()
  twx_test_simple_fail ()
  endblock ()
endif ()
twx_test_unit_pop ()

# message ( STATUS "ARGV and ;" )
# block ()
# list ( APPEND CMAKE_MESSAGE_CONTEXT ARGV )
# if ( TRUE )
#   function ( TwxPOC_ARGV_1 )
#     message ( STATUS "ARGV0 => ``${ARGV0}''" )
#   endfunction ()
#   TwxPOC_ARGV_1 ( "a;b" )
#   function ( TwxPOC_ARGV_2 )
#     cmake_parse_arguments ( PARSE_ARGV 0 twx.R "OPTION" "" "" )
#     message ( STATUS "ARGV0 => ``${ARGV0}''" )
#   endfunction ()
#   TwxPOC_ARGV_2 ( "a;b" OPTION )
# endif ()
# endblock ()

# ANCHOR: Matching special characters
twx_test_unit_push ( NAME "Matching special characters" CORE "SpecialMatch" )
#[==[
"^" "$"
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
]==]
if ( /TWX/TEST/UNIT.RUN )
  block ()
  function ( TwxPocTestCoreSpecial twx.R_ACTUAL M twx.R_EXPECTED )
    twx_test_simple_check ( "${twx.R_ACTUAL} MATCHES ${twx.R_EXPECTED}" )
    twx_expect_matches ( "${twx.R_ACTUAL}" "${twx.R_EXPECTED}" )
    twx_test_simple_pass ()
  endfunction ()
  TwxPocTestCoreSpecial ( "^" MATCHES [=[[$^]]=] )
  TwxPocTestCoreSpecial ( "$" MATCHES [=[[$^]]=] )
  TwxPocTestCoreSpecial ( "." MATCHES [=[[.$^]]=] )
  TwxPocTestCoreSpecial ( "\\\\" MATCHES [=[[\\\\.$^]]=] )
  TwxPocTestCoreSpecial ( "[" MATCHES [=[[[\\.$^]]=] )
  TwxPocTestCoreSpecial ( "]" MATCHES [=[[]]]=] )
  TwxPocTestCoreSpecial ( "-" MATCHES [=[[][\\.$^-]]=] )
  TwxPocTestCoreSpecial ( "*" MATCHES [=[[]*[\\.$^-]]=] )
  TwxPocTestCoreSpecial ( "+" MATCHES [=[[]+*[\\.$^-]]=] )
  TwxPocTestCoreSpecial ( "?" MATCHES [=[[]?+*[\\.$^-]]=] )
  TwxPocTestCoreSpecial ( "|" MATCHES [=[[]|?+*[\\.$^-]]=] )
  TwxPocTestCoreSpecial ( "(" MATCHES [=[[]()|?+*[\\.$^-]]=] )
  TwxPocTestCoreSpecial ( ")" MATCHES [=[[]()|?+*[\\.$^-]]=] )
  set ( re [=[[]()|?+*[\\.$^-]]=] )
  twx_test_simple_check ( "re => ``^${re}+''" )
  twx_expect_matches ( "^$.\\][-*+?|()" "^${re}+$" )
  twx_test_simple_pass ()
  twx_test_simple_check ( "(${re}) -> ``\\\\1''" )
  string (
    REGEX REPLACE "(${re})" "\\\\1"
    actual_
    "^"
  )
  twx_expect_equal_string ( "${actual_}" "\\1" )
  twx_test_simple_pass ()
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Script arguments
twx_test_unit_push ( NAME "Script arguments" CORE "ScriptArguments")
if ( /TWX/TEST/UNIT.RUN )
  block ()
  twx_test_simple_check ( "Expected" )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DARGV0=ZERO"
      "-DARGV1=O N E"
      "-DARGV2=T;W;O"
      "-DARGV3=T\nH\nR\nE\nE"
      -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript1.cmake"
      RESULT_VARIABLE twx.RESULT
      OUTPUT_VARIABLE twx.OUTPUT
      ERROR_VARIABLE  twx.ERROR
      OUTPUT_STRIP_TRAILING_WHITESPACE
    COMMAND_ERROR_IS_FATAL ANY
  )
  twx_assert_0 ( "${twx.RESULT}" )
  twx_expect_matches ( "${twx.OUTPUT}" "ZERO" )
  twx_expect_matches ( "${twx.OUTPUT}" "O N E" )
  twx_expect_matches ( "${twx.OUTPUT}" "T;W;O" )
  twx_expect_matches ( "${twx.OUTPUT}" "T\nH\nR\nE\nE" )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Bad ARGV0" )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DARGV0=ZER0"
      "-DARGV1=0 N E"
      "-DARGV2=T;W;0"
      "-DARGV3=T\nR\nE\nE"
      -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript1.cmake"
    RESULT_VARIABLE twx.RESULT
    OUTPUT_VARIABLE twx.OUTPUT
    ERROR_VARIABLE  twx.ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  twx_expect ( twx.RESULT 1 )
  # twx_expect_matches ( "${twx.OUTPUT}" "ZERO" )
  # twx_expect_matches ( "${twx.OUTPUT}" "O N E" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T;W;O" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T\nH\nR\nE\nE" )
  twx_expect_matches ( "${twx.ERROR}" "Bad ARGV0" )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Bad ARGV1" )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DARGV0=ZERO"
      "-DARGV1=0 N E"
      "-DARGV2=T;W;0"
      "-DARGV3=T\nR\nE\nE"
      -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript1.cmake"
    RESULT_VARIABLE twx.RESULT
    OUTPUT_VARIABLE twx.OUTPUT
    ERROR_VARIABLE  twx.ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  twx_expect ( twx.RESULT 1 )
  twx_expect_matches ( "${twx.OUTPUT}" "ZERO" )
  # twx_expect_matches ( "${twx.OUTPUT}" "O N E" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T;W;O" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T\nH\nR\nE\nE" )
  twx_expect_matches ( "${twx.ERROR}" "Bad ARGV1" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Bad ARGV2" )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DARGV0=ZERO"
      "-DARGV1=O N E"
      "-DARGV2=T;W;0"
      "-DARGV3=T\nR\nE\nE"
      -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript1.cmake"
    RESULT_VARIABLE twx.RESULT
    OUTPUT_VARIABLE twx.OUTPUT
    ERROR_VARIABLE  twx.ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  twx_expect ( twx.RESULT 1 )
  twx_expect_matches ( "${twx.OUTPUT}" "ZERO" )
  twx_expect_matches ( "${twx.OUTPUT}" "O N E" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T;W;O" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T\nH\nR\nE\nE" )
  twx_expect_matches ( "${twx.ERROR}" "Bad ARGV2" )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Bad ARGV3" )
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DARGV0=ZERO"
      "-DARGV1=O N E"
      "-DARGV2=T;W;O"
      "-DARGV3=H\nR\nE\nE"
      -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript1.cmake"
    RESULT_VARIABLE twx.RESULT
    OUTPUT_VARIABLE twx.OUTPUT
    ERROR_VARIABLE  twx.ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  twx_expect ( twx.RESULT 1 )
  twx_expect_matches ( "${twx.OUTPUT}" "ZERO" )
  twx_expect_matches ( "${twx.OUTPUT}" "O N E" )
  twx_expect_matches ( "${twx.OUTPUT}" "T;W;O" )
  # twx_expect_matches ( "${twx.OUTPUT}" "T\nH\nR\nE\nE" )
  twx_expect_matches ( "${twx.ERROR}" "Bad ARGV3" )
  twx_test_simple_pass ()
  
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: Script messages
twx_test_unit_push ( NAME "Script messages" CORE "ScriptMsg")
if ( TRUE )
  block ()
  macro ( TwxPOCTestScriptMsg twx.R_TYPE )
    execute_process (
      COMMAND "${CMAKE_COMMAND}"
        "-DTWX_POC_TEST_TYPE=${twx.R_TYPE}"
        -P "${CMAKE_CURRENT_LIST_DIR}/TwxPOCScript2.cmake"
      RESULT_VARIABLE twx.RESULT_VARIABLE
      OUTPUT_VARIABLE twx.OUTPUT_VARIABLE
      ERROR_VARIABLE  twx.ERROR_VARIABLE
      OUTPUT_STRIP_TRAILING_WHITESPACE
      # COMMAND_ERROR_IS_FATAL ANY
    )
    twx_assert_0 ( "${twx.RESULT_VARIABLE}" )
  endmacro ()
  foreach ( twx.TYPE
    # SEND_ERROR
    WARNING AUTHOR_WARNING DEPRECATION
  )
    twx_test_simple_check ( "${twx.TYPE}" )
    TwxPOCTestScriptMsg ( "${twx.TYPE}" )
    twx_expect_matches ( "${twx.ERROR_VARIABLE}" "MSG: ${twx.TYPE}" )
    twx_expect ( twx.OUTPUT_VARIABLE "" )
    twx_test_simple_pass ()
  endforeach ()
  foreach ( twx.TYPE
    NOTICE
  )
    twx_test_simple_check ( "${twx.TYPE}" )
    TwxPOCTestScriptMsg ( "${twx.TYPE}" )
    twx_expect ( twx.ERROR_VARIABLE "MSG: ${twx.TYPE}\n" )
    twx_expect ( twx.OUTPUT_VARIABLE "" )
    twx_test_simple_pass ()
  endforeach ()
  twx_test_simple_check ( "NOTYPE" )
  TwxPOCTestScriptMsg ( "NOTYPE" )
  twx_expect ( twx.ERROR_VARIABLE "NOTYPEMSG: NOTYPE\n" )
  twx_expect ( twx.OUTPUT_VARIABLE "" )
  twx_test_simple_pass ()
  foreach ( twx.TYPE
    STATUS VERBOSE DEBUG TRACE
  )
    twx_test_simple_check ( "${twx.TYPE}" )
    TwxPOCTestScriptMsg ( "${twx.TYPE}" )
    twx_expect ( twx.OUTPUT_VARIABLE "-- MSG: ${twx.TYPE}" )
    twx_expect ( twx.ERROR_VARIABLE "" )
    twx_test_simple_pass ()
  endforeach ()
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()

twx_test_suite_pop ()

#*/
