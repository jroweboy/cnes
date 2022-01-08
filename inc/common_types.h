
#ifndef COMMON_TYPES_H
#define COMMON_TYPES_H

#include <stdbool.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef signed char s8;
typedef signed short s16;


#ifdef __NES__
// limit X/Y to a u8 on NES by default
typedef u8 coord;


// Turn on fastcall later
#define __LIB_CALLSPEC __fastcall__

#else
// allow for u16 cooridnate space on PC for HD rendering
typedef u16 coord;

// If we aren't compiling for the NES then ignore __fastcall__ 
#define __LIB_CALLSPEC 
#endif

#endif //COMMON_TYPES_H
