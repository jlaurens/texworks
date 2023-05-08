#[===============================================[
This is part of TWX build and test system.
https://github.com/TeXworks/texworks

This is `<...>/res/CMakeLists.txt`

```
add_subdirectory ( res )
```
Configure files

#]===============================================]


include ( TwxInfoLib )

twx_info_write_begin ()
twx_info_set (
  DOC_ICO
  "${TWX_DIR}/res/images/TeXworks-doc.ico"
)
twx_info_set (
  APP_ICO
  "${TWX_DIR}/res/images/TeXworks.ico"
)
# The manifest is built by `configure_file`
twx_info_set (
  WIN_MANIFEST
  "${PROJECT_BINARY_DIR}/res/winOS/TeXworks.exe.manifest"
)
twx_info_write_end ( "res" )
