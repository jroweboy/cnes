
#include "cnes.h"
#include "cnes_internal.h"
#include <SDL2/SDL.h>


static const u8 FPS = 60;

static bool close = false;

static void update(uint32_t deltaTime);

int main(int argc, char *argv[]) {
  SDL_LogInfo(LOG_DRIVER, "hello");

  if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_EVENTS) != 0) {
    SDL_LogError(LOG_DRIVER, "Unable to initialize SDL: %s", SDL_GetError());
    return 1;
  }
  renderer_init();
  audio_init();
  joypad_init();

  // frequency in Hz to period in ms
  u64 tickInteval = 1000 / FPS;
  u64 lastUpdateTime = 0;
  u64 deltaTime = 0;
  u64 currentTime;
  s64 timeToSleep;

  // main loop
  while (!close) {
    
    currentTime = SDL_GetTicks64();
    deltaTime = currentTime - lastUpdateTime;
    timeToSleep = tickInteval - deltaTime;
    if (timeToSleep > 0) {
      SDL_Delay(timeToSleep);
    }
    
    update(deltaTime); // game logic
    lastUpdateTime = currentTime;
  } 

  renderer_quit();
  SDL_Quit();

  return CNES_SUCCESS;
}

static void update(uint32_t deltaTime) {
  static SDL_Event event;

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
}
