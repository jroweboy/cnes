
#include "cnes.h"
#include "internal.h"
#include <SDL2/SDL.h>

struct Joypad {
  u8 previous;
  u8 current;
  u8 pressed;
  u8 released;
};

static struct Joypad player1;
static struct Joypad player2;
static SDL_GameController *controller = NULL;

int joypad_init() {
  memset(&player1, 0, sizeof(player1));
  memset(&player2, 0, sizeof(player2));
  
  int ret = SDL_Init(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER);
  if (ret < 0)
  {
    SDL_LogError(LOG_JOYPAD, "SDL could not initialize! SDL Error: %s\n", SDL_GetError());
    return ret; 
  }

  for (int i = 0; i < SDL_NumJoysticks(); ++i) {
    if (SDL_IsGameController(i)) {
      controller = SDL_GameControllerOpen(i);
      if (controller) {
        break;
      } else {
        SDL_LogError(LOG_JOYPAD, "Could not open gamecontroller %i: %s\n", i, SDL_GetError());
      }
    }
  }

  return 0;
}

u8 bit_set(u8 value, u8 bitmask) {
  return value | bitmask;
}

u8 bit_clear(u8 value, u8 bitmask) {
  return value & ~bitmask;
}

void joypad_event(SDL_Event event) {
  u8 (*op)(u8, u8);
  
  if (event.key.type == SDL_KEYUP) {
    op = bit_clear;
  } else if (event.key.type == SDL_KEYDOWN) {
    op = bit_set;
  } else {
    return;
  }

  switch (event.key.keysym.sym) {
    case SDLK_z:
      player1.current = op(player1.current, PAD_B);
      break;
    case SDLK_x:
      player1.current = op(player1.current, PAD_A);
      break;
    case SDLK_LEFT:
      player1.current = op(player1.current, PAD_LEFT); break;
    case SDLK_RIGHT:
      player1.current = op(player1.current, PAD_RIGHT); break;
    case SDLK_UP:
      player1.current = op(player1.current, PAD_UP); break;
    case SDLK_DOWN:
      player1.current = op(player1.current, PAD_DOWN); break;
  }
}

// ====== Public functions ======

void __LIB_CALLSPEC update_joypad() {
  player1.pressed = (player1.previous ^ player1.current) & player1.current;
  player1.released = (player1.previous ^ player1.current) & player1.previous;

  player2.pressed = (player2.previous ^ player2.current) & player2.current;
  player2.released = (player2.previous ^ player2.current) & player2.previous;

  player1.previous = player1.current;
  player2.previous = player2.current;
}

bool __LIB_CALLSPEC player1_pressed(u8 buttons) {
  return player1.pressed & buttons;
}

bool __LIB_CALLSPEC player1_held(u8 buttons) {
  return player1.current & buttons;
}

bool __LIB_CALLSPEC player1_released(u8 buttons) {
  return player1.released & buttons;
}

