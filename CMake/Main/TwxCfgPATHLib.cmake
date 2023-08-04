#[===============================================[/*
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
 ( C ) 2023 JL
*/
/** @file
	* @brief Manage Cfg data related to binary paths
	*
	* The only purpose is to write a Cfg data file to store
	* the static list of factory binary paths elaborated at build time.
	*
	* Usage:
	*
	* 	include ( TwxCfgPATHLib )
	*
	* Output:
	* - `TwxBuildData/<project_name>_paths.ini`, will be automatically read by
	*   the `configure_file` related commands. In that case, will be defined
	* - `TWX_CFG_FACTORY_PATH`
	*
	* Any subsequent try to include this script in the same project
	* is a noop.
	*
	* This was originally implemented that way. It is now implemented as runtime
	* support.
	*/
/*
#]===============================================]

include_guard ( GLOBAL )

# Binary Directories available in TL ( https://www.tug.org/svn/texlive/trunk/Master/bin/ )
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

# ANCHOR: twx_binary_PATH__add_TeXLive_default
#[=======[*/
/** @brief Add TeXLive related binary paths
	*
	* @param var for key `VAR`, the list variable to modify.
	* @param delta for key `YEAR_DELTA`, optional non negative integer.
	*   Defaults to 5.
	* 	Use TeXLive distributions from the current year minus delta
	* 	to the current year plus delta.
	*/
twx_binary_PATH__add_TeXLive_default ( VAR var [YEAR_DELTA delta]) {}
/*
#]=======]
function ( twx_binary_PATH__add_TeXLive_default )
  cmake_parse_arguments (
		PARSE_ARGV 0 twx.R
		"" "VAR;YEAR_DELTA" ""
	)
	twx_arg_assert_parsed ()
	if ( DEFINED twx.R_YEAR_DELTA )
		twx_assert_compare ( "${twx.R_YEAR_DELTA}" >= 0 )
	else ()
		set ( twx.R_YEAR_DELTA 5 )
	endif ()
	string ( TIMESTAMP yearCurrent_ "%Y" UTC )
	math ( EXPR yearMin_ "${yearCurrent_} - ${twx.R_YEAR_DELTA}" )
	math ( EXPR yearMax_ "${yearCurrent_} + ${twx.R_YEAR_DELTA}" )
	if ( WIN32 )
		set ( path_ "c:/w32tex/bin" )
		foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
			list ( PREPEND path_ "c:/texlive/${year_}/bin" )
		endforeach ()
	elseif ( APPLE )
		foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
			list ( PREPEND path_ "/usr/local/texlive/${year_}/bin/universal-darwin" )
		endforeach ()
		if ( CMAKE_SIZEOF_VOID_P GREATER 4 )
			foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
				list ( PREPEND path_ "/usr/local/texlive/${year_}/bin/x86_64-darwin" )
			endforeach ()
			foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
				list ( PREPEND path_ "/usr/local/texlive/${year_}/bin/x86_64-darwinlegacy" )
			endforeach ()
		else ()
			foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
				list ( PREPEND path_ "/usr/local/texlive/${year_}/bin/i386-darwin" )
			endforeach ()
		endif ()
	else ()
		if ( CYGWIN )
			set ( OS_ "cygwin" )
			set ( ARCH64_ "x86_64" )
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "FreeBSD" )
			set ( OS_ "freebsd" )
			set ( ARCH64_ "amd64" )
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "NetBSD" )
			set ( OS_ "netbsd" )
			set ( ARCH64_ "amd64" )
		elseif ( "${CMAKE_SYSTEM_NAME}" STREQUAL "SunOS" )
			set ( OS_ "solaris" )
			set ( ARCH64_ "x86_64" )
		# FIXME: darwinlegacy, linuxmusl
		else ()
			set ( OS_ "linux" )
			set ( ARCH64_ "x86_64" )
		endif ()
		if ( CMAKE_SIZEOF_VOID_P GREATER 4 )
			set ( ARCH_ "${ARCH64_}" )
		else ()
			set ( ARCH_ "i386" )
		endif ()
		set ( path_ "" )
		foreach ( year_ RANGE ${yearMin_} ${yearMax_} )
			list ( PREPEND path_ "/usr/local/texlive/${year_}/bin/${ARCH_}-${OS_}" )
		endforeach ()
	endif ()
	list ( APPEND ${twx.R_VAR} ${path_} )
	twx_export ( ${twx.R_VAR} )
endfunction ( twx_binary_PATH__add_TeXLive_default )

# ANCHOR: twx_binary_PATH__add_MiKTeX_default
#[=======[*/
/** @brief Add MikTeX related binary paths
	*
	* - Windows: Installs to "%LOCALAPPDATA%\Programs\MiKTeX" or "C:\Program Files\MiKTeX"
	* 	 ( previously, versioned folders such as "C:\Program Files\MiKTeX 2.9" were used )
	* - Linux: Installs miktex-* binaries to /usr/bin and symlinks them to ~/bin or
	* 	/usr/local/bin ( https://miktex.org/howto/install-miktex-unx )
	* - Mac OS_ X uses the same symlink locations as Linux ( https://miktex.org/howto/install-miktex-mac )
	*
	* @param var for key `VAR`, the list variable to modify.
	* @param version_list for key `VERSION`, the list of supported versions.
	*   Defaults to 2.8, 2.9 and 3.0.
	*
	*/
twx_binary_PATH__add_MiKTeX_default ( VAR var ) {}
/*
#]=======]
function ( twx_binary_PATH__add_MiKTeX_default )
  cmake_parse_arguments (
		PARSE_ARGV 0 twx.R
		"" "VAR" "VERSION"
	)
	twx_arg_assert_parsed ()
	if ( WIN32 )
		list ( APPEND ${twx.R_VAR} "%LOCALAPPDATA%/Programs/MiKTeX/miktex/bin" )
		list ( APPEND ${twx.R_VAR} "%SystemDrive%/Program Files/MiKTeX/miktex/bin" )
		list ( APPEND ${twx.R_VAR} "%SystemDrive%/Program Files (x86)/MiKTeX/miktex/bin" )
		if ( NOT DEFINED twx.R_VERSION )
			set ( twx.R_VERSION 3.0 2.9 2.8 )
		endif ()
		foreach ( _miktex_version ${twx.R_VERSION} )
			# TODO: replace hard coded program files path with
			# %ProgramFiles% ( might cause problems when running a 32bit application
			# on 64bit Windows ) or %ProgramW6432% ( added in Win7 )
			list ( APPEND ${twx.R_VAR} "%LOCALAPPDATA%/Programs/MiKTeX ${_miktex_version}/miktex/bin" )
			list ( APPEND ${twx.R_VAR} "%SystemDrive%/Program Files/MiKTeX ${_miktex_version}/miktex/bin" )
			list ( APPEND ${twx.R_VAR} "%SystemDrive%/Program Files (x86)/MiKTeX ${_miktex_version}/miktex/bin" )
		endforeach ()
	else ()
		twx_assert_undefined ( twx.R_VERSION )
		list ( APPEND ${twx.R_VAR} "\${HOME}/bin" "/usr/local/bin" )
	endif ()
	twx_export ( ${twx.R_VAR} )
endfunction ( twx_binary_PATH__add_MiKTeX_default )

# ANCHOR: twx_binary_PATH__add_TeX
#[=======[*/
/** @brief Add TeX related binary paths
	*
	* This is only relevant when building the application on your own,
	* because it relies on an installed TeX distribution
	* available in the PATH while building the application.
	*
	* @param var for key `VAR`, the list variable to modify.
	*
	* Ignored when CMake is cross compiling.
	*/
twx_binary_PATH__add_TeX ( VAR var ) {}
/*
#]=======]
function ( twx_binary_PATH__add_TeX .VAR twx.R_VAR )
	twx_arg_assert_count ( ${ARGC} == 2 )
	twx_arg_assert_keyword ( .VAR )
	if ( CMAKE_CROSSCOMPILING )
		return ()
	endif ()
	if ( WIN32 )
		get_filename_component ( tex_ tex.exe PROGRAM )
	else ()
		get_filename_component ( tex_ tex PROGRAM )
	endif ()
	if ( NOT tex_ )
		return ()
	endif ()
	get_filename_component ( path_ "${tex_}" DIRECTORY )
	list ( PREPEND ${twx.R_VAR} "${path_}" )
	twx_export ( ${twx.R_VAR} )
endfunction ( twx_binary_PATH__add_TeX )

# ANCHOR: twx_binary_PATH__add_system_default
#[=======[*/
/** @brief Add system related binary paths
	*
	* This is only relevant when building the application on your own,
	* because it relies on an installed TeX distribution
	* available in the PATH while building the application.
	*
	* @param var for key `VAR`, the list variable to modify.
	*
	*/
twx_binary_PATH__add_system_default ( VAR var ) {}
/*
#]=======]
function ( twx_binary_PATH__add_system_default .VAR twx.R_VAR )
	twx_arg_assert_count ( ${ARGC} == 2 )
	twx_arg_assert_keyword ( .VAR )
	if ( APPLE )
		list ( PREPEND ${twx.R_VAR} "/Library/TeX/texbin" "/usr/texbin" )
	endif ()
	if ( UNIX )
		list ( APPEND ${twx.R_VAR} "/usr/local/bin" "/usr/bin" )
	endif ()
	twx_export ( ${twx.R_VAR} )
endfunction ()

# ANCHOR: twx_binary_PATH_generate_ini
#[=======[*/
/** @brief Generate the binary paths related ini file
	*
	* This is only relevant when building the application on your own,
	* because it relies on an installed TeX distribution
	* available in the PATH while building the application.
	*
	* @param id for key `ID`, optional identifier used by Cfg library.
	* 	Defaults to `paths`.
	*
	*/
twx_binary_PATH_generate_ini([ID id]) {}
/*
#]=======]
function ( twx_binary_PATH_generate_ini )
	cmake_parse_arguments (
		PARSE_ARGV 0 twx.R
		"" "ID" ""
	)
	twx_arg_assert_parsed ()
	if ( NOT DEFINED twx.R_ID )
	  set ( twx.R_ID "paths" )
	endif ()
	twx_cfg_write_begin ( ID "${twx.R_ID}" )
	# only one local variable used
	set ( paths_ )
	twx_binary_PATH__add_TeXLive_default ( VAR paths_ )
	twx_binary_PATH__add_MiKTeX_default ( VAR paths_ )
	twx_binary_PATH__add_system_default ( VAR paths_ )
	twx_binary_PATH__add_TeX ( VAR paths_ )
	list ( REMOVE_DUPLICATES paths_ )
	if ( NOT WIN32 )
		# Windows uses ";" as path separator, just as CMake does for lists
		# *nix systems use ":", so we have to replace the separators
		string ( REPLACE ";" ":" paths_ "${paths_}" )
	endif ()
	twx_cfg_set ( "FACTORY_PATH=${paths_}" )
	twx_cfg_write_end ()
	message ( VERBOSE "TwxCfgPATHLib: Paths updated" )
	if ( WIN32 )
		string ( REPLACE ";" "\n  " paths_ "${paths_}" )
	else ()
		string ( REPLACE ":" "\n  " paths_ "${paths_}" )
	endif ()
	set ( CMAKE_MESSAGE_INDENT )
	message ( 
		VERBOSE
		"TwxCfgPATHLib: Paths updated\n  ${paths_}"
	)
endfunction ()

twx_binary_PATH_generate_ini ( ID "paths" )

#*/
