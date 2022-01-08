#!/usr/bin/make -f

TITLE = cnes_example

SRCS = main
NES_SRCS = nesheader

# user defined paths
INC_DIR = ../inc
LIB_DIR = ../lib
OBJ_DIR = bin
SRC_DIR = src

# nes compiler defines
# CCFLAGS contains a few C optimizing flags
CFLAGS65 := -t nes -I $(INC_DIR) --bin-include-dir $(INC_DIR) -g -W1
CCFLAGS65 := -t nes -I $(INC_DIR) --static-locals -Oirs -g
LIBS65 := cnes.nes.lib
LDFLAGS65 := -L $(LIB_DIR)

# pc compiler defines
# debug
LIBS := -L$(LIB_DIR) -lcnes.pc $(shell pkg-config --libs sdl2) -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lversion -luuid -lSetupapi
LDFLAGS := -static -static-libgcc
CCFLAGS := $(shell pkg-config --cflags sdl2) -Wall -g -O0 -I$(INC_DIR)

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

.PHONY: clean all default nes pc $(LIB_DIR)/cnes.pc.lib
default: all

clean:
	-rm -rf $(OBJ_DIR)/*

all: nes pc

# NES compiler targets
nes: $(TITLE).nes

OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).nes.o)
NES_OBJS := $(foreach s,$(NES_SRCS),$(OBJ_DIR)/$(s).nes.o)

$(OBJ_DIR)/map.txt $(OBJ_DIR)/$(TITLE).dbg $(TITLE).nes: $(OBJS) $(NES_OBJS) $(LIB_DIR)/$(LIBS65)
	$(DIR)
	$(LD65) -o $(TITLE).nes -m $(OBJ_DIR)/map.txt --dbgfile $(OBJ_DIR)/$(TITLE).dbg -C src/nes.cfg $(LDFLAGS65) --start-group $^ $(LIBS65) --end-group

$(OBJ_DIR)/%.nes.o: $(OBJ_DIR)/%.nes.s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

$(OBJ_DIR)/%.nes.s: $(SRC_DIR)/%.c
	$(DIR)
	$(CC65) $(CCFLAGS65) -o $@ $<

-include $(OBJS:%.nes.o=%.nes.d)

$(LIB_DIR)/$(LIBS65):
	@$(MAKE) -C ../ neslib

# pc compiler targets

PC_OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).pc.o)
DEPFLAGS = -MF $(patsubst %.pc.o,%.pc.d,$@) -MMD -MP

pc: $(TITLE_EXE)

$(TITLE_EXE): $(PC_OBJS) $(LIB_DIR)/cnes.pc.lib
	$(DIR)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $@

$(OBJ_DIR)/%.pc.o: $(SRC_DIR)/%.c
	$(DIR)
	$(CC) $(DEPFLAGS) -c $(CCFLAGS) $< -o $@

-include $(PC_OBJS:%.pc.o=%.pc.d)

$(LIB_DIR)/cnes.pc.lib:
	@$(MAKE) -C ../ pclib
