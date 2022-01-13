
; Generated Audio engine code template.
; This file should be linked into the final build in order to play NES audio

; Force Famistudio to use our options instead
FAMISTUDIO_CFG_EXTERNAL = 1
FAMISTUDIO_CFG_C_BINDINGS = 0

; Segment handling
; Use some basic segment setup for common values
.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE

; Setup the segments where the audio/dmc data will end up in.

{famistudio_segment_code}

.code

; Music list for the CNES engine
{famistudio_music_list}

; Common default configuration options for the engine
; Can be overridden with compiler flags as needed
; Example: ca65 -DFAMISTUDIO_CFG_DPCM_SUPPORT=0

.ifndef FAMISTUDIO_CFG_NTSC_SUPPORT
FAMISTUDIO_CFG_NTSC_SUPPORT = 1
.endif

.ifndef FAMISTUDIO_CFG_DPCM_SUPPORT
FAMISTUDIO_CFG_DPCM_SUPPORT = 1
.endif

.ifndef FAMISTUDIO_CFG_SFX_SUPPORT
FAMISTUDIO_CFG_SFX_SUPPORT = 1
.endif
.ifndef FAMISTUDIO_CFG_SFX_STREAMS
FAMISTUDIO_CFG_SFX_STREAMS = 2
.endif

.ifndef FAMISTUDIO_CFG_SMOOTH_VIBRATO
FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1
.endif

; Famistudio configuration options required by the tracks

{famistudio_config_options}

; Begin Famistudio engine code

{famistudio_engine_code}
