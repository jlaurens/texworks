# Usage: `include(TwxGitRev)`
# This can be done very early

#[=======[
Compared to the original version we have cosmetic changes but
more importantly we no longer rely on `PROJECT_SOURCE_DIR`
assuming that the core preamble is loaded.
We also move the "GitRev.h" definition to the caller
and finally, use a variable for that header.
Instead we use `TWX_DIR_ROOT` which always point to the correct location.
#]=======]
set (GitRev.h "GitRev.h")
set (TWX_HEADER_l "${CMAKE_CURRENT_BINARY_DIR}/src/${GitRev.h}")

# Make sure we have up-to-date git commit infos

execute_process (
  COMMAND "${CMAKE_COMMAND}"
  "-DHEADER=${TWX_HEADER_l}"
  -P "${TWX_DIR_CMake}/Include/TwxGitRevTool.cmake"
  WORKING_DIRECTORY "${TWX_DIR_ROOT}"
)

add_custom_target (
  GitRev ALL
  "${CMAKE_COMMAND}"
  "-DHEADER=${TWX_HEADER_l}"
  -P "${TWX_DIR_CMake}/Include/TwxGitRevTool.cmake"
  WORKING_DIRECTORY "${TWX_DIR_ROOT}"
  COMMENT "Update git commit info"
)

# There will be a target dependency afterwards.

# Recover git commit info from `src/GitRev.h`.
# Use same ideas for TeXWorks VERSION
# HASH
file (STRINGS "${TWX_HEADER_l}" TWX_line_l REGEX ".*HASH.*")
if ("${TWX_line_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${GitRev.h}: missing GIT_COMMIT_HASH ${TWX_line_l}")
endif ()
if ("${TWX_line_l}" MATCHES "\"([a-f0-9]+\\*?)\"")
  set(TeXworks_GIT_HASH "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${GitRev.h}: missing hash")
endif ()
# DATE
file (STRINGS "${TWX_HEADER_l}" TWX_line_l REGEX ".*DATE.*")
if ("${TWX_line_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${GitRev.h}: missing GIT_COMMIT_DATE")
endif ()
if ("${TWX_line_l}" MATCHES "\"([-+:0-9TZ]+)\"")
  set(TeXworks_GIT_DATE "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${GitRev.h}: missing date")
endif ()
# BRANCH
file (STRINGS "${TWX_HEADER_l}" TWX_line_l REGEX ".*BRANCH.*")
if ("${TWX_line_l}" STREQUAL "")
  message(FATAL_ERROR "Bad ${GitRev.h}: missing GIT_COMMIT_BRANCH")
endif ()
if ("${TWX_line_l}" MATCHES "\"(.+)\"")
  set(TeXworks_GIT_BRANCH "${CMAKE_MATCH_1}")
else ()
  message(FATAL_ERROR "Bad ${GitRev.h}: missing branch name")
endif ()

unset (TWX_line_l)
unset (TWX_HEADER_l)
unset (GitRev.h)

# message("TeXworks_GIT_HASH => ${TeXworks_GIT_HASH}")
# message("TeXworks_GIT_DATE => ${TeXworks_GIT_DATE}")
# message("TeXworks_GIT_BRANCH => ${TeXworks_GIT_BRANCH}")
