# Standalone helper to launch `git` and retrieve information.
cmake_minimum_required(VERSION 3.1)

include(
	"${CMAKE_CURRENT_LIST_DIR}/Base.cmake"
	NO_POLICY_SCOPE
)

if (NOT HEADER)
	message(FATAL_ERROR "HEADER not set")
endif ()

set(TWX_old_hash_l "")
set(TWX_old_date_l "")

set(TWX_branch_l "<Unknown>")

set(TWX_success_l FALSE)

# Recover old git commit info from the header if available.
# We don't want to touch the file if nothing relevant has changed as that would
# trigger an unnecessary rebuild of parts of the project
if (EXISTS "${HEADER}")
	file(
		STRINGS "${HEADER}" TWX_l
		REGEX "GIT_COMMIT_HASH"
	)
	if ("${TWX_l}" MATCHES "[a-f0-9]+")
		set (TWX_old_hash_l CMAKE_MATCH_0)
	endif ()
	file(
		STRINGS "${HEADER}" TWX_l
		REGEX "GIT_COMMIT_DATE"
	)
	if ("${TWX_l}" MATCHES "[-+:0-9TZ]+")
		set (TWX_old_date_l CMAKE_MATCH_0)
	endif ()
endif()

# Try to run git to obtain the last commit hash and date
find_package(Git QUIET)

if (GIT_FOUND)
	execute_process (
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "show" "--no-patch" "--pretty=%h"
		RESULT_VARIABLE TWX_hash_result_l
		OUTPUT_VARIABLE TWX_new_hash_l
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	execute_process(
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "show" "--no-patch" "--pretty=%cI"
		RESULT_VARIABLE TWX_date_result_l
		OUTPUT_VARIABLE TWX_new_date_l
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
  # Display the branch too
	execute_process(
		COMMAND "${GIT_EXECUTABLE}"
		"--git-dir=.git" "branch" "--show-current"
		RESULT_VARIABLE TWX_branch_result_l
		OUTPUT_VARIABLE TWX_branch_l
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	if (
		${TWX_hash_result_l} EQUAL 0 AND
		${TWX_date_result_l} EQUAL 0 AND
		NOT "${TWX_new_hash_l}" STREQUAL "" AND
		NOT "${TWX_new_date_l}" STREQUAL ""
	)
		set(TWX_success_l TRUE)
		execute_process(
			COMMAND "${GIT_EXECUTABLE}"
			"--git-dir=.git" "diff" "--ignore-cr-at-eol"
			"--quiet" "HEAD"
			RESULT_VARIABLE MODIFIED_RESULT
		)
		if ("${MODIFIED_RESULT}" EQUAL 1)
			set(TWX_new_hash_l "${TWX_new_hash_l}*")
		endif ()
	endif ()
endif (GIT_FOUND)

if (NOT TWX_success_l)
	# Maybe this is an exported source code and not a git clone
	# Try to retrieve the export commit hash and date from GitArchiveInfo.txt
	file (
		STRINGS
		"GitArchiveInfo.txt"
		TWX_l
		REGEX "GIT_COMMIT_HASH"
	)
	if ("${TWX_l}" MATCHES "[a-f0-9]+")
	  set (TWX_new_hash_l "${CMAKE_MATCH_0}")
	endif ()
	file (
		STRINGS
		GitArchiveInfo.txt
		TWX_l
		REGEX "GIT_COMMIT_DATE"
	)
	if ("${TWX_l}" MATCHES "[-+:0-9TZ]+")
	  set (TWX_new_date_l "${CMAKE_MATCH_0}")
	endif ()

	if (NOT "${TWX_new_hash_l}" STREQUAL "" AND
	    NOT "${TWX_new_date_l}" STREQUAL ""
	)
		set(TWX_success_l TRUE)
	endif ()
endif (NOT TWX_success_l)

if (TWX_success_l)
	if (NOT "${TWX_old_hash_l}" STREQUAL "${TWX_new_hash_l}" OR
		  NOT "${TWX_old_date_l}" STREQUAL "${TWX_new_date_l}")
		# If everything worked and the data has changed, update the output file
		file (
			WRITE "${HEADER}"
"// This file is used to identify the latest git commit.\
Please do not touch.\n\
#define GIT_COMMIT_HASH \"${TWX_new_hash_l}\"\n\
#define GIT_COMMIT_DATE \"${TWX_new_date_l}\"\n\
#define GIT_COMMIT_BRANCH \"${TWX_branch_l}\"\n"
)
		message (STATUS "Git commit info updated: ${TWX_new_hash_l}, ${TWX_new_date_l}, ${TWX_branch_l}")
	endif ()
else (TWX_success_l)
	if ("${TWX_old_hash_l}" STREQUAL "" OR "${TWX_old_date_l}" STREQUAL "")
		message(FATAL_ERROR "Could not determine git commit info")
	else ()
		message(WARNING "Could not determine git commit info")
	endif ()
endif (TWX_success_l)

