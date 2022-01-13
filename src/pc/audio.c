
#include "cnes.h"
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>

static Mix_Music** songs;

int audio_init() {
  int flags=MIX_INIT_OGG;
  int initted=Mix_Init(flags);
  if ((initted & flags) != flags) {
    printf("Mix_Init: Failed to init required ogg support!\n");
    printf("Mix_Init: %s\n", Mix_GetError());
    return EXIT_FAILURE;
  }


  if (Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 4096) == -1) {
    printf("SDL2_mixer could not be initialized!\n"
            "SDL_Error: %s\n", SDL_GetError());
    return EXIT_FAILURE;
  }

  // Count the number of songs we have
  int i = 0;
  while (song_list[i++] != NULL);
  songs = malloc(sizeof(Mix_Music*) * i);

  // Now initialize the songs with the provided songs
  i = 0;
  while (song_list[i] != NULL) {
    songs[i] = Mix_LoadMUS(song_list[i]);
    i++;
  }

  return 0;
}

void __LIB_CALLSPEC music_start(u8 song) {
  if(Mix_PlayMusic(songs[song], -1) == -1) {
    printf(".OGG sound could not be played!\n"
            "SDL_Error: %s\n", SDL_GetError());
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