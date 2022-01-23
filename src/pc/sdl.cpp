
#include "cnes.h"
#include "core.h"

#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>
#include <bgfx/bgfx.h>
#include <bgfx/platform.h>
#include <bx/spscqueue.h>
#include <bx/thread.h>

#include <functional>
#include <memory>

static const u8 FPS = 60;
static bool close = false;

bx::AllocatorI* getDefaultAllocator() {
  static bx::DefaultAllocator s_allocator;
  return &s_allocator;
}

static void* sdlNativeWindowHandle(SDL_Window* _window)
{
  SDL_SysWMinfo wmi;
  SDL_VERSION(&wmi.version);
  if (!SDL_GetWindowWMInfo(_window, &wmi) )
  {
    return NULL;
  }

#	if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
#		if ENTRY_CONFIG_USE_WAYLAND
  wl_egl_window *win_impl = (wl_egl_window*)SDL_GetWindowData(_window, "wl_egl_window");
  if(!win_impl)
  {
    int width, height;
    SDL_GetWindowSize(_window, &width, &height);
    struct wl_surface* surface = wmi.info.wl.surface;
    if(!surface)
      return nullptr;
    win_impl = wl_egl_window_create(surface, width, height);
    SDL_SetWindowData(_window, "wl_egl_window", win_impl);
  }
  return (void*)(uintptr_t)win_impl;
#		else
  return (void*)wmi.info.x11.window;
#		endif
#	elif BX_PLATFORM_OSX || BX_PLATFORM_IOS
  return wmi.info.cocoa.window;
#	elif BX_PLATFORM_WINDOWS
  return wmi.info.win.window;
#   elif BX_PLATFORM_ANDROID
  return wmi.info.android.window;
#	endif // BX_PLATFORM_
}

inline bool sdlSetWindow(SDL_Window* _window)
{
  SDL_SysWMinfo wmi;
  SDL_VERSION(&wmi.version);
  if (!SDL_GetWindowWMInfo(_window, &wmi) )
  {
    return false;
  }

  bgfx::PlatformData pd;
#	if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
#		if ENTRY_CONFIG_USE_WAYLAND
  pd.ndt          = wmi.info.wl.display;
#		else
  pd.ndt          = wmi.info.x11.display;
#		endif
#	else
  pd.ndt          = NULL;
#	endif // BX_PLATFORM_
  pd.nwh          = sdlNativeWindowHandle(_window);

  pd.context      = NULL;
  pd.backBuffer   = NULL;
  pd.backBufferDS = NULL;
  bgfx::setPlatformData(pd);

  return true;
}

static void sdlDestroyWindow(SDL_Window* _window)
{
  if(!_window)
    return;
#	if BX_PLATFORM_LINUX || BX_PLATFORM_BSD
#		if ENTRY_CONFIG_USE_WAYLAND
  wl_egl_window *win_impl = (wl_egl_window*)SDL_GetWindowData(_window, "wl_egl_window");
  if(win_impl)
  {
    SDL_SetWindowData(_window, "wl_egl_window", nullptr);
    wl_egl_window_destroy(win_impl);
  }
#		endif
#	endif
  SDL_DestroyWindow(_window);
}

int main(int argc, char *argv[]) {
  if (SDL_Init(SDL_INIT_TIMER|SDL_INIT_EVENTS) != 0) {
    SDL_LogError(LOG_DRIVER, "Unable to initialize SDL: %s", SDL_GetError());
    return 1;
  }

  SDL_Window* window = SDL_CreateWindow("CNES",
    SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
    256, 240, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);

  sdlSetWindow(window);

  bx::Thread m_thread;

  m_thread.init(cnes::app, nullptr);

  // frequency in Hz to period in ms
  u64 tickInteval = 1000 / FPS;
  u64 lastUpdateTime = 0;
  u64 deltaTime = 0;
  u64 currentTime;
  s64 timeToSleep;

  // main loop
  while (!close) {
    
    currentTime = SDL_GetTicks();
    deltaTime = currentTime - lastUpdateTime;
    timeToSleep = tickInteval - deltaTime;
    if (timeToSleep > 0) {
      SDL_Delay(timeToSleep);
    }
    
    bgfx::renderFrame();
    lastUpdateTime = currentTime;
  }

  while (bgfx::RenderFrame::NoContext != bgfx::renderFrame() ) {};
  m_thread.shutdown();

  sdlDestroyWindow(window);
  SDL_Quit();

  return CNES_SUCCESS;
}
