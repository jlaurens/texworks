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

#[=======[
Standalone helper to launch `git` and retrieve information.
Launched by `TwxSetupGitRev.cmake`

Input:

* `VERBOSE`: ON or OFF
* `HEADER_IN`
* `HEADER_OUT`, the former configured
* `SOURCE_IN`
* `SOURCE_OUT`, the former configured

Configuration variables, @ONLY

* `TWX_GIT_COMMIT_HASH`
* `TWX_GIT_COMMIT_DATE`
* `TWX_GIT_COMMIT_BRANCH`

used to configure a header and a source file.

#]=======]

cmake_minimum_required(VERSION 3.1)

include (
	"${CMAKE_CURRENT_LIST_DIR}/../../Cmake/Include/Base.cmake"
	NO_POLICY_SCOPE
)

if (NOT HEADER_IN)
	message(FATAL_ERROR "HEADER_IN not set")
endif ()
if (NOT HEADER_OUT)
	message(FATAL_ERROR "HEADER_OUT not set")
endif ()
if (NOT SOURCE_IN)
	message(FATAL_ERROR "SOURCE_IN not set")
endif ()
if (NOT SOURCE_OUT)
	message(FATAL_ERROR "SOURCE_OUT not set")
endif ()

if (VERBOSE)
	message(STATUS "Git Tool: HEADER_IN  => ${HEADER_IN}")
	message(STATUS "Git Tool: HEADER_OUT => ${HEADER_OUT}")
	message(STATUS "Git Tool: SOURCE_IN  => ${SOURCE_IN}")
	message(STATUS "Git Tool: SOURCE_OUT => ${SOURCE_OUT}")
endif ()

set(OLD_GIT_COMMIT_HASH "")
set(OLD_GIT_COMMIT_DATE "")

set(TWX_GIT_COMMIT_BRANCH "<Unknown>")

set(_success FALSE)

# Recover old git commit info from the header if available.
# We don't want to touch the file if nothing relevant has changed as that would
# trigger an unnecessary rebuild of parts of the project
if (EXISTS "${HEADER_OUT}")
	file(
		STRINGS "${HEADER_OUT}" TWX_l
		REGEX "HASH"
	)
	if ("${TWX_l}" MATCHES "\"([^\"]*)\"")
		set (OLD_GIT_COMMIT_HASH "${CMAKE_MATCH_1}")
	endif ()
	file(
		STRINGS "${HEADER_OUT}" TWX_l
		REGEX "DATE"
	)
	if ("${TWX_l}" MATCHES "\"([^\"]*)\"")
		set (OLD_GIT_COMMIT_DATE "${CMAKE_MATCH_1}")
	endif ()
endif()
# Try to run git to obtain the last commit hash and date
find_package(Git QUIET)

if (GIT_FOUND)
	execute_process (
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "show" "--no-patch" "--pretty=%h"
		RESULT_VARIABLE _hash_result
		OUTPUT_VARIABLE TWX_GIT_COMMIT_HASH
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	execute_process(
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "show" "--no-patch" "--pretty=%cI"
		RESULT_VARIABLE _date_result
		OUTPUT_VARIABLE TWX_GIT_COMMIT_DATE
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
  # Display the branch too
	execute_process(
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "branch" "--show-current"
		OUTPUT_VARIABLE TWX_GIT_COMMIT_BRANCH
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	if (
		${_hash_result} EQUAL 0 AND
		${_date_result} EQUAL 0 AND
		NOT "${TWX_GIT_COMMIT_HASH}" STREQUAL "" AND
		NOT "${TWX_GIT_COMMIT_DATE}" STREQUAL ""
	)
		set(_success TRUE)
		execute_process(
			COMMAND "${GIT_EXECUTABLE}"
			"--git-dir=.git" "diff" "--ignore-cr-at-eol"
			"--quiet" "HEAD"
			RESULT_VARIABLE MODIFIED_RESULT
		)
		if ("${MODIFIED_RESULT}" EQUAL 1)
			set(TWX_GIT_COMMIT_HASH "${TWX_GIT_COMMIT_HASH}*")
		endif ()
	endif ()
endif (GIT_FOUND)

if (NOT _success)
	# Maybe this is an exported source code and not a git clone
	# Try to retrieve the export commit hash and date from GitArchiveInfo.txt
	file (
		STRINGS
		"GitArchiveInfo.txt"
		TWX_l
		REGEX "HASH"
	)
	if ("${TWX_l}" MATCHES "\"([^\"]*)\"")
	  set (TWX_GIT_COMMIT_HASH "${CMAKE_MATCH_1}")
	endif ()
	file (
		STRINGS
		"GitArchiveInfo.txt"
		TWX_l
		REGEX "DATE"
	)
	if ("${TWX_l}" MATCHES "\"([^\"]*)\"")
	  set (TWX_GIT_COMMIT_DATE "${CMAKE_MATCH_1}")
	endif ()

	if (NOT "${TWX_GIT_COMMIT_HASH}" STREQUAL "" AND
	    NOT "${TWX_GIT_COMMIT_DATE}" STREQUAL ""
	)
		set(_success TRUE)
	endif ()
endif (NOT _success)

if (_success)
	if (NOT "${OLD_GIT_COMMIT_HASH}" STREQUAL "${TWX_GIT_COMMIT_HASH}" OR
		  NOT "${OLD_GIT_COMMIT_DATE}" STREQUAL "${TWX_GIT_COMMIT_DATE}")
		# If everything worked and the data has changed, update the output file
		configure_file (
			${SOURCE_IN}
			${SOURCE_OUT}
			@ONLY
		)
		configure_file (
			${HEADER_IN}
			${HEADER_OUT}
			@ONLY
		)
		message (STATUS "Git commit info updated: ${TWX_GIT_COMMIT_HASH}, ${TWX_GIT_COMMIT_DATE}, ${TWX_GIT_COMMIT_BRANCH}")
		message (STATUS "Generated: ${HEADER_OUT}")
		message (STATUS "Generated: ${SOURCE_OUT}")
	endif ()
else (_success)
	if ("${OLD_GIT_COMMIT_HASH}" STREQUAL "" OR "${OLD_GIT_COMMIT_DATE}" STREQUAL "")
		message(FATAL_ERROR "Could not determine git commit info")
	else ()
		message(WARNING "Could not determine git commit info")
	endif ()
endif (_success)

