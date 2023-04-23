#[=================[
# Build Lua plugin

Create and sets up the `TwxLuaPlugin` library target.

Relies on global variables

* `TWX_BUILD_SHARED_PLUGINS`
* `LUA_PLUGIN_MOC`
* `TWX_WARNING_OPTIONS`
* `QT_LIBRARIES`
* `LUA_LIBRARIES`
* `TWX_ADDITIONAL_LIBRARIES`
* `TWX_PLUGIN_DIR`

Use local variables:

* `TwxLuaPlugin_TYPE`
* `TWX_SCRIPT_SOURCES`

#]=================]

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "This is not a primary `CMakeLists.txt`" )
endif ()

if ( NOT TWX_WITH_LUA )
  return ()
endif ()

if ( NOT LUA_FOUND )
  message ( FATAL_ERROR "Missing Lua: unset TWX_WITH_LUA" )
endif ()

if ( TWX_BUILD_SHARED_PLUGINS )
  set (
    TwxLuaPlugin_TYPE
    MODULE
  )
else ()
  set (
    TwxLuaPlugin_TYPE
    STATIC
  )
endif ( )

if ( TWX_BUILD_SHARED_PLUGINS )
  # For shared builds, we pull in scripting/Script.cpp so all references can be resolved
  # This seems to be needed particularly when building dlls with MinGW on
  # Windows (as is done in the Appveyor CI build) as the dll linking stage
  # requires all symbols to be resolved
  # NB: This can lead to spurious "one definition rule ( odr ) violation" messages
  # with some sanitizers
  # TODO: Figure out of setting ENABLE_EXPORTS=TRUE on the TeXworks target and
  # subsequent linking to the TeXworks target can help "resolve" symbols by
  # telling the linker they can be found in the host program loading the dll
  set (
    TWX_SCRIPT_SOURCES
    "${TWX_DIR_src}/scripting/Script.cpp"
  )
else ( )
  # For static builds, scripting/Script.cpp is already included in the main app, so we
  # don't pull it in here to avoid multiple definitions of the Qt metaobject
  set ( TWX_SCRIPT_SOURCES )
endif ( )

add_library (
  TwxLuaPlugin
  ${TwxLuaPlugin_TYPE}
  LuaScriptInterface.cpp
  LuaScript.cpp
  ${TWX_SCRIPT_SOURCES}
  ${LUA_PLUGIN_MOC}
)
target_compile_options (
  TwxLuaPlugin
  PRIVATE ${TWX_WARNING_OPTIONS}
)
# Disallow automatic casts from char* to QString ( enforcing the use of tr ( ) or
# explicitly specifying the string encoding )
target_compile_definitions (
  TwxLuaPlugin
  PRIVATE
    -DQT_NO_CAST_FROM_ASCII
    -DQT_NO_CAST_TO_ASCII
    -DQT_NO_CAST_FROM_BYTEARRAY
)

target_include_directories (
  TwxLuaPlugin
  SYSTEM
  PRIVATE ${LUA_INCLUDE_DIR}
)
target_include_directories (
  TwxLuaPlugin
  PRIVATE ${TWX_DIR_src}
)

# Specify link libraries even if the plugin is built statically so all the
# interface properties of the Qt targets ( include directories, lib directories,
# etc. ) are available
target_link_libraries (
  TwxLuaPlugin
  ${QT_LIBRARIES}
  ${LUA_LIBRARIES}
  ${TWX_ADDITIONAL_LIBRARIES}
)
if ( TWX_BUILD_SHARED_PLUGINS )
  install (
    TARGETS TwxLuaPlugin
    LIBRARY DESTINATION ${TWX_PLUGIN_DIR}
  )
endif ( )
