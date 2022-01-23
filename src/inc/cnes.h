
#ifndef CNES_H
#define CNES_H

#ifdef __cplusplus
extern "C" {
#endif

#include "common_types.h"

/**
 * @brief Engine provides callbacks for NMI and IRQs and runs the main application loop.
 */
#ifndef CNES_DISABLE_ENGINE
#include "engine.h"
#endif //CNES_ENGINE

/**
 * @brief Joypad sets up RAM for pooling joypads and drives updating joypad state
 */
#ifndef CNES_DISABLE_JOYPAD
#include "joypad.h"
#endif //CNES_DISABLE_JOYPAD

/// Provides high level drawing functionality
#ifndef CNES_DISABLE_DRAWING
#include "drawing.h"
#endif //CNES_DISABLE_DRAWING

/// Engine provides audio through famistudio.
#ifndef CNES_DISABLE_AUDIO
#include "audio.h"
#endif //CNES_DISABLE_AUDIO

/// Driver code (handles game initialization)

/**
 * @brief User provided initialization function. Called by the driver code
 * after the basic setup has happened. This is a good time for the user to
 * start drawing the first background to the screen.
 */
extern void init_callback();

/**
 * @brief User provided callback, expected to run one frame of game logic.
 * The user can check the `late_frame` variable provided to see if the NMI
 * was fired before this function finished executing. In the case that the NMI
 * fires while this function is still running, then `late_frame` will be set before
 * runframe is called again.
 * 
 * On PC this function is expected to run to completion each frame.
 */
extern void runframe();

/**
 * @brief Set to true when an NMI occurs during `runframe`. Can be checked if you
 * need to have branching logic to prevent slowdowns
 */
extern bool late_frame;

#ifdef __cplusplus
}
#endif

#endif // CNES_H
