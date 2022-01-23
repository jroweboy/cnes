
#include "cnes.h"
#include "core.h"
#include "joypad.h"

#include <SDL2/SDL.h>

namespace cnes {

Joypad::Joypad() {
  
  int ret = SDL_Init(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER);
  if (ret < 0) {
    SDL_LogError(LOG_JOYPAD, "SDL could not initialize! SDL Error: %s\n", SDL_GetError());
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
}

void Joypad::update() {
  player1.pressed = player1.current & ~player1.previous;
  player1.released = ~player1.current & player1.previous;
  player2.pressed = player2.current & !player2.previous;
  player2.released = ~player2.current & player2.previous;

  for (int i=0; i<8; ++i) {
    u8 button = 1<<i;
    if (player1_current(button)) {
      ++player1.held[i];
    } else if (player1_released(button)) {
      player1.held[i] = 0;
    }
    if (player2_current(button)) {
      ++player2.held[i];
    } else if (player2_released(button)) {
      player2.held[i] = 0;
    }
  }

  player1.previous = player1.current;
  player2.previous = player2.current;
}


static u8 bit_set(u8 value, u8 bitmask) {
  return value | bitmask;
}

static u8 bit_clear(u8 value, u8 bitmask) {
  return value & ~bitmask;
}

void Joypad::event(SDL_Event& event) {
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


}
