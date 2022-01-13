
#ifndef CNES_AUDIO_H
#define CNES_AUDIO_H

#include "common_types.h"

/**
 * @brief Starts playing music based on the track number provided.
 * The audio will continue to loop until either stop music is called
 * or start_music is called with a new track
 * 
 * @param song - Track ID for the audio to play.
 * 
 * Usage:
 * music_queue = CNES_MUSIC_*;
 * // where the * is an index into the generated music list
 */
extern volatile u8 music_queue;
extern volatile u8 music_playing;

/**
 * @brief Pauses or unpauses the current music track
 * 
 * Usage:
 * music_queue = CNES_MUSIC_PAUSE;
 */
#define CNES_MUSIC_PAUSE ((u8)253)

/**
 * @brief Stops music playback.
 * 
 * Usage:
 * music_queue = CNES_MUSIC_STOP;
 */
#define CNES_MUSIC_STOP ((u8)254)


/**
 * @brief Starts playing sfx based on the sfx number provided.
 * 
 * @param song - Track ID for the sfx audio to play. 
 */
extern volatile u8 sfx_queue;
void __LIB_CALLSPEC sfx_play(u8 sfx);

#endif //CNES_AUDIO_H
