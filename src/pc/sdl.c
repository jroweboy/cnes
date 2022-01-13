
#include "cnes.h"
#include "internal.h"
#include <SDL2/SDL.h>

int main(int argc, char *argv[]) {

  renderer_init();
  audio_init();
  joypad_init();

  bool close = false;
  // animation loop
  while (!close) {
    SDL_Event event;

    // Events mangement
    while (SDL_PollEvent(&event)) {
      switch (event.type) {

      case SDL_QUIT:
        // handling of close button
        close = true;
        break;

      case SDL_KEYDOWN:
      case SDL_KEYUP:
        joypad_event(event);
      }
    }
    runframe();
    renderer_render();
    // calculates to 60 fps
    SDL_Delay(1000 / 60);
  } 

  renderer_quit();
  SDL_Quit();

  return EXIT_SUCCESS;
}

void wait_for_frame_end() {
  return;
}
