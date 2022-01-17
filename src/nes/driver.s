
.include "common.s"

; Import driver defined values
.global oam

.code

.import GameLoop, InitEngine

.export _driver_reset:=Reset
.proc Reset
  sei       ; mask interrupts
  cld       ; disable decimal mode
  lda #0
  sta PPUCTRL ; disable NMI
  sta PPUMASK ; disable rendering
  sta $4015 ; disable APU sound
  sta $4010 ; disable DMC IRQ
  lda #$40
  sta $4017 ; disable APU IRQ
  ldx #$FF
  txs       ; initialize stack
  ; wait for first vblank
  bit PPUSTATUS
  :
    bit PPUSTATUS
    bpl :-
  ; clear all RAM to 0
  lda #0
  ldx #0
  :
    sta $0000, X
    sta $0100, X
    sta $0200, X
    sta $0300, X
    sta $0400, X
    sta $0500, X
    sta $0600, X
    sta $0700, X
    inx
    bne :-
  ; place all sprites offscreen at Y=255
  lda #255
  ldx #0
  :
    sta oam, X
    inx
    inx
    inx
    inx
    bne :-
  ; wait for second vblank
  :
    bit PPUSTATUS
    bpl :-

  ldx #0
  stx $a000 ; Vertical mirroring

  ; disable scanline IRQ
  sta IRQDISABLE

  ; NES is initialized, ready to begin!
  ; enable the NMI for graphical updates, and jump to our main program
  lda #%10001000
  sta PPUCTRL
  jsr InitEngine
  jmp GameLoop
  ; endless loop
.endproc

.proc GameLoop
  ; TODO check late frame
  lda late_frame
  jsr _runframe
  lda #1
  sta wait_for_nmi
  :
    ldx next_frame
  beq :-
  lda #0
  sta next_frame
  jmp GameLoop
.endproc