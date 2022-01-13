
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
#define player1_pressed(button) ((u8)(button) & player1_pres)
#define player1_held(button) ((u8)(button) & player1_curr)
#define player1_released(button) ((u8)(button) & player1_rele)
#else
bool __LIB_CALLSPEC player1_pressed(u8 buttons);
bool __LIB_CALLSPEC player1_held(u8 buttons);
bool __LIB_CALLSPEC player1_released(u8 buttons);
#endif //__NES__

#ifdef CNES_JOYPAD_PLAYER2

#ifdef __NES__
extern volatile u8 player2_prev;
extern volatile u8 player2_curr;
extern volatile u8 player2_pres;
extern volatile u8 player2_rele;
#define player2_pressed(button) ((u8)(button) & player2_pres)
#define player2_held(button) ((u8)(button) & player2_curr)
#define player2_released(button) ((u8)(button) & player2_rele)
#else
bool __LIB_CALLSPEC player2_pressed(u8 button);
bool __LIB_CALLSPEC player2_held(u8 button);
bool __LIB_CALLSPEC player2_released(u8 button);
#endif //__NES__

#endif //CNES_JOYPAD_PLAYER2

#endif //CNES_JOYPAD_H
