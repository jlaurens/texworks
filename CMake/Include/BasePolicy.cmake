
# CMake 3.1 significantly improves support for imported targets, Qt5, c++11, etc.
cmake_policy(VERSION 3.1)

# Silence warning about linking to qtmain.lib statically on Windows
IF(POLICY CMP0020)
  cmake_policy(SET CMP0020 NEW)
ENDIF()

# Silence warning about using @rpath on OS X.
if(POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif()

# Only interpret if() arguments as variables or keywords when unquoted.
if(POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif()

# Silence warning about ninja custom command byproducts
if(POLICY CMP0058)
  cmake_policy(SET CMP0058 NEW)
endif()

# Prefer newer OpenGL libraries over legacy ones
if (POLICY CMP0072)
  cmake_policy(SET CMP0072 NEW)
endif ()

# Silence warning about option() treating variables differently on the first run
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

#[===[Nota bene
Use
````
cmake_policy(PUSH)
cmake_policy(POP)
````
to apply policies locally.
]===]
