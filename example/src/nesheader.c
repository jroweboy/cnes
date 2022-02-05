
#define NES2_MAPPER 4
#define NES2_PRG 65536
#define NES2_BRAM 8192
#define NES2_MIRROR 'H'
#define NES2_TV 'N'

#include "nes2header.h"

#pragma rodata-name(push, "INESHDR")
    NES2_HEADER();
#pragma rodata-name(pop)

#include "cnes.h"

#pragma data-name(push, "VECTORS")
const void const* vectors[3] = {
    &driver_nmi,
    &driver_reset,
    &driver_irq
};
#pragma data-name(pop)
