# CMake

(Work in progress)

## Version

- New in version 3.2. CMake learned to support unicode characters encoded as UTF-8 on Windows. This was already supported on platforms whose system APIs accept UTF-8 encoded strings.
- New in version 3.3. The if() command learned a new IN_LIST operator that evaluates to true if a given element is contained in a named list.
- New in version 3.4. The SOURCE_DIR and BINARY_DIR target properties were introduced to allow project code to query where a target is defined.
- New in version 3.5. The `cmake_parse_arguments()` command is now implemented natively.
- New in version 3.7. The if() command gained new boolean comparison operations LESS_EQUAL, GREATER_EQUAL, STRLESS_EQUAL, STRGREATER_EQUAL, VERSION_LESS_EQUAL, and VERSION_GREATER_EQUAL.
- New in version 3.7. The cmake_parse_arguments() command gained a new PARSE_ARGV mode to read arguments directly from ARGC and ARGV# variables inside a function() body.
- New in version 3.9: All regular expression-related commands, including e.g. if(MATCHES), save subgroup matches in the variables CMAKE_MATCH_<n> for <n> 0..9.
- New in version 3.10. The string() command learned a new PREPEND subcommand.
- New in version 3.11: The source files can be omitted if they are added later using target_sources().
- New in versions 3.16: CMAKE_MESSAGE_INDENT, The message() command joins the strings from this list and for log levels of NOTICE and below, it prepends the resultant string to each line of the message.
- New in versions 3.17: CMAKE_MESSAGE_CONTEXT, When enabled by the cmake --log-context command line option or the CMAKE_MESSAGE_CONTEXT_SHOW variable, the message() command converts the CMAKE_MESSAGE_CONTEXT list into a dot-separated string surrounded by square brackets and prepends it to each line for messages of log levels NOTICE and below.
- New in version 3.17: The target_link_libraries() command may now be called to modify targets created outside the current directory. See policy CMP0079.
- New in version 3.18: The cmake_language() command was added for meta-operations on scripted or built-in commands, starting with a mode to CALL other commands, and EVAL CODE to inplace evaluate a CMake script.
- New in version 3.19: The string() command gained a set of new JSON sub commands that provide JSON parsing capabilities.
- New in version 3.23: Properties. The INITIALIZE_FROM_VARIABLE option specifies a variable from which the property should be initialized. The BRIEF_DOCS and FULL_DOCS options are optional.
- New in version 3.25: The block() and endblock() commands were added to manage specific scopes (policy or variable) for a contained block of commands.
- New in version 3.25: See the cmake_language() command for a way to query the current message logging level.
- New in version 3.25: The return() command gained a PROPAGATE option to propagate variables to the scope to which control returns. See policy CMP0140.

## About TeXworks folder /CMake

* `Command` contains various tools to be used directly by CMake with `-P` switch.
* `Modules` contains custom package loaders. Each file inside is included
  with the `find_package` instruction. (In progress)
* `Include` contains various libraries to be used with instruction `include`.
  None will load a package, it may eventually provide tools to load a package.

Various `CMakeLists.txt`

This folder contains utilities to build various `CMakeLists.txt`.

## Problem
The whole TeXworks code is divided into partially independent modules superseeded by a primary `CMakeLists.txt` at the top level.
In order to build and test the various modules separately,
we don't always want to start from the top, but from a directory below, mainly one of the modules.
Then we need to share some configuration settings and tools,
at least the `C++` compiler version and `CMake` policy.
This will be achieved by the inclusion of various `.cmake` files contained in this library.


## Shared preamble
It is a minimal set of configuration settings and tools.
The `TwxBase.cmake` should be included by any main `CMakeLists.txt` at the very top with for example:
```
include(
  "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)
```
where `<...>` is replaced with the approriate number of `..` components to indicate a path relative to the directory of the containing `CMakeLists.txt`.

In general, auxiliary `CMakeLists.txt` loaded after an `add_subdirectory(...)` instruction don't need to include `TwxBase.cmake`.
However, some `CMakeLists.txt`, like in modules, may be either main or auxiliary: we need to differentiate the situation.
The first time `TwxBase.cmake` is loaded after a `project(...)` instruction,
the global variable `TWX_PROJECT_IS_ROOT` is set to a truthy value.
After any subsequent attempt to load `TwxBase.cmake` after a `project(...)` instruction,
this global variable is set to false.
Such `CMakeLists.txt` will start with
```
include(
  "${CMAKE_CURRENT_LIST_DIR}/<...>/CMake/Base/TwxBase.cmake"
  NO_POLICY_SCOPE
)
if (TWX_PROJECT_IS_ROOT)
  <do some configuration as main>
else ()
  <do some configuration as secondary>
endif ()
```

The other `.cmake` files shall not in general include `TwxBase.cmake`.

### Global variables
All of them are prefixed with `TWX_`.
`TWX_DIR` is the path of the directory containing all the sources. Other variable mimic the directory hierarchy with the exact case sensitive folder names. These folder names may change in the future for a better readability, using a global variable will make any change easier.

Other variables are defined by included `.cmake` files.

Beware of the scopes while defining new variables.

### `include`
Once the base is loaded, we can use `include(...)` instructions without specifying a full file path, instead we just give the module name. The subfolder `CMake/Include` is used for that.

Moreover, `find_package(...)` will look for modules into subfolder `CMake/Modules` in addition to standard locations.

The `Include` directory contains global tools and functions, whereas the `Module` directory really contains module related material.

## Guard
In order to prevent some `<file name>.cmake` file of this folder to be included more than once, we can use a trick similar to `.h` macro guards.
The very first `CMake` instructions are sometimes
```
if(DEFINED TWX_GUARD_CMake_Include_<file name>)
  return()
endif()
set(TWX_GUARD_CMake_Include_<file name>)
```
At least it guards from including twice the same file at the same scope level.
`TWX_GUARD_CMake_Include_<file name>` may be replaced by anything more relevant.
Similar ideas may be used instead.

## Coding style
It is a weak convention to prefix global variables by `TWX_`, macros and functions or local variables by `twx_`. When inside a function,
a leading or trailing `_` denotes local variables. Inside macros, a trailing `_twx` is used to avoid collisions with outside variables.

The global commands defined here are prefixed with `twx_`,
which clearly indicates that they are not standard commands.
Names follow modern cmake case relative standards,
according to this quote from `CMake` maintener Brad King
  | Ancient CMake versions required upper-case commands.
  | Later command names became case-insensitive.
  | Now the preferred style is lower-case.

## Available `.cmake` files description

* `TwxBase`: everyone primary `CMakeLists.txt` must include this.
* `TwxBasePolicy`: the policy settings.

File names starting with `Twx` indicate a stronger bound with `TeXworks`.
Others indicate more general contents.

## Various configuration flags used

* WIN32 AND MINGW
* MSVC

## CMake behaviour

- properties are not persistent.
