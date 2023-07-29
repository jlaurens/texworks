#[===============================================[/*
This is part of the TWX build and test system.
See https://github.com/TeXworks/texworks
(C)  JL 2023
*//** @file
@brief Update the translation data file with `lupdate`.

Usage:
```
cmake ... -P .../CMake/Script/TwxTranslationCommmand.cmake
```

Expected input state:

- `TWX_TARGET`
- `TWX_BUILD_DIR`
- `TWX_INPUT_FILES`
- `TWX_INCLUDE_PATH`
- `Qt_LUPDATE_EXECUTABLE`
*//*
#]===============================================]

include_guard ( GLOBAL )

include ( "${CMAKE_CURRENT_LIST_DIR}/TwxTranslationLib.cmake" )

list ( SORT TWX_INPUT_FILES )
list ( REMOVE_DUPLICATES TWX_INPUT_FILES )

message( STATUS "Updating ${TWX_TARGET}.pro" )

# ANCHOR: twx_translation_create_pro_file
#[=======[
*//**
@brief Create a `.pro` file for translation purposes

@param path_var is the name of a variablel holding the project file path
@param target for key `TARGET` is the name of a target
@param include_path for key `INCLUDE_PATH` is the location to look for source files
@param build_dir for key `BUILD_DIR` is the location of build products
@param ... for key `INPUT_FILES` is the list of input files
*/
twx_translation_create_pro_file ( path_var TARGET target ) {}
/*
#]=======]
function( twx_translation_create_pro_file path_var_ )
  cmake_parse_arguments (
    PARSE_ARGV 0 twx.R
    "" "TARGET;INCLUDE_PATH;BUILD_DIR" "INPUT_FILES"
  )
  twx_arg_assert_parsed ()
  twx_assert_non_void ( path_var_ )
  twx_assert_non_void ( twx.R_TARGET )
  foreach ( label_ SOURCES HEADERS FORMS RESOURCES RC_FILE ICON TRANSLATIONS )
    set ( _my_${label_} )
  endforeach ()
  set ( pro_DIR_twx "${twx.R_BUILD_DIR}/trans" )
  # Sort files into different categories
  foreach ( _file ${twx.R_INPUT_FILES} )
    # TODO: Possibly skip files with GENERATED property
    get_filename_component ( _ext ${_file} EXT )
    get_filename_component ( _abs ${_file} ABSOLUTE )
    if ( _ext MATCHES "\\.ts$" )
      list ( APPEND _my_TRANSLATIONS ${_abs} )
    elseif ( _ext MATCHES "\\.ui$" )
      list ( APPEND _my_FORMS ${_abs} )
    elseif ( _ext MATCHES "\\.qrc$" )
      list ( APPEND _my_RESOURCES ${_abs} )
    elseif ( _ext MATCHES "\\.(h|hpp|hxx)$" )
      list ( APPEND _my_HEADERS ${_abs} )
    elseif ( _ext MATCHES "\\.(c|cpp|cxx|c\\+\\+)$" )
      list ( APPEND _my_SOURCES ${_abs} )
    elseif ( _ext MATCHES "\\.rc$" )
      if ( _my_RC_FILE STREQUAL "" )
        set ( _my_RC_FILE "${_abs}" )
      else ()
        message (
          AUTHOR_WARNING
          "twx_translation_create_pro_file: ignored ${_abs} after ${_my_RC_FILE}."
        )
      endif ()
    elseif ( _ext MATCHES "\\.icns$" )
      if ( _my_ICON STREQUAL "" )
        set ( _my_ICON "${_abs}" )
      else ()
        message (
          AUTHOR_WARNING
          "twx_translation_create_pro_file: ignored ${_abs} after ${_my_ICON}."
        )
      endif ()
    elseif ( NOT "${_ext}" STREQUAL "" )
      message (
        AUTHOR_WARNING
        "twx_translation_create_pro_file: ignored '${_abs}'."
      )
    endif ()
  endforeach ( _file )

  # Construct the .pro file
  set (
    pro_contents_twx "\
# READ ONLY\n
# This file was generated automatically by the TWX build and test system.
error(\"This file is not intended for building.\n\
Please use CMake instead. See README.md for further instructions.\")"
  )
  if ( NOT twx.R_INCLUDE_PATH STREQUAL "" )
    list (
      APPEND pro_contents_twx
      # INCLUDEPATH must be set so lupdate finds headers, namespace declarations, etc
      "INCLUDEPATH += ${twx.R_INCLUDEPATH}"
    )
  endif ()

  foreach ( label_ SOURCES HEADERS FORMS RESOURCES RC_FILE ICON TRANSLATIONS )
    set ( line_ "${label_} =" )
    foreach( _file ${_my_${label_}} )
      file ( RELATIVE_PATH _file ${pro_DIR_twx} ${_file} )
      list ( APPEND line_ "  ``${_file}''" )
    endforeach()
    string ( REPLACE ";" "\\\n" _file "${_file}" )
    list (
      APPEND pro_contents_twx
      "${_file}"
    )
  endforeach ()

  string ( REPLACE ";" "\n" pro_contents_twx "${pro_contents_twx}" )
  set ( ${path_var_} "${pro_DIR_twx}/${twx.R_TARGET}.pro" )
  file ( WRITE "${${path_var_}}(busy)" "${pro_contents_twx}\n" )
  execute_process (
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${${path_var_}}(busy)"
      "${${path_var_}}"
    COMMAND ${CMAKE_COMMAND} -E remove
      "${${path_var_}}(busy)"
    COMMAND_ERROR_IS_FATAL ANY
  )
  twx_export ( ${path_var_} )
endfunction ( twx_translation_create_pro_file )

twx_translation_create_pro_file (
	pro_path_
	TARGET "${TWX_TARGET}"
	BUILD_DIR "${TWX_BUILD_DIR}"
	INCLUDE_PATH "${TWX_INCLUDE_PATH}"
	INPUT_FILES "${TWX_INPUT_FILES}"
)

twx_message ( VERBOSE "TwxTranslationCommand: ${pro_path_}" DEEPER )

message ( STATUS "TwxTranslationCommand: Running lupdate ${TWX_TARGET}.pro" )
execute_process (
	COMMAND "${Qt_LUPDATE_EXECUTABLE}" "${TWX_TARGET}.pro"
  COMMAND_ERROR_IS_FATAL ANY
)
