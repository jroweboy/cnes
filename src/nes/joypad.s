.include "common.s"

.bss

PREVIOUS  = 0
CURRENT   = 1
PRESSED   = 2
RELEASED  = 3
HELD      = 4

player1: .res 4
.export _p1_previous = player1 + PREVIOUS
.export _p1_current  = player1 + CURRENT
.export _p1_pressed  = player1 + PRESSED
.export _p1_released = player1 + RELEASED

.ifdef CNES_JOYPAD_HELD
p1_held: .res 8
.export _p1_held     = player1 + HELD
.endif ;CNES_JOYPAD_HELD

.ifdef CNES_JOYPAD_PLAYER2
player2: .res 4
.export _p2_previous = player2 + PREVIOUS
.export _p2_current  = player2 + CURRENT
.export _p2_pressed  = player2 + PRESSED
.export _p2_released = player2 + RELEASED

.ifdef CNES_JOYPAD_HELD
p2_held: .res 8
.export _p2_held     = player2 + HELD
.endif ;CNES_JOYPAD_HELD
.endif ;CNES_JOYPAD_PLAYER2

.code

.macro MacroJoypadUpdate player, load
.scope
  ; p1_released = !p1_current && p1_previous
.if load = 1
  lda player + CURRENT
.endif
  eor #$ff
  and player + PREVIOUS
  sta player + RELEASED

  ; p1_pressed = p1_current && !p1_previous
  lda player + PREVIOUS
  eor #$ff
  and player + CURRENT
  sta player + PRESSED
.ifdef CNES_JOYPAD_HELD
  lda player + CURRENT
Loop:
  rol
  bcc Else
  ; if this button is held increment
  inc player + HELD,x
  dex
  bpl Loop
  jmp Exit
Else:
  ; else clear this button
  sty player + HELD,x
  dex
  bpl Loop
Exit:
.endif
.endscope
.endmacro

.export _update_joypad:=GamepadSafeRead
.proc GamepadSafeRead
  ; Scratches A, X, Y
  lda player1 + CURRENT
  sta player1 + PREVIOUS
.ifdef CNES_JOYPAD_HELD
  ldx #7
  ldy #0
.endif

.ifdef CNES_JOYPAD_PLAYER2
  lda player2 + CURRENT
  sta player2 + PREVIOUS
.endif

  jsr GamepadRead
Reread:
  lda player1 + CURRENT
  pha
    jsr GamepadRead
  pla
  cmp player1 + CURRENT
  bne Reread

  ; now figure out which buttons are just pressed and which ones are just released
  MacroJoypadUpdate player1, 0

.ifdef CNES_JOYPAD_PLAYER2
  MacroJoypadUpdate player2, 1
.endif
  rts
.endproc

.proc GamepadRead
  lda #$01
  ; While the strobe bit is set, buttons will be continuously reloaded.
  ; This means that reading from JOYPAD1 will only return the state of the
  ; first button: button A.
  sta JOYPAD1
.ifdef CNES_JOYPAD_PLAYER2
  sta player2 + CURRENT  ; player 2's buttons double as a ring counter
.else
  sta player1 + CURRENT
.endif
  lsr          ; now A is 0
  ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
  ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
  sta JOYPAD1
Loop:
    lda JOYPAD1
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player1 + CURRENT  ; Carry -> bit 0; bit 7 -> Carry
.ifdef CNES_JOYPAD_PLAYER2
    lda JOYPAD2
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player2 + CURRENT  ; Carry -> bit 0; bit 7 -> Carry
.endif
  bcc Loop
  rts
.endproc
