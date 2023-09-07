#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief Variable utilities
  *
  * See @ref CMake/README.md.
  *
  * Usage:
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Core/TwxVarLib.cmake"
  *   )
  *
  * Output state:
  * - `twx_var_assert_name ()`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_var_assert_name
#[=======[*/
/** @brief Raise when not a literal variable name.
  *
  * @param ..., non empty list of variables names to test.
  */
twx_var_assert_name(...) {}
/*#]=======]
function ( twx_var_assert_name .name )
  twx_function_begin ()
  set ( i 0 )
  while ( TRUE )
    set ( v "${ARGV${i}}" )
    # message ( TR@CE "v => ``${v}''" )
    if ( NOT "${v}" MATCHES "${/TWX/CONST/VARIABLE_RE}" )
      set ( msg "Not a variable name: ``${v}''" )
      if ( COMMAND twx_fatal )
        twx_fatal ( "${msg}" RETURN )
      else ()
        message ( FATAL_ERROR "${msg}" )
      endif ()
    endif ()
    math ( EXPR i "${i}+1" )
    if ( i GREATER_EQUAL ARGC )
      break ()
    endif ()
  endwhile ()
endfunction ( twx_var_assert_name )

# ANCHOR: twx_var_log
#[=======[*/
/** @brief Log variable contents.
  *
  * @param mode, optional `message()` mode, defaults to `NOTICE`.
  *   When mode is `FATAL_ERROR` and `twx_fatal()` command is used
  *   instead of `message()` when available.
  * @param ..., the list of variable names.
  * @param msg for key `MSG`, optional banner message.
  * @param RETURN_ON_FATAL, optional flag. When set and in `FATAL_ERROR` mode,
  *   execute `return()`.
  *   Takes precedence over `BREAK_ON_FATAL`.
  * @param BREAK_ON_FATAL, optional flag. When set and in `FATAL_ERROR` mode,
  *   execute `break()`. 
  */
twx_var_log( [mode] ... [MSG msg] [RETURN_ON_FATAL] [BREAK_ON_FATAL]) {}
/*#]=======]
macro ( twx_var_log )
  set ( twx_var_log.ARGV ${ARGV} )
  if ( "${ARGV0}" IN_LIST /TWX/CONST/MESSAGE/MODES )
    list ( POP_FRONT twx_var_log.ARGV twx_var_log.MODE )
  else ()
    set ( twx_var_log.MODE )
  endif ()
 # message ( "*************** twx_var_log.I => ``${twx_var_log.I}''")
  cmake_parse_arguments (
    twx_var_log.R "BREAK_ON_FATAL;RETURN_ON_FATAL" "MSG" "" ${twx_var_log.ARGV}
  )
  if ( DEFINED twx_var_log.R_MSG )
    set ( twx_var_log.R_MSG " ${twx_var_log.R_MSG}: " )
  else ()
    set ( twx_var_log.R_MSG )
  endif ()
  # message ( "*************** twx_var_log.R_UNPARSED_ARGUMENTS => ``${twx_var_log.R_UNPARSED_ARGUMENTS}''")
  # message ( "*************** ARGV => ``${ARGV}''")
  foreach ( twx_var_log.X IN LISTS twx_var_log.R_UNPARSED_ARGUMENTS )
    if ( DEFINED ${twx_var_log.X} )
      set ( twx_var_log.X "${twx_var_log.R_MSG}${/TWX/FORMAT/Var}${twx_var_log.X} => ``${${twx_var_log.X}}''${/TWX/FORMAT/RESET}" )
    else ()
      set ( twx_var_log.X "${twx_var_log.R_MSG}${/TWX/FORMAT/Var}${twx_var_log.X} => UNDEFINED${/TWX/FORMAT/RESET}" )
    endif ()
    if ( COMMAND twx_fatal AND twx_var_log.MODE STREQUAL "FATAL_ERROR" )
      twx_fatal ( "${twx_var_log.X}" )
      if ( twx_var_log.R_RETURN_ON_FATAL )
        return ()
      elseif ( twx_var_log.R_BREAK_ON_FATAL )
        break ()
      endif ()
    else ()
      message ( ${twx_var_log.MODE} "${twx_var_log.X}" )
    endif ()
  endforeach ()
  foreach ( X ARGV MODE R_BREAK_ON_FATAL R_RETURN_ON_FATAL R_MSG R_UNPARSED_ARGUMENTS R_KEYWORDS_MISSING_VALUES )
    set ( twx_var_log.${X} )
  endforeach ()
endmacro ( twx_var_log )

# ANCHOR: twx_var_unset
#[=======[*/
/** @brief Unset variables.
  *
  * @param ..., list of variable names, of suffices if `VAR_PREFIX` is provided.
  * @param prefix for key `VAR_PREFIX`, optional prefix for all given names.
  */
twx_var_unset(... [VAR_PREFIX prefix]) {}
/*#]=======]
macro ( twx_var_unset )
  # Possible name conflicts
  cmake_parse_arguments (
    twx_var_unset.R "" "VAR_PREFIX" "" ${ARGV}
  )
  foreach ( X IN LISTS twx_var_unset.R_UNPARSED_ARGUMENTS )
    set ( ${twx_var_unset.R_VAR_PREFIX}${X} )
  endforeach ()
  set ( twx_var_unset.R_VAR_PREFIX )
endmacro ()

twx_lib_require ( Const )

twx_lib_did_load ()

#*/
