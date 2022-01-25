
#pragma once

#include <SDL2/SDL.h>
#include <bgfx/bgfx.h>

namespace cnes {

class Renderer {

public:

  Renderer();

  

private:
    bgfx::ProgramHandle program = BGFX_INVALID_HANDLE;
    bgfx::ShaderHandle vs = BGFX_INVALID_HANDLE;
    bgfx::ShaderHandle fs = BGFX_INVALID_HANDLE;
    bgfx::UniformHandle scroll = BGFX_INVALID_HANDLE;
    bgfx::TextureHandle palette = BGFX_INVALID_HANDLE;

    int width = 0;
    int height = 0;

    bool quit = false;
};


}