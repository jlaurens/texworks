TeXworks development
====================

This documentation explains how sources are organized. It is intended for developers.

The test and build system
-------------------------
Building and testing TeXworks is based on `CMake`. The `CMake` folder contains supplemental `.cmake` library files useful for building and testing. Each one is documented separately and a doxygen based documpentation is available.

Modularity
----------
The whole source is organised in a tree of separate entities that can build and test independently. [See](modules/Readme.md).

The documentation
-----------------
Each module as well as the whole projection can have its own doxygen documentation available with `make doxydoc`, after the standard configuration step.
