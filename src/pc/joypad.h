#pragma once

#include "common_types.h"
#include "cnes.h"

#include <SDL2/SDL.h>
#include <SDL2/SDL_gamecontroller.h>

namespace cnes {

class Joypad {

public:

  Joypad();

  void update();

  void event(SDL_Event& event);

  bool player1_pressed(u8 buttons) {
    return player1.pressed & buttons;
  }

  bool player1_current(u8 buttons) {
    return player1.current & buttons;
  }

  bool player1_released(u8 buttons) {
    return player1.released & buttons;
  }

  u8 player1_held(u8 button) {
    return player1.held[pad_to_held(button)];
  }

  bool player2_pressed(u8 buttons) {
    return player2.pressed & buttons;
  }

  bool player2_current(u8 buttons) {
    return player2.current & buttons;
  }

  bool player2_released(u8 buttons) {
    return player2.released & buttons;
  }

  u8 player2_held(u8 button) {
    return player2.held[pad_to_held(button)];
  }

private:
struct State {
  u8 previous;
  u8 current;
  u8 pressed;
  u8 released;
  u8 held[8];
};
  State player1 = {};
  State player2 = {};
  SDL_GameController *controller = nullptr;

  static inline u8 pad_to_held(u8 pad) {
    switch (pad) {
      case PAD_A:
      default:
        return 7;
      case PAD_B:
        return 6;
      case PAD_SELECT:
        return 5;
      case PAD_START:
        return 4;
      case PAD_UP:
        return 3;
      case PAD_DOWN:
        return 2;
      case PAD_LEFT:
        return 1;
      case PAD_RIGHT:
        return 0;
    }
  }

};

}