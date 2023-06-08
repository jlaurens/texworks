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

This module serves as proof of concept, together with the `Typeset` one.
The structure of the folder is constrained:
- `CMakeLists.txt`  is the root file that can be loaded standalone,
  in `TeXworks` context of course,
- `src/` contains the sources
- `src/Setup.cmake` declares the contents of the module
- `Test/` contains the testing material
- `Test/CMakeLists.txt` declares all the tests
- `Test/WorkingDirectory` is the template of the working directory
  common to all tests
- `CMake/` may contain additional CMake commands or libraries
  that do not fit in the general `CMake` directory because they are not shared.

The main product is a static library in `/TwxProduct/libTwxCore.a` together with its corresponding headers.
The public headers are collected in `/TwxProduct/include/`.
A special version of the headers for testing purposes only is available
`/TwxProduct/include_for_testing/`.

While building and testing the static library, private headers are used.
For example, `TwxLocate.in.h` partly reads
```
namespace Twx {
namespace Core {
@TWX_CFG_include_TwxNamespaceTestMain_private_h@
class Locate
{
  [...]
  @TWX_CFG_include_TwxLocate_private_h@
  @TWX_CFG_include_TwxFriendTestMain_private_h@
};
} // namespace Core
} // namespace Twx
```
While populating the `/TwxProduct/include/` folder, we use `configure_file` with no special variables defined, such that 
`/TwxProduct/include/TwxLocate.h` partly reads.
```
namespace Twx {
namespace Core {

class Locate
{
  [...]


};
} // namespace Core
} // namespace Twx
```
But if we build or test the library, then some variables are defined
such that `/TwxBuild/src/TwxLocate.h` partly reads
```
namespace Twx {
namespace Core {
namespace Test {
  class Main;
}
class Locate
{
  [...]
  #include "TwxLocate_private.h"
  friend class Test::Main;
};
} // namespace Core
} // namespace Twx
```
Now the sources as well as the `Twx::Core::Test::Main` class have access to the private header `/TwxBuild/src/TwxLocate_private.h`

This feature relies on `TwxCfgFileLib`.

Some headers have no private material such that this trick is not necessary.
