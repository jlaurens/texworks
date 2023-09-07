#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Hook management.
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include ( TwxHookLib.cmake )
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# ANCHOR: twx_hook_call
#[=======[*/
/** @brief Run the commands registered for a given hook.
  *
  * Each command is run in the current scope.
  * The call order is exactly the registering order.
  *
  * @param hook_id for key ID, a variable name uniquely identifying the hook.
  * @param ..., possibly empty list of arguments forwarded to the
  * registered commands. Semicolon should be escaped.
  */
twx_hook_call(Id hook_id ...) {}
/*#]=======]
macro ( twx_hook_call .ID twx.R_ID )
  twx_function_begin ()
  twx_expect_equal_string ( "${.ID}" "ID" )
  twx_tree_get (
    TREE TWX_HOOK_COMMANDS
    KEY "${twx.R_ID}"
    IN_VAR twx_hook_call.commands
  )
  message ( TRACE "Commands ``${twx_hook_call.commands}''" )
  foreach ( twx_hook_call.cmd ${twx_hook_call.commands} )
    message ( TRACE "Call ``${twx_hook_call.cmd}''" )
    cmake_language ( CALL "${twx_hook_call.cmd}" ${ARGN} )
  endforeach ()
  set ( twx_hook_call.commands )
  set ( twx_hook_call.cmd )
  list ( POP_BACK CMAKE_MESSAGE_CONTEXT )
endmacro ()

# ANCHOR: twx_hook_export
#[=======[*/
/** @brief Export registered hooked commands.
  *
  * Export the private storage to the parent scope.
  */
twx_hook_export() {}
/*#]=======]
macro ( twx_hook_export )
  twx_export ( TWX_HOOK_COMMANDS )
endmacro ()

# ANCHOR: twx_hook_register
#[=======[*/
/** @brief Register a command for a given hook.
  *
  * @param hook_id for key ID, a variable name uniquely identifying the hook.
  *   This must not only consist of uppercase letters with underscores.
  *   Commands are registered only once, each further attempt to register a command
  *   a second time will place the command at the end of the list.
  * @param ..., non empty list of command names. These are called by `twx_hook_call()`.
  */
twx_hook_register(ID hook_id ... ) {}
/*#]=======]
function ( twx_hook_register .ID twx.R_ID )
  twx_function_begin ()
  twx_expect_equal_string ( "${.ID}" "ID" )
  twx_tree_get (
    TREE TWX_HOOK_COMMANDS
    KEY "${twx.R_ID}"
    IN_VAR commands_
  )
  twx_expect_unequal_string ( "${ARGN}" "" )
  list ( REMOVE_ITEM commands_ ${ARGN} )
  list ( APPEND commands_ ${ARGN} )
  twx_tree_set (
    TREE TWX_HOOK_COMMANDS
    "${twx.R_ID}=${commands_}"
  )
  message ( TRACE "Registered: ``${commands_}''" )
  twx_hook_export ()
endfunction ()

# ANCHOR: twx_hook_unregister
#[=======[*/
/** @brief Unregister a command for a given hook.
  *
  * @param hook_id for key ID, a variable name uniquely identifying the hook.
  * @param ..., list of command names. Remove the given commands from the list
  * of commands that are called by `twx_hook_call()`.
  * If the list is empty then all the commands are unregistered.
  */
twx_hook_unregister(ID hook_id ...) {}
/*#]=======]
function ( twx_hook_unregister .ID twx.R_ID )
  twx_function_begin ()
  twx_expect_equal_string ( "${.ID}" "ID" )
  twx_tree_get (
    TREE TWX_HOOK_COMMANDS
    KEY "${twx.R_ID}"
    IN_VAR commands_
  )
  if ( "${ARGN}" STREQUAL "" )
    twx_tree_set (
      TREE TWX_HOOK_COMMANDS
      "${twx.R_ID}"
    )
  else ()
    list ( REMOVE_ITEM commands_ ${ARGN} )
    twx_tree_set (
      TREE TWX_HOOK_COMMANDS
      "${twx.R_ID}=${commands_}"
    )
  endif ()
  twx_hook_export ()
endfunction ()

twx_lib_require ( "Fatal" "Tree" "Expect" "Export" )

# ANCHOR: TWX_HOOK_COMMANDS
twx_tree_init ( TREE TWX_HOOK_COMMANDS )

twx_lib_did_load ()

#*/
