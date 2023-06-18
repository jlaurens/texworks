TeXworks modules
====================

This documentation explains the module system.

Except the `include` one, each folder in this directory is gathering sources for one specific module.

- `QtPDF` is a pdf viewer that can build as a separate application.
- `synctex` relates to TeX synchronization
- `Twx...` folders focus on specific technologies. These are managed by [TwxModuleLib.cmake](../CMake/Include/TwxModuleLib.cmake) for building and testing.
  - `TwxCore` for core utilities
  - `TwxTypeset` for typesetting management
  - `TwxW3` for internet usage
  - `TwxHelp` to build and test the help system.
- `include` contains files that are shared by all the modules.

`Twx` modules
-------------
Each `Twx` module folder basically contains

- an optional `README.md`
- a main `CMakeLists.txt`, which reads the same for all the modules, except for minor modifications here and there.
- a `src` folder including a `Setup.cmake` file that declares the source and header files of the module, as well as its various library dependencies
- a `Test` folder including a `CMakeLists.txt` and an optional `TestSetup.cmake`. The former is common to every module whereas the latter contains
material for the module only

More details are available in the documentation of [TwxModuleLib](../CMake/Include/TwxModuleLib.cmake) `CMake` TeXworks library.
