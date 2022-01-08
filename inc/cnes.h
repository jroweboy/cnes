
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
 * start drawing the background to the screen.
 */
extern void init_callback();

/**
 * @brief Called after initialization happens, this is the main loop!
 * This will be expected to never return on NES.
 * On PC after this returns, the game will terminate.
 */
extern void gameloop();

#endif // CNES_H
