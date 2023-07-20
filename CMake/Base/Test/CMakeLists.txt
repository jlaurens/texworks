#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
*/
/** @file
  * @brief CMake/Base/Test Cmake file
  * 
  * Test the various cmake libraries.
  * 
  */
/*
#]===============================================]

cmake_minimum_required ( VERSION 3.25 )

include_guard ( GLOBAL )

include (
  "${CMAKE_CURRENT_LIST_DIR}/../TwxBasePolicy.cmake"
  NO_POLICY_SCOPE
)
project ( TwxCMakeBaseTest )

set ( TWX_TEST ON )

set ( CMAKE_MESSAGE_LOG_LEVEL TRACE )
set ( CMAKE_MESSAGE_CONTEXT_SHOW ON )
list ( APPEND CMAKE_MESSAGE_CONTEXT Test.Base )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxPOC/TwxPOCTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCore/TwxCoreTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTest/TwxTestTest.cmake" )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAssert/TwxAssertTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExpect/TwxExpectTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxDir/TwxDirTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMath/TwxMathTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxIncrement/TwxIncrementTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxArg/TwxArgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxSplit/TwxSplitTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxExport/TwxExportTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxMessage/TwxMessageTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTree/TwxTreeTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxHook/TwxHookTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxUtil/TwxUtilTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxGlobal/TwxGlobalTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxAns/TwxAnsTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxState/TwxStateTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxCfg/TwxCfgTest.cmake" )
include ( "${CMAKE_CURRENT_LIST_DIR}/TwxBase/TwxBaseTest.cmake" )

file ( GLOB tests */Base/Test/*/*Test.cmake )
foreach ( t ${tests} )
  message ( TRACE "OTHER => \"${t}\"" )
  include ( ${t} )
endforeach ()

list ( POP_BACK CMAKE_MESSAGE_CONTEXT )

message ( STATUS "CMake/Base test... DONE" )

#*/
