#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks
(C)  JL 2023
#]===============================================]

if ( NOT DEFINED TWX_DIR_src OR 
     NOT DEFINED TWX_DIR_build )
  message (
		FATAL ERROR
		"TWX_DIR_src and TWX_DIR_build should be defined"
	)
endif ()

set (
	TwxCore_SOURCES
	"${TWX_DIR_build}/src/Core/TwxInfo.cpp"
)
set (
	TwxCore_HEADERS
	"${TWX_DIR_src}/Core/TwxInfo.h"
)
