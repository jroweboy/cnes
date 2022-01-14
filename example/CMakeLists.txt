
cmake_minimum_required(VERSION 3.11)

project(cnes_example LANGUAGES C ASM)

if (CMAKE_CXX_COMPILER_ID MATCHES "cc65")
  set(BUILD_TYPE nes)
else()
  set(BUILD_TYPE pc)
endif()

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Normally the cnes library is a subdirectory of the project.
# But we can do a little hacky-workaround to make that work
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_BINARY_DIR}/cnes)

if (CMAKE_CXX_COMPILER_ID MATCHES "cc65")
  set(exe ${CMAKE_PROJECT_NAME}.nes)
  set(lib cnes.nes)
else()
  set(exe ${CMAKE_PROJECT_NAME})
  set(lib cnes.pc)
endif()


find_package( PythonInterp 3 REQUIRED )

set(gen ${CMAKE_BINARY_DIR}/gen)

add_custom_command(
  OUTPUT ${gen}/inc/music.h gen/${BUILD_TYPE}/audio/internal.h ${gen}/${BUILD_TYPE}/audio/internal.c
  COMMAND ${PYTHON_EXECUTABLE} ${cnes_SOURCE_DIR}/scripts/generate_audio.py "--${BUILD_TYPE}" ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio ${CMAKE_BINARY_DIR}/gen
  DEPENDS ${cnes_SOURCE_DIR}/scripts/generate_audio.py ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio
  COMMENT "Generating Music Headers/Data"
)

add_executable(${exe}
  src/main.c
  ${gen}/${BUILD_TYPE}/audio/internal.c
)

target_include_directories(${exe}
  PRIVATE ${cnes_SOURCE_DIR}/inc
  PRIVATE $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/gen/inc>
  )

target_link_libraries(${exe} -Wl,--start-group ${lib})

if (CMAKE_CXX_COMPILER_ID MATCHES "cc65")
  target_sources(${exe} PRIVATE src/nesheader.c)
endif()
