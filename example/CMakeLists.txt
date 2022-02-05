
cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

project(cnes_example LANGUAGES C ASM)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  find_package(CNES REQUIRED)
endif()

set(RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

if (NES)
  set(platform_srcs
    src/nes.cfg
    src/nesheader.c
  )
else()
  set(platform_srcs
  )
endif()

add_executable(${PROJECT_NAME}
  src/main.c
  ${platform_srcs}
)

include(CNESAudioGen)
cnes_audio_gen(SRC ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio DEST ${CMAKE_BINARY_DIR}/gen)

target_link_libraries(${PROJECT_NAME} PRIVATE -Wl,--start-group CNES::CNES CNES::AudioGen)

if (NES)
  target_link_options(${PROJECT_NAME} PRIVATE
    -C ${CMAKE_CURRENT_SOURCE_DIR}/src/nes.cfg
    -m $<TARGET_FILE_DIR:${PROJECT_NAME}>/map.txt
    --ld-args --dbgfile,$<TARGET_FILE_DIR:${PROJECT_NAME}>/${PROJECT_NAME}.dbg
  )
else()
  target_link_libraries(${PROJECT_NAME} PRIVATE -static)
endif()
