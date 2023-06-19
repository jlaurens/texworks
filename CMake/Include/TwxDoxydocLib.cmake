#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief  Doxygen support

Doxygen support to generate source documentation.
See @ref CMake/README.md.

Usage (`TwxBase` is required) :
```
  include ( TwxDoxydocLib )
  twx_doxydoc (...)
```
Output:

- `twx_doxydoc()`

*/
/*#]===============================================]

if ( NOT DEFINED TWX_IS_BASED )
  message ( FATAL_ERROR "Missing `TwxBase`" )
  return ()
endif ()

if ( COMMAND twx_doxydoc )
  return ()
endif ()

find_package ( Doxygen )

if ( NOT DOXYGEN_FOUND )
  function ( twx_doxydoc )
    message (
      STATUS
      "Install Doxygen to generate the developer documentation"
    )
  endfunction ()
  return ()
endif ()

# ANCHOR: twx_doxydoc
#[=======[*/
/** @brief Generate source documentation with a target.

Put `twx_doxydoc(binary_dir)` in the main `CMakeLists.txt`
and run `make doxydoc` from the command line in that same build directory.
The documentation is then available at `<binary_dir>/doxydoc/`.

This function is one shot. Next invocation will issue a warning.
If Doxygen is not installed, this function is a noop.

Input:
- `.../Developer/doxydoc.in.txt` is the configuration file

 */
void twx_doxydoc() {}
/*#]=======]
function ( twx_doxydoc )
  # set input and output files
  twx_assert_non_void ( CMAKE_CURRENT_SOURCE_DIR )
  set (
    twx_in
    "${CMAKE_CURRENT_SOURCE_DIR}/Developer/doxydoc.in.txt"
  )
  if ( NOT EXISTS "${twx_in}" )
    set (
      twx_in
      "${TWX_DIR}Developer/doxydoc.in.txt"
    )
  endif ()
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
  set (
    twx_out
    "${TWX_PROJECT_BUILD_DATA_DIR}doxydoc.txt"
  )
  twx_assert_non_void ( CMAKE_CURRENT_BINARY_DIR )
  set (
    TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/doxydoc/
  )
  configure_file ( ${twx_in} ${twx_out} @ONLY )
  add_custom_target (
    ${PROJECT_NAME}_doxydoc
    COMMAND ${DOXYGEN_EXECUTABLE} ${twx_out}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generating ${PROJECT_NAME} developer documentation with Doxygen"
    VERBATIM
  )
  if ( TWX_PROJECT_IS_ROOT )
    add_custom_target ( doxydoc ALIAS ${PROJECT_NAME}_doxydoc )
  endif ()
endfunction ( twx_doxydoc )

#*/
