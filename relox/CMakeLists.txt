# CMakeList.txt : CMake project for relox, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.16)

# Add source to this project's executable.
# add_executable (relox "relox.cpp" "relox.h")

include_directories(".")

find_package(BISON)
find_package(FLEX)

BISON_TARGET(ReloxParser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/parser.h)
FLEX_TARGET(ReloxLexer lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.c DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/lexer.h)
ADD_FLEX_BISON_DEPENDENCY(ReloxLexer ReloxParser)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories("include")

file(GLOB relox_SRC CONFIGURE_DEPENDS "*.h" "*.c")
file(GLOB relox_INCLUDES_HEADER_SRC CONFIGURE_DEPENDS "include/*.h")

# Add source to this project's executable.
add_executable (relox
 ${relox_SRC}
 ${relox_INCLUDES_HEADER_SRC}
 ${BISON_ReloxParser_OUTPUTS}
 ${FLEX_ReloxLexer_OUTPUTS}
 )

 target_link_libraries(relox ${FLEX_LIBRARIES})

# TODO: Add tests and install targets if needed.
