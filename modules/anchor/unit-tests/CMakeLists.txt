# File to build unit-tests

include_directories("${CMAKE_SOURCE_DIR}/src")

# Tags
add_executable(test_anchor_Parser
    TWParser_test.cpp
    TWParser_test.h
    "${CMAKE_SOURCE_DIR}/src/TWParser.cpp"
)
target_compile_options(test_anchor_Parser PRIVATE ${WARNING_OPTIONS})
target_link_libraries(test_anchor_Parser ${QT_LIBRARIES})
add_test(NAME test_anchor_Parser COMMAND test_anchor_Parser WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/testcases")

# Tags
add_executable(test_anchor_Tag
    TWTag_test.cpp
    TWTag_test.h
    "${CMAKE_SOURCE_DIR}/src/TWTag.cpp"
    "${CMAKE_SOURCE_DIR}/src/TWParser.cpp"
    "${CMAKE_SOURCE_DIR}/src/TextDocument.cpp"
)
target_compile_options(test_anchor_Tag PRIVATE ${WARNING_OPTIONS})
target_link_libraries(test_anchor_Tag ${QT_LIBRARIES})
add_test(NAME test_anchor_Tag COMMAND test_anchor_Tag WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/testcases")

