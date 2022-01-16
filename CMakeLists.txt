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

function(message)
    if (NOT MESSAGE_QUIET)
        _message(${ARGN})
    endif()
endfunction()

if (NOT NES)
  # PC dependencies
  include(FetchContent)

  # Turn off BUILD_SHARED_LIBS to convince SDL_mixer to build static
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

  FetchContent_Declare(
    SDL2
    GIT_REPOSITORY "https://github.com/libsdl-org/SDL.git"
    GIT_TAG release-2.0.20
  )

  FetchContent_GetProperties(SDL2)
  if (NOT sdl2_POPULATED)
    FetchContent_Populate(SDL2)
    set(SDL_STATIC_PIC ON CACHE BOOL "" FORCE)
    # Turn ON SDL_SHARED so when SDL_Mixer can target it
    # (it looks for the shared target only right now)
    set(SDL_SHARED ON CACHE BOOL "" FORCE)
    set(MESSAGE_QUIET OFF)
    add_subdirectory(${sdl2_SOURCE_DIR} ${sdl2_BINARY_DIR})
    unset(MESSAGE_QUIET)
  endif ()

  FetchContent_Declare(
    SDL2Mixer
    GIT_REPOSITORY "https://github.com/libsdl-org/SDL_mixer.git"
    GIT_TAG master
  )

  FetchContent_GetProperties(SDL2Mixer)

  if (NOT sdl2mixer_POPULATED)
    FetchContent_Populate(SDL2Mixer)
    set(SUPPORT_OGG ON CACHE BOOL "" FORCE)
    set(MESSAGE_QUIET OFF)
    add_subdirectory(${sdl2mixer_SOURCE_DIR} ${sdl2mixer_BINARY_DIR})
    unset(MESSAGE_QUIET)
  endif ()
  
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