if (CMAKE_CXX_COMPILER_ID MATCHES "cc65")
  set(module cnes.nes)
else()
  set(module cnes.pc)
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "cc65")
  add_library(${module} STATIC
    nes/audio.s
    nes/common.s
    nes/driver.s
    nes/engine.s
    nes/joypad.s
    nes/nes.c
  )
else()
  add_library(${module} STATIC
    pc/audio.c
    pc/internal.h
    pc/joypad.c
    pc/renderer.c
    pc/sdl.c
  )
  target_link_libraries(${module}
    PUBLIC SDL2main SDL2-static SDL2_mixer
  )
endif()

target_include_directories(${module}
  PUBLIC ${CNES_INCLUDE_DIR}
)
