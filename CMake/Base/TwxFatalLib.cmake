#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Fatal utilities
  *
  * include (
  *   "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxFatalLib.cmake"
  * )
  *
  * Utilities:
  *
  * - `twx_fatal()`, a shortcut to `message(FATAL_ERROR ...)``
  *   with some testing facilities.
  *
  * Testing utilities:
  * - `twx_fatal_catched()`
  */
/*#]===============================================]

include_guard ( GLOBAL )

# We define a custom target as global scope.
if ( NOT CMAKE_SCRIPT_MODE_FILE )
  add_custom_target (
    TwxFatalLib.cmake
  )
  define_property (
    TARGET PROPERTY TWX_FATAL_MESSAGE
  )
endif ()

# ANCHOR: twx_fatal
#[=======[
*/
/** @brief Terminate with a FATAL_ERROR message.
  *
  * @param ..., non empty list of text messages.
  *   In normal mode, all parameters are forwarded as is to `message(FATAL_ERROR ...)`.
  *   In test mode, the parameters are recorded for later use,
  *   nothing is displayed and the program does not stop.
  *
  */
twx_fatal(...){}
/*
#]=======]
function ( twx_fatal )
  set ( m )
  set ( i 0 )
  unset ( ARGV${ARGC} )
  while ( TRUE )
    if ( NOT DEFINED ARGV${i} )
      break ()
    endif ()
    if ( ARGV${i} MATCHES "(^|[^\\])(\\\\)*\\$" )
      list ( APPEND m "${ARGV${i}}\\" )
    else ()
      list ( APPEND m "${ARGV${i}}" )
    endif ()
    math ( EXPR i "${i}+1" )
  endwhile ()
  if ( TWX_FATAL_CATCH AND NOT CMAKE_SCRIPT_MODE_FILE )
    get_target_property(
      fatal_
      TwxFatalLib.cmake
      TWX_FATAL_MESSAGE
    )
    if ( fatal_ MATCHES "-NOTFOUND$")
      set ( fatal_ )
    endif ()
    list ( APPEND fatal_ "${m}" )
    set_target_properties (
      TwxFatalLib.cmake
      PROPERTIES
        TWX_FATAL_MESSAGE "${fatal_}"
    )
  else ()
    message ( FATAL_ERROR ${m} )
  endif ()
endfunction ()

message ( DEBUG "TwxFatalLib loaded" )

#*/
