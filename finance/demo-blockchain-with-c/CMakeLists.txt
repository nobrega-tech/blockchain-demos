cmake_minimum_required(VERSION 3.16)
project(demo_blockchain_c C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

add_executable(demo-blockchain
  src/sha256.c
  src/blockchain.c
  src/main.c
)
target_include_directories(demo-blockchain PRIVATE src)

if(MSVC)
  target_compile_options(demo-blockchain PRIVATE /O2)
else()
  target_compile_options(demo-blockchain PRIVATE -O3 -Wall -Wextra)
endif()

target_compile_definitions(demo-blockchain PRIVATE DEMO_IMPL_NAME="c")