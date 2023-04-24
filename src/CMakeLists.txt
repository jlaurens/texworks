# Build TeXworks
# ==============

# Collect Source Files
# --------------------

# **NOTE:** _A `GLOB` operation is quick, but may not be appropriate. It may be
# better to maintain an explicit list of source files. Particularly, adding a
# new file to an explicit list will cause CMake to automatically reconfigure
# the next time `make` is invoked. When `GLOB` is used, the developer will have
# to remember to re-run `cmake` if a source file is added._

include ( TwxSrcSetup )

set (
  ${PROJECT_NAME}_SOURCES
  ${TwxSrc_SOURCES}
)

set (
  ${PROJECT_NAME}_HEADERS
  ${TwxSrc_HEADERS}
)


if ( WIN32 )
  list ( APPEND ${PROJECT_NAME}_SOURCES InterProcessCommunicatorWin.cpp )
elseif ( APPLE )
  list ( APPEND ${PROJECT_NAME}_SOURCES InterProcessCommunicatorDummy.cpp )
  list ( APPEND ${PROJECT_NAME}_SOURCES utils/OSVersionInfo_mac.mm )
else ()
  list ( APPEND ${PROJECT_NAME}_SOURCES InterProcessCommunicatorDBus.cpp )
endif ()

if ( WITH_QTSCRIPT )
  list ( APPEND ${PROJECT_NAME}_SOURCES scripting/JSScriptInterface.cpp scripting/JSScript.cpp )
  list ( APPEND ${PROJECT_NAME}_HEADERS scripting/JSScriptInterface.h scripting/JSScript.h )
  add_definitions ( -DWITH_QTSCRIPT )
endif ()

set (TEXWORKS_UIS CitationSelectDialog.ui
                 CompletingEdit.ui
                 Find.ui
                 HardWrapDialog.ui
                 PDFDocumentWindow.ui
                 PDFFind.ui
                 PrefsDialog.ui
                 Replace.ui
                 ResourcesDialog.ui
                 ScriptManagerWidget.ui
                 SearchResults.ui
                 TemplateDialog.ui
                 TeXDocumentWindow.ui
                 ToolConfig.ui
                 ui/ListSelectDialog.ui
                 )

set (TEXWORKS_RCS ${TWX_DIR_res}/resfiles.qrc
                 ${TWX_DIR_res}/resources.qrc)

FILE ( GLOB TEXWORKS_TRANS_TS   "${TWX_DIR_trans}/*.ts" )
FILE ( GLOB QT_TRANS_QM         "${TWX_DIR_trans}/qt/*.qm" )

# Create the `<...>.rc` file
if ( WIN32 )
  set (
    TWX_out_l
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.rc
  )
  if ( NOT EXISTS "${TWX_out_l}" )
    set (
      TWX_in_l
      ${TWX_DIR_res}/TeXworks.in.rc
    )
    if ( NOT MSVC )
      set ( CREATE_MANIFEST TRUE )
    endif ( NOT MSVC )
    twx_configure_file_set (
      APP_ICO       "${TWX_DIR_res}/images/TeXworks.ico"
      DOC_ICO       "${TWX_DIR_res}/images/TeXworks-doc.ico"
      VERSION_MAJOR ${PROJECT_NAME}_VERSION_MAJOR
      VERSION_MINOR ${PROJECT_NAME}_VERSION_MINOR
      VERSION_PATCH ${PROJECT_NAME}_VERSION_PATCH
      NAME          ${PROJECT_NAME}
      COPYRIGHT
        "Copyright (C) 2007-2023  Jonathan Kew, Stefan L�ffler, Charlie Sharpsteen"
      VERSION       ${PROJECT_NAME}_VERSION
      REVISION      ${TWX_GIT_HASH}
      MANIFEST      "${TWX_DIR_res}/TeXworks.exe.manifest"
    )
    configure_file ( ${TWX_in_l} ${TWX_out_l} )
    list (
      APPEND ${PROJECT_NAME}_SOURCES
      ${TWX_out_l}
    )
    twx_configure_file_unset (
      APP_ICO
      DOC_ICO
      VERSION_MAJOR
      VERSION_MINOR
      VERSION_PATCH
      NAME
      VERSION
      REVISION
      COPYRIGHT
      MANIFEST
    )
    unset ( TWX_in_l )
  endif ()
  unset ( TWX_out_l )
endif ( WIN32 )

# These source files along with the `.moc` files generated from some headers
# form the TeXworks scripting API. We export them to variables in the
# `PARENT_SCOPE` ( top level CMake file ) so that they will be available to the
# build processes of the scripting language plugins.
SET (TeXworks_SCRIPT_API
  ${CMAKE_CURRENT_SOURCE_DIR}/scripting/Script.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/scripting/ScriptAPI.cpp
  PARENT_SCOPE
)

SET (TeXworks_SCRIPT_API_H
  ${CMAKE_CURRENT_SOURCE_DIR}/scripting/Script.h
  ${CMAKE_CURRENT_SOURCE_DIR}/scripting/ScriptAPI.h
  ${CMAKE_CURRENT_SOURCE_DIR}/TWSystemCmd.h
  ${CMAKE_CURRENT_SOURCE_DIR}/Settings.h
  PARENT_SCOPE
)

# App Setup
# ---------

# On OS X, set GUI type to an `.app` bundle, gather icon files and add core system
# frameworks to the library link list.
IF ( APPLE )
  SET ( GUI_TYPE MACOSX_BUNDLE )

  LIST ( APPEND ${PROJECT_NAME}_LIBRARIES  "-framework Foundation" )

  set ( TeXworks_APP_ICONS "${TWX_DIR_res}/TeXworks.icns" "${TWX_DIR_res}/TeXworks-doc.icns" )
  SET_SOURCE_FILES_PROPERTIES ( ${TeXworks_APP_ICONS}
    PROPERTIES
      MACOSX_PACKAGE_LOCATION Resources
  )
ENDIF ()

# **WARNING:** _Windows is untested_
IF ( WIN32 )
  SET ( GUI_TYPE WIN32 )
ENDIF ()

# Compilation
# -----------

IF ( NOT ${BUILD_SHARED_PLUGINS} )
  IF ( WITH_LUA AND LUA_FOUND )
    LIST ( INSERT ${PROJECT_NAME}_LIBRARIES 0 TWLuaPlugin ${LUA_LIBRARIES} )
  ENDIF ()
  IF ( WITH_PYTHON AND PYTHONLIBS_FOUND )
    LIST ( INSERT ${PROJECT_NAME}_LIBRARIES 0 TWPythonPlugin ${PYTHON_LIBRARIES} )
  ENDIF ()
ENDIF ()

# Build the executable
ADD_EXECUTABLE (
  ${PROJECT_NAME}_target
  ${GUI_TYPE}
  ${${PROJECT_NAME}_SOURCES}
  ${${PROJECT_NAME}_HEADERS}
  ${TEXWORKS_RCS}
  ${TeXworks_APP_ICONS}
)
add_dependencies (
  ${PROJECT_NAME}_target
  GitRev_target
)

if ( UNIX AND NOT APPLE )

  set_target_properties (
    ${PROJECT_NAME}_target
    PROPERTIES OUTPUT_NAME $<LOWER_CASE:${PROJECT_NAME}>
  )
else ()
  set_target_properties (
    ${PROJECT_NAME}_target
    PROPERTIES OUTPUT_NAME ${PROJECT_NAME}
  )
endif ()

target_compile_options (
  ${PROJECT_NAME}_target
  PRIVATE ${WARNING_OPTIONS}
)


# Add translations
target_add_qt_translations (
  ${PROJECT_NAME}_target
  TS_FILES ${TEXWORKS_TRANS_TS}
  QM_FILES ${QT_TRANS_QM}
  INCLUDEPATH "../src/"
)

get_target_property (
  _lupdatePath
  ${QtMAJOR}::lupdate LOCATION
)
get_target_property (
  _sources
  ${PROJECT_NAME}_target
  SOURCES
)
add_custom_target (
  ${PROJECT_NAME}_UpdateTranslations
  COMMAND "${CMAKE_COMMAND}"
  "-DOUTPUTFILE=\"${TWX_DIR_trans}/${PROJECT_NAME}_trans.pro\""
  "-DPROJECT_NAME=\"${PROJECT_NAME}\""
  "-DQt_LUPDATE_EXECUTABLE=\"${_lupdatePath}\""
  "-DFILES=\"${_sources};${TEXWORKS_UIS};${TEXWORKS_TRANS_TS}\""
  "-DINCLUDEPATH=\"${TWX_DIR_src}\""
  -P "${TWX_DIR_modules}/QtPDF/CMake/Modules/UpdateTranslations.cmake"
  WORKING_DIRECTORY "${TWX_DIR_src}")

if ( NOT TARGET UpdateTranslations )
  add_custom_target (
    UpdateTranslations
  )
endif ()
add_dependencies (
  UpdateTranslations
  ${PROJECT_NAME}_UpdateTranslations
)

if ( UNIX )
  # Required ( at least ) on OpenBSD to make scripting plugins work
  set_target_properties (
    ${PROJECT_NAME}_target
    PROPERTIES LINK_FLAGS -rdynamic )
endif ()

# Specify libraries to be linked to TeXworks.
target_link_libraries (
  ${PROJECT_NAME}_target
  QtPDF::qtpdf
  ${${PROJECT_NAME}_LIBRARIES}
)

# Disallow automatic casts from char* to QString ( enforcing the use of tr ( ) or
# explicitly specifying the string encoding)
twx_target_Qt_guards (
  ${PROJECT_NAME}_target
)

target_compile_definitions (
  ${PROJECT_NAME}_target
  PRIVATE TW_BUILD_ID="${TW_BUILD_ID}"
)

function ( target_add_path_define target name path )
  if ( IS_ABSOLUTE ${path} )
    target_compile_definitions (
      ${target}
      PRIVATE ${name}="${path}"
    )
  else ()
    target_compile_definitions (
      ${target}
      PRIVATE ${name}="${CMAKE_INSTALL_PREFIX}/${path}"
    )
  endif ()
endfunction ()

if ( UNIX AND NOT APPLE )
  target_add_path_define (
    ${PROJECT_NAME}_target
    "TW_HELPPATH" "${TeXworks_HELP_DIR}"
  )
  target_add_path_define (
    ${PROJECT_NAME}_target
    "TW_PLUGINPATH" "${TeXworks_PLUGIN_DIR}"
  )
  target_add_path_define (
    ${PROJECT_NAME}_target
    "TW_DICPATH" "${TeXworks_DIC_DIR}"
  )
endif ()

# TODO: move to TwxResSetuptPLIST.cmake
if ( APPLE )
# For OS X, generate `Info.plist` and add it to the `.app` bundle.
  set (
    TWX_out_l
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.plist
  )
  if ( NOT EXISTS "${TWX_out_l}" )
    set (
      TWX_in_l
      ${TWX_DIR_res}/TeXworks.in.plist
    )
    twx_configure_file_set (
      DOC_ICNS ${PROJECT_NAME}-doc.icns
      APP_ICNS ${PROJECT_NAME}.icns
      NAME     ${PROJECT_NAME}
      VERSION  ${PROJECT_NAME}_VERSION
      REVISION ${TWX_GIT_HASH}
    )
    configure_file ( ${TWX_in_l} ${TWX_out_l} @ONLY )
    unset ( __TWX_PROJECT_NAME__ )
    unset ( __TWX_VERSION__ )
    unset ( __TWX_REVISION__ )
    set_target_properties (
      ${PROJECT_NAME}_target
      PROPERTIES MACOSX_BUNDLE_INFO_PLIST ${TWX_out_l}
    )
    twx_configure_file_unset (
      APP_ICO
      DOC_ICO
      NAME
      VERSION
      REVISION
    )
    unset ( TWX_in_l )
  endif ()
  unset ( TWX_out_l )
endif ()

if ( UNIX )
  set_target_properties (
    ${PROJECT_NAME}_target
    PROPERTIES COMPILE_FLAGS -fPIC
  )
endif ()

# Installation
# ------------
if ( WIN32 )
  # On Windows, put everything into the root install directory
  install (
    TARGETS ${PROJECT_NAME}_target
    RUNTIME DESTINATION . COMPONENT
  )
else ()
  install (
    TARGETS ${PROJECT_NAME}_target
    RUNTIME DESTINATION bin COMPONENT
    BUNDLE DESTINATION . COMPONENT
  )
endif ()

if ( UNIX AND NOT APPLE )
  set (
    TWX_prefix_l
    "${CMAKE_INSTALL_PREFIX}/${TeXworks_ICON_DIR}"
  )
  install (
    FILES "${TWX_DIR_res}/images/TeXworks.png"
    DESTINATION "${TWX_prefix_l}/512x512/apps"
    RENAME ${PROJECT_NAME}.png
  )
  foreach ( _res 48 64 128 )
    install (
      FILES "${TWX_DIR_res}/images/TeXworks-${_res}.png"
      DESTINATION "${TWX_prefix_l}/${_res}x${_res}/apps"
      RENAME ${PROJECT_NAME}.png
    )
  endforeach ()
  # install ( FILES ${TWX_DIR_res}/images/TeXworks-128.png DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_ICON_DIR}/128x128/apps RENAME ${PROJECT_NAME}.png )
  # install ( FILES ${TWX_DIR_res}/images/TeXworks-64.png DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_ICON_DIR}/64x64/apps RENAME ${PROJECT_NAME}.png )
  # install ( FILES ${TWX_DIR_res}/images/TeXworks-48.png DESTINATION ${CMAKE_INSTALL_PREFIX}/${TeXworks_ICON_DIR}/48x48/apps RENAME ${PROJECT_NAME}.png )
  install (
    FILES
      "${TWX_DIR_ROOT}/COPYING"
      "${TWX_DIR_ROOT}/README.md"
      "${TWX_DIR_ROOT}/NEWS"
    DESTINATION
      "${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_DOCS_DIR}"
  )
  install (
    FILES "${TWX_DIR_res}/texworks.1"
    DESTINATION
      "${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_MAN_DIR}"
  )
  install (
    FILES "${TWX_DIR_res}/texworks.desktop"
    DESTINATION
    "${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_DESKTOP_DIR}"
  )
  install (
    FILES "${TWX_DIR_res}/texworks.appdata.xml"
    DESTINATION
      "${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_APPDATA_DIR}"
  )
endif ( UNIX AND NOT APPLE )

# On OS X, ensure there is always a `qt.conf` file as all hell will break loose
# if one isn't there.  This may need to be customized for use on non-Apple
# systems.
#
# Protip: If there are wierd errors like "Qt libraries loaded twice" or
# "looking for a tablet device", then something may have gone pear shaped with
# `qt.conf`.
if ( APPLE )
  set (
    _qtconf_dir
    ${PROJECT_NAME}.app/Contents/Resources
  )
  set (
    _qtconf_contents "[Paths]\nPlugins = PlugIns"
  )

  install ( CODE "
    file (
      WRITE
      \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${_qtconf_dir}/qt.conf\"
      \"${_qtconf_contents}\"
    )
  ")
endif ()
