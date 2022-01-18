
#ifndef CNES_JOYPAD_H
#define CNES_JOYPAD_H

#include "common_types.h"

#define PAD_A       0x80
#define PAD_B       0x40
#define PAD_SELECT  0x20
#define PAD_START   0x10
#define PAD_UP      0x08
#define PAD_DOWN    0x04
#define PAD_LEFT    0x02
#define PAD_RIGHT   0x01

void __LIB_CALLSPEC update_joypad(void);

#ifdef __NES__
extern volatile u8 p1_previous;
extern volatile u8 p1_current;
extern volatile u8 p1_pressed;
extern volatile u8 p1_released;
#define player1_pressed(button)   ((u8)(button) & p1_pressed)
#define player1_current(button)   ((u8)(button) & p1_current)
#define player1_released(button)  ((u8)(button) & p1_released)
#ifndef CNES_DISABLE_JOYPAD_HELD
extern volatile u8 p1_held[8];
#define CNES_HELD_LOOKUP(button) (\
  ((button) == PAD_A)       ? 0 : \
  ((button) == PAD_B)       ? 1 : \
  ((button) == PAD_SELECT)  ? 2 : \
  ((button) == PAD_START)   ? 3 : \
  ((button) == PAD_UP)      ? 4 : \
  ((button) == PAD_DOWN)    ? 5 : \
  ((button) == PAD_LEFT)    ? 6 : \
  ((button) == PAD_RIGHT)   ? 7 : 0)

#define player1_held(button) \
  (p1_held[CNES_HELD_LOOKUP((u8)(button))])
#endif //CNES_DISABLE_JOYPAD_HELD

#ifndef CNES_DISABLE_JOYPAD_PLAYER2
extern volatile u8 p2_previous;
extern volatile u8 p2_current;
extern volatile u8 p2_pressed;
extern volatile u8 p2_released;
#define player2_pressed(button)   ((u8)(button) & p2_pressed)
#define player2_current(button)   ((u8)(button) & p2_current)
#define player2_released(button)  ((u8)(button) & p2_released)
#ifndef CNES_DISABLE_JOYPAD_HELD
extern volatile void* p2_held;
#define player2_held(button) \
  (*(((u8*)p2_held) + ((u8*)held_lookup_table + ((u8)(button)))))
#endif //CNES_DISABLE_JOYPAD_HELD
#endif //CNES_DISABLE_JOYPAD_PLAYER2

#else

bool __LIB_CALLSPEC player1_pressed(u8 buttons);
bool __LIB_CALLSPEC player1_current(u8 buttons);
bool __LIB_CALLSPEC player1_released(u8 buttons);
#ifndef CNES_DISABLE_JOYPAD_HELD
u8   __LIB_CALLSPEC player1_held(u8 button);
#endif //CNES_DISABLE_JOYPAD_HELD

#ifndef CNES_DISABLE_JOYPAD_PLAYER2
bool __LIB_CALLSPEC player2_pressed(u8 buttons);
bool __LIB_CALLSPEC player2_current(u8 buttons);
bool __LIB_CALLSPEC player2_released(u8 buttons);
#ifndef CNES_DISABLE_JOYPAD_HELD
u8   __LIB_CALLSPEC player2_held(u8 button);
#endif //CNES_DISABLE_JOYPAD_HELD
#endif //CNES_DISABLE_JOYPAD_PLAYER2

#endif //__NES__

#endif //CNES_JOYPAD_H
