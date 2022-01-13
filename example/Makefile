#!/usr/bin/make -f

TITLE = cnes_example

SRCS = main
NES_SRCS = nesheader

# user defined paths
INC_DIR = ../inc
LIB_DIR = ../lib
BIN_DIR = build
NES_OBJ_DIR = $(BIN_DIR)/nes/obj
NES_BIN_DIR = $(BIN_DIR)/nes/bin
NES_GEN_DIR = $(BIN_DIR)/nes/gen
PC_BIN_DIR = $(BIN_DIR)/pc/bin
PC_OBJ_DIR = $(BIN_DIR)/pc/obj
PC_GEN_DIR = $(BIN_DIR)/pc/gen
SRC_DIR = src
AUDIO_DIR = ./assets/audio

CNESLIB_NES = cnes.nes.lib
CNESLIB_PC  = cnes.pc.lib

# nes compiler defines
# CCFLAGS contains a few C optimizing flags
CFLAGS65 := -t nes -I $(INC_DIR) -I $(NES_GEN_DIR) --bin-include-dir $(INC_DIR) -g -W1
CCFLAGS65 := -t nes -I $(INC_DIR) -I $(NES_GEN_DIR) --static-locals -Oirs -g
LIBS65 := $(CNESLIB_NES)
LDFLAGS65 := -L $(LIB_DIR)

# pc compiler defines
# debug
SDL_LIB_FLAGS:=$(shell pkg-config --libs-only-l ogg sdl2 sdl2_mixer)
SDL_LIB_FLAGS_L:=$(shell pkg-config --libs-only-L ogg sdl2 sdl2_mixer)
LIBS := -L$(LIB_DIR) $(SDL_LIB_FLAGS_L) -Wl,--start-group -lcnes.pc $(SDL_LIB_FLAGS) -Wl,--end-group
LDFLAGS := -Wl,-subsystem,windows
CCFLAGS := $(shell pkg-config --cflags ogg sdl2 sdl2_mixer) -Wall -g -O0 -I$(INC_DIR) -I$(PC_GEN_DIR)

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
	-rm -rf $(BIN_DIR)/*

all: nes pc

LIB65_NES_SRC = $(wildcard ../src/nes/*) $(wildcard ../scripts/*) $(wildcard ../inc/*) ../Makefile
# list foreign targets here
$(LIB_DIR)/$(LIBS65): $(LIB65_NES_SRC)
	@$(MAKE) --no-print-directory -C ../ neslib

LIB65_PC_SRC = $(wildcard ../src/pc/*) $(wildcard ../scripts/*) $(wildcard ../inc/*) ../Makefile
$(LIB_DIR)/cnes.pc.lib: $(LIB65_PC_SRC)
	@$(MAKE) --no-print-directory -C ../ pclib

# NES compiler targets
nes: $(NES_BIN_DIR)/$(TITLE).nes

OBJS := $(foreach s,$(SRCS),$(NES_OBJ_DIR)/$(s).o)
NES_OBJS := $(foreach s,$(NES_SRCS),$(NES_OBJ_DIR)/$(s).o)
AUDIO_SRC := $(wildcard $(AUDIO_DIR)/*.fms)
NES_AUDIO_OUT := $(NES_GEN_DIR)/audio/engine_build
NES_OBJS += $(NES_AUDIO_OUT).o

$(NES_BIN_DIR)/map.txt $(NES_BIN_DIR)/$(TITLE).dbg $(NES_BIN_DIR)/$(TITLE).nes: $(OBJS) $(NES_OBJS) $(LIB_DIR)/$(CNESLIB_NES) $(SRC_DIR)/nes.cfg
	$(DIR)
	$(LD65) -o $(NES_BIN_DIR)/$(TITLE).nes -m $(NES_BIN_DIR)/map.txt --dbgfile $(NES_BIN_DIR)/$(TITLE).dbg -C src/nes.cfg $(LDFLAGS65) --start-group $(OBJS) $(NES_OBJS)  $(LIBS65) --end-group

$(NES_OBJ_DIR)/%.o: $(NES_OBJ_DIR)/%.s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

$(NES_OBJ_DIR)/%.s: $(SRC_DIR)/%.c $(NES_AUDIO_OUT).h
	$(DIR)
	$(CC65) $(CCFLAGS65) -o $@ $<

-include $(NES_OBJS:%.o=%.d)

# NES famistudio audio targets
audio: nes_audio pc_audio

nes_audio: $(NES_AUDIO_OUT).o

$(NES_AUDIO_OUT).s $(NES_AUDIO_OUT).h: $(AUDIO_SRC) $(wildcard ../scripts/*)
	$(PY) ../scripts/generate_audio.py -n $(AUDIO_DIR) $(NES_GEN_DIR)/audio/

$(NES_AUDIO_OUT).o: $(NES_AUDIO_OUT).s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

# pc compiler targets

PC_OBJS := $(foreach s,$(SRCS),$(PC_OBJ_DIR)/$(s).o)
PC_OBJS += $(PC_OBJ_DIR)/pc_build.o
DEPFLAGS = -MF $(patsubst %.o,%.d,$@) -MMD -MP
PC_AUDIO_OUT := $(PC_GEN_DIR)/audio/pc_build

pc: $(PC_BIN_DIR)/$(TITLE_EXE)

DLLS:= SDL2.dll SDL2_mixer.dll libFLAC-8.dll libmpg123-0.dll \
	libopusfile-0.dll libvorbisfile-3.dll libssp-0.dll libogg-0.dll \
	libopus-0.dll libvorbis-0.dll

PC_BIN_DLLS := $(foreach s,$(DLLS),$(PC_BIN_DIR)/$(s))

$(PC_BIN_DIR)/$(TITLE_EXE): $(PC_OBJS) $(LIB_DIR)/$(CNESLIB_PC) $(PC_BIN_DLLS)
	$(DIR)
	$(CC) $(PC_OBJS) -o $@ $(LDFLAGS) $(LIBS)

$(PC_OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(PC_AUDIO_OUT).h
	$(DIR)
	$(CC) $(DEPFLAGS) -o $@ -c $(CCFLAGS) $<

# PC famistudio audio targets
pc_audio: $(PC_AUDIO_OUT).h

$(PC_AUDIO_OUT).h $(PC_AUDIO_OUT).c: $(AUDIO_SRC) $(wildcard ../scripts/*)
	$(PY) ../scripts/generate_audio.py -p $(AUDIO_DIR) $(PC_GEN_DIR)/audio

$(PC_OBJ_DIR)/pc_build.o: $(PC_AUDIO_OUT).c
	$(DIR)
	$(CC) $(DEPFLAGS) -o $@ -c $(CCFLAGS) $<


# copy DLLs to the exe folder
$(PC_BIN_DIR)/%.dll: /mingw64/bin/%.dll
	$(DIR)
	@cp -f $< $@

-include $(PC_OBJS:%.o=%.d)
