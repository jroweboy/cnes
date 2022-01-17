# CNES

**Framework for building NES games that run natively on PC**

![NES](https://github.com/jroweboy/cnes/actions/workflows/build_nes.yml/badge.svg)
![Linux](https://github.com/jroweboy/cnes/actions/workflows/build_linux.yml/badge.svg)
![Windows (MSVC)](https://github.com/jroweboy/cnes/actions/workflows/build_win_msvc.yml/badge.svg)

## What is CNES?

CNES is a framework that focuses on a cross platform solution for making
NES games that conviently compiles and runs on PC as well.
The goal is to have a truly cross platform solution, where the same assets
and game code can be shared across all platforms.
By building with the CNES interface, your game will run natively on the NES
through the optimized NES implementation, and also natively on PC with
SDL2 (and maybe other platforms in the future!)

## How does CNES compare to other C based NES libraries?

Right now, CNES is a very small library with almost no features.
As such, I recommend that you use any other NES C library that you find out there!
The eventual difference will be that unlike any other NES C library out there,
CNES is built from the ground up to compile natively to PC as well.
Your game code will truly be cross platform with CNES.

(TODO full feature comparison/breakdown!)

## Where can I see a sample?

CNES is still in heavy development so expect it to change often!
Check out the `example` directory for the full example.

```c

/**
 * Main game loop called by the CNES engine
 * 
 * See: example/main.c for the full code
 */
void runframe() {
    update_joypad();

    if (player1_pressed(PAD_A)) {
        music_start(SONG_MEGALOVANIA);
    }
    if (player1_released(PAD_B)) {
        music_start(SONG_METAL_CRUSHER);
    }
}
```

## What about a feature roadmap?

## Audio

### NES
>
>Current
>
> * Basic support for playing/pausing Famistudio audio tracks
> * Build script to export to NES
>
>Planned
>
> * Sound effect support
>
>Maybe Someday
>
> * Other NES sound engine support

### PC
>
>Current
>
> * Basic support for playing `ogg` audio tracks
> * Build script to export to PC
>
>Planned
>
> * Sound effect support
> * Multiple audio tracks (ie: optional HD track support)

## Controller

### NES

>Current
>
> * Reading player 1 and 2 data
>
>Maybe Someday
>
> * Alternate input devices (Zapper, Multi tap, etc)

### PC

>Current
>
> * Reading player 1 (keyboard only)
>
>Planned
>
> * Game controller support
> * Controller/Key mapping.
> * Hotkey support
>
>Maybe Someday
>
> * Touch screen support (for mobile phones)

## Graphics

### NES

>Current (None)
>
>Planned
>
> * Omni-directional screen scroll
> * Screen split support
> * Animated background tiles
> * Asset pipeline for metatile/metasprites

### PC

>Current (None)
>
>Planned
>
> * SDL based renderer of the sprites/tiles.
> * Asset pipeline to generate sprite sheets and tilemaps
> * HD Viewport (widescreen support)
> * HD Asset configuration

## Configuration

### NES

>Current (None)
>
>Planned
>
> * Save data helper methods

### PC

>Current (None)
>
>Planned
>
> * Save data helper methods
> * Default configuration menu (for setting graphics/audio/controller options)
>
>Maybe Planned:
>
> * Adding a UI library (Dear IMGUI or similar) for UI widgets
