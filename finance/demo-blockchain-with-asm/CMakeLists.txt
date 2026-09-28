cmake_minimum_required(VERSION 3.16)
project(demo_blockchain_asm C ASM)
set(CMAKE_C_STANDARD 11)
enable_language(ASM)
add_executable(demo-blockchain
  src/sha256.c
  src/pow_mine.S
  src/blockchain.c
  src/main.c
)
target_include_directories(demo-blockchain PRIVATE src)
target_compile_definitions(demo-blockchain PRIVATE DEMO_USE_ASM_MINE DEMO_IMPL_NAME="asm")
if(NOT MSVC)
  target_compile_options(demo-blockchain PRIVATE $<$<COMPILE_LANGUAGE:C>:-O3 -Wall -Wextra>)
endif()