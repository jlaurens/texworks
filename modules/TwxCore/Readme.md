# TeXworks sources

About `src/Core`

This folder contains core technologies with quite no dependency,
except with `Qt`, the `stl` and the files here located.

The tests can run standalone with usual `cmake` technic:
```
mkdir build_Core
cd build_Core
cmake ... && cmake --build . && ctest .
```

In the documentation built with `make doxydoc`,
see `Const`, `Env`, `Key`, `Path` and `Core` namespaces.
