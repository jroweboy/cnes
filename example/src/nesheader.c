
#define NES2_MAPPER 4
#define NES2_PRG 65536
#define NES2_CHR 8192
#define NES2_BRAM 8192
#define NES2_MIRROR 'V'
#define NES2_TV 'N'

#include "nes2header.h"

#pragma rodata-name(push, "INESHDR")
    NES2_HEADER();
#pragma rodata-name(pop)
