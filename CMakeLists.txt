cmake_minimum_required(VERSION 3.20)

# CNES library
project(cnes LANGUAGES C ASM)

if (NOT CNES_BUILD_SINGLE AND (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR))
  # use external project add to build the application into separate subfolders
  include(ExternalProject)
  get_filename_component(CNES_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/cmake/cc65-toolchain.cmake ABSOLUTE)
  get_filename_component(CNES_PREFIX_PATH ${CMAKE_SOURCE_DIR}/tools/cc65 ABSOLUTE)
  ExternalProject_Add(nes
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    BINARY_DIR ${CMAKE_BINARY_DIR}/nes
    BUILD_ALWAYS 1
    INSTALL_COMMAND cmake -E echo "Skipping install step."
    TEST_COMMAND cmake -E echo "Skipping test step."
    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH:PATH=${CNES_PREFIX_PATH}
      -DCMAKE_FRAMEWORK_PATH:PATH=${CNES_FRAMEWORK_PATH}
      -DCMAKE_TOOLCHAIN_FILE:PATH=${CNES_TOOLCHAIN_FILE}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM}
      -DCNES_BUILD_SINGLE=On
  )
  ExternalProject_Add(pc
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    BINARY_DIR ${CMAKE_BINARY_DIR}/pc
    BUILD_ALWAYS 1
    INSTALL_COMMAND cmake -E echo "Skipping install step."
    TEST_COMMAND cmake -E echo "Skipping test step."
    CMAKE_ARGS
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM}
      -DCNES_BUILD_SINGLE=On
  )
  return()
endif()

if (CMAKE_SYSTEM_PROCESSOR MATCHES "6502")
  set(NES ON CACHE BOOL "" FORCE)
endif()

if (NOT NES)

  # Turn off BUILD_SHARED_LIBS to convince SDL_mixer to build static
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

  # fetch SDL2 dependency and build it.
  include(${PROJECT_SOURCE_DIR}/cmake/CPM.cmake)
  CPMAddPackage(
    NAME SDL2
    VERSION 2.0.20
    GITHUB_REPOSITORY "libsdl-org/SDL"
    GIT_TAG "release-2.0.20"
    OPTIONS "SDL_STATIC_PIC ON" "SDL_SHARED OFF"
  )
  if(NOT TARGET SDL2::SDL2)
    add_library(SDL2::SDL2 ALIAS SDL2-static)
  endif()
  CPMAddPackage(
    NAME SDL2Mixer
    VERSION 2.0.20
    GITHUB_REPOSITORY "libsdl-org/SDL_mixer"
    GIT_TAG "60a82b21bdbf2f4626eebee11600f29cebbe1c49"
    OPTIONS "SUPPORT_OGG ON"
  )
endif()

set(CNES_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/inc)

add_subdirectory(src)

# set(INCLUDE_INSTALL_DIR inc/ CACHE FILEPATH "")
# set(LIB_INSTALL_DIR lib/ CACHE FILEPATH "")
# set(SYSCONFIG_INSTALL_DIR etc/cnes/ CACHE FILEPATH "")

# include(CMakePackageConfigHelpers)

# configure_package_config_file(
#   cmake/CNESConfig.cmake.in
#   ${CMAKE_CURRENT_BINARY_DIR}/CNESConfig.cmake
#   INSTALL_DESTINATION ${LIB_INSTALL_DIR}/cnes/cmake
#   PATH_VARS INCLUDE_INSTALL_DIR SYSCONFIG_INSTALL_DIR
# )
# write_basic_package_version_file(
#   ${CMAKE_CURRENT_BINARY_DIR}/CNESConfigVersion.cmake
#   VERSION 0.1.0
#   COMPATIBILITY SameMajorVersion
# )
# install(
#   FILES ${CMAKE_CURRENT_BINARY_DIR}/CNESConfig.cmake
#   ${CMAKE_CURRENT_BINARY_DIR}/CNESConfigVersion.cmake
#   DESTINATION ${LIB_INSTALL_DIR}/cnes/cmake
# )