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

if (Twx_Git_SOURCES)
  return ()
endif ()

#[=======[
Compared to the original version we have much more
than cosmetic changes.
We use `twx_configure_file`.
#]=======]
set (
  TWX_HEADER_IN_l
  "${TWX_DIR_src}/Git/GitRev.in.h"
)
set (
  TWX_HEADER_OUT_l
  "${CMAKE_CURRENT_BINARY_DIR}/src/GitRev.h"
)
set (
  TWX_SOURCE_IN_l
  "${TWX_DIR_src}/Git/TwxGitRev.in.cpp"
)
set (
  TWX_SOURCE_OUT_l
  "${CMAKE_CURRENT_BINARY_DIR}/src/Git/TwxGitRev.cpp"
)

if (TWX_CONFIG_VERBOSE)
  set (TWX_l ON)
else ()
  set (TWX_l OFF)
endif ()

# Make sure we have up-to-date git commit infos
execute_process (
  COMMAND "${CMAKE_COMMAND}"
  "-DHEADER_IN=${TWX_HEADER_IN_l}"
  "-DHEADER_OUT=${TWX_HEADER_OUT_l}"
  "-DSOURCE_IN=${TWX_SOURCE_IN_l}"
  "-DSOURCE_OUT=${TWX_SOURCE_OUT_l}"
  "-DVERBOSE=${TWX_l}"
  -P "${CMAKE_CURRENT_LIST_DIR}/Tool.cmake"
  WORKING_DIRECTORY "${TWX_DIR_ROOT}"
)

add_custom_target (
  GitRev ALL
  "${CMAKE_COMMAND}"
  "-DHEADER_IN=${TWX_HEADER_IN_l}"
  "-DHEADER_OUT=${TWX_HEADER_OUT_l}"
  "-DSOURCE_IN=${TWX_SOURCE_IN_l}"
  "-DSOURCE_OUT=${TWX_SOURCE_OUT_l}"
  "-DVERBOSE=${TWX_l}"
  -P "${CMAKE_CURRENT_LIST_DIR}/Tool.cmake"
  WORKING_DIRECTORY "${TWX_DIR_ROOT}"
  COMMENT "Update git commit info"
)

# There will be a target dependency afterwards.

# Recover git commit info from `src/GitRev.h`.
# Use same ideas for TeXWorks VERSION
# HASH
file (STRINGS "${TWX_HEADER_OUT_l}" TWX_l REGEX ".*GIT_COMMIT_HASH.*")
if ("${TWX_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing GIT_COMMIT_HASH ${TWX_l}")
endif ()
if ("${TWX_l}" MATCHES ".*\"(.*)\".*")
  set(TeXworks_GIT_HASH "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing hash")
endif ()
# DATE
file (STRINGS "${TWX_HEADER_OUT_l}" TWX_l REGEX ".*GIT_COMMIT_DATE.*")
if ("${TWX_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing GIT_COMMIT_DATE")
endif ()
if ("${TWX_l}" MATCHES ".*\"(.*)\".*")
  set(TeXworks_GIT_DATE "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing date")
endif ()
# BRANCH
file (STRINGS "${TWX_HEADER_OUT_l}" TWX_l REGEX ".*GIT_COMMIT_BRANCH.*")
if ("${TWX_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing GIT_COMMIT_BRANCH")
endif ()
if ("${TWX_l}" MATCHES ".*\"(.*)\".*")
  set(TeXworks_GIT_BRANCH "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${TWX_HEADER_OUT_l}: missing branch name")
endif ()

# message("TeXworks_GIT_HASH => ${TeXworks_GIT_HASH}")
# message("TeXworks_GIT_DATE => ${TeXworks_GIT_DATE}")
# message("TeXworks_GIT_BRANCH => ${TeXworks_GIT_BRANCH}")

set (
  Twx_Git_SOURCES
  "${TWX_SOURCE_OUT_l}"
)
set (
  Twx_Git_HEADERS
  "${TWX_DIR_src}/Git/TwxGitRev.h"
  "${TWX_HEADER_OUT_l}"
)
set (
  Twx_Git_GENERATER_HEADERS
  "${TWX_HEADER_OUT_l}"
)

unset (TWX_l)
unset (TWX_HEADER_IN_l)
unset (TWX_HEADER_OUT_l)
unset (TWX_SOURCE_IN_l)
unset (TWX_SOURCE_OUT_l)
