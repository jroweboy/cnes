
#include "cnes.h"
#include <SDL.h>

void update_joypad() {
    // Do nothing. Joypad updates are driven by SDL event loop
}

bool __LIB_CALLSPEC player1_pressed(u8 buttons) {
    return false;
}

bool __LIB_CALLSPEC player1_held(u8 buttons) {
    return false;
}

bool __LIB_CALLSPEC player1_released(u8 buttons) {
    return false;
}

