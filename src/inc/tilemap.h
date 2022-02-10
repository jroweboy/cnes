#ifndef CNES_TILEMAP_H
#define CNES_TILEMAP_H


#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"


#ifdef __NES__

#else

#endif

/**
 * Turns Rendering Off;
 * Look up the internal coords for the entrance
 * Decompress and write the needed strips to screen 0
 * 
 * @param map_id 
 */
void load_tilemap(u8 map_id, u8 entrance_id);

#ifdef __cplusplus
}
#endif

#endif //CNES_TILEMAP_H