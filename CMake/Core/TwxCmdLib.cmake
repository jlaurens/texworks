#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Command utilities
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxCmdLib.cmake"
  *   )
  *
  * Output state:
  * - `twx_function_begin ()`
  * - `twx_function_end ()`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_function_begin
#[=======[*/
/** @brief Begin the body of a command.
  *
  * Call this at the beginning of each function or macro.
  * @param name, optional function or command name that will appear
  *   in the context. Useful for macros.
  *   For functions, CMAKE_CURRENT_FUNCTION is used.
  * @param yorn for key `MESSAGE_CONTEXT_SHOW`, optional value.
  */
twx_function_begin(name [MESSAGE_CONTEXT_SHOW yorn]) {}
/*#]=======]
macro ( twx_macro_begin )
  cmake_parse_arguments( TwxCmdLib.R "" "MESSAGE_CONTEXT_SHOW" "" ${ARGV} )
  list ( APPEND TwxCmdLib.TWX_CMD ${TWX_CMD} )
  if ( TwxCmdLib.R_UNPARSED_ARGUMENTS STREQUAL "" )
    message ( FATAL_ERROR "Missing name" )
  else ()
    set ( TWX_CMD "${TwxCmdLib.R_UNPARSED_ARGUMENTS}" )
  endif ()
  list ( APPEND CMAKE_MESSAGE_CONTEXT ${TWX_CMD} )
  string ( REPLACE ";" "->" TWX_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" )
  list ( APPEND TwxCmdLib.MESSAGE_CONTEXT_SHOW ${CMAKE_MESSAGE_CONTEXT_SHOW} )
  if ( DEFINED TwxCmdLib.R_MESSAGE_CONTEXT_SHOW )
    set ( CMAKE_MESSAGE_CONTEXT_SHOW "${TwxCmdLib.R_MESSAGE_CONTEXT_SHOW}" )
  endif ()
endmacro ( twx_macro_begin )

# ANCHOR: twx_function_begin
#[=======[*/
/** @brief Begin the body of a command.
  *
  * Call this at the beginning of each function or macro.
  * @param name, optional function or command name that will appear
  *   in the context. Useful for macros.
  *   For functions, CMAKE_CURRENT_FUNCTION is used.
  * @param yorn for key `MESSAGE_CONTEXT_SHOW`, optional value.
  */
twx_function_begin([MESSAGE_CONTEXT_SHOW yorn]) {}
/*#]=======]
macro ( twx_function_begin )
  twx_macro_begin ( ${CMAKE_CURRENT_FUNCTION} ${ARGV} )
endmacro ( twx_function_begin )

# ANCHOR: twx_function_end
#[=======[*/
/** @brief Begin the body of a command.
  *
  * Call this at the end of each macro.
  */
twx_function_end() {}
/*#]=======]
macro ( twx_macro_end )
  list ( POP_BACK TwxCmdLib.TWX_CMD TWX_CMD )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
  string ( REPLACE ";" "->" TWX_MESSAGE_CONTEXT "${CMAKE_MESSAGE_CONTEXT}" )
  list ( POP_BACK TwxCmdLib.MESSAGE_CONTEXT_SHOW )
endmacro ( twx_macro_end )

# ANCHOR: twx_function_end
#[=======[*/
/** @brief Begin the body of a command.
  *
  * Call this at the end of each macro.
  */
twx_function_end() {}
/*#]=======]
macro ( twx_function_end )
  twx_macro_end ()
endmacro ( twx_function_end )

twx_lib_did_load ()

#*/
