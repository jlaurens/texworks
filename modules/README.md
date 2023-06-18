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
  