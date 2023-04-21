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

if (Twx_Typeset_SOURCES)
  return ()
endif ()

include (WithQt)
twx_append_QT (
	REQUIRED Test Core
)
# TODO: `src/Typeset` should not be hard coded.
set (
  Twx_Typeset_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/TwxTypesetManager.cpp"
)
set (
  Twx_Typeset_HEADERS
  "${CMAKE_CURRENT_LIST_DIR}/TwxTypesetManager.h"
)
