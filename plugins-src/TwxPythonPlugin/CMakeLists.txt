#[===================[
# Build Python Plugin

Create and sets up the `TwxPythonPlugin` library target.

Relies on global variables

* `TWX_WITH_PYTHON`
* `TWX_BUILD_SHARED_PLUGINS`
* `PYTHON_PLUGIN_MOC`
* `TWX_WARNING_OPTIONS`
* `PYTHON_INCLUDE_DIRS`
* `QT_LIBRARIES`
* `PYTHON_LIBRARIES`
* `TWX_ADDITIONAL_LIBRARIES`
* `TWX_PLUGIN_DIR`

Use local variables:

* `TwxPythonPlugin_TYPE`
* `TWX_SCRIPT_SOURCES`

#]===================]

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "This is not a primary `CMakeLists.txt`" )
endif ()

if ( NOT TWX_WITH_PYTHON )
  return ()
endif ()

if ( NOT PythonLibs_FOUND )
  message ( FATAL_ERROR "Missing Python: unset TWX_WITH_PYTHON" )
endif ()

if ( TWX_BUILD_SHARED_PLUGINS )
  set (
    TwxPythonPlugin_TYPE
    MODULE
  )
else ()
  set (
    TwxPythonPlugin_TYPE
    STATIC
  )
endif ()

if ( TWX_BUILD_SHARED_PLUGINS )
  # For shared builds, we pull in scripting/Script.cpp so all references can be
  # resolved
  # This seems to be needed particularly when building dlls with MinGW on
  # Windows ( as is done in the Appveyor CI build ) as the dll linking stage
  # requires all symbols to be resolved
  # NB: This can lead to spurious "one definition rule ( odr ) violation" messages
  # with some sanitizers
  # TODO: Figure out of setting ENABLE_EXPORTS=TRUE on the TeXworks target and
  # subsequent linking to the TeXworks target can help "resolve" symbols by
  # telling the linker they can be found in the host program loading the dll
  set ( TWX_SCRIPT_SOURCES "../../src/scripting/Script.cpp" )
else ()
  # For static builds, scripting/Script.cpp is already included in the main app, so we
  # don't pull it in here to avoid multiple definitions of the Qt metaobject
  set ( TWX_SCRIPT_SOURCES "" )
endif ()

add_library (
  TwxPythonPlugin
  ${TwxPythonPlugin_TYPE}
  PythonScriptInterface.cpp
  PythonScript.cpp
  ${TWX_SCRIPT_SOURCES}
  ${PYTHON_PLUGIN_MOC}
)
target_compile_options (
  TwxPythonPlugin
  PRIVATE ${TWX_WARNING_OPTIONS}
)
if ( NOT MSVC )
	# Don't warn about old-style casts as the Python headers are littered with
	# macros ( which are handled as if copied into our code ) using those
	target_compile_options (
    TwxPythonPlugin
    PRIVATE -Wno-old-style-cast
  )
endif ()

target_include_directories (
  TwxPythonPlugin
  SYSTEM
  PRIVATE ${PYTHON_INCLUDE_DIRS}
)
target_include_directories (
  TwxPythonPlugin
  PRIVATE ${TWX_DIR_src}
)

# Specify link libraries even if the plugin is built statically so all the
# interface properties of the Qt targets ( include directories, lib directories,
# etc. ) are available
target_link_libraries (
  TwxPythonPlugin
  ${QT_LIBRARIES}
  ${PYTHON_LIBRARIES}
  ${TWX_ADDITIONAL_LIBRARIES}
)
if ( ${TWX_BUILD_SHARED_PLUGINS} )
  install (
    TARGETS TwxPythonPlugin
    LIBRARY DESTINATION ${TWX_PLUGIN_DIR}
  )
endif ()
