
#pragma once

#include "common_types.h"

#include <SDL2/SDL_mixer.h>

#include <vector>

namespace cnes {

class Audio {
public:

  Audio();

  void music_start(u8 song);

  void music_pause();

  void music_stop();

  void sfx_play(u8 sfx);

private:
  std::vector<Mix_Music*> songs;
};

}
