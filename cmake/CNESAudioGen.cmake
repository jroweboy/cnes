
function(cnes_audio_gen)
  set(options NES PC ALL)
  set(oneValueArgs SRC DEST)
  set(multiValueArgs)
  cmake_parse_arguments(CNES_AUDIO_GEN "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (CNES_AUDIO_NES)
    set(build_type --nes)
  elseif(CNES_AUDIO_PC)
    set(build_type --pc)
  else()
    set(build_type)
  endif()

  if (NOT CNES_AUDIO_GEN_SRC)
    message(FATAL_ERROR "Audio Gen SRC folder is required!")
  endif()
  if (NOT CNES_AUDIO_GEN_DEST)
    message(FATAL_ERROR "Audio Gen DEST folder is required!")
  endif()

  find_file(famistudio NAMES FamiStudio FamiStudio.exe)
  if (NOT famistudio)
    message(FATAL_ERROR "Cannot generate audio output: Unable to find Famistudio")
  endif()
  message(STATUS "Famistudio found at ${famistudio}, audio gen enabled for ${CNES_AUDIO_GEN_SRC}")

  find_package(PythonInterp 3 REQUIRED)

  # add all required build items to the list of exports
  set(audio_gen ${CNES_AUDIO_GEN_DEST}/inc/cnes_audio_gen.h)
  if (NES)
    list(APPEND audio_gen
      ${CNES_AUDIO_GEN_DEST}/nes/audio/cnes_nes_audio_gen_internal.h
      ${CNES_AUDIO_GEN_DEST}/nes/audio/cnes_nes_audio_gen_internal.s
    )
  else()
    list(APPEND audio_gen
      ${CNES_AUDIO_GEN_DEST}/pc/audio/cnes_pc_audio_gen_internal.h
      ${CNES_AUDIO_GEN_DEST}/pc/audio/cnes_pc_audio_gen_internal.c
    )
  endif()
  
  find_file(audio_script NAMES generate_audio generate_audio.py)
  if (NOT audio_script)
    message(FATAL_ERROR "Cannot generate audio output: Unable to find generate_audio.py")
  endif()
  add_custom_command(
    OUTPUT ${audio_gen}
    COMMAND ${PYTHON_EXECUTABLE} ${audio_script} ${build_type} --famistudio-path=${famistudio} ${CNES_AUDIO_GEN_SRC} ${CNES_AUDIO_GEN_DEST}
    DEPENDS ${audio_script} ${CNES_AUDIO_GEN_SRC}
    COMMENT "Generating Music Headers/Data with Famistudio"
  )
  add_library(CNESAudioGen ${audio_gen})
  add_library(CNES::AudioGen ALIAS CNESAudioGen)
  target_include_directories(CNESAudioGen PUBLIC ${CNES_AUDIO_GEN_DEST}/inc)
endfunction()
