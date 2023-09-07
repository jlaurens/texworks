#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Testing Core/Global.
  *
  * First test.
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()

block ()

# ANCHOR: POC
twx_test_unit_push ( NAME POC )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Unset" )
  set ( FOO "Dummy" )
  get_property (
    FOO
    GLOBAL
    PROPERTY /TwxGlobalTest/POC
  )
  twx_assert_undefined ( FOO )
  twx_test_simple_pass ()
  
  twx_test_simple_check ( "Undefined" )
  set ( FOO "Dummy" )
  set_property (
    GLOBAL
    PROPERTY /TwxGlobalTest/POC
  )
  get_property (
    FOO
    GLOBAL
    PROPERTY /TwxGlobalTest/POC
  )
  twx_assert_undefined ( FOO )
  twx_test_simple_pass ()
  
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: set__/get__
twx_test_unit_push ( CORE "set__/get__" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Undefined" )
  set ( var "Dmmmy" )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Undefined, no IN_VAR" )
  set ( /TwxGlobalTest/FOO "Dmmmy" )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO )
  twx_assert_undefined ( /TwxGlobalTest/FOO )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, non empty" )
  set ( var )
  twx_global_set__ ( "Dummy" KEY /TwxGlobalTest/FOO )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_expect ( var "Dummy" )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, non empty+IN_VAR" )
  set ( var )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO "Dummy" )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, empty, explicit" )
  set ( var )
  twx_global_set__ ( "" KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_expect ( var "" )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, empty" )
  set ( var )
  twx_global_set__ ( "" KEY /TwxGlobalTest/FOO )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_expect ( var "" )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO )
  twx_global_get__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, non empty+IN_VAR" )
  set ( var )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO "Dummy" )
  twx_global_set__ ( KEY /TwxGlobalTest/FOO IN_VAR var )
  twx_assert_undefined ( var )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Undefined, no IN_VAR" )
  set ( /TwxGlobalTest/CHI "Dummy" )
  twx_global_get__ ( KEY /TwxGlobalTest/CHI )
  twx_assert_undefined ( /TwxGlobalTest/CHI )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, no IN_VAR" )
  set ( /TwxGlobalTest/CHI )
  twx_global_set__ ( Dummy KEY /TwxGlobalTest/CHI )
  twx_global_get__ ( KEY /TwxGlobalTest/CHI )
  twx_expect ( /TwxGlobalTest/CHI "Dummy" )
  twx_global_set__ ( KEY /TwxGlobalTest/CHI IN_VAR v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Undefined, no KEY" )
  set ( /TwxGlobalTest/MEE "Dummy" )
  twx_global_get__ ( IN_VAR /TwxGlobalTest/MEE )
  twx_assert_undefined ( /TwxGlobalTest/MEE )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Defined, no KEY" )
  set ( /TwxGlobalTest/MEE )
  twx_global_set__ ( Dummy KEY /TwxGlobalTest/MEE )
  twx_global_get__ ( IN_VAR /TwxGlobalTest/MEE )
  twx_expect ( /TwxGlobalTest/MEE "Dummy" )
  twx_global_set__ ( KEY /TwxGlobalTest/MEE IN_VAR v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: increment
twx_test_unit_push ( CORE "increment" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Initial" )
  twx_global_set__ ( KEY x )
  twx_global_increment ( KEY x )
  twx_global_get__ ( KEY x )
  twx_expect ( x 1 )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Initial+STEP" )
  twx_global_set__ ( KEY x )
  twx_global_increment ( KEY x STEP 123 )
  twx_global_get__ ( KEY x )
  twx_expect ( x 123 )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Initial+IN_VAR" )
  twx_global_set__ ( KEY x )
  twx_global_increment ( KEY x IN_VAR x )
  twx_global_get__ ( KEY x )
  twx_expect ( x 1 )
  twx_test_simple_pass ()

  twx_test_simple_check ( "400+20+1" )
  twx_global_set__ ( 400 KEY x )
  twx_global_increment ( KEY x IN_VAR var )
  twx_expect ( var 401 )
  twx_global_increment ( KEY x STEP 20 IN_VAR var )
  twx_expect ( var 421 )
  twx_test_simple_pass ()

  twx_test_simple_check ( "500-80+1" )
  twx_global_set__ ( 500 KEY x )
  twx_global_increment ( KEY x )
  twx_global_increment ( KEY x STEP -80 IN_VAR var )
  twx_expect ( var 421 )
  twx_test_simple_pass ()

  # twx_test_simple_check ( "500-80+1" )
  # twx_global_set__ ( -0.5 KEY FOO )
  # twx_global_increment ( KEY x STEP 0.5 IN_VAR var )
  # twx_expect ( var 0 )
  # twx_test_simple_fail ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: append
twx_test_unit_push ( CORE "append" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "PREPARE" )
  set ( /TwxDlobalTest/x "Dummy" )
  twx_global_set__ ( KEY /TwxDlobalTest/x )
  twx_global_get__ ( KEY /TwxDlobalTest/x )
  twx_assert_undefined ( /TwxDlobalTest/x )
  twx_test_simple_pass ()

  twx_test_simple_check ( "FOO" )
  twx_global_set__ ( KEY /TwxDlobalTest/x )
  twx_global_append ( FOO KEY /TwxDlobalTest/x IN_LIST v )
  twx_expect ( v "FOO" )
  twx_test_simple_pass ()

  twx_test_simple_check ( "CHI MEE" )
  twx_global_append ( CHI MEE KEY /TwxDlobalTest/x IN_LIST v )
  twx_expect ( v "FOO;CHI;MEE" )
  twx_global_set__ ( KEY /TwxDlobalTest/x IN_VAR v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: remove
twx_test_unit_push ( CORE "remove" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Normal" )
  twx_global_set__ ( "FOO;CHI;MEE;FOO;CHI;MEE" KEY /TwxDlobalTest/x IN_VAR v )
  twx_expect ( v "FOO;CHI;MEE;FOO;CHI;MEE" )
  twx_global_remove ( FOO KEY /TwxDlobalTest/x IN_LIST v )
  twx_expect ( v "CHI;MEE;CHI;MEE" )
  twx_global_remove ( MEE CHI KEY /TwxDlobalTest/x IN_LIST v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: get_back
twx_test_unit_push ( CORE "get_back" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Normal" )
  twx_global_set__ ( "FOO;CHI;MEE;FOO;CHI;MEE" KEY /TwxDlobalTest/x )
  set ( v )
  twx_global_get_back ( KEY /TwxDlobalTest/x IN_VAR v )
  twx_expect ( v "MEE" )
  twx_global_set__ ( KEY x )
  twx_test_simple_pass ()

  twx_test_simple_check ( "Normal, no IN_VAR" )
  twx_global_set__ ( "FOO;CHI;MEE;FOO;CHI;MEE" KEY /TwxDlobalTest/x )
  set ( /TwxDlobalTest/x )
  twx_global_get_back ( KEY /TwxDlobalTest/x )
  twx_expect ( /TwxDlobalTest/x "MEE" )
  twx_global_set__ ( KEY /TwxDlobalTest/x IN_VAR v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: pop_back
twx_test_unit_push ( CORE "pop_back" )
if ( /TWX/TEST/UNIT.RUN )
  block ()

  twx_test_simple_check ( "Normal" )
  twx_global_set__ (KEY /TwxDlobalTest/x )
  twx_global_append ( FOO CHI MEE FOO CHI MEE KEY /TwxDlobalTest/x )
  twx_global_remove ( FOO KEY /TwxDlobalTest/x IN_LIST v )
  twx_expect ( v "CHI;MEE;CHI;MEE" )
  twx_global_remove ( MEE CHI KEY /TwxDlobalTest/x IN_LIST v )
  twx_assert_undefined ( v )
  twx_test_simple_pass ()

  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
