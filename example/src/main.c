
#include "cnes.h"
#include "cnes_audio_gen.h"

void init_callback() {}

void runframe() {
    update_joypad();

    if (player1_held(PAD_A) == 60) {
        music_start(SONG_MEGALOVANIA);
    }
    if (player1_released(PAD_B)) {
        music_start(SONG_METAL_CRUSHER);
    }
}
