#!/usr/bin/make -f

TITLE = cnes

SRCS =
NES_SRCS = common driver engine joypad audio
NES_SRCS_C = nes

PC_SRCS_C = sdl joypad audio renderer

DIR = @mkdir -p $(@D)
INC_DIR = inc
OBJ_DIR = bin
GEN_DIR = bin/gen
LIB_DIR = lib
NES_SRC_DIR = src/nes
PC_SRC_DIR = src/pc

# nes compiler defines
# CCFLAGS contains a few C optimizing flags
CFLAGS65 := -t nes -I $(INC_DIR) --bin-include-dir $(INC_DIR) -g -W1
CCFLAGS65 := -t nes -I $(INC_DIR) --static-locals -Oirs -g

# pc compiler defines
# debug
LIBS := $(shell pkg-config --libs --static ogg sdl2 sdl2_mixer)
CCFLAGS := $(shell pkg-config --cflags sdl2 sdl2_mixer) -Wall -g -O0 -I$(INC_DIR)

# release
#LIBS := $(shell pkg-config --libs sdl2)
#CCFLAGS := $(shell pkg-config --cflags sdl2) -Wall -s -O3

ifdef COMSPEC
CA65 := tools/cc65/bin/ca65
CC65 := tools/cc65/bin/cc65
LD65 := tools/cc65/bin/ld65
AR65 := tools/cc65/bin/ar65
PY := py -3
else
CA65 := ca65
CC65 := cc65
LD65 := ld65
AR65 := ld65
PY := python3
endif

.PHONY: clean all default neslib pclib
default: all

clean:
	-rm -rf $(OBJ_DIR)/*

all: neslib pclib

neslib: $(LIB_DIR)/$(TITLE).nes.lib

COMMON_OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).nes.o)
NES_OBJS := $(foreach s,$(NES_SRCS),$(OBJ_DIR)/$(s).nes.o)
NES_OBJS += $(foreach s,$(NES_SRCS_C),$(GEN_DIR)/$(s).nes.o)
NES_OBJS += $(COMMON_OBJS)

$(LIB_DIR)/$(TITLE).nes.lib: $(NES_OBJS)
	$(DIR)
	$(AR65) r $(LIB_DIR)/$(TITLE).nes.lib $^

$(OBJ_DIR)/%.nes.o: $(NES_SRC_DIR)/%.s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

$(GEN_DIR)/%.nes.o: $(GEN_DIR)/%.nes.s
	$(DIR)
	$(CA65) $(CFLAGS65) --create-dep $(@:.o=.d) -l $(@:.o=.lst) -o $@ $<

$(GEN_DIR)/%.nes.s: $(NES_SRC_DIR)/%.c
	$(DIR)
	$(CC65) $(CCFLAGS65) -o $@ $<

-include $(NES_OBJS:%.o=%.d)

pclib: $(LIB_DIR)/$(TITLE).pc.lib

# pc compiler targets

PC_OBJS := $(foreach s,$(SRCS),$(OBJ_DIR)/$(s).pc.o)
PC_OBJS += $(foreach s,$(PC_SRCS_C),$(OBJ_DIR)/$(s).pc.o)
DEPFLAGS = -MF $(patsubst %.pc.o,%.pc.d,$@) -MMD -MP

$(LIB_DIR)/$(TITLE).pc.lib: $(PC_OBJS)
	$(DIR)
	$(AR) rc $(LIB_DIR)/$(TITLE).pc.lib $^

$(OBJ_DIR)/%.pc.o: $(PC_SRC_DIR)/%.c
	$(DIR)
	$(CC) $(DEPFLAGS) -c $(CCFLAGS) $< -o $@

-include $(PC_OBJS:%.pc.o=%.pc.d)
