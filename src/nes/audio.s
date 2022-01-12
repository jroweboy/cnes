
.include "common.s"

.bss
; External variables that can be written to in order to play audio during the next NMI
music_queue:      .res 1
sfx_queue:        .res 1
.export _music_queue:=music_queue, _sfx_queue:=sfx_queue

; Holds the CNES value for the currently playing audio
music_current:    .res 1
; Variables to store the famistudio information for the currently playing audio track
music_banka:      .res 1
music_bankc:      .res 1

sfx_id:           .res 1

.import banka, bankc
.import famistudio_music_play, famistudio_music_stop, famistudio_music_pause
.import famistudio_update, famistudio_sfx_sample_play, famistudio_init, famistudio_sfx_init

; The build file spits out a list of music and SFX that can be played.
; the data is in an array of each of these
.import MusicAddrHi, MusicAddrLo, MusicBank_A, MusicBank_C
.import SFXAddrHi, SFXAddrLo, SFXId

.code

.macro MacroSetMusicBank
  BANK_PRGA music_banka
  BANK_PRGC music_bankc
.endmacro

.macro MacroRestoreMusicBank
  BANK_PRGA banka
  BANK_PRGC bankc
.endmacro

.macro MacroLoadMusicTrack
  ; X = which CNES track to load
  lda MusicBank_A,x
  sta music_banka
  lda MusicBank_C,x
  sta music_bankc
  txa
  tay
  lda MusicAddrLo,x
  ldx MusicAddrHi,y
  tay
.endmacro
.macro MacroLoadSFXTrack
  ; X = which CNES track to load
  lda SFXId,x
  sta sfx_id
  txa
  tay
  lda SFXAddrLo,x
  ldx SFXAddrHi,y
  tay
.endmacro

.export InitMusic
.proc InitMusic
  lda #SONG_CLEAR
  sta music_queue
  sta music_current
  lda #0
  sta sfx_queue

  ldx #0 ; By default, load the init with the first song in the music list
  MacroLoadMusicTrack
  lda #1 ; NTSC ; TODO support other formats
  ; A = NTSC
  ; X = MusicAddrHi
  ; Y = MusicAddrLo
  jsr famistudio_init

  MacroLoadSFXTrack
  jmp famistudio_sfx_init
  ;rts
.endproc

.macro MacroMusicUpdate
.scope Music
  lda music_queue
  bpl MusicPlay
  cmp #SONG_CLEAR 
    beq Exit
  cmp #SONG_STOP
    beq MusicStop
  ; assume paused since its the only other status
  ; cmp #SONG_PAUSE
  ;   beq MusicPause
MusicPause:
  lda music_current
  bmi Unpause
    ; pause
    ora #SONG_PAUSED_MASK
    sta music_current
    lda #1
    jsr famistudio_music_pause
    bne ClearQueue
  Unpause:
    and #%01111111 ; #~SONG_PAUSED_MASK
    sta music_current
    lda #0
    jsr famistudio_music_pause
    bne ClearQueue ;should be unconditional

MusicStop:
  lda #SONG_CLEAR
  sta music_current
  jsr famistudio_music_stop

MusicPlay:
  sta music_current
  ; load the data for this music track
  tax
  MacroLoadMusicTrack
  jsr famistudio_music_play

ClearQueue:
  lda #SONG_CLEAR
  sta music_queue
Exit:
.endscope
.endmacro

.macro MacroSFXUpdate
.scope SFX
  lda sfx_queue
  ; check if theres even anything in the queue
  beq Exit
  ldx #8 ; we pre decrement so start at 8
  ; check each bit one at a time for sfx
Loop:
  dex
  bmi Exit
  asl
  bcc Loop
  pha
    ; TODO fix sfx playing
    ; lda DPCM_SFX_OFFSET,x
    jsr famistudio_sfx_sample_play
  pla
  ; if theres any other sfx to play it'll be nonzero
  bne Loop
  ; since its zero, clear out the queue and return
  sta sfx_queue
Exit:
.endscope
.endmacro

.export UpdateMusic
.proc UpdateMusic
  MacroMusicUpdate
  MacroSFXUpdate
  MacroSetMusicBank
  jsr famistudio_update
  MacroRestoreMusicBank
  rts
.endproc
