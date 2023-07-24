#[===============================================[/*
This is part of the TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Convenient shortcuts to manage warnings.

Usage:
```
include ( TwxWarningLibLib )
```
*//** @brief Adapted to each compiler.

Values are reset to factory defaults
each time the script is included.
*/
TWX_WARNING_OPTIONS;
/*
#]===============================================]

include_guard ( GLOBAL )

twx_lib_will_load ()

# ANCHOR: twx_warning_target
#[=======[
*//**
@brief Set warning options to the given target
@param target the name of an existing target
*/
twx_warning_target(target) {}
/*
#]=======]
function ( twx_warning_target target_ )
  target_compile_options (
    ${target_}
    PRIVATE ${TWX_WARNING_OPTIONS}
  )
endfunction ()

# ANCHOR: twx_warning_add
#[=======[
*/
/**
  * @brief Append the given warning options
  *
  * @param ... list of warning options like `-W...`
  */
twx_warning_add ( ... ) {}
/*
#]=======]
function ( twx_warning_add )
  list (
    APPEND TWX_WARNING_OPTIONS
    ${ARGN}
  )
endfunction ()

# ANCHOR: twx_warning_remove
#[=======[
*/
/**
  * @brief Remove the given warning options
  *
  * @param ... list of warning options like `-W...`
  */
twx_warning_remove ( ... ) {}
/*
#]=======]
function ( twx_warning_remove )
  list (
    REMOVE_ITEM TWX_WARNING_OPTIONS
    ${ARGN}
  )
endfunction ()

# ANCHOR: TWX_WARNING_OPTIONS
#[=======[
# Initialize `TWX_WARNING_OPTIONS`
#]=======]
if ( NOT DEFINED TWX_WARNING_OPTIONS )
  if (MSVC)
    twx_warning_add ( /W4 )
  else ()
    twx_warning_add (
      -Wall -Wpedantic -Wextra -Wconversion
      -Wold-style-cast -Woverloaded-virtual
    )
  endif ()
endif ()

twx_lib_did_load ()

#*/
