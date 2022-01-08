
.include "common.s"
.include "common_ppu.s"

; Import user defined functions
.import _init_callback, _gameloop

; Import driver defined values
.import oam
.import HandleIRQ, HandleNMI

.segment "VECTORS"
.word (HandleNMI)
.word (Reset)
.word (HandleIRQ)

.code

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
  
  ; BANK_PRGA #_INITIAL_CODE_BANK_A
  ; BANK_PRGC #_INITIAL_CODE_BANK_C

  ; disable scanline IRQ
  sta IRQDISABLE

  ; NES is initialized, ready to begin!
  ; enable the NMI for graphical updates, and jump to our main program
  lda #%10001000
  sta PPUCTRL
  jsr _init_callback
  jmp _gameloop
  ; endless loop
.endproc

