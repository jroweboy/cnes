
#include "cnes.h"

void init_callback() {

}

void runframe() {

    update_joypad();

    if (player1_pressed(PAD_A)) {
        music_start(1);
    }
    if (player1_released(PAD_B)) {
        music_start(2);
    }
}

