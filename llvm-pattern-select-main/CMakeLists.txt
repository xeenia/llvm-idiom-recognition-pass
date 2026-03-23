cmake_minimum_required(VERSION 3.20)
project(PatternSelectPass LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM REQUIRED CONFIG)
message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION} at ${LLVM_DIR}")

add_library(PatternSelectPass MODULE
  src/PatternSelectPass.cpp
  src/PatternRules.cpp 
)

target_include_directories(PatternSelectPass PRIVATE ${LLVM_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_compile_definitions(PatternSelectPass PRIVATE ${LLVM_DEFINITIONS})

target_link_libraries(PatternSelectPass PRIVATE LLVM)

set_target_properties(PatternSelectPass PROPERTIES
  PREFIX ""
)
