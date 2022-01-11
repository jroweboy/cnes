
#ifndef CNES_H
#define CNES_H

#include "common_types.h"
#include "cnes_defaults.h"

#if CNES_JOYPAD
#include "joypad.h"
#endif

/// Provides high level drawing functionality
#if CNES_DRAWING
#include "drawing.h"
#endif

/// Engine provides callbacks for NMI and IRQs.
#if CNES_ENGINE
#include "engine.h"
#endif

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

#endif // CNES_H
