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

#[=======[
Basic configuration extracted from
the `CMakeLists.txt` version `0.7.0`.
#]=======]
if (TWX_GUARD_CMake_Include_BaseConfig)
  return ()
endif ()
set (TWX_GUARD_CMake_Include_BaseConfig ON)

set (CMAKE_COLOR_MAKEFILE ON)

#[=======[
 Always add the current source and binary directories
to the header include path when compiling.
CMAKE_CURRENT_SOURCE_DIR and CMAKE_CURRENT_BINARY_DIR
are added to the include path for each directory.
For the top `/CMakeLists.txt` it is `/`
but for `/unit-tests/CMakeLists.txt` it is `/unit-tests`.
#]=======]
set (CMAKE_INCLUDE_CURRENT_DIR ON)

# To let Qt targets handle moc automatically:
set (CMAKE_AUTOMOC TRUE)
# To let Qt targets handle rcc automatically:
set (CMAKE_AUTORCC TRUE)
# To let Qt targets handle uic automatically:
set (CMAKE_AUTOUIC TRUE)

if (WIN32 AND MINGW)
  # Ensure that no cpp flags are passed to windres,
  # the Windows resource compiler.
  # At least with MinGW 4 on Windows,
  # that would cause problems
  set (
    CMAKE_RC_COMPILE_OBJECT
    "<CMAKE_RC_COMPILER> -O coff <DEFINES> <SOURCE> <OBJECT>"
  )
endif ()

if (MSVC)
	add_compile_options("$<$<C_COMPILER_ID:MSVC>:/utf-8>")
	add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/utf-8>")
endif ()

set (CMAKE_CXX_STANDARD 11)
