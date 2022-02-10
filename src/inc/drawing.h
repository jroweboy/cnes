#ifndef CNES_DRAWING_H
#define CNES_DRAWING_H


#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"
#include "cnes_macros.h"

extern u8* cnes_object_metasprite;
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


#ifdef __NES__
  typedef u8 ColorSize;
#else
  typedef u32 ColorSize;
#endif // __NES__

extern ColorSize palette[32];
extern volatile u8 vblank_tasks;
ZP(vblank_tasks);

#define set_bg_color(color_val) do { palette[0] = color_val; } while (0);

#define set_tile_color(index, color_ptr) do { \
    palette[(index * 4) + 1] = color_ptr[index + 0]; \
    palette[(index * 4) + 2] = color_ptr[index + 1]; \
    palette[(index * 4) + 3] = color_ptr[index + 2]; \
  } while (0);

#define set_sprite_color(index, color_ptr) do { \
    palette[(index * 4) + 16 + 1] = color_ptr[index + 0]; \
    palette[(index * 4) + 16 + 2] = color_ptr[index + 1]; \
    palette[(index * 4) + 16 + 3] = color_ptr[index + 2]; \
  } while (0);

#define UPDATE_SPRITES (1 << 7)
#define UPDATE_PALETTE (1 << 6)
#define UPDATE_BACKGROUND (1 << 5)
#define update_palette() do { vblank_tasks |= UPDATE_PALETTE; } while (0);


/**
 * @brief Configures the mirroring mode for the screens.
 * 
 */

void set_horizontal_mirroring();
void set_vertical_mirroring();

/**
 * @brief Disables rendering for the next frame. Allows you to access the PPU RAM without
 * any rendering glitches, but the screen will be black during this time.
 * 
 */
void disable_rendering();
void enable_rendering();

/**
 * @brief Draws a single tile to the an entire nametable
 * 
 * @param tile 
 */
void clear_screen(u8 screen, u8 tile);


#ifdef __cplusplus
}
#endif

#endif //CNES_DRAWING_H