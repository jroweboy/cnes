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

void set_scroll_off();
void set_scroll_horizontal();
void set_scroll_vertical();
void set_scroll_omni();

void disable_rendering();
void enable_rendering();
void clear_screen();

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC draw_metasprite(u8 object_slot);

/**
 * @brief 
 * 
 * @param metatile_id 
 */
void __LIB_CALLSPEC load_metatile(u8 metatile_id);

/**
 * @brief 
 * 
 */
void __LIB_CALLSPEC place_metatile(u8 metatile_id, u8 x, u8 y);


#ifdef __cplusplus
}
#endif

#endif //CNES_DRAWING_H