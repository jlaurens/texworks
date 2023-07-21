#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*/
/** @file
@brief Translation helpers.

Include this file with

```
include ( TwxTranslationLib )
```

This requires `TwxBase`

*//*
#]===============================================]

include_guard ( GLOBAL )

include ( "${CMAKE_CURRENT_LIST_DIR}../Base/TwxBase.cmake" )

set ( CMAKE_AUTORCC ON )
	
# ANCHOR: twx_translation_target_setup
#[=======[
*//**
@brief Add transation capabilities to a target

Make the `.qrc` file from the given `.ts` and `.qm` files.

Usage
```
```

@param target is the name of a target
@param build_dir for key `BUILD_DIR`, is the location of built material
@param ts_files for key `TS_FILES`, is a list of `.ts` files
@param qm_files for key `QM_FILES`, is a list of `.qm` files
@param ui_files for key `UI_FILES`, is a list of `.ui` files
*/
twx_translation_target_setup ( target ) {}
/*
#]=======]
function ( twx_translation_target_setup twx.R_TARGET )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "BUILD_DIR" "TS_FILES;QM_FILES;UI_FILES" )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( twx.R_TARGET )
  twx_assert_non_void ( twx.R_BUILD_DIR )
  twx_assert_non_void ( QtMAJOR )

  list ( SORT twx.R_TS_FILES )
  qt_add_translation ( my_generated_qm ${twx.R_TS_FILES} )
  set (
    my_qrc_path
    "${twx.R_BUILD_DIR}/trans/${twx.R_TARGET}.qrc"
  )
  twx_translation_make_qrc (
    ${my_qrc_path}
    QM_FILES "${my_generated_qm}" ${twx.R_QM_FILES}
  )
  target_sources ( ${twx.R_TARGET} PRIVATE ${my_qrc_path} )
  # Explicitly set the generated .qm files as dependencies for the autogen
  # target to ensure they are built before AUTORCC is run
  set_target_properties (
    ${twx.R_TARGET}
    PROPERTIES
      AUTOGEN_TARGET_DEPENDS "${my_qrc_path}"
  )

  get_target_property ( _lupdate_path ${QtMAJOR}::lupdate LOCATION )
  get_target_property ( _sources ${twx.R_TARGET} SOURCES )
  twx_state_serialize ()
  add_custom_target (
    ${twx.R_TARGET}_translation
    COMMAND "${CMAKE_COMMAND}"
      "-DTWX_BUILD_DIR=\"${twx.R_BUILD_DIR}\""
      "-DTWX_TARGET=\"${twx.R_TARGET}\""
      "-DTWX_INPUT_FILES=\"${_sources};${${twx.R_TARGET}_UIS};${${twx.R_TARGET}_TRANS_TS}\""
      "-DTWX_INCLUDE_PATH=\"${TYWX_DIR}/src\""
      "-DQt_LUPDATE_EXECUTABLE=\"${_lupdate_path}\""
      "${-DTWX_STATE}"
      -P "${TWX_DIR}CMake/Script/TwxTranslationScript.cmake"
  )
  if ( NOT TARGET UpdateTranslations )
    add_custom_target( UpdateTranslations )
  endif ()
  add_dependencies (
    UpdateTranslations
    ${twx.R_TARGET}_translation
  )
endfunction ( twx_translation_target_setup )

# ANCHOR: twx_translation_make_qrc
#[=======[
*//**
@brief Create a `.qrc` file from `.qm` files

@param path is the name of a target
@param ... for key `QM_FILES` is the list of `.qm` files to embed.
*/
twx_translation_make_qrc ( path QM_FILES ... ) {}
/*
#]=======]
function ( twx_translation_make_qrc outfile )
  cmake_parse_arguments ( PARSE_ARGV 0 twx.R "" "" "QM_FILES" )
  twx_arg_assert_parsed ()
  set ( _contents
    "<!DOCTYPE RCC>"
    "<RCC version=\"1.0\">"
    "<qresource>"
  )
  foreach ( _file ${twx.R_QM_FILES} )
    get_filename_component ( _filename "${_file}" NAME )
    list ( APPEND _contents
      "<file alias=\"resfiles/translations/${_filename}\">${_file}</file>"
    )
  endforeach ( _file )
  list (
    APPEND _contents
    "</qresource>"
    "</RCC>"
  )
  string ( REPLACE ";" "\n" _contents "${_contents}" )
  file ( WRITE "${outfile}(busy)" "${_contents}" )
  execute_process (
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${outfile}(busy)"
      "${outfile}"
    COMMAND ${CMAKE_COMMAND} -E remove
      "${outfile}(busy)"
  )
endfunction(twx_translation_make_qrc)
