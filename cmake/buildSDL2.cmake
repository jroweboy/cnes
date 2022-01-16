
# Add the SDL2 build to its own CMake file for workflow caching purposes
# so we can hash this file and check if someone modifies it to rebuild the cache

function(message)
if (NOT MESSAGE_QUIET)
    _message(${ARGN})
endif()
endfunction()

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
  # Turn OFF SDL_SHARED so it doesn't set the SDL2::SDL2 target.
  # SDL2Mixer looks for the shared target, so we create an alias
  # for that to force it to run static instead
  set(SDL_SHARED OFF CACHE BOOL "" FORCE)
  set(MESSAGE_QUIET OFF)
  add_subdirectory(${sdl2_SOURCE_DIR} ${sdl2_BINARY_DIR})
  unset(MESSAGE_QUIET)
endif ()

FetchContent_Declare(
  SDL2Mixer
  GIT_REPOSITORY "https://github.com/libsdl-org/SDL_mixer.git"
  GIT_TAG 60a82b21bdbf2f4626eebee11600f29cebbe1c49
)

FetchContent_GetProperties(SDL2Mixer)

if (NOT sdl2mixer_POPULATED)
  FetchContent_Populate(SDL2Mixer)
  # 
  set(SUPPORT_OGG ON CACHE BOOL "" FORCE)

  # prevent SDL2Mixer from creating its own jank SDL2::SDL2 target
  add_library(SDL2::SDL2 ALIAS SDL2-static)

  set(MESSAGE_QUIET OFF)
  add_subdirectory(${sdl2mixer_SOURCE_DIR} ${sdl2mixer_BINARY_DIR})
  unset(MESSAGE_QUIET)

endif ()
