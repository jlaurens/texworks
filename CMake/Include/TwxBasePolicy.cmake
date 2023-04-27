#[===============================================[
This is part of the TeXworks build system.
See https://github.com/TeXworks/texworks
( C ) JL 2023

Automatically loaded by the `Base` module.

Defines basic variables to be used by various scripts.

#]===============================================]

if ( NOT TWX_IS_BASED )
  message( FATAL_ERROR "Base not loaded" )
endif ()

# NB: This file MUST be included with NO_POLICY_COPE
# Otherwise all the changes below won't live after the end

# CMake 3.1 significantly improves support for imported targets, Qt5, c++11, etc.
cmake_policy ( VERSION 3.1 )

# Silence warning about linking to qtmain.lib statically on Windows
if ( POLICY CMP0020 )
  cmake_policy ( SET CMP0020 NEW )
endif ()

# Silence warning about using @rpath on OS X.
if ( POLICY CMP0042 )
  cmake_policy ( SET CMP0042 NEW )
endif ()

# Only interpret if () arguments as variables or keywords when unquoted.
if ( POLICY CMP0054 )
  cmake_policy ( SET CMP0054 NEW )
endif ()

# Silence warning about ninja custom command byproducts
if ( POLICY CMP0058 )
  cmake_policy ( SET CMP0058 NEW )
endif ()

# Prefer newer OpenGL libraries over legacy ones
if ( POLICY CMP0072 )
  cmake_policy ( SET CMP0072 NEW )
endif ()

# Silence warning about option() treating variables differently on the first run
if ( POLICY CMP0077 )
  cmake_policy ( SET CMP0077 NEW )
endif ()

# CMake 3.24 and above prefers to set the timestamps of all extracted contents to the time of the extraction.
if ( POLICY CMP0135 )
  cmake_policy ( SET CMP0135 NEW )
endif ()

#[=======[ Nota bene
Use
````
cmake_policy ( PUSH )
cmake_policy ( POP )
````
to apply policies locally.
]=======]
