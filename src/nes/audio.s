
.include "common.inc"

.bss
; External variables that can be written to in order to play audio during the next NMI
music_queue:      .res 1
sfx_queue:        .res 1
.export _music_queue:=music_queue, _sfx_queue:=sfx_queue

; Holds the CNES value for the currently playing audio
music_current:    .res 1
.export _music_playing:=music_current
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

.proc LoadMusicProject
  ; X = which CNES track to load
  txa
  pha
    lda MusicBank_A-1,x
    sta music_banka
    lda MusicBank_C-1,x
    sta music_bankc
    BANK_PRGA music_banka
    BANK_PRGC music_bankc
    txa
    tay
    lda MusicAddrHi-1,x
    ldx MusicAddrLo-1,y
    tay
    lda #1
    ; A = 1(NTSC); X = Lo; Y = Hi
    jsr famistudio_init
  pla
  tax
  tay
  lda SFXAddrHi-1,x
  ldx SFXAddrLo-1,y
  tay
  ; X = lo; Y = Hi
  jmp famistudio_sfx_init
  ; rts
.endproc

.export InitMusic
.proc InitMusic
  lda #SONG_CLEAR
  sta music_queue
  sta music_current
  lda #0
  sta sfx_queue

  ; By default, load the init with the first song in the music list
  ldx #0
  jmp LoadMusicProject
  ;rts
.endproc

.macro MacroMusicUpdate
.scope Music
  lda music_queue
  beq Exit
  ; New song to play so let it run
  bpl MusicPlay
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
    jmp ClearQueue
MusicStop:
  lda #SONG_CLEAR
  sta music_current
  jsr famistudio_music_stop
  jmp ClearQueue

MusicPlay:
  sta music_current
  ; load the data for this music track
  tax
  jsr LoadMusicProject
  ; we expect all audio tracks to be in their own projects
  lda #0
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
