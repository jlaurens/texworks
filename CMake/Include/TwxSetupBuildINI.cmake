#[===============================================[
This is part of the TeXworks build system.
See https://github.com/TeXworks/texworks
(C)  JL 2023

It configures files with the hard coded list of keys
given below.
Usages:
```
cmake -DPROJECT_NAME="..." -DPROJECT_BINARY_DIR="..." -P ".../TwxSetupBuildINI.cmake"
```
from a target at build time or directly at configure time
```
include ( TwxSetupBuildINI )
```
When used in `-P` mode, "CMake sets the variables
`CMAKE_BINARY_DIR`, `CMAKE_SOURCE_DIR`, `CMAKE_CURRENT_BINARY_DIR` and
`CMAKE_CURRENT_SOURCE_DIR` to the current working directory."
Also, no global variable is defined directly:
it is read from a file.

Implementation details:
* `<binary_dir>/build_ini/<ProjectName>Static.ini`
  is a file containing key-value pairs that are
  not subject to change since configuration time.
* `<binary_dir>/build_ini/TwxGit.ini`
  is a file containing git related key-value pairs
  that may change after configuration time.
* `<binary_dir>/build_ini/TwxInList.txt`
  is a list of input files established at configuration time.
  This file respects UTF-8 encoding.

The location of the input file relative to the source directory and
the location of the output file relative to the binary directory
are expected to be the same.

Here is the static list of recognized keys.
Other keys can be used but they must be managed elsewhere.
For each `<key_twx>` we have `TWX_PROJECT_<key_twx>` and `<project_name>_<key_twx>`
to store the same value.
* General info (static values)
  - `NAME`
  - `NAME_LOWER`
  - `NAME_UPPER`
  - `COPYRIGHT_YEARS`
  - `COPYRIGHT_HOLDERS`
  - `AUTHORS`
* Version (static values)
  - `VERSION`
  - `VERSION_SHORT`
  - `VERSION_MAJOR`
  - `VERSION_MINOR`
  - `VERSION_PATCH`
  - `VERSION_TWEAK`
* Build (static values)
  - `BUILD_ID`
* Packaging (static values)
  - `DOC_ICO`
  - `APP_ICO`
  - `WIN_MANIFEST`
* Git (dynamic values)
  - `GIT_HASH`
  - `GIT_DATE`
  - `GIT_BRANCH`

JL
#]===============================================]

if ( NOT PROJECT_NAME )
  message ( FATAL_ERROR "Undefined PROJECT_NAME" )
endif ()
if ( NOT PROJECT_BINARY_DIR )
  message ( FATAL_ERROR "Undefined PROJECT_BINARY_DIR" )
endif ()

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "TwxSetupBuildINI: ${PROJECT_NAME}" )
  message ( STATUS "TwxSetupBuildINI: ${CMAKE_SOURCE_DIR}" )
  message ( STATUS "TwxSetupBuildINI: ${PROJECT_BINARY_DIR}" )
elseif ( TWX_IS_BASED )
  message ( STATUS "TwxSetupBuildINI" )
endif ()

if ( TWX_IS_BASED )
  # We are in configure mode
  set ( configure_files_twx ON )
else ()
  include (
    "${CMAKE_CURRENT_LIST_DIR}/TwxBase.cmake"
    NO_POLICY_SCOPE
  )
endif ()

set (
  TWX_DIR_build_ini
  "${PROJECT_BINARY_DIR}/build_ini"
)
set (
  Readme.md
  "${TWX_DIR_build_ini}/Readme.md"
)
set (
  Static.ini
  "${TWX_DIR_build_ini}/${PROJECT_NAME}Static.ini"
)
set (
  Git.ini
  "${TWX_DIR_build_ini}/TwxGit.ini"
)
if ( NOT EXISTS "${Readme.md}" )
  file (
    WRITE
    "${Readme.md}"
    "This folder is generated automatically by the TeXworks build system.\n"
    "Remove the whole folder when source files were added or removed.\n"
  )
endif ()

if ( NOT EXISTS "${Static.ini}" )
  # First read the project related ini
  include ( TwxParseProjectINI )
  twx_parse_project_INI (
    "${PROJECT_NAME}"
    "${CMAKE_SOURCE_DIR}"
  )
  string (
    TOUPPER
    "${PROJECT_NAME}"
    TWX_PROJECT_NAME_UPPER
  )
  string (
    TOLOWER
    "${PROJECT_NAME}"
    TWX_PROJECT_NAME_LOWER
  )
  file (
    WRITE
    "${Static.ini}"
    "[This file is generated automatically by the TeXworks build system]\n"
    "VERSION       = <<<${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}>>>\n"
    "VERSION_SHORT = <<<${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}>>>\n"
    "VERSION_MAJOR = <<<${PROJECT_VERSION_MAJOR}>>>\n"
    "VERSION_MINOR = <<<${PROJECT_VERSION_MINOR}>>>\n"
    "VERSION_PATCH = <<<${PROJECT_VERSION_PATCH}>>>\n"
    "VERSION_TWEAK = <<<${PROJECT_VERSION_TWEAK}>>>\n"
    "NAME          = <<<${PROJECT_NAME}>>>\n"
    "NAME_UPPER    = <<<${TWX_PROJECT_NAME_UPPER}>>>\n"
    "NAME_LOWER    = <<<${TWX_PROJECT_NAME_LOWER}>>>\n"
    "COPYRIGHT_YEARS   = <<<${TWX_PROJECT_COPYRIGHT_YEARS}>>>\n"
    "COPYRIGHT_HOLDERS = <<<${TWX_PROJECT_COPYRIGHT_HOLDERS}>>>\n"
    "AUTHORS       = <<<${TWX_PROJECT_AUTHORS}>>>\n"
    "BUILD_ID      = <<<${TWX_BUILD_ID}>>>\n"
    "DOC_ICO       = <<<${CMAKE_SOURCE_DIR}/res/images/TeXworks-doc.ico>>>\n"
    "APP_ICO       = <<<${CMAKE_SOURCE_DIR}/res/images/TeXworks.ico>>>\n"
    "WIN_MANIFEST  = <<<${CMAKE_BINARY_DIR}/res/winOS/TeXworks.exe.manifest>>>\n"
  )
endif ()
# ANCHOR: Read the static key_twx/value keys
# At configuration time there is some intentional redundancy
file (
  STRINGS
  "${Static.ini}"
  lines_twx
  ENCODING UTF-8
)
include ( TwxConfigureFile )
foreach ( line_twx IN LISTS lines_twx )
  if ( line_twx MATCHES "([^= ]*)[ =]*<<<(.*)>>>" )
    twx_configure_file_prepare (
      "${CMAKE_MATCH_1}"
      "${CMAKE_MATCH_2}"
    )
    set (
      TWX_PROJECT_${CMAKE_MATCH_1}
      "${CMAKE_MATCH_2}"
    )
    set (
      ${PROJECT_NAME}_${CMAKE_MATCH_1}
      "${CMAKE_MATCH_2}"
    )
  endif ()
endforeach ()


# ANCHOR: GIT
set ( OLD_HASH_twx "" )
set ( OLD_DATE_twx "" )
set ( OLD_BRANCH_twx "" )
set ( SUCCESS_twx FALSE )

# Recover old git commit info from `.../@ONLYGit.ini` if available.
# We don't want to touch the file if nothing relevant has changed as that would
# trigger an unnecessary rebuild of parts of the project
if ( EXISTS "${Git.ini}" )
  file (
    STRINGS "${Git.ini}"
    git_info
    ENCODING UTF-8
  )
  foreach ( key_twx GIT_HASH GIT_DATE GIT_BRANCH )
    set ( OLD_${key_twx} )
    foreach ( line_kwx IN LISTS git_info )
      if ( line_kwx MATCHES "${key_twx}[ =]*<<<(.*)>>>" )
        set (
          OLD_${key_twx} "${CMAKE_MATCH_1}"
        )
      endif ()
    endforeach()
  endforeach()

endif()

set ( Unavailable_twx "<Unavailable>")
set ( NEW_BRANCH_twx "${Unavailable_twx}")

# Try to run git to obtain the last commit hash and date
find_package ( Git QUIET )

if ( GIT_FOUND )
	execute_process (
    COMMAND "${GIT_EXECUTABLE}"
    "--git-dir=.git" "show" "--no-patch" "--pretty=%h"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE HASH_RESULT_twx
    OUTPUT_VARIABLE NEW_HASH_twx
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set( ENV{TZ} UTC0 )
	execute_process (
    COMMAND "${GIT_EXECUTABLE}"
    "--git-dir=.git" "show" "--no-patch" "--pretty=%cI"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE DATE_RESULT_twx
    OUTPUT_VARIABLE NEW_DATE_twx
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
	if ( ${HASH_RESULT_twx} EQUAL 0 AND
       ${DATE_RESULT_twx} EQUAL 0 AND
      NOT NEW_HASH_twx STREQUAL "" AND
      NOT NEW_DATE_twx STREQUAL "" )
		set ( SUCCESS_twx TRUE )
		execute_process (
      COMMAND "${GIT_EXECUTABLE}"
      "--git-dir=.git" "diff" "--ignore-cr-at-eol" "--quiet" "HEAD"
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      RESULT_VARIABLE MODIFIED_RESULT_twx
    )
		if ( MODIFIED_RESULT_twx EQUAL 1)
			set( NEW_HASH_twx "${NEW_HASH_twx}*")
		endif ()
	endif ()
	execute_process (
    COMMAND "${GIT_EXECUTABLE}"
    "--git-dir=.git" "branch" "--show-current"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE BRANCH_RESULT_twx
    OUTPUT_VARIABLE NEW_BRANCH_twx
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endif ( GIT_FOUND )

set ( GIT_OK_twx 1 )
if ( NOT SUCCESS_twx )
	# Maybe this is an exported source code and not a git clone
	# Try to retrieve the export commit hash and date from GitArchiveInfo.txt
  if ( TWX_PROJECT_GIT_HASH_STATIC STREQUAL "" )
    set (
      NEW_HASH_twx
      "${Unavailable_twx}"
    )
		message ( WARNING "Could not determine git commit info" )
    set ( GIT_OK_twx 0 )
  else ()
    set (
      NEW_HASH_twx
      "${TWX_PROJECT_GIT_HASH_STATIC}"
    )
  endif ()
  if ( TWX_PROJECT_GIT_DATE_STATIC STREQUAL "" )
    set (
      NEW_DATE_twx
      "${Unavailable_twx}"
    )
    if ( GIT_OK_twx )
		  message ( WARNING "Could not determine git commit info" )
      set ( GIT_OK_twx 0 )
    endif ()
  else ()
    set (
      NEW_HASH_twx
      "${TWX_PROJECT_GIT_DATE_STATIC}"
    )
  endif ()
endif ( NOT SUCCESS_twx )

if ( NOT OLD_HASH_twx STREQUAL NEW_HASH_twx OR
      NOT OLD_DATE_twx STREQUAL NEW_DATE_twx )
  # If everything worked and the data has changed, update the output file
  file (
    WRITE "${Git.ini}"
    "[This file is generated automatically by the TeXworks build system]\n"
    "GIT_HASH   = <<<${NEW_HASH_twx}>>>\n"
    "GIT_DATE   = <<<${NEW_DATE_twx}>>>\n"
    "GIT_BRANCH = <<<${NEW_BRANCH_twx}>>>\n"
    "GIT_OK     = <<<${GIT_OK_twx}>>>\n"
  )
  message ( STATUS "Git commit info updated" )
endif ()

# ANCHOR: Read the file contents.
file (
  STRINGS "${Git.ini}"
  git_info
  ENCODING UTF-8
)
foreach ( key_twx GIT_HASH GIT_DATE GIT_BRANCH GIT_OK )
  foreach ( line_kwx IN LISTS git_info )
    if ( line_kwx MATCHES "${key_twx}[ =]*<<<(.*)>>>" )
      set (
        TWX_PROJECT_${key_twx} "${CMAKE_MATCH_1}"
      )
      set (
        ${PROJECT_NAME}_${key_twx} "${CMAKE_MATCH_1}"
      )
      twx_configure_file_prepare (
        ${key_twx} "${CMAKE_MATCH_1}"
      )
    endif ()
  endforeach ()
endforeach ()

# ANCHOR: Get the list of all the *.in files (and friends)
set (
  list.txt
  "${PROJECT_BINARY_DIR}/build_ini/TwxInList.txt"
)
if ( NOT EXISTS "${list.txt}" )
  message ( STATUS "GLOB_RECURSE: CMAKE_SOURCE_DIR => ${CMAKE_SOURCE_DIR}")
  file (
    GLOB_RECURSE files_twx
    RELATIVE "${CMAKE_SOURCE_DIR}"
    "res/*.in"
    "res/*.in.*"
    "src/*.in"
    "src/*.in.*"
  )
  string (
    REPLACE ";" "\n" files_twx "${files_twx}"
  )
  file (
    WRITE "${list.txt}" ${files_twx}
  )
endif ()

file (
  STRINGS
  "${list.txt}"
  files_twx
  ENCODING UTF-8
)
while ( NOT files_twx STREQUAL "" )
  list ( GET files_twx 0 file )
  list ( REMOVE_AT files_twx 0 )
  message ( STATUS "file => ${file}" )
  if ( file MATCHES "(.*)\.in$")
    set (
      output
      "${CMAKE_MATCH_1}"
    )
  elseif ( file MATCHES "(.*)\.in(\..*)" )
    set (
      output
      "${CMAKE_MATCH_1}${CMAKE_MATCH_2}"
    )
  else ()
    message ( FATAL_ERROR "Logically unreachable" )
  endif ()
  twx_configure_file (
    "${CMAKE_SOURCE_DIR}/${file}"
    "${PROJECT_BINARY_DIR}/${output}"
    ONLY_CHANGED
  )
  if ( TWX_CONFIG_VERBOSE )
    message ( STATUS "configure_file: ${CMAKE_SOURCE_DIR}/${file} -> ${PROJECT_BINARY_DIR}/${output}" )
  endif ()
endwhile ()
