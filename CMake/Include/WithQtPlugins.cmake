#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

if (NOT TWX_IS_BASED)
  message(FATAL_ERROR "Base not loaded")
endif ()

if (DEFINED _GUARD_CMake_Include_WithQTPlugins)
  return ()
endif()
set(_GUARD_CMake_Include_WithQTPlugins)

#[=======[
# Qt Plugins management utilities

## Global variables

* `QT_PLUGINS`:
This is not a `Qt` macro.

## Utilities

* `twx_setup_PLUGINS`

#]=======]

if (APPLE)

function (twx_setup_QT_PLUGINS)
  # Inspired by https://github.com/MaximAlien/macdeployqt/blob/bc9c0ba199f323a42e3f1cc04d4b66e3e59ac995/macdeployqt/shared.cpp
  if (QT_PLUGIN_PATH)
    set(_pluginDir "${QT_PLUGIN_PATH}")
  else () 
    # get_target_property(_pluginDir ${QtMAJOR}::Widgets LOCATION)
    # get_filename_component(_pluginDir "${_pluginDir}" REALPATH)
    # get_filename_component(_pluginDir "${_pluginDir}" DIRECTORY)
    # set(_pluginDir "${_pluginDir}/../../../../share/qt/plugins")
    # get_filename_component(_pluginDir "${_pluginDir}" REALPATH)
    get_target_property (
      _pluginDir ${QtMAJOR}::Widgets LOCATION
    )
    get_filename_component (
      _pluginDir
      "${_pluginDir}/../../../../../share/qt/plugins"
      REALPATH
    )
  endif ()

  set (QT_PLUGINS)
  foreach (_lib IN ITEMS platforms/qcocoa styles/qmacstyle)
    get_filename_component(_lib_name ${_lib} NAME)
    get_filename_component(_lib_dir  ${_lib} DIRECTORY)
    find_library(
      _plugin_${_lib_name}
      NAMES ${_lib_name}
      HINTS ${_pluginDir}
      PATH_SUFFIXES ${_lib_dir}
    )
    if (NOT _plugin_${_lib_name})
      message(FATAL_ERROR "Could not find plugin ${_lib} in ${_pluginDir}")
    else ()
      list(APPEND QT_PLUGINS "${_plugin_${_lib_name}}")
    endif ()
  endforeach ()
  set (QT_PLUGINS ${QT_PLUGINS} PARENT_SCOPE)
  message(STATUS "QT_PLUGINS = ${QT_PLUGINS}")
endfunction ()

else ()

function (twx_setup_QT_PLUGINS)
endfunction ()

endif ()
