#ifndef CNES_DRAWING_H
#define CNES_DRAWING_H


#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"


extern u8* cnes_object_sprite;
extern u8* cnes_object_x;
extern u8* cnes_object_y;

enum ColorBase {
  GRAY        = 0x10,
  AZURE       = 0x11,
  BLUE        = 0x12,
  VIOLET      = 0x13,
  MAGENTA     = 0x14,
  ROSE        = 0x15,
  RED         = 0x16,
  ORANGE      = 0x17,
  YELLOW      = 0x18,
  CHARTREUSE  = 0x19,
  GREEN       = 0x1a,
  SPRING      = 0x1b,
  CYAN        = 0x1c,
  BLACK       = 0x1f,
};

enum ColorIntensity {
  DARK    = -0x10,
  MEDIUM  = 0x00, // Default
  LIGHT   = 0x10,
  PALE    = 0x20,
};

void __LIB_CALLSPEC set_background(u8 color);

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC draw_metasprite(u8 object_slot);

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC draw_metatile(u8 metatile_id);


#ifdef __cplusplus
}
#endif

#endif //CNES_DRAWING_H