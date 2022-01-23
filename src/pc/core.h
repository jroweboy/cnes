
#pragma once
  
#define CNES_FAILURE -1
#define CNES_SUCCESS 0

// Logging defines

#define LOG_DRIVER 0
#define LOG_AUDIO 1
#define LOG_RENDER 2
#define LOG_JOYPAD 3

#include "common_types.h"

#include <bx/spscqueue.h>
#include <bx/thread.h>
#include <SDL2/SDL.h>

#include <memory>

namespace cnes {

class Core;

struct AppData {
  bx::SpScUnboundedQueueT<SDL_Event> events;
};

s32 app(bx::Thread* _thread, void* _userData);

}

