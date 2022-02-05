
#include "cnes.h"
#include "cnes_audio_gen.h"

FAST_FUNC(game_state);

void title_screen();
void main_menu();
void gameplay();
void gameover();

void init_callback() {
    set_bg_color(DARK + BLUE);
    update_palette();
    FAST_FUNC_INIT(game_state);
    FAST_FUNC_SET(game_state, title_screen);
}

void runframe() {
    update_joypad();
    FAST_CALL(game_state);
}


void title_screen() {

    load_rle();

}

void main_menu() {

}

void gameplay() {

}

void gameover() {

}