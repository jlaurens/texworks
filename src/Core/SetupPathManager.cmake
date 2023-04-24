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

if ( NOT TWX_IS_BASED )
  message ( FATAL_ERROR "Base not loaded" )
endif ()

if ( DEFINED TWX_PATH_LIST_SEPARATOR )
  return ()
endif ()

#[=======[
This module configures `TwxPathManager.cpp`
from `TwxPathManager.in.cpp`.

Global variables are

* `TWX_STATIC_BINARY_PATHS`
* `TWX_PATH_LIST_SEPARATOR`

Only included by `<...>/src/Core/Setup.cmake`.

#]=======]

# The easy part
if ( WIN32 )
	set ( TWX_PATH_LIST_SEPARATOR ";" )
else ()
  set ( TWX_PATH_LIST_SEPARATOR ":" )
endif ()


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

# ANCHOR: __twx_add_TeXLive_default_binary_paths
function ( __twx_add_TeXLive_default_binary_paths pathsVar )
	string ( TIMESTAMP yearCur "%Y" UTC )
	math ( EXPR yearMin "${yearCur} - 5" )
	math ( EXPR yearMax "${yearCur} + 5" )
	if ( WIN32 )
		set ( _path "c:/w32tex/bin" )
		foreach ( year RANGE ${yearMin} ${yearMax} )
			list ( INSERT _path 0 "c:/texlive/${year}/bin" )
		endforeach ()
	else ()
		if ( ${CMAKE_SIZEOF_VOID_P} EQUAL 4 )
			set ( ARCH "i386" )
		else ()
			set ( ARCH "x86_64" )
		endif ()
		if ( CYGWIN )
			set ( OS "cygwin" )
		elseif ( APPLE )
			set ( OS "darwin" )
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD" )
			set ( OS "freebsd" )
			if ( "${ARCH}" STREQUAL "x86_64" )
				set ( ARCH "amd64" )
			endif ()
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "NetBSD" )
			set ( OS "netbsd" )
			if ( "${ARCH}" STREQUAL "x86_64" )
				set ( ARCH "amd64" )
			endif ()
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "SunOS" )
			set ( OS "solaris" )
		# FIXME: darwinlegacy, linuxmusl
		else ()
			set ( OS "linux" )
		endif ()
		set ( _path "" )
		foreach ( year RANGE ${yearMin} ${yearMax} )
			list ( INSERT _path 0 "/usr/local/texlive/${year}/bin/${ARCH}-${OS}" )
		endforeach ()
		if ( APPLE )
			foreach ( year RANGE ${yearMin} ${yearMax} )
				list ( INSERT _path 0 "/usr/local/texlive/${year}/bin/x86_64-darwinlegacy" )
			endforeach ()
			foreach ( year RANGE ${yearMin} ${yearMax} )
				list ( INSERT _path 0 "/usr/local/texlive/${year}/bin/universal-darwin" )
			endforeach ()
		endif ()
	endif ()
	list ( APPEND ${pathsVar} ${_path} )
	set ( ${pathsVar} "${${pathsVar}}" PARENT_SCOPE )
endfunction ( __twx_add_TeXLive_default_binary_paths pathsVar )

# ANCHOR: __twx_add_MiKTeX_default_binary_paths
# MiKTeX
# Windows: Installs to "%LOCALAPPDATA%\Programs\MiKTeX" or "C:\Program Files\MiKTeX"
# (previously, versioned folders such as "C:\Program Files\MiKTeX 2.9" were used)
# Linux: Installs miktex-* binaries to /usr/bin and symlinks them to ~/bin or
# /usr/local/bin (https://miktex.org/howto/install-miktex-unx)
# Mac OS X uses the same symlink locations as Linux (https://miktex.org/howto/install-miktex-mac)
function (__twx_add_MiKTeX_default_binary_paths pathsVar)
	if (WIN32)
		list ( APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX/miktex/bin" )
		list ( APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX/miktex/bin" )
		list (  APPEND ${pathsVar} "%SystemDrive%/Program Files (x86 )/MiKTeX/miktex/bin" )
		foreach ( _miktex_version IN ITEMS 3.0 2.9 2.8 )
			# TODO: replace hard coded program files path with
			# %ProgramFiles% (might cause problems when running a 32bit application
			# on 64bit Windows) or %ProgramW6432% (added in Win7)
			list ( APPEND ${pathsVar} "%LOCALAPPDATA%/Programs/MiKTeX ${_miktex_version}/miktex/bin" )
			list ( APPEND ${pathsVar} "%SystemDrive%/Program Files/MiKTeX ${_miktex_version}/miktex/bin" )
			list (  APPEND ${pathsVar} "%SystemDrive%/Program Files (x86 )/MiKTeX ${_miktex_version}/miktex/bin" )
		endforeach ()
	else ()
		list ( APPEND ${pathsVar} "\${HOME}/bin" "/usr/local/bin" )
	endif ()
	set ( ${pathsVar} "${${pathsVar}}" PARENT_SCOPE )
endfunction ( __twx_add_MiKTeX_default_binary_paths pathsVar )

# ANCHOR: __twx_add_TeX_binary_paths
function ( __twx_add_TeX_binary_paths pathsVar )
	if ( CMAKE_CROSSCOMPILING )
		return ()
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
	set ( ${pathsVar} "${${pathsVar}}" PARENT_SCOPE )
endfunction ( __twx_add_TeX_binary_paths pathsVar )

# ANCHOR: __twx_add_system_default_binary_paths
function ( __twx_add_system_default_binary_paths pathsVar )
	if ( APPLE )
		list ( INSERT ${pathsVar} 0 "/Library/TeX/texbin" "/usr/texbin" )
	endif ()
	if ( UNIX )
		list ( APPEND ${pathsVar} "/usr/local/bin" "/usr/bin" )
	endif ()
	set ( ${pathsVar} "${${pathsVar}}" PARENT_SCOPE )
endfunction ( __twx_add_system_default_binary_paths pathsVar )

# ANCHOR: twx_generate_default_binary_paths
#[=======[
Public function to setup the paths and
configure files accordingly.
Input are

* `<...>/src/Core/DefaultBinaryPaths.in.h`
* `<...>/src/Core/TwxDefaultBinaryPaths.in.cpp`

#]=======]

# only one local variable used
set ( TWX_paths "" )

__twx_add_TeXLive_default_binary_paths ( TWX_paths )
__twx_add_MiKTeX_default_binary_paths ( TWX_paths )
__twx_add_system_default_binary_paths ( TWX_paths )
__twx_add_TeX_binary_paths ( TWX_paths )

set ( TWX_alt "<<<pwd>>>/A;<<<pwd>>>/B;<<<pwd>>>/C;" )

list ( REMOVE_DUPLICATES TWX_paths )

if ( NOT WIN32 )
	# Windows uses ";" as path separator, just as CMake does for lists
	# *nix systems use ":", so we have to replace the separators
	string ( REPLACE ";" ":" TWX_paths "${TWX_paths}" )
	string ( REPLACE ";" ":" TWX_alt   "${TWX_alt}" )
endif ()

if ( TwxCore_TEST )
	set ( TWX_STATIC_BINARY_PATHS "${TWX_alt}" )
	set ( TWX_ALT_STATIC_BINARY_PATHS "${TWX_paths}" )
else ()
	set ( TWX_STATIC_BINARY_PATHS "${TWX_paths}" )
	set ( TWX_ALT_STATIC_BINARY_PATHS "${TWX_alt}" )
endif ()

twx_configure_file (
	"${TWX_DIR_src}/Core/TwxPathManager.in.cpp"
	"${CMAKE_CURRENT_BINARY_DIR}/src/Core/TwxPathManager.cpp"
	TWX_ans
)
if ( TWX_ans )
	if ( WIN32 )
		string ( REPLACE ";" "', '" TWX_paths "${TWX_paths}" )
	else ()
		string ( REPLACE ":" "', '" TWX_paths "${TWX_paths}" )
	endif ()
	message ( STATUS "Generating static binary paths:\n   '${TWX_paths}'" )
endif ()

unset ( TWX_ans )
unset ( TWX_paths )
