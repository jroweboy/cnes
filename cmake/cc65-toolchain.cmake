# CMake toolchain file for cc65

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR 6502)

# Check for user provided CC65_PATH environment variable
list(APPEND CMAKE_PREFIX_PATH $ENV{CC65_PATH})

find_program(_CL65 cl65)
set(CMAKE_C_COMPILER ${_CL65})
set(CMAKE_C_COMPILER_ID cc65)
set(CMAKE_ASM_COMPILER ${_CL65})
set(CMAKE_ASM_COMPILER_ID ca65)

find_program(_AR ar65)
set(CMAKE_AR "${_AR}" CACHE FILEPATH "Archiver path override (prevents issues with cmake)")

# Overridable default flag values.
set(CC65_TARGET_FLAG "-t nes" CACHE STRING "Target flag for CC65")
set(CC65_DEBUG_FLAG "-g -DDEBUG --asm-define DEBUG" CACHE STRING "Debug flags for CC65")
set(CC65_OPT_MAX_FLAG "-Oisr" CACHE STRING "Max Optimization flags for CC65")
set(CC65_OPT_MIN_SIZE "-O" CACHE STRING "Optimization flags for Min Size Build CC65")

# Set default to the expected CMake variables
set(CMAKE_ASM_FLAGS_INIT "${CC65_TARGET_FLAG}")
set(CMAKE_ASM_FLAGS "${CC65_TARGET_FLAG}" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_DEBUG_INIT "${CC65_DEBUG_FLAG}")
set(CMAKE_ASM_FLAGS_DEBUG "${CMAKE_ASM_FLAGS_DEBUG_INIT}" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_RELEASE_INIT "${CC65_OPT_MAX_FLAG}")
set(CMAKE_ASM_FLAGS_RELEASE "${CMAKE_ASM_FLAGS_RELEASE_INIT}" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_MINSIZEREL_INIT "${CC65_OPT_MIN_SIZE}")
set(CMAKE_ASM_FLAGS_MINSIZEREL "${CMAKE_ASM_FLAGS_MINSIZEREL_INIT}" CACHE STRING "" FORCE)
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO_INIT "${CC65_OPT_MAX_FLAG} ${CC65_DEBUG_FLAG}")
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "${CMAKE_ASM_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING "" FORCE)

set(CMAKE_C_FLAGS_INIT "${CC65_TARGET_FLAG}")
set(CMAKE_C_FLAGS "${CC65_TARGET_FLAG}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_DEBUG_INIT "${CC65_DEBUG_FLAG}")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE_INIT "${CC65_OPT_MAX_FLAG}")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "${CC65_OPT_MIN_SIZE}")
set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL_INIT}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${CC65_OPT_MAX_FLAG} ${CC65_DEBUG_FLAG}")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT}" CACHE STRING "" FORCE)

# this is already the default
#set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS s;S;asm)

# Change the C and ASM compile commands a bit to spit out a listing file
# and also a .s file for the c as well (for nes debugging)
set(CMAKE_C_COMPILE_OBJECT
  "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -E -o <OBJECT>.c -S <SOURCE>"
  "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -o <OBJECT>.s -S <SOURCE>"
  "<CMAKE_C_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -l <OBJECT>.lst -o <OBJECT> -c <OBJECT>.s"
)
# NOTE: if you do NOT enable the ASM and C languages, then cmake will not properly fill in the <INCLUDES>
# template. It will leave off the `-I` flag causing compiler errors. Make sure you define your
# project with `project(name LANGUAGES C ASM) or later call `enable_languages(C ASM)` for this to work

set(CMAKE_ASM_COMPILE_OBJECT
  "<CMAKE_ASM_COMPILER> <FLAGS> <DEFINES> <INCLUDES> -l <OBJECT>.lst -o <OBJECT> -c <SOURCE>"
)

# Change the command when making a static library since ar65 doesn't allow removing .o from libs
set(CMAKE_C_CREATE_STATIC_LIBRARY
    "<CMAKE_COMMAND> -E remove <TARGET>"
    "<CMAKE_AR> a <TARGET> <LINK_FLAGS> <OBJECTS>"
)
set(CMAKE_ASM_CREATE_STATIC_LIBRARY ${CMAKE_C_CREATE_STATIC_LIBRARY})

# HACK: Work around to prevent Cmake from editing some variables
macro(set_readonly VAR)
  # Set the variable itself
  set("${VAR}" "${ARGN}")
  # Store the variable's value for restore it upon modifications.
  set("_${VAR}_readonly_val" "${ARGN}")
  # Register a watcher for a variable
  variable_watch("${VAR}" readonly_guard)
endmacro()

# Watcher for a variable which emulates readonly property.
macro(readonly_guard VAR access value current_list_file stack)
  if ("${access}" STREQUAL "MODIFIED_ACCESS")
    # Restore a value of the variable to the initial one.
    set(${VAR} "${_${VAR}_readonly_val}")
  endif()
endmacro()

# I have no clue how they are expecting me to set this, but this is the only way I've found to
# keep this variable set
set_readonly(CMAKE_INCLUDE_FLAG_ASM "--asm-include-dir ")

set_readonly(CMAKE_EXECUTABLE_SUFFIX ".nes")
