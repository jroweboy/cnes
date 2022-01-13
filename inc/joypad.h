
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
extern volatile u8 player1_prev;
extern volatile u8 player1_curr;
extern volatile u8 player1_pres;
extern volatile u8 player1_rele;
#define player1_pressed(button)\
  (__A__ = (button),\
  asm("and %v", player1_pres),\
  __A__)
#define player1_held(button)\
  (__A__ = (button),\
  asm("and %v", player1_curr),\
  __A__)
#define player1_released(button)\
  (__A__ = (button),\
  asm("and %v", player1_rele),\
  __A__)
#else
bool __LIB_CALLSPEC player1_pressed(u8 buttons);
bool __LIB_CALLSPEC player1_held(u8 buttons);
bool __LIB_CALLSPEC player1_released(u8 buttons);
#endif //__NES__

#ifdef CNES_JOYPAD_PLAYER2

bool __LIB_CALLSPEC player2_pressed(u8 button);
bool __LIB_CALLSPEC player2_held(u8 button);
bool __LIB_CALLSPEC player2_released(u8 button);

#endif //CNES_JOYPAD_PLAYER2

#endif //CNES_JOYPAD_H
