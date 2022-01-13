
#include "cnes.h"


void init_callback() {

}

void runframe() {


    update_joypad();

    if (player1_pressed(PAD_A)) {
        music_queue = 1;
    }
    if (player1_released(PAD_B)) {
        music_queue = 2;
    }
}

