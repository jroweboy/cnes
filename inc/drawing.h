#ifndef CNES_DRAWING_H
#define CNES_DRAWING_H

#include "common_types.h"

#ifndef CNES_OBJECT_COUNT
#define CNES_OBJECT_COUNT 32
#endif //OBJECT_COUNT

extern u8 cnes_object_type[CNES_OBJECT_COUNT];
extern coord cnes_object_x[CNES_OBJECT_COUNT];
extern coord cnes_object_y[CNES_OBJECT_COUNT];

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC draw_metasprite(u8 object_id);

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC draw_metatile(u8 metatile_id);

#endif //CNES_DRAWING_H