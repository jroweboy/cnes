
#include "cnes.h"
#include "cnes_internal.h"
#include <SDL2/SDL.h>

static SDL_Window* win;
static SDL_Renderer* ren;

int renderer_init() {
  
  if (SDL_Init(SDL_INIT_VIDEO) != 0) {
    SDL_LogError(LOG_RENDER, "SDL_Init Error: %s\n", SDL_GetError());
    return CNES_FAILURE;
  }

  SDL_Window* win = SDL_CreateWindow("CNES", 100, 100, 256, 240, SDL_WINDOW_SHOWN);
  if (win == NULL) {
    SDL_LogError(LOG_RENDER, "SDL_CreateWindow Error: %s\n", SDL_GetError());
    return CNES_FAILURE;
  }

  SDL_Renderer* ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  if (ren == NULL) {
    SDL_LogError(LOG_RENDER, "SDL_CreateRenderer Error: %s\n", SDL_GetError());
    SDL_DestroyWindow(win);
    SDL_Quit();
    return CNES_FAILURE;
  }
  
  SDL_SetRenderDrawColor(ren, 0, 0, 0, SDL_ALPHA_OPAQUE);

  return CNES_SUCCESS;
}

int renderer_render() {
  // clears the screen
  SDL_RenderClear(ren);

  // triggers the double buffers
  // for multiple rendering
  SDL_RenderPresent(ren);

  return CNES_SUCCESS;
}

int renderer_quit() {
  SDL_DestroyRenderer(ren);
  SDL_DestroyWindow(win);
  return CNES_SUCCESS;
}