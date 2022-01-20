
#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include <stdbool.h>
#include <stdint.h>

typedef uint8_t   u8;
typedef uint16_t  u16;
typedef uint32_t  u32;
typedef int8_t    s8;
typedef int16_t   s16;
typedef int32_t   s32;

#ifdef __NES__
// limit X/Y to a u8 on NES by default
typedef u8 coord;

#define __LIB_CALLSPEC __fastcall__

#else

typedef uint64_t  u64;
typedef int64_t   s64;

// allow for u16 cooridnate space on PC for HD rendering
typedef u16 coord;

// If we aren't compiling for the NES then ignore __fastcall__ 
#define __LIB_CALLSPEC 
#endif

#endif //COMMON_TYPES_H
