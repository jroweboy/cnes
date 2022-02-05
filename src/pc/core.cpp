
#include "audio.h"
#include "core.h"
#include "joypad.h"
#include "renderer.h"

#include <SDL2/SDL.h>

#include <memory>


static std::unique_ptr<cnes::Core> core;

namespace cnes {


class Core {
public:

  Core(AppData* _appdata) : appdata(_appdata), joypad{}, renderer{} {} 

  s32 run() {
    while (true) {

    }
    return 0;
  }

  AppData* appdata;
  Audio audio;
  Joypad joypad;
  Renderer renderer;
};

int32_t app(bx::Thread* _thread, void* _userData)
{
  BX_UNUSED(_thread);
  BX_UNUSED(_userData);
  
  core = std::move(std::unique_ptr<Core>(new Core((AppData*)_userData)));

  int32_t result = core->run();

  SDL_Event event;
  SDL_QuitEvent& qev = event.quit;
  qev.type = SDL_QUIT;
  SDL_PushEvent(&event);
  return result;
}

}

extern "C" {

// JOYPAD 
void __LIB_CALLSPEC update_joypad() {
  core->joypad.update();
}

bool __LIB_CALLSPEC player1_pressed(u8 buttons) {
  return core->joypad.player1_pressed(buttons);
}

bool __LIB_CALLSPEC player1_current(u8 buttons) {
  return core->joypad.player1_current(buttons);
}

bool __LIB_CALLSPEC player1_released(u8 buttons) {
  return core->joypad.player1_released(buttons);
}

u8 __LIB_CALLSPEC player1_held(u8 button) {
  return core->joypad.player1_held(button);
}

bool __LIB_CALLSPEC player2_pressed(u8 buttons) {
  return core->joypad.player2_pressed(buttons);
}

bool __LIB_CALLSPEC player2_current(u8 buttons) {
  return core->joypad.player2_current(buttons);
}

bool __LIB_CALLSPEC player2_released(u8 buttons) {
  return core->joypad.player2_released(buttons);
}

u8 __LIB_CALLSPEC player2_held(u8 button) {
  return core->joypad.player2_held(button);
}

// AUDIO
void __LIB_CALLSPEC music_start(u8 song) {
  core->audio.music_start(song);
}

void __LIB_CALLSPEC music_pause() {
  core->audio.music_pause();
}

void __LIB_CALLSPEC music_stop() {
  core->audio.music_stop();
}

void __LIB_CALLSPEC sfx_play(u8 sfx) {
  core->audio.sfx_play(sfx);
}

// DRAWING

}
