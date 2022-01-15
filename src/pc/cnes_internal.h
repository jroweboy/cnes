
#ifndef _INTERNAL_H
#define _INTERNAL_H

#include <SDL2/SDL.h>

// Logging defines

#define LOG_DRIVER 0
#define LOG_AUDIO 1
#define LOG_RENDER 2
#define LOG_JOYPAD 3

// Init functions

int renderer_init();
int joypad_init();
int audio_init();

// joypad 

void joypad_event(SDL_Event event);

// renderer

int renderer_render();

// quit functions
int renderer_quit();

#endif //_INTERNAL_H
