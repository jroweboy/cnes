
#ifndef CNES_H
#define CNES_H

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

#include "common_types.h"

/**
 * @brief Engine provides callbacks for NMI and IRQs and runs the main application loop.
 */
#ifndef CNES_DISABLE_ENGINE
#include "engine.h"
#endif //CNES_DISABLE_ENGINE

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


#ifdef __NES__

/**
 * @brief Define temporary register variables that can be used to pass data between ASM
 * and C functions. These can be used safely from the main code, but should be considered
 * temp variables.
 */
extern u8 R0;
extern u8 R1;
extern u8 R2;
extern u8 R3;
extern u8 R4;
extern u8 R5;
extern u8 R6;
extern u8 R7;
extern u8 R8;
extern u8 R9;
extern u8 R10;
extern u8 R11;
extern u8 R12;
extern u8 R13;
extern u8 R14;
extern u8 R15;

#pragma zpsym ("R0");
#pragma zpsym ("R1");
#pragma zpsym ("R2");
#pragma zpsym ("R3");
#pragma zpsym ("R4");
#pragma zpsym ("R5");
#pragma zpsym ("R6");
#pragma zpsym ("R7");
#pragma zpsym ("R8");
#pragma zpsym ("R9");
#pragma zpsym ("R10");
#pragma zpsym ("R11");
#pragma zpsym ("R12");
#pragma zpsym ("R13");
#pragma zpsym ("R14");
#pragma zpsym ("R15");
#endif // __NES__


#ifdef __cplusplus
}
#endif //__cplusplus

#endif // CNES_H
