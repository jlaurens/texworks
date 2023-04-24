#[===============================================[
This is part of TeXworks,
an environment for working with TeX documents.
Copyright (C) 2023  Jérôme Laurens & co

License: GNU General Public License as published by
the Free Software Foundation; either version 2 of
the License, or ( at your option ) any later version.
See a copy next to this file or 
<http://www.gnu.org/licenses/>.

#]===============================================]

if ( NOT TWX_IS_BASED )
  message( FATAL_ERROR "Base not loaded" )
endif ()

if ( TwxGit_SOURCES )
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

if ( TWX_CONFIG_VERBOSE )
  set ( TWX_l ON )
else ()
  set ( TWX_l OFF )
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
  GitRev_target ALL
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
file (
  STRINGS "${TWX_HEADER_OUT_l}"
  TWX_l
  REGEX "HASH"
)
if ( "${TWX_l}" STREQUAL "" )
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing \"HASH\""
  )
endif ()
if ( "${TWX_l}" MATCHES "\"(.+)\"" )
  set( TWX_GIT_HASH "${CMAKE_MATCH_1}" )
else ()
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing hash value"
  )
endif ()
# DATE
file (
  STRINGS "${TWX_HEADER_OUT_l}"
  TWX_l
  REGEX "DATE"
)
if ( "${TWX_l}" STREQUAL "" )
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing \"DATE\""
  )
endif ()
if ( "${TWX_l}" MATCHES "\"(.+)\"" )
  set( TWX_GIT_DATE "${CMAKE_MATCH_1}" )
else ()
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing date value"
  s)
endif ()
# BRANCH
file (
  STRINGS "${TWX_HEADER_OUT_l}"
  TWX_l
  REGEX "BRANCH"
)
if ( "${TWX_l}" STREQUAL "" )
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing \"BRANCH\""
  )
endif ()
if ( "${TWX_l}" MATCHES "\"(.+)\"" )
  set( TWX_GIT_BRANCH "${CMAKE_MATCH_1}" )
else ()
  message(
    FATAL_ERROR
    "Bad ${TWX_HEADER_OUT_l}: missing branch name"
  )
endif ()

# message( "TWX_GIT_HASH => ${TWX_GIT_HASH}" )
# message( "TWX_GIT_DATE => ${TWX_GIT_DATE}" )
# message( "TWX_GIT_BRANCH => ${TWX_GIT_BRANCH}" )

set (
  TwxGit_SOURCES
  "${TWX_SOURCE_OUT_l}"
)
set (
  TwxGit_HEADERS
  "${TWX_DIR_src}/Git/TwxGitRev.h"
  "${TWX_HEADER_OUT_l}"
)
set (
  TwxGit_GENERATED_HEADERS
  "${TWX_HEADER_OUT_l}"
)

unset ( TWX_l )
unset ( TWX_HEADER_IN_l )
unset ( TWX_HEADER_OUT_l )
unset ( TWX_SOURCE_IN_l )
unset ( TWX_SOURCE_OUT_l )
