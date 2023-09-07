#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
  * @brief  Doxygen support
  *
  * Doxygen support to generate source documentation.
  * See @ref CMake/README.md.
  *
  * Usage (`TwxBase` is required) :
  *
  *   include ( TwxDoxydocLib )
  *   twx_doxydoc (...)
  *
  * Output:
  * 
  * - `twx_doxydoc()`
  * 
  */
/*#]===============================================]

include_guard ( GLOBAL )

function ( twx_doxydoc )
  message (
    STATUS
    "Not doxydoc in script mode"
  )
endfunction ()

twx_lib_will_load ( NO_SCRIPT )

find_package ( Doxygen )

if ( NOT DOXYGEN_FOUND )
  function ( twx_doxydoc )
    message (
      STATUS
      "Install Doxygen to generate the developer documentation"
    )
  endfunction ()
  twx_lib_did_load ()
  return ()
endif ()

# ANCHOR: twx_doxydoc
#[=======[*/
/** @brief Generate source documentation with a target.
  *
  * Put `twx_doxydoc(binary_dir)` in the main `CMakeLists.txt`
  * and run `make doxydoc` from the command line in that same build directory.
  * The documentation is then available at `<binary_dir>/doxydoc/`.
  *
  * This function is one shot. Next invocation will issue a warning.
  * If Doxygen is not installed, this function is a noop.
  *
  * Input:
  * - `.../Developer/doxydoc.in.txt` is the configuration file
  * 
  */
void twx_doxydoc() {}
/*#]=======]
function ( twx_doxydoc )
  twx_function_begin ()
  # set input and output files
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "SOURCE_DIR" ""
  )
  if ( NOT twx.R_SOURCE_DIR )
    set ( twx.R_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  endif ()
  twx_assert_non_void ( twx.R_SOURCE_DIR )
  set (
    twx_in
    "${twx.R_SOURCE_DIR}/Developer/doxydoc.in.txt"
  )
  message ( "``${twx_in}''" )
  if ( NOT EXISTS "${twx_in}" )
    set (
      twx_in
      "${TWX_DIR}Developer/doxydoc.in.txt"
    )
  endif ()
  twx_assert_exists ( "${twx_in}" )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  set (
    twx_out
    "${TWX_PROJECT_BUILD_DATA_DIR}doxydoc.txt"
  )
  twx_assert_non_void ( CMAKE_CURRENT_BINARY_DIR )
  twx_message_log ( DEBUG "configure_file: ``${twx_in}'' -> ``${twx_out}''" )
  # Complete state for configuration:
  set (
    /TWX/CFG/DOXYGEN_OUTPUT_DIRECTORY
    "${TWX_PROJECT_DOXYDOC_DIR}"
  )
  configure_file ( "${twx_in}" "${twx_out}" @ONLY )
  add_custom_target (
    ${PROJECT_NAME}_doxydoc
    COMMAND "${DOXYGEN_EXECUTABLE}" "${twx_out}"
    WORKING_DIRECTORY "${twx.R_SOURCE_DIR}"
    COMMENT "Generating ${PROJECT_NAME} developer documentation with Doxygen"
    VERBATIM
  )
  if ( TWX/PROJECT_IS_ROOT )
    if ( TARGET doxydoc )
      twx_fatal ( "``twx_doxydoc()'' already called on root project" )
      return ()
    endif ()
    add_custom_target ( doxydoc DEPENDS ${PROJECT_NAME}_doxydoc )
  endif ()
endfunction ( twx_doxydoc )

twx_lib_did_load ()

#*/
