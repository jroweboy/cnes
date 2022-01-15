
#ifndef CNES_AUDIO_H
#define CNES_AUDIO_H

#include "common_types.h"

#ifdef __NES__
extern volatile u8 music_queue;
extern volatile u8 music_playing;
/**
 * @brief Starts playing music based on the track number provided.
 * The audio will continue to loop until either stop music is called
 * or start_music is called with a new track
 * 
 * @param song - Track ID for the audio to play.
 */
#define music_start(song) (music_queue = (song))

/**
 * @brief Pauses or unpauses the current music track
 */
#define CNES_MUSIC_PAUSE ((u8)253)
#define music_pause() (music_queue = (CNES_MUSIC_PAUSE))

/**
 * @brief Stops music playback.
 */
#define CNES_MUSIC_STOP ((u8)254)
#define music_stop() (music_queue = (CNES_MUSIC_STOP))


/**
 * @brief Starts playing sfx based on the sfx number provided.
 * 
 * @param song - Track ID for the sfx audio to play. 
 */
extern volatile u8 sfx_queue;
void __LIB_CALLSPEC sfx_play(u8 sfx);

#else
extern const unsigned char* cnes_song_list[];
extern const unsigned int cnes_song_len[];
extern const unsigned int cnes_songs_len;

void __LIB_CALLSPEC music_start(u8 song);

void __LIB_CALLSPEC music_pause();

void __LIB_CALLSPEC music_stop();

void __LIB_CALLSPEC sfx_play(u8 sfx);

#endif //__NES__


#endif //CNES_AUDIO_H
