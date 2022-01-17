
.include "common.s"


.zeropage
; Prevents NMI re-entry
nmi_lock:       .res 1
.exportzp nmi_lock

; When the NMI fires outside of the wait frame loop, this is set
late_frame:     .res 1
.exportzp _late_frame:=late_frame

.segment "OAM"
oam: .res 256
.global oam

.bss
wait_for_nmi:   .res 1
next_frame:     .res 1

.code


; Import user defined functions
.import _init_callback, _runframe

.import InitEngine
.import InitMusic
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

  lda #1
  sta nmi_lock
  
  jmp _init_callback
  jsr InitMusic
  jsr InitEngine

  ; NES is initialized, ready to begin!
  ; enable the NMI for graphical updates, and jump to our main program
  lda #%10001000
  sta PPUCTRL
  jmp GameLoop
  ; endless loop
.endproc

.import UpdateMusic
.export _driver_nmi:=HandleNMI
.proc HandleNMI
  pha
    lda PPUSTATUS       ; Clear the NMI flag
    lda nmi_lock
    beq EarlyExit
    ; save registers. A was already saved above
    pha
    pha
      ; jsr DrawingNMICallback
      ; jsr PrepareNextScreen
      jsr UpdateMusic
      lda #1
      sta next_frame
      sta nmi_lock
    ; restore registers and return
    pla
    pla
EarlyExit:
  pla
  rti
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