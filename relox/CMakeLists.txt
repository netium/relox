# CMakeList.txt : CMake project for relox, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.21)

# Add source to this project's executable.
add_executable (relox "relox.cpp" "relox.h")

find_package(BISON)
BISON_TARGET(ReloxParser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.c DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/parser.h)

# Add source to this project's executable.
add_executable (relox "relox.cpp" "relox.h" ${BISON_ReloxParser_OUTPUTS})

# TODO: Add tests and install targets if needed.
