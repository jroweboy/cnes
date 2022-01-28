
#include "cnes.h"
#include "core.h"
#include "renderer.h"

#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <SDL2/SDL.h>

#include <functional>
#include <memory>


namespace cnes {

Renderer::Renderer() {

  bgfx::Init init;
  init.type     = bgfx::RendererType::Count;
  init.resolution.width  = 256;
  init.resolution.height = 240;
  init.resolution.reset  = BGFX_RESET_VSYNC;
  bgfx::init(init);

  // Enable debug text.
  bgfx::setDebug(BGFX_DEBUG_TEXT);

  // Set view 0 clear state.
  bgfx::setViewClear(0, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH, 0x000000ff, 1.0f, 0);
}


}
