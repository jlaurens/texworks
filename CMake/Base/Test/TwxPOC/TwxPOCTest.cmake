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

message ( STATUS "Proof of concept test...")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL DEBUG )

message ( STATUS "Always OR" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT "OR" )
if ( TRUE OR "a==b" MATCHES ".==." )
  if ( NOT "${CMAKE_MATCH_0}" STREQUAL "a==b" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
endif ()
endblock ()

message ( STATUS "Global storage in custom target" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT storage )
if ( TRUE )
  add_custom_target ( TWX_BAZ )
  define_property ( TARGET PROPERTY TWX_FOO )
  set_target_properties (
    TWX_BAZ
    PROPERTIES TWX_FOO "TWX_BAR"
  )
  # There is no track of TWX_FOO nor TWX_BAR in the build forlder
  # `find . -exec grep "TWX_FOO" "{}" \; -print` returns nothing.
endif ()
endblock ()

message ( STATUS "falsy variable name" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT falsy )
if ( TRUE )
  set ( IGNORE ON )
  if ( IGNORE )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
endif ()
endblock ()

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

message ( STATUS "Matching special characters" )
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
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT special_match )
if ( TRUE )
  if ( NOT "^" MATCHES [=[[$^]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "$" MATCHES [=[[$^]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "." MATCHES [=[[.$^]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "\\" MATCHES [=[[\\.$^]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "[" MATCHES [=[[[\\.$^]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "]" MATCHES [=[[]]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "-" MATCHES [=[[][\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "*" MATCHES [=[[]*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "+" MATCHES [=[[]+*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "?" MATCHES [=[[]?+*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "|" MATCHES [=[[]|?+*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT "(" MATCHES [=[[]()|?+*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  if ( NOT ")" MATCHES [=[[]()|?+*[\\.$^-]]=] )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  set ( re [=[[]()|?+*[\\.$^-]]=] )
  if ( NOT "^$.\\][-*+?|()" MATCHES "^${re}+$" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
  string (
    REGEX REPLACE "(${re})" "\\\\\\1"
    actual_
    "^"
  )
  if ( NOT "${actual_}" STREQUAL "\\^" )
    message ( FATAL_ERROR "FAILURE" )
  endif ()
endif ()
endblock ()

endblock ()

message ( STATUS "Proof of concept test... DONE")

#*/
