#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief TwxExportLib test suite.
  *
  *//*
#]===============================================]

include_guard ( GLOBAL )

twx_test_suite_push ()
block ()

# ANCHOR: POC
# Sucess: normal call
twx_test_unit_push ( NAME "POC" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  set ( TwxExportTest.key1a )
  set ( TwxExportTest.key2a )
  set ( TwxExportTest.key3a )
  set ( TwxExportTest.key1b DUMMY1b )
  set ( TwxExportTest.key2b DUMMY2b )
  set ( TwxExportTest.key3b DUMMY3b )
  set ( TwxExportTest.key4 )
  set ( TwxExportTest.key5 DUMMY )
  function ( TwxExportTest_POC )
    set ( TwxExportTest.key1a "value" PARENT_SCOPE )
    set ( TwxExportTest.key2a "" PARENT_SCOPE )
    set ( TwxExportTest.key3a PARENT_SCOPE )
    set ( TwxExportTest.key1b "value" PARENT_SCOPE )
    set ( TwxExportTest.key2b "" PARENT_SCOPE )
    set ( TwxExportTest.key3b PARENT_SCOPE )
    set ( TwxExportTest.key4 PARENT_SCOPE )
    set ( TwxExportTest.key5 PARENT_SCOPE )
  endfunction ()
  TwxExportTest_POC ()
  twx_expect ( TwxExportTest.key1a "value" )
  twx_expect ( TwxExportTest.key2a "" )
  twx_assert_undefined ( TwxExportTest.key3a )
  twx_expect ( TwxExportTest.key1b "value" )
  twx_expect ( TwxExportTest.key2b "" )
  twx_assert_undefined ( TwxExportTest.key3b )
  twx_assert_undefined ( TwxExportTest.key4 )
  twx_assert_undefined ( TwxExportTest.key5 )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: POC2
twx_test_unit_push ( NAME "POC2" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  macro ( TwxExportTest_POC2_a )
    set ( TwxExportTest.key1a "value" PARENT_SCOPE )
    set ( TwxExportTest.key2a "" PARENT_SCOPE )
    set ( TwxExportTest.key3a PARENT_SCOPE )
    set ( TwxExportTest.key1b "value" PARENT_SCOPE )
    set ( TwxExportTest.key2b "" PARENT_SCOPE )
    set ( TwxExportTest.key3b PARENT_SCOPE )
    unset ( TwxExportTest.key4 PARENT_SCOPE )
    unset ( TwxExportTest.key5 PARENT_SCOPE )
  endmacro ()
  function ( TwxExportTest_POC2_b )
    TwxExportTest_POC2_a ()
  endfunction ()
  # State before
  set ( TwxExportTest.key1a )
  set ( TwxExportTest.key2a )
  set ( TwxExportTest.key3a )
  set ( TwxExportTest.key1b DUMMY1b )
  set ( TwxExportTest.key2b DUMMY2b )
  set ( TwxExportTest.key3b DUMMY3b )
  set ( TwxExportTest.key4 )
  set ( TwxExportTest.key5 DUMMY )
  twx_assert_undefined ( TwxExportTest.key )
  # Call
  TwxExportTest_POC2_b ()
  # State after
  twx_expect ( TwxExportTest.key1a "value" )
  twx_expect ( TwxExportTest.key2a "" )
  twx_assert_undefined ( TwxExportTest.key3a )
  twx_expect ( TwxExportTest.key1b "value" )
  twx_expect ( TwxExportTest.key2b "" )
  twx_assert_undefined ( TwxExportTest.key3b )
  twx_assert_undefined ( TwxExportTest.key4 )
  twx_assert_undefined ( TwxExportTest.key5 )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: twx_export
twx_test_unit_push ( NAME "twx_export" CORE twx_export )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  function ( TwxExportTest_twx_export )
    twx_export ( "TwxExportTest.key1a=value1a" )
    twx_export ( "TwxExportTest.key2a" )
    twx_export ( "TwxExportTest.key3a" EMPTY )
    twx_export ( "TwxExportTest.key4a" UNSET )
    twx_export ( "TwxExportTest.key1b=value1b" )
    twx_export ( "TwxExportTest.key2b" )
    twx_export ( "TwxExportTest.key3b" EMPTY )
    twx_export ( "TwxExportTest.key4b" UNSET )
  endfunction ()
  # State before
  set ( TwxExportTest.key1a )
  set ( TwxExportTest.key2a )
  set ( TwxExportTest.key3a )
  set ( TwxExportTest.key4a )
  set ( TwxExportTest.key1b DUMMY1b )
  set ( TwxExportTest.key2b DUMMY2b )
  set ( TwxExportTest.key3b DUMMY3b )
  set ( TwxExportTest.key4b DUMMY4b )
  set ( TwxExportTest.key5 )
  set ( TwxExportTest.key6 DUMMY )
  twx_assert_undefined ( TwxExportTest.key )
  # Call
  TwxExportTest_twx_export ()
  # State after
  twx_expect ( TwxExportTest.key1a "value1a" )
  twx_assert_undefined ( TwxExportTest.key2a )
  twx_expect ( TwxExportTest.key3a "" )
  twx_assert_undefined ( TwxExportTest.key4a )
  twx_expect ( TwxExportTest.key1b "value1b" )
  twx_expect ( TwxExportTest.key2b "DUMMY2b")
  twx_expect ( TwxExportTest.key3b "" )
  twx_assert_undefined ( TwxExportTest.key4b )
  endblock ()
endif ()
twx_test_unit_pop ()

# ANCHOR: twx_export(multi)
twx_test_unit_push ( NAME "twx_export(multi)" CORE "twx_export-multi" )
if ( /TWX/TEST/UNIT.RUN )
  block ()
  function ( TwxExportTest_twx_export_multi )
    twx_export (
      "TwxExportTest.key1a=value1a"
      "TwxExportTest.key2a"
      "TwxExportTest.key1b=value1b"
      "TwxExportTest.key2b"
    )
  endfunction ()
  # State before
  set ( TwxExportTest.key1a )
  set ( TwxExportTest.key2a )
  set ( TwxExportTest.key1b DUMMY1b )
  set ( TwxExportTest.key2b DUMMY2b )
  # Call
  TwxExportTest_twx_export_multi ()
  # State after
  twx_expect ( TwxExportTest.key1a "value1a" )
  twx_assert_undefined ( TwxExportTest.key2a )
  twx_expect ( TwxExportTest.key1b "value1b" )
  twx_expect ( TwxExportTest.key2b "DUMMY2b")
  endblock ()
endif ()
twx_test_unit_pop ()

endblock ()
twx_test_suite_pop ()

#*/
