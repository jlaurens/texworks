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

if ( DEFINED //CMake/Include/Test/TwxPOCTest.cmake )
  return ()
endif ()

set ( //CMake/Include/Test/TwxPOCTest.cmake ON )

message ( STATUS "Proof of concept test...")

block ()

set ( CMAKE_MESSAGE_LOG_LEVEL DEBUG )
list ( APPEND CMAKE_MESSAGE_CONTEXT POC )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )

message ( STATUS "Global storage in custom target" )
block ()
list ( APPEND CMAKE_MESSAGE_CONTEXT storage )
add_custom_target ( TWX_BAZ )
define_property ( TARGET PROPERTY TWX_FOO )
set_target_properties (
  TWX_BAZ
  PROPERTIES TWX_FOO "TWX_BAR"
)
# There is no track of TWX_FOO nor TWX_BAR in the build forlder
# `find . -exec grep "TWX_FOO" "{}" \; -print` returns nothing.
endblock ()

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
endblock ()

endblock ()

message ( STATUS "Proof of concept test... DONE")

#*/
