
#include "cnes.h"
#include "cnes_internal.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>

static Mix_Music** songs;

int audio_init() {
  int flags=MIX_INIT_OGG;
  int initted=Mix_Init(flags);
  if ((initted & flags) != flags) {
    SDL_LogError(LOG_AUDIO, "Mix_Init: Failed to init required ogg support! %s\n", Mix_GetError());
    return CNES_FAILURE;
  }


  if (Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 4096) == -1) {
    SDL_LogError(LOG_AUDIO, "SDL2_mixer could not be initialized!\n"
            "SDL_Error: %s\n", SDL_GetError());
    return CNES_FAILURE;
  }

  songs = malloc(cnes_song_list_len * sizeof(Mix_Music*));
  if (!songs) {
    SDL_LogError(LOG_AUDIO, "Umm malloc?\n");
    return CNES_FAILURE;
  }

  // Now initialize the songs with the provided songs
  for (int i=0; i<cnes_song_list_len; i++) {
    SDL_RWops* ops = SDL_RWFromConstMem((void*)cnes_song_list[i], cnes_song_len[i]);
    songs[i] = Mix_LoadMUS_RW(ops, 1);
  }

  return CNES_SUCCESS;
}

void __LIB_CALLSPEC music_start(u8 song) {
  if(Mix_PlayMusic(songs[song], -1) == -1) {
    SDL_LogError(LOG_AUDIO, ".OGG sound could not be played!\n SDL_Error: %s\n", SDL_GetError());
  }
}

void __LIB_CALLSPEC music_pause() {
  if (Mix_Paused(-1))
    Mix_Resume(-1);
  else
    Mix_Pause(-1);
}

void __LIB_CALLSPEC music_stop() {
  Mix_HaltMusic();
}

void __LIB_CALLSPEC sfx_play(u8 sfx) {

}