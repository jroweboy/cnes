cmake_minimum_required(VERSION 3.20)

# CNES library
project(cnes)

if (NOT CNES_BUILD_SINGLE)
  # use external project add to build the application into separate subfolders
  # we have to do this BEFORE adding project so that we can add toolchain files
  
  # hacky workaround to forward cmake args to ExternalProject
  # https://stackoverflow.com/a/48555098
  get_cmake_property(vars CACHE_VARIABLES)
  foreach(var ${vars})
    get_property(currentHelpString CACHE "${var}" PROPERTY HELPSTRING)
    if("${var}" MATCHES "No help, variable specified on the command line." OR "${var}" MATCHES "CNES_" OR "${var}" MATCHES "VCPKG_")
      # message("${var} = [${${var}}]  --  ${currentHelpString}") # uncomment to see the variables being processed
      list(APPEND CMDLINE_ARGS "-D${var}=${${var}}")
    endif()
  endforeach()

  if(MSVC)
    set(CNES_NATIVE_PRESET msvc)
  elseif(MSYS OR MINGW)
    set(CNES_NATIVE_PRESET mingw)
  else()
    set(CNES_NATIVE_PRESET native)
  endif()

  include(ExternalProject)
  ExternalProject_Add(nes
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    BINARY_DIR ${CMAKE_BINARY_DIR}/nes
    BUILD_ALWAYS 1
    INSTALL_COMMAND cmake -E echo "Skipping install step."
    TEST_COMMAND cmake -E echo "Skipping test step."
    CMAKE_ARGS --preset nes ${CMDLINE_ARGS}
  )
  ExternalProject_Add(native
    SOURCE_DIR ${CMAKE_SOURCE_DIR}
    BINARY_DIR ${CMAKE_BINARY_DIR}/native
    BUILD_ALWAYS 1
    INSTALL_COMMAND cmake -E echo "Skipping install step."
    TEST_COMMAND cmake -E echo "Skipping test step."
    CMAKE_ARGS --preset ${CNES_NATIVE_PRESET} ${CMDLINE_ARGS}
  )
  return()
endif()


if (CMAKE_SYSTEM_PROCESSOR MATCHES "6502")
  set(NES ON CACHE BOOL "" FORCE)
endif()

if (NES)
  enable_language(ASM C)
else()
  enable_language(C CXX)
endif()

option(CNES_BUILD_EXAMPLE "Builds the CNES example exe" OFF)

add_subdirectory(src)

if (CNES_BUILD_EXAMPLE)
  add_subdirectory(example)
endif()
