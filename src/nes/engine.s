
.include "common.s"

.zeropage
; Prevents NMI re-entry
nmi_lock:       .res 1
; When the NMI fires outside of the wait frame loop, this is set
late_frame:     .res 1
.exportzp _late_frame:=late_frame

; Stores jsr (indirect) pointers for fast callbacks
screen_jmp_abs: .res 3
screen_jmp_ptr  = screen_jmp_abs + 1
.exportzp screen_jmp_abs, screen_jmp_ptr
irq_handler_abs:.res 3
irq_handler_ptr = irq_handler_abs + 1
irq_jmp_abs:    .res 3
irq_jmp_ptr     = irq_jmp_abs + 1
.globalzp irq_jmp_ptr

; Stores the 6502 registers when IRQs are triggered for speedy access
irq_a:          .res 1
irq_x:          .res 1
irq_y:          .res 1


.segment "OAM"
oam: .res 256
.global oam

.bss
; Temp variables that should only be accessed in IRQs
irq_tmp:        .res 1
irq_tmp2:       .res 1
.export irq_tmp, irq_tmp2

screen_state:   .res 1
next_frame:     .res 1
.export screen_state, next_frame

banka:          .res 1
bankc:          .res 1
.export banka, bankc

irq_scanline:   .res 1
wait_for_nmi:   .res 1
.export _wait_for_frame_end=WaitForFrameEnd

.code

; Import user defined functions
.import _init_callback, _runframe

.import InitMusic
.export InitEngine
.proc InitEngine
  jsr InitMusic
  jmp _init_callback
  ; rts
.endproc

.export GameLoop
.proc GameLoop
  lda late_frame
  jsr _runframe
  lda #1
  sta wait_for_nmi
  :
    ldx next_frame
  bpl :-
  jmp GameLoop
.endproc

SCANLINE_NMI           = 0

.import UpdateMusic
.export HandleNMI, _driver_nmi:=HandleNMI
.proc HandleNMI
  sta irq_a
  lda PPUSTATUS       ; Clear the NMI flag
  lda nmi_lock
  bne EarlyExit
  ; save registers. A was already saved above
  stx irq_x
  sty irq_y
  ; jsr DrawingNMICallback
  jsr PrepareNextScreen
  jsr UpdateMusic
  inc next_frame
  ; unlock re-entry flag
  lda #0
  sta nmi_lock
  ; restore registers and return
  ldy irq_y
  ldx irq_x
EarlyExit:
  lda irq_a
  rti
.endproc

.export InitIRQ
.proc InitIRQ
  lda #OP_JMP_ABS
  sta irq_jmp_abs
  lda #OP_JMP_ABS
  sta irq_handler_abs
  lda #OP_JMP_ABS
  sta screen_jmp_abs
  rts
.endproc

;;;
; in [a] - Sets the handler to the callback provided by A
.proc SetNextIRQHandler
  asl
  tax
  lda IRQ_CALLBACK_TABLE,x
  sta irq_handler_ptr
  lda IRQ_CALLBACK_TABLE+1,x
  sta irq_handler_ptr+1
  rts
IRQ_CALLBACK_TABLE:
.endproc

.export HandleIRQ, _driver_irq:=HandleIRQ
.proc HandleIRQ
  sta irq_a
  stx irq_x
  sty irq_y

  ; writing anything (even 0) will disable mmc3 IRQ
  sta IRQDISABLE
  jsr irq_handler_abs

  ldy irq_y
  ldx irq_x
  lda irq_a
  rti
.endproc

;; Called in NMI to setup the next screen state.
;; Screen state is used to determine which IRQ handlers we will use for this next frame
.proc PrepareNextScreen
  lda #SCANLINE_NMI
  sta irq_scanline

  lda screen_state
  asl
  tax
  lda ScreenStateTable,x
  sta screen_jmp_ptr
  lda ScreenStateTable+1,x
  sta screen_jmp_ptr+1
  jmp (screen_jmp_ptr)

ScreenStateTable:
.endproc

.proc WaitForFrameEnd
  :
  ldx next_frame
  bpl :-
  rts
.endproc

;;;;;;;;;;;;;;;;;;;;;;;;
; Delays A clocks + overhead
; Clobbers A. Preserves X,Y.
; Time: A+25 clocks (including JSR)
;;;;;;;;;;;;;;;;;;;;;;;;
                  ;       Cycles              Accumulator         Carry flag
                  ; 0  1  2  3  4  5  6          (hex)           0 1 2 3 4 5 6
                  ;
                  ; 6  6  6  6  6  6  6   00 01 02 03 04 05 06
:      sbc #7     ; carry set by CMP
DelayA25Clocks:
       cmp #7     ; 2  2  2  2  2  2  2   00 01 02 03 04 05 06   0 0 0 0 0 0 0
       bcs :-     ; 2  2  2  2  2  2  2   00 01 02 03 04 05 06   0 0 0 0 0 0 0
       lsr        ; 2  2  2  2  2  2  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
       bcs *+2    ; 2  3  2  3  2  3  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
       beq :+     ; 3  3  2  2  2  2  2   00 00 01 01 02 02 03   0 1 0 1 0 1 0
       lsr        ;       2  2  2  2  2         00 00 01 01 01       1 1 0 0 1
       beq @rts   ;       3  3  2  2  2         00 00 01 01 01       1 1 0 0 1
       bcc @rts   ;             3  3  2               01 01 01           0 0 1
:      bne @rts   ; 2  2              3   00 00             01   0 1         0
@rts:  rts        ; 6  6  6  6  6  6  6   00 00 00 00 01 01 01   0 1 1 1 0 0 1
; Total cycles:    25 26 27 28 29 30 31

