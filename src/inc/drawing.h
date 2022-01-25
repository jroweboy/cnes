#ifndef CNES_DRAWING_H
#define CNES_DRAWING_H


#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"


extern u8* cnes_object_sprite;
extern u8* cnes_object_x;
extern u8* cnes_object_y;

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