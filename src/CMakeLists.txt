if (NES)
  set(module cnes_nes)
else()
  set(module cnes_pc)

  # find the dependencies from vcpkg
  find_package(SDL2 CONFIG REQUIRED)
  find_package(sdl2-mixer CONFIG REQUIRED)
  find_package(bgfx CONFIG REQUIRED)

  find_package(Vorbis CONFIG REQUIRED)
  find_package(Ogg CONFIG REQUIRED)
endif()


include(CMakeDependentOption)
add_library(${module}_cdefine INTERFACE)
add_library(${module}_asmdefine INTERFACE)

macro(cnes_option)
  set(options DEPENDENT)
  set(oneValueArgs NAME)
  set(multiValueArgs ARGS)
  cmake_parse_arguments(CNES_OPTION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT CNES_OPTION_NAME)
    message(FATAL_ERROR "Option name is required!")
  endif()

  if (CNES_OPTION_DEPENDENT)
    cmake_dependent_option(${CNES_OPTION_NAME} ${CNES_OPTION_ARGS})
  else()
    option(${CNES_OPTION_NAME} ${CNES_OPTION_ARGS})
  endif()

  target_compile_definitions(${module}_cdefine INTERFACE $<$<NOT:$<BOOL:CNES_OPTION_NAME>>:"DISABLE_CNES_OPTION_NAME">)
  target_compile_options(${module}_asmdefine INTERFACE $<$<NOT:$<BOOL:CNES_OPTION_NAME>>:"--asm-define DISABLE_CNES_OPTION_NAME">)
endmacro()

cnes_option(NAME CNES_ENGINE ARGS "Enable CNES IRQ engine" ON)

cnes_option(NAME CNES_AUDIO ARGS "Enable CNES audio engine (using famistudio)" ON)
cnes_option(DEPENDENT NAME CNES_AUDIO_GEN ARGS "Automatically generate the required files from the path set in CNES_AUDIO_PATH" ON CNES_AUDIO OFF)

cnes_option(NAME CNES_JOYPAD ARGS "Enable CNES Joypad support" ON)
cnes_option(DEPENDENT NAME CNES_JOYPAD_HELD ARGS "Enable button held checking. (Adds 8 bytes of RAM per player)" ON CNES_JOYPAD OFF)
cnes_option(DEPENDENT NAME CNES_JOYPAD_PLAYER2 ARGS "Enable polling for player 2. (Adds 4-12 bytes of RAM)" ON CNES_JOYPAD OFF)

cnes_option(NAME CNES_DRAWING ARGS "Enable CNES Screen support" ON)

set(cnes_headers
  inc/audio.h
  inc/cnes.h
  inc/common_types.h
  inc/drawing.h
  inc/engine.h
  inc/famistudio_cc65.h
  inc/joypad.h
  inc/nes2header.h
)

if (NES)
  add_library(${module} STATIC
    nes/audio.s
    nes/common.inc
    nes/drawing.s
    nes/driver.s
    nes/engine.s
    nes/joypad.s

    # p8crt65 - for popslide and nstripe using PB8 
    # see https://wiki.nesdev.org/w/index.php/Tile_compression
    nes/p8crt65/src/popslide.inc
    nes/p8crt65/src/popslideinternal.inc
    nes/p8crt65/src/popslide16.s
    nes/p8crt65/src/nstripe.s

    ${cnes_headers}
  )

  target_include_directories(${module} PRIVATE nes/p8crt65/src)
  target_link_libraries(${module} INTERFACE ${module}_asmdefine ${module}_cdefine)
else()
  add_library(${module} STATIC
    pc/audio.cpp
    pc/audio.h
    pc/core.cpp
    pc/core.h
    pc/joypad.cpp
    pc/joypad.h
    pc/renderer.cpp
    pc/renderer.h
    pc/sdl.cpp
    ${cnes_headers}
  )
  set_property(TARGET ${module} PROPERTY CXX_STANDARD 11)
  set_target_properties(${module} PROPERTIES LINKER_LANGUAGE CXX)
  target_link_libraries(${module} PRIVATE 
    SDL2::SDL2main SDL2::SDL2-static SDL2::SDL2_mixer Vorbis::vorbis Ogg::ogg
    bgfx::bx bgfx::iqa bgfx::astc bgfx::bgfx
    ${module}_cdefine
  )
endif()

target_include_directories(${module} PUBLIC inc/)

add_library(CNES::CNES ALIAS ${module})
