.include "common.s"

.bss
music_queue:      .res 1
sfx_queue:        .res 1
audio_current:    .res 1

.import __AUDIO_DMC_LOAD__, banka, bankc

.export InitMusic
.export UpdateMusic


.segment "LOWCODE"

.proc InitMusic
  jsr SetAudioBank
  jsr AudioInit
  jmp RestoreBank
  ; implicit rts
.endproc

.proc UpdateMusic
  jsr SetAudioBank
  jsr AudioUpdate
  jmp RestoreBank
  ; implicit rts
.endproc

.proc SetAudioBank
  BANK_PRGA #AUDIO0
  ; BANK_PRGC #AUDIO_DMC0
  rts
.endproc

.proc RestoreBank
  BANK_PRGA banka
  ; BANK_PRGC bankc
  rts
.endproc

.proc AudioInit
  lda #SONG_CLEAR
  sta music_queue
  sta audio_current
  lda #0
  sta sfx_queue

  lda #1 ; NTSC
  ldx #<(megalovania_music_data)
  ldy #>(megalovania_music_data)
  jsr famistudio_init

  ldx #<(sounds)
  ldy #>(sounds)
  jmp famistudio_sfx_init
  ;rts
.endproc

.proc AudioUpdate
  jsr MusicUpdate
  jsr SFXUpdate
  jmp famistudio_update
  ;rts
.endproc

.proc MusicUpdate
  lda music_queue
  cmp #SONG_CLEAR
    beq Exit
  cmp #SONG_STOP
    beq MusicStop
  cmp #SONG_PAUSE
    beq MusicPause

  ; music_play
  ; the SONG_ defines are setup to be the same as the famistudio exported song list
  sta audio_current
  jsr famistudio_music_play
  bpl ClearQueue

MusicPause:
  lda audio_current
  bmi Unpause
    ; pause
    ora #SONG_PAUSED_MASK
    sta audio_current
    lda #1
    jsr famistudio_music_pause
    bne ClearQueue
  Unpause:
    and #%01111111 ; #~SONG_PAUSED_MASK
    sta audio_current
    lda #0
    jsr famistudio_music_pause
    bne ClearQueue ;should be unconditional

MusicStop:
  lda #SONG_CLEAR
  sta audio_current
  jsr famistudio_music_stop

ClearQueue:
  lda #SONG_CLEAR
  sta music_queue
Exit:
  rts
.endproc

.proc SFXUpdate
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
    lda DPCM_SFX_OFFSET,x
    jsr famistudio_sfx_sample_play
  pla
  ; if theres any other sfx to play it'll be nonzero
  bne Loop
  ; since its zero, clear out the queue and return
  sta sfx_queue
Exit:
  rts
.endproc
