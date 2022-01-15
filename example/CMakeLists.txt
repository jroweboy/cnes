
cmake_minimum_required(VERSION 3.11)

project(cnes_example LANGUAGES C ASM)

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Normally the cnes library is a subdirectory of the project.
# But we can do a little hacky-workaround to make that work
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/.. ${CMAKE_CURRENT_BINARY_DIR}/cnes)

set(gen ${CMAKE_BINARY_DIR}/gen)

if (NES)
  set(BUILD_TYPE nes)
  set(exe ${CMAKE_PROJECT_NAME}.nes)
  set(lib cnes.nes)
  set(platform_srcs
    src/nes.cfg
    src/nesheader.c
  )
  list(APPEND audio_gen ${gen}/nes/audio/engine_build.s)
else()
  set(BUILD_TYPE pc)
  set(exe ${CMAKE_PROJECT_NAME})
  set(lib cnes.pc)
  set(platform_srcs
  )
endif()

find_file(famistudio NAMES FamiStudio FamiStudio.exe PATHS ${cnes_SOURCE_DIR}/tools/famistudio)
if (NOT famistudio)
  message(WARNING "Unable to find Famistudio. Skipping audio generation.")
else()
  message(STATUS "Famistudio found at ${famistudio}, audio gen enabled for ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio")
  find_package(PythonInterp 3 REQUIRED)

  # add all required build items to the list of exports
  set(audio_gen ${gen}/inc/cnes_audio_gen.h)
  if (NES)
    list(APPEND audio_gen
      ${gen}/${BUILD_TYPE}/audio/engine_build.s
    )
  else()
    list(APPEND audio_gen 
      ${gen}/pc/audio/internal.h
      ${gen}/pc/audio/internal.c
    )
  endif()

  add_custom_command(
    OUTPUT ${audio_gen}
    COMMAND ${PYTHON_EXECUTABLE} ${cnes_SOURCE_DIR}/scripts/generate_audio.py --${BUILD_TYPE} --famistudio-path=${famistudio} ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio ${gen}
    DEPENDS ${cnes_SOURCE_DIR}/scripts/generate_audio.py ${CMAKE_CURRENT_SOURCE_DIR}/assets/audio
    COMMENT "Generating Music Headers/Data with Famistudio"
  )
endif()

add_executable(${exe}
  src/main.c
  ${platform_srcs}
  ${audio_gen}
)

target_include_directories(${exe}
  PRIVATE ${cnes_SOURCE_DIR}/inc
  PRIVATE $<BUILD_INTERFACE:${gen}/inc>
)

target_link_libraries(${exe} -Wl,--start-group ${lib})

if (NES)
  target_link_options(${exe} PRIVATE
    -m ${CMAKE_BINARY_DIR}/map.txt
    -C ${CMAKE_CURRENT_SOURCE_DIR}/src/nes.cfg
    --ld-args --dbgfile,${CMAKE_BINARY_DIR}/${exe}.dbg
  )
endif()
