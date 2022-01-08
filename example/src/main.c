
#include "cnes.h"

void callback_nmi() {
    
}

void gameloop() {
    while (1) {
        update_joypad();

        if (player1_pressed(PAD_A)) {
            update_joypad();
        }

        wait_for_frame_end();
    }
}

