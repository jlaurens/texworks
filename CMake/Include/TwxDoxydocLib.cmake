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

if ( NOT TWX_IS_BASED )
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

option (
  TWX_DOCUMENT_TEST_SUITES
  "Document the Test suites"
  OFF
)

# ANCHOR: twx_doxydoc
#[=======[*/
/*! @fn twx_doxydoc(binary_dir)

Generate source documentation with a target.

Put `twx_doxydoc(binary_dir)` in the main `CMakeLists.txt`
and run `make doxydoc` from the command line in that same build directory.
The documentation is then available at `<binary_dir>/doxydoc/`.

This function is one shot. Next invocation will issue a warning.
If Doxygen is not installed, this function is a noop.

Input:
- `.../Developer/doxydoc.in.txt` is the configuration file

    @param PROJECT optional flag for projects.
    @param MODULE optional flag for modules.
 */
void twx_doxydoc([PROJECT|MODULE]) {}
/*#]=======]
function ( twx_doxydoc )
  twx_parse_arguments ( "PROJECT;MODULE" "" "" ${ARGN} )
  twx_assert_parsed ()
  if ( my_twx_MODULE )
    if ( "${TWX_MODULE_NAME}" STREQUAL "" )
      message ( FATAL_ERROR "No module defined" )
    endif ()
    set ( target_ "doxydoc_module_${TWX_MODULE_NAME}" )
    include ( TwxModuleLib )
    
    set ( in_  "${TWX_DIR}/Developer/doxydoc.in.txt" )
    set ( out_ "${TWX_BUILD_DATA_DIR}/doxydoc.txt" )
    set (
      TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
      ${TWX_DOC_DIR}/doxydoc
    )
  elseif ( my_twx_PROJECT )
    set ( target_ "doxydoc_${PROJECT_NAME}" )
    set ( in_  "${TWX_DIR}/Developer/doxydoc.in.txt" )
    set ( out_ "${TWX_BUILD_DATA_DIR}/doxydoc.txt" )
    set (
      TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
      ${TWX_DOC_DIR}/doxydoc
    )
  else ()
    set ( target_ "doxydoc" )
    set ( in_  "${TWX_DIR}/Developer/doxydoc.in.txt" )
    set ( out_ "${TWX_BUILD_DATA_DIR}/doxydoc.txt" )
    set (
      TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
      ${TWX_DOC_DIR}/doxydoc
    )
  endif ()


  twx_assert_non_void ( TWX_DOC_DIR )
  if ( "${ARGN}" STREQUAL "" )
    if ( TARGET doxydoc )
      twx_message_verbose ( WARNING "Main doxydoc target already defined" )
      return ()
    endif ()
    twx_assert_non_void ( TWX_DIR )
    twx_assert_non_void ( TWX_BUILD_DATA_DIR )
    # this is the main documentation
    set (
      twx_in
      "${TWX_DIR}/Developer/doxydoc.in.txt"
    )
    set (
      twx_out
      "${TWX_BUILD_DATA_DIR}/doxydoc.txt"
    )
    set (
      TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
      ${TWX_DOC_DIR}/doxydoc
    )
    if ( TWX_DOCUMENT_TEST_SUITES )
      set ( TWX_CFG_DOXYGEN_EXCLUDE_PATTERNS )
    else ()
      set ( TWX_CFG_DOXYGEN_EXCLUDE_PATTERNS "*/Test/* *private*" )
    endif ()
    configure_file ( ${twx_in} ${twx_out} @ONLY )
    add_custom_target(
      doxydoc
      COMMAND ${DOXYGEN_EXECUTABLE} ${twx_out}
      WORKING_DIRECTORY ${TWX_DIR}
      COMMENT "Generating main developer documentation with Doxygen"
      VERBATIM
    )
    return ()
  endif ()
  if ( TARGET doxydoc )
  message ( WARNING "Main doxydoc target already defined" )
  return ()
endif ()
set ( name_ "${ARGN}" )

twx_assert_non_void ( TWX_DIR )
twx_assert_non_void ( TWX_BUILD_DATA_DIR )
# this is the main documentation
set (
  twx_in
  "${TWX_DIR}/Developer/doxydoc.in.txt"
)
set (
  twx_out
  "${TWX_BUILD_DATA_DIR}/doxydoc.txt"
)
set (
  TWX_CFG_DOXYGEN_OUTPUT_DIRECTORY
  ${TWX_DOC_DIR}/doxydoc
)
if ( TWX_DOCUMENT_TEST_SUITES )
  set ( TWX_CFG_DOXYGEN_EXCLUDE_PATTERNS )
else ()
  set ( TWX_CFG_DOXYGEN_EXCLUDE_PATTERNS "*/Test/* *private*" )
endif ()
configure_file ( ${twx_in} ${twx_out} @ONLY )
add_custom_target(
  doxydoc
  COMMAND ${DOXYGEN_EXECUTABLE} ${twx_out}
  WORKING_DIRECTORY ${TWX_DIR}
  COMMENT "Generating main developer documentation with Doxygen"
  VERBATIM
)




  twx_assert_non_void ( PROJECT_SOURCE_DIR )
  twx_assert_non_void ( TWX_DOC_DIR )
  twx_assert_non_void ( TWX_PROJECT_BUILD_DATA_DIR )
endfunction ( twx_doxydoc )

#[=======[
*/
#]=======]
