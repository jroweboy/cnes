#ifndef CNES_DEFAULTS_H
#define CNES_DEFAULTS_H

#ifndef CNES_JOYPAD

/**
 * A simple NES safe joypad interface that has a few helper functions
 * to track the state of the joypad over time
 */
#define CNES_JOYPAD 1

/**
 * If you have a single player game, it saves cycles and RAM to
 * skip processing player2 input
 */
#define CNES_JOYPAD_PLAYER2

/**
 * Held checks uses an additional 8 bytes of RAM for each player 
 * so it might not be useful if you don't need to know how long
 * a button has been held for
 */
#define CNES_JOYPAD_HELD
#endif

#ifndef CNES_DRAWING
// enable drawing routine
#define CNES_DRAWING 1
#endif

#ifndef CNES_ENGINE
// enable drawing routine
#define CNES_ENGINE 1
#endif

#ifndef CNES_AUDIO
// enable audio engine
#define CNES_AUDIO 1
#endif

#endif //CNES_DEFAULTS_H