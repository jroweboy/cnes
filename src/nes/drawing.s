

.include "common.inc"
.include "popslide.inc"

.zeropage

ppuctrl:        .res 1
ppumask:        .res 1

scroll_x:       .res 1
.exportzp _scroll_x = scroll_x
scroll_y:       .res 1
.exportzp _scroll_y = scroll_y

vblank_tasks:   .res 1
.exportzp _vblank_tasks = vblank_tasks

.bss

oam:            .res 256
.export _oam:=oam

palette:        .res 32
.export _palette:=palette


.segment "CNES_DRAWING"

.export DrawingInit
.proc DrawingInit
  rts
.endproc

; Drawing is for handling basic writing code to the NES
.export DrawingNMICallback
.proc DrawingNMICallback
  lda vblank_tasks
  ldx #0
  stx vblank_tasks
  asl a
  bcc NoOAM
    stx OAMADDR
    ldx #>oam
    stx OAMDMA
NoOAM:

  asl a
  bcs :+
    jmp NoPalette
  :
    ; set PPU address to $3F00
    lda #$3f
    sta PPUADDR
    lda #$01
    stx PPUADDR
    ; Update sprite and tile colors
.repeat 8, I
    lda palette + I * 4 + 1
    sta PPUDATA
    lda palette + I * 4 + 2
    sta PPUDATA
    lda palette + I * 4 + 3
    sta PPUDATA
    sta PPUDATA
.endrepeat
    ; Update the background color
    lda palette
    sta PPUDATA
NoPalette:

  asl a
  pha
  bcc NoPopSlide
    jsr popslide_terminate_blit
NoPopSlide:

  lda scroll_x
  sta PPUSCROLL
  lda scroll_y
  sta PPUSCROLL
  lda ppuctrl
  sta PPUCTRL
  lda ppumask
  sta PPUMASK

  pla
  rts
.endproc

