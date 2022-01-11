
#ifndef CNES_AUDIO_H
#define CNES_AUDIO_H

#include "common_types.h"

#ifdef __NES__
extern u8 
#endif //__NES__

/**
 * @brief Starts playing music based on the track number provided.
 * The audio will continue to loop until either stop music is called
 * or start_music is called with a new track
 * 
 * @param song - Track ID for the audio to play. 
 */
void __LIB_CALLSPEC start_music(u8 song);

/**
 * @brief Pauses or unpauses the current music track
 */
void __LIB_CALLSPEC toggle_music();

/**
 * @brief Stops music playback.
 */
void __LIB_CALLSPEC stop_music();

/**
 * @brief Starts playing sfx based on the sfx number provided.
 * 
 * @param song - Track ID for the sfx audio to play. 
 */
void __LIB_CALLSPEC sfx_play(u8 sfx);

#endif //CNES_AUDIO_H
