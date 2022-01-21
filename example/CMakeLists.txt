
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(cnes_example LANGUAGES C ASM)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  find_package(CNES REQUIRED)
endif()

if (NES)
  set(platform_srcs
    src/nes.cfg
    src/nesheader.c
  )
else()
  set(platform_srcs
  )
endif()

add_executable(${CMAKE_PROJECT_NAME}
  src/main.c
  ${platform_srcs}
)

include(CNESAudioGen)
cnes_audio_gen(SRC ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio DEST ${CMAKE_BINARY_DIR}/gen)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE -Wl,--start-group CNES::CNES CNES::AudioGen)

if (NES)
  target_link_options(${CMAKE_PROJECT_NAME} PRIVATE
    -m ${CMAKE_BINARY_DIR}/map.txt
    -C ${CMAKE_CURRENT_SOURCE_DIR}/src/nes.cfg
    --ld-args --dbgfile,${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.dbg
  )
else()
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE -static)
endif()
