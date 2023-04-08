# Anchors are tags and bookmarks
cmake_minimum_required(VERSION 3.1)
project(Anchor VERSION 0.1)

# set(TWAnchor_SOURCES
#   src/TWAnchorDock.cpp
#   src/TWAnchorParser.cpp
#   src/TWAnchorTag.cpp
# )
# set(TWAnchor_HEADERS
#   src/TWAnchorDock.h
#   src/TWAnchorParser.h
#   src/TWAnchorTag.h
# )

# if (QT_DEFAULT_MAJOR_VERSION EQUAL 6)
#   find_package(Qt6 REQUIRED COMPONENTS Core Widgets LinguistTools)

#   if (WITH_TESTS)
#     find_package(Qt6 OPTIONAL_COMPONENTS Test QUIET)
#     if (NOT Qt6Test_FOUND)
#       set(WITH_TESTS OFF)
#     endif()
#   endif()

#   # Note: Qt6 only sets Qt6_VERSION, etc., but not QT_VERSION_MAJOR,
#   # etc. which is used here.
#   set(QT_VERSION_MAJOR "${Qt6_VERSION_MAJOR}")
#   set(QT_VERSION_MINOR "${Qt6_VERSION_MINOR}")
#   set(QT_VERSION_PATCH "${Qt6_VERSION_PATCH}")

#   SET(TWAnchor_LIBS
#     ${QT_PLATFORM_LIBRARIES}
#     Qt6::Core Qt6::Widgets
#   )
#   SET(TWAnchor_TEST_LIBS
#     Qt6::Test
#   )
# else ()
#   find_package(Qt5 REQUIRED COMPONENTS Core Widgets LinguistTools)

#   if (WITH_TESTS)
#     find_package(Qt5 OPTIONAL_COMPONENTS Test QUIET)
#     if (NOT Qt5Test_FOUND)
#     set(WITH_TESTS OFF)
#     endif()
#   endif()

#   if (WIN32 AND NOT BUILD_SHARED_LIBS)
#     find_package(Qt5WindowsPlatformSupport)
#   endif ()

#   # Note: Qt5 only sets Qt5_VERSION, etc., but not QT_VERSION_MAJOR,
#   # etc. which is used here.
#   set(QT_VERSION_MAJOR "${Qt5_VERSION_MAJOR}")
#   set(QT_VERSION_MINOR "${Qt5_VERSION_MINOR}")
#   set(QT_VERSION_PATCH "${Qt5_VERSION_PATCH}")

#   SET(TWAnchor_LIBS
#     ${QT_PLATFORM_LIBRARIES}
#     Qt5::Core Qt5::Widgets
#   )
#   SET(TWAnchor_TEST_LIBS
#     ${QT_PLATFORM_LIBRARIES}
#     Qt5::Test
#   )
# endif ()

add_subdirectory(unit-tests)
