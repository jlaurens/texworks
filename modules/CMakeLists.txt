
set ( MODULE_INCLUDE_DIRS )

set ( QTPDF_LIB_TYPE STATIC )
set ( QTPDF_VIEWER OFF )
add_subdirectory ( QtPDF )

add_subdirectory ( TwxCore )
add_subdirectory ( TwxTypeset )

# add_subdirectory ( TwxEngine )

# We DO NOT include the synctex subdirectory here as that is handled entirely by
# FindSynctex.cmake
