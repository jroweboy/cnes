
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

  # hacky way to remove shared libaries from the final linker command.
  get_target_property(EXE_LINKED_LIBS SDL2_mixer LINK_LIBRARIES)
  list(FILTER EXE_LINKED_LIBS EXCLUDE REGEX "SDL2::SDL2")
  list(APPEND EXE_LINKED_LIBS SDL2-static)
  set_property(TARGET SDL2_mixer PROPERTY LINK_LIBRARIES ${EXE_LINKED_LIBS})

endif ()
