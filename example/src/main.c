
#include "cnes.h"


void init_callback() {

}

void runframe() {
    if (player1_pressed(PAD_A)) {
        update_joypad();
    }
}
