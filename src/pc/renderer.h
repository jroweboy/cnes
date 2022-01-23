
#pragma once

#include <SDL2/SDL.h>
#include <bgfx/bgfx.h>

namespace cnes {

class Renderer {

public:

  Renderer();

private:
    SDL_Window* window = nullptr;
    bgfx::ProgramHandle program = BGFX_INVALID_HANDLE;
    bgfx::VertexBufferHandle vbh = BGFX_INVALID_HANDLE;
    bgfx::IndexBufferHandle ibh = BGFX_INVALID_HANDLE;

    int width = 0;
    int height = 0;

    bool quit = false;
};


}