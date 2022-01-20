if (NES)
  set(module cnes.nes)
else()
  set(module cnes.pc)
endif()

add_library(${module}_cdefine INTERFACE)
target_compile_definitions(${module}_cdefine INTERFACE 

  $<$<NOT:$<BOOL:CNES_ENGINE>>:"CNES_DISABLE_ENGINE">
  $<$<NOT:$<BOOL:CNES_JOYPAD>>:"CNES_DISABLE_JOYPAD">
  $<$<NOT:$<BOOL:CNES_JOYPAD_HELD>>:"CNES_DISABLE_JOYPAD_HELD">
  $<$<NOT:$<BOOL:CNES_JOYPAD_PLAYER2>>:"CNES_DISABLE_JOYPAD_PLAYER2">
  $<$<NOT:$<BOOL:CNES_AUDIO>>:"CNES_DISABLE_AUDIO">
  $<$<NOT:$<BOOL:CNES_DRAWING>>:"CNES_DISABLE_DRAWING">
)

file(GLOB cnes_headers ${PROJECT_SOURCE_DIR}/inc/*.h)

if (NES)
  add_library(${module}_asmdefine INTERFACE)
  target_compile_options(${module}_asmdefine INTERFACE 
  
    $<$<NOT:$<BOOL:CNES_ENGINE>>:"--asm-define CNES_DISABLE_ENGINE">
    $<$<NOT:$<BOOL:CNES_JOYPAD>>:"--asm-define CNES_DISABLE_JOYPAD">
    $<$<NOT:$<BOOL:CNES_JOYPAD_HELD>>:"--asm-define CNES_DISABLE_JOYPAD_HELD">
    $<$<NOT:$<BOOL:CNES_JOYPAD_PLAYER2>>:"--asm-define CNES_DISABLE_JOYPAD_PLAYER2">
    $<$<NOT:$<BOOL:CNES_AUDIO>>:"--asm-define CNES_DISABLE_AUDIO">
    $<$<NOT:$<BOOL:CNES_DRAWING>>:"--asm-define CNES_DISABLE_DRAWING">
  )
  add_library(${module} STATIC
    nes/audio.s
    nes/common.inc
    nes/driver.s
    nes/engine.s
    nes/joypad.s
    nes/nes.c
    ${cnes_headers}
  )
  target_link_libraries(${module} INTERFACE ${module}_asmdefine ${module}_cdefine)
else()
  add_library(${module} STATIC
    pc/audio.c
    pc/cnes_internal.h
    pc/joypad.c
    pc/renderer.c
    pc/sdl.c
    ${cnes_headers}
  )
  target_link_libraries(${module} 
    PUBLIC SDL2main SDL2-static SDL2_mixer ${module}_cdefine
  )
endif()

target_include_directories(${module}
  PUBLIC ${CNES_INCLUDE_DIR}
)
