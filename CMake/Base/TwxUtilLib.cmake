#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Utilities
  *
  *   include (
  *     "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxUtilLib.cmake"
  *   )
  *
  * Output state:
  * - `TWX_DIR`
  *
  */
/*#]===============================================]

include_guard ( GLOBAL )
twx_lib_will_load ()

# ANCHOR: Utility `twx_util_timestamp`
#[=======[
*/
/** @brief Retrieve the timestamp of a given file.
  *
  * Usage:
  *
  *   twx_util_timestamp ( <filepath_> IN_VAR <variable> )
  *
  * Records the file timestamp.
  * The precision is 1s.
  * Correct up to 2036-02-27.
  *
  * @param path,
  * @param var for key `IN_VAR` will hold the result on return.
  *
  */
twx_util_timestamp ( path IN_VAR var ) {}
/*
#]=======]
function ( twx_util_timestamp filepath_ twx_util_timestamp.IN_VAR twx_util_timestamp.R_IN_VAR )
  twx_arg_assert_count ( ${ARGC} == 3 )
  twx_arg_assert_keyword ( twx_util_timestamp.IN_VAR )
  twx_var_assert_name ( "${twx_util_timestamp.R_IN_VAR}" )
  file (
    TIMESTAMP "${filepath_}" twx_util_timestamp.TS "%S:%M:%H:%j:%Y" UTC
  )
  if ( twx_util_timestamp.TS MATCHES "^([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$" )
    math (
      EXPR
      twx_util_timestamp.TS "
      ${CMAKE_MATCH_1} + 60 * (
        ${CMAKE_MATCH_2} + 60 * (
          ${CMAKE_MATCH_3} + 24 * (
            ${CMAKE_MATCH_4} + 365 * (
              ${CMAKE_MATCH_5}-2023
            )
          )
        )
      )"
    )
    if ( "${CMAKE_MATCH_5}" GREATER "2024" )
      math (
        EXPR
        twx_util_timestamp.TS
        "${twx_util_timestamp.TS} + 86400"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2028" )
      math (
        EXPR
        twx_util_timestamp.TS
        "${twx_util_timestamp.TS} + 172800"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2032" )
      math (
        EXPR
        twx_util_timestamp.TS
        "${twx_util_timestamp.TS} + 259200"
      )
    elseif ( "${CMAKE_MATCH_5}" GREATER "2036" )
      math (
        EXPR
        twx_util_timestamp.TS
        "${twx_util_timestamp.TS} + 345600"
      )
    endif ()
  else ()
    set ( twx_util_timestamp.TS 0 )
  endif ()
  twx_export ( "${twx_util_timestamp.R_IN_VAR}=${twx_util_timestamp.TS}" )
endfunction ()

twx_lib_require ( "Arg" "Export" )

twx_lib_did_load ()

#*/
