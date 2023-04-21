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

if (Twx_Version_SOURCES)
  return ()
endif ()

include (WithQt)
twx_append_QT (
	REQUIRED Test Core
)

#[=======[
## Global setting
`TWX_VERSION_HEADER` contains the path of the header file to parse
for version information. This path is relative to the root `src` directory.
Default value: `TWVersion.h`.
# TODO: `TWVersion.h` => `TWXVersion.h`.

## Global constants defined here:

* `TWX_VERSION_MAJOR`: nonnegative integer <a>
* `TWX_VERSION_MINOR`: nonnegative integer <b>
* `TWX_VERSION_PATCH`: nonnegative integer <c>
* `TWX_VERSION_TWEAK`: nonnegative integer <d> or ""
* `TWX_VERSION`: <a>.<b>.<c>
* `TWX_VERSION_SHORT`: <a>.<b>
* `TWX_VERSION_LONG`: <a>.<b>.<c>[.<d>], the last part only
  when <d> is not a void string.

Other sets of variable are synonyms:
`PROJECT_VERSION_...`, `<TWX_NAME_MAIN>_VERSION_...`, `<TWX_NAME_MAIN>_VER_...`.
The latter should not be used.

#]=======]

if (TWX_VERSION_HEADER)
  set (TWXVersion.h "${TWX_VERSION_HEADER}")
else ()
  set (TWXVersion.h "TWVersion.h")
endif ()

set (TWX_H "${TWX_DIR_src}/${TWXVersion.h}")

# TODO: Change `BUGFIX` to more conventional `PATCH`.
foreach (TWX_l "MAJOR" "MINOR" "BUGFIX")
  file (STRINGS "${TWX_H}" TWX_lines_l REGEX "${TWX_l}")
  if (TWX_lines_l MATCHES "[0-9]+")
    set (TWX_VERSION_${TWX_l} "${CMAKE_MATCH_0}")
  elseif (NOT "${TWX_lines_l}" STREQUAL "")
    message (FATAL "Bad `${TWX_H}` contents.")
  else ()
    set (TWX_VERSION_${TWX_l} "")
  endif ()
endforeach ()

unset (TWX_H)
unset (TWX_lines_l)

set (TWX_VERSION_PATCH "${TWX_VERSION_BUGFIX}")
unset (TWX_VERSION_BUGFIX)

set (TWX_VERSION_ALL "${TWX_VERSION_MAJOR}")
set (TWX_VERSION_FULL "${TWX_VERSION_ALL}")
if (NOT "${TWX_VERSION_MINOR}" STREQUAL "")
  set (TWX_VERSION_ALL "${TWX_VERSION_ALL}.${TWX_VERSION_MINOR}")
  set (TWX_VERSION_FULL "${TWX_VERSION_ALL}")
  if (NOT "${TWX_VERSION_PATCH}" STREQUAL "")
    set (TWX_VERSION_ALL "${TWX_VERSION_ALL}.${TWX_VERSION_PATCH}")
    set (TWX_VERSION_FULL "${TWX_VERSION_ALL}")
    if (NOT "${TWX_VERSION_TWEAK}" STREQUAL "")
      set (TWX_VERSION_FULL "${TWX_VERSION_LONG}.${TWX_VERSION_TWEAK}")
    endif ()
  endif ()
endif ()

# Mimic the official `project` command
foreach (TWX_l "MAJOR" "MINOR" "PATCH" "TWEAK")
  set(PROJECT_VERSION_${TWX_l} "${TWX_VERSION_${TWX_l}}")
  set(${TWX_NAME_MAIN}_VERSION_${TWX_l} "${TWX_VERSION_${TWX_l}}")
  # TODO: change the "_VER_" to the more conventional and readable "_VERSION_"
  set(${TWX_NAME_MAIN}_VER_${TWX_l} "${TWX_VERSION_${TWX_l}}")
endforeach ()

set(TeXworks_VERSION "${TWX_VERSION_ALL}")

set (
  TWX_IN_l
  "${TWX_DIR_src}/Version/TwxVersion.in.cpp"
)
set (
  TWX_OUT_l
  "${CMAKE_CURRENT_BINARY_DIR}/src/Version/TwxVersion.cpp"
)
twx_configure_file(
  "${TWX_IN_l}"
  "${TWX_OUT_l}"
  TWX_l
)
# TODO: Remove `TWVersion.h`?
# Copy the header
set (
  Twx_Version_SOURCES
  "${TWX_OUT_l}"
)

set (
  Twx_Version_SOURCES_HEADERS
  "${TWX_DIR_src}/Version/TwxVersion.h"
  "${TWX_DIR_src}/TWVersion.h"
)

unset (TWX_l)
unset (TWX_IN_l)
unset (TWX_OUT_l)

