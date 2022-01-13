#!/usr/bin/make -f

TITLE = cnes_example

SRCS = main
NES_SRCS = nesheader

# user defined paths
INC_DIR = ../inc
LIB_DIR = ../lib
OBJ_DIR = bin
SRC_DIR = src
AUDIO_DIR = ./assets/audio

CNESLIB_NES = cnes.nes.lib
CNESLIB_PC  = cnes.pc.lib

# nes compiler defines
# CCFLAGS contains a few C optimizing flags
CFLAGS65 := -t nes -I $(INC_DIR) --bin-include-dir $(INC_DIR) -g -W1
CCFLAGS65 := -t nes -I $(INC_DIR) --static-locals -Oirs -g
LIBS65 := $(CNESLIB_NES)
LDFLAGS65 := -L $(LIB_DIR)

# pc compiler defines
# debug
SDL_LIB_FLAGS:=$(shell pkg-config --libs-only-l ogg sdl2 sdl2_mixer)
SDL_LIB_FLAGS_L:=$(shell pkg-config --libs-only-L ogg sdl2 sdl2_mixer)
LIBS := -L$(LIB_DIR) $(SDL_LIB_FLAGS_L) -Wl,--start-group -lcnes.pc $(SDL_LIB_FLAGS) -Wl,--end-group
LDFLAGS := -Wl,-subsystem,windows
CCFLAGS := $(shell pkg-config --cflags ogg sdl2 sdl2_mixer) -Wall -g -O0 -I$(INC_DIR)

# release
#LIBS := $(shell pkg-config --libs sdl2)
#CCFLAGS := $(shell pkg-config --cflags sdl2) -Wall -s -O3

# standard helper defines

ifdef COMSPEC
CC65 := ../tools/cc65/bin/cc65
CA65 := ../tools/cc65/bin/ca65
LD65 := ../tools/cc65/bin/ld65
PY := py -3
TITLE_EXE := $(TITLE).exe
else
CC65 := cc65
CA65 := ca65
LD65 := ld65
PY := python3
TITLE_EXE := $(TITLE)
endif

CC := gcc
DIR = @mkdir -p $(@D)

# default targets

.PHONY: clean all default nes pc audio

default: all

clean:
	-rm -rf $(OBJ_DIR)/*

all: nes pc

LIB65_NES_SRC = $(wildcard ../src/nes/*) $(wildcard ../scripts/*) $(wildcard ../inc/*) ../Makefile
# list foreign targets here
$(LIB_DIR)/$(LIBS65): $(LIB65_NES_SRC)
	@$(MAKE) --no-print-directory -C ../ neslib

LIB65_PC_SRC = $(wildcard ../src/pc/*) $(wildcard ../scripts/*) $(wildcard ../inc/*) ../Makefile
$(LIB_DIR)/cnes.pc.lib: $(LIB65_PC_SRC)
	@$(MAKE) --no-print-directory -C ../ pclib

# NES compiler targets
nes: $(OBJ_DIR)/$(TITLE).nes

OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).nes.o)
NES_OBJS := $(foreach s,$(NES_SRCS),$(OBJ_DIR)/$(s).nes.o)
AUDIO_SRC := $(wildcard $(AUDIO_DIR)/*.fms)
AUDIO_OUT := $(OBJ_DIR)/audio/engine_build
NES_OBJS += $(AUDIO_OUT).nes.o

$(OBJ_DIR)/map.txt $(OBJ_DIR)/$(TITLE).dbg $(OBJ_DIR)/$(TITLE).nes: $(OBJS) $(NES_OBJS) $(LIB_DIR)/$(CNESLIB_NES) src/nes.cfg
	$(DIR)
	$(LD65) -o $(OBJ_DIR)/$(TITLE).nes -m $(OBJ_DIR)/map.txt --dbgfile $(OBJ_DIR)/$(TITLE).dbg -C src/nes.cfg $(LDFLAGS65) --start-group $(OBJS) $(NES_OBJS)  $(LIBS65) --end-group

$(OBJ_DIR)/%.nes.o: $(OBJ_DIR)/%.nes.s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

$(OBJ_DIR)/%.nes.s: $(SRC_DIR)/%.c
	$(DIR)
	$(CC65) $(CCFLAGS65) -o $@ $<

-include $(OBJS:%.nes.o=%.nes.d)


# NES famistudio audio targets
audio: $(AUDIO_OUT).nes.o

$(AUDIO_OUT).s: $(AUDIO_SRC) $(wildcard ../scripts/*)
	$(PY) ../scripts/generate_audio.py $(AUDIO_DIR) ./$(OBJ_DIR)/audio

$(AUDIO_OUT).nes.o: $(AUDIO_OUT).s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

# pc compiler targets

PC_OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).pc.o)
DEPFLAGS = -MF $(patsubst %.pc.o,%.pc.d,$@) -MMD -MP

pc: $(OBJ_DIR)/$(TITLE_EXE)

DLLS:= $(OBJ_DIR)/SDL2.dll $(OBJ_DIR)/SDL2_mixer.dll \
	$(OBJ_DIR)/libFLAC-8.dll $(OBJ_DIR)/libmpg123-0.dll \
	$(OBJ_DIR)/libopusfile-0.dll $(OBJ_DIR)/libvorbisfile-3.dll \
	$(OBJ_DIR)/libssp-0.dll $(OBJ_DIR)/libogg-0.dll $(OBJ_DIR)/libopus-0.dll \
	$(OBJ_DIR)/libvorbis-0.dll

$(OBJ_DIR)/$(TITLE_EXE): $(PC_OBJS) $(LIB_DIR)/$(CNESLIB_PC) $(DLLS)
	$(DIR)
	$(CC) $(PC_OBJS) -o $@ $(LDFLAGS) $(LIBS)

$(OBJ_DIR)/%.pc.o: $(SRC_DIR)/%.c
	$(DIR)
	$(CC) $(DEPFLAGS) -o $@ -c $(CCFLAGS) $<

# copy DLLs to the exe folder
$(OBJ_DIR)/%.dll:
	@cp -f /mingw64/$@ $@

-include $(PC_OBJS:%.pc.o=%.pc.d)
