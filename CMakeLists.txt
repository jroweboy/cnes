cmake_minimum_required(VERSION 3.20)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "6502")
  set(NES ON CACHE BOOL "" FORCE)
endif()

if (NOT NES)
  # PC dependencies
  include(FetchContent)

  FetchContent_Declare(
    SDL2
    GIT_REPOSITORY "https://github.com/libsdl-org/SDL.git"
    GIT_TAG release-2.0.20
  )

  FetchContent_GetProperties(SDL2)

  if (NOT sdl2_POPULATED)
    FetchContent_Populate(SDL2)
    add_subdirectory(${sdl2_SOURCE_DIR} ${sdl2_BINARY_DIR})
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
    add_subdirectory(${sdl2mixer_SOURCE_DIR} ${sdl2mixer_BINARY_DIR})
  endif ()
endif()
# CNES library

project(cnes LANGUAGES C)

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