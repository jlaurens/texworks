if (DEFINED TWX_GUARD_CMake_Include_BaseConfig)
  return ()
endif()
set(TWX_GUARD_CMake_Include_BaseConfig)

SET(CMAKE_COLOR_MAKEFILE ON)

# Always add the current source and binary directories to the header include
# path when compiling.
SET(CMAKE_INCLUDE_CURRENT_DIR ON)
SET(CMAKE_AUTOMOC TRUE)
SET(CMAKE_AUTORCC TRUE)
SET(CMAKE_AUTOUIC TRUE)

IF(WIN32 AND MINGW)
  # Ensure that no cpp flags are passed to windres, the Windows resource compiler.
  # At least with MinGW 4 on Windows, that would cause problems
  SET(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> -O coff <DEFINES> <SOURCE> <OBJECT>")
ENDIF()

if (MSVC)
	add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
	add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
endif ()

set (CMAKE_CXX_STANDARD 11)
