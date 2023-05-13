#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
(C) 2023 JL
*//** @file

@brief Manage Cfg data related to paths

The only purpose is to write a Cfg data file
to store the path list separator and the static list
of binary paths elaborated at build time.

Usage:
```
include ( TwxConfigureFilePaths )
```
Input state:
- `TWX_TEST_PATHS` is a list of paths useful for testing.

Output:
- `build_data/<project_name>_paths.ini`, will be automatically read by
  the `configure_file` related commands. In that case, will be defined
  - `TWX_CFG_PATH_LIST_SEPARATOR`
  - `TWX_CFG_FACTORY_BINARY_PATHS`
  - `TWX_CFG_FACTORY_BINARY_PATHS_TEST` See @ref TWX_TEST_PATHS

Any subsequent try to include this script in the same project
is a noop.

**//*
#]===============================================]

# Guard
include ( TwxCfgLib )
twx_cfg_return_if_exists ( "paths" )

# Binary Directories available in TL (https://www.tug.org/svn/texlive/trunk/Master/bin/)
# aarch64-linux/
# amd64-freebsd/
# amd64-netbsd/
# armhf-linux/
# i386-cygwin/ -2023
# i386-freebsd/
# i386-linux/
# i386-netbsd/
# i386-solaris/
# universal-darwin/ +2023
# win32/ -2023
# windows/ +2023
# x86_64-cygwin/
# x86_64-darwin/ -2023
# x86_64-darwinlegacy/
# x86_64-linux/
# x86_64-linuxmusl/
# x86_64-solaris/

# ANCHOR: twx__add_TeXLive_default_binary_paths
function ( twx__add_TeXLive_default_binary_paths pathsVar )
	string( TIMESTAMP yearCur "%Y" UTC )
	math( EXPR yearMin "${yearCur} - 5" )
	math( EXPR yearMax "${yearCur} + 5" )
	if ( WIN32 )
		set( _path "c:/w32tex/bin" )
		foreach( year RANGE ${yearMin} ${yearMax} )
			list( INSERT _path 0 "c:/texlive/${year}/bin"  )
		endforeach()
	else ()
		if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 4)
			set(ARCH "i386")
		else ()
			set(ARCH "x86_64")
		endif ()
		if (CYGWIN)
			set(OS "cygwin")
		elseif (APPLE)
			set(OS "darwin")
		elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD")
			set(OS "freebsd")
			if ("${ARCH}" STREQUAL "x86_64")
				set(ARCH "amd64")
			endif ()
		elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "NetBSD")
			set(OS "netbsd")
			if ("${ARCH}" STREQUAL "x86_64")
				set(ARCH "amd64")
			endif ()
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "SunOS" )
			set ( OS "solaris" )
		# FIXME: darwinlegacy, linuxmusl
		else ()
			set( OS "linux" )
		endif ()
		set( _path "" )
		foreach( year RANGE ${yearMin} ${yearMax} )
			list( INSERT _path 0 "/usr/local/texlive/${year}/bin/${ARCH}-${OS}" )
		endforeach()
		if ( APPLE )
			foreach( year RANGE ${yearMin} ${yearMax} )
				list( INSERT _path 0 "/usr/local/texlive/${year}/bin/x86_64-darwinlegacy" )
			endforeach ()
			foreach ( year RANGE ${yearMin} ${yearMax} )
				list ( INSERT _path 0 "/usr/local/texlive/${year}/bin/universal-darwin" )
			endforeach ()
		endif ()
	endif ()
	list ( APPEND ${pathsVar} ${_path} )
	twx_export ( ${pathsVar} )
endfunction (twx__add_TeXLive_default_binary_paths pathsVar )

# ANCHOR: twx__add_MiKTeX_default_binary_paths
# MiKTeX
# Windows: Installs to "%LOCALAPPDATA%\Programs\MiKTeX" or "C:\Program Files\MiKTeX"
# (previously, versioned folders such as "C:\Program Files\MiKTeX 2.9" were used)
# Linux: Installs miktex-* binaries to /usr/bin and symlinks them to ~/bin or
# /usr/local/bin (https://miktex.org/howto/install-miktex-unx)
# Mac OS X uses the same symlink locations as Linux (https://miktex.org/howto/install-miktex-mac)
function (twx__add_MiKTeX_default_binary_paths pathsVar)
	if (WIN32)
		list(APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX/miktex/bin")
		list(APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX/miktex/bin")
		list(APPEND ${pathsVar} "%SystemDrive%/Program Files (x86)/MiKTeX/miktex/bin")
		foreach(_miktex_version IN ITEMS 3.0 2.9 2.8)
			# TODO: replace hard coded program files path with
			# %ProgramFiles% (might cause problems when running a 32bit application
			# on 64bit Windows) or %ProgramW6432% (added in Win7)
			list(APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX ${_miktex_version}/miktex/bin")
			list(APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX ${_miktex_version}/miktex/bin")
			list(APPEND ${pathsVar} "%SystemDrive%/Program Files (x86)/MiKTeX ${_miktex_version}/miktex/bin")
		endforeach()
	else ()
		list(APPEND ${pathsVar} "\${HOME}/bin" "/usr/local/bin")
	endif ()
	twx_export ( ${pathsVar} )
endfunction ( twx__add_MiKTeX_default_binary_paths pathsVar )

# ANCHOR: twx__add_TeX_binary_paths
#[=======[
This is only relevant when building the application on your own,
because it relies on an installed TeX distribution
available in the PATH while building the application.
Ignored when CMake is cross compiling.
#]=======]
function ( twx__add_TeX_binary_paths pathsVar )
	if ( CMAKE_CROSSCOMPILING )
		return()
	endif ()
	if ( WIN32 )
		get_filename_component ( _tex tex.exe PROGRAM )
	else ()
		get_filename_component ( _tex tex PROGRAM )
	endif ()
	if ( NOT _tex )
		return ()
	endif ()
	get_filename_component ( _path "${_tex}" DIRECTORY )
	list ( INSERT ${pathsVar} 0 "${_path}" )
	twx_export ( ${pathsVar} )
endfunction (twx__add_TeX_binary_paths pathsVar)

# ANCHOR: twx__add_system_default_binary_paths
function ( twx__add_system_default_binary_paths pathsVar )
	if ( APPLE )
		list ( INSERT ${pathsVar} 0 "/Library/TeX/texbin" "/usr/texbin" )
	endif ()
	if ( UNIX )
		list( APPEND ${pathsVar} "/usr/local/bin" "/usr/bin" )
	endif ()
	twx_export ( ${pathsVar} )
endfunction ( twx__add_system_default_binary_paths pathsVar )

# ANCHOR: Generate the info .ini

twx_cfg_write_begin ()

if (WIN32)
	twx_cfg_set ( PATH_LIST_SEPARATOR ";" )
else ()
	twx_cfg_set ( PATH_LIST_SEPARATOR ":" )
endif ()

# only one local variable used
set ( TWX_paths )

twx__add_TeXLive_default_binary_paths ( TWX_paths )
twx__add_MiKTeX_default_binary_paths  ( TWX_paths )
twx__add_system_default_binary_paths  ( TWX_paths )
twx__add_TeX_binary_paths ( TWX_paths )

list(REMOVE_DUPLICATES TWX_paths)

if (NOT WIN32)
	# Windows uses ";" as path separator, just as CMake does for lists
	# *nix systems use ":", so we have to replace the separators
	string(REPLACE ";" ":" TWX_paths "${TWX_paths}")
  if ( DEFINED TWX_TEST_PATHS )
	  string(REPLACE ";" ":" TWX_TEST_PATHS "${TWX_TEST_PATHS}")
  endif ()
endif ()

if ( "${TWX_TEST_PATHS}" STREQUAL "" )
  twx_cfg_set ( FACTORY_BINARY_PATHS "${TWX_paths}" )
  twx_cfg_set ( FACTORY_BINARY_PATHS_TEST "" )
else()
  twx_cfg_set ( FACTORY_BINARY_PATHS "${TWX_TEST_PATHS}" )
  twx_cfg_set ( FACTORY_BINARY_PATHS_TEST "${TWX_paths}" )
endif ()

twx_cfg_write_end ( "paths" )

if ( TWX_CONFIG_VERBOSE )
  message ( STATUS "Paths updated" )
endif ()

if ( TWX_CONFIG_VERBOSE AND NOT "${TWX_paths}" STREQUAL "" )
	if ( WIN32 )
		string(REPLACE ";" "', '" TWX_paths "${TWX_paths}")
	else ()
		string(REPLACE ":" "', '" TWX_paths "${TWX_paths}")
	endif ()
  message (
    STATUS
    "Generated static binary paths:\n   '${TWX_paths}'"
  )
endif ()

unset ( TWX_paths )

#[=======[
*//** @brief For tests

If `TWX_TEST_PATHS` is not void, it is used as list of paths
instead of the generate one.
Moreover, this list generated at build time is still available through
`TWX_CFG_BINARY_PATHS_TEST`.
*/
TWX_TEST_PATHS;
/*
#]=======]
#*/
