.include "common.inc"

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

.ifndef CNES_DISABLE_JOYPAD_HELD
p1_held: .res 8
.export _p1_held     = p1_held
.endif ;CNES_DISABLE_JOYPAD_HELD

.ifndef CNES_DISABLE_JOYPAD_PLAYER2
player2: .res 4
.export _p2_previous = player2 + PREVIOUS
.export _p2_current  = player2 + CURRENT
.export _p2_pressed  = player2 + PRESSED
.export _p2_released = player2 + RELEASED

.ifndef CNES_DISABLE_JOYPAD_HELD
p2_held: .res 8
.export _p2_held     = p2_held
.endif ;CNES_DISABLE_JOYPAD_HELD
.endif ;CNES_DISABLE_JOYPAD_PLAYER2

.segment "CNES_JOYPAD"

.macro MacroCheckHeld player
.scope
Loop:
  rol
  bcc Else
  ; if this button is held increment
  inc player, x
  bpl CheckExit
Else:
  ; else clear this button
  pha
    tya
    sta player, x
  pla
CheckExit:
  dex
  bpl Loop
.endscope
.endmacro

.export _update_joypad:=GamepadSafeRead
.proc GamepadSafeRead
  ; Scratches A, X, Y
  lda player1 + CURRENT
  sta player1 + PREVIOUS
  ldx #0
  ldy #0

.ifndef CNES_DISABLE_JOYPAD_PLAYER2
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
  ; p1_released = ~player1.current & player1.previous
PlayerPressRelease:
  lda player1 + CURRENT, x
  eor #$ff
  and player1 + PREVIOUS,x
  sta player1 + RELEASED,x

  ; p1_pressed = player1.current & ~player1.previous
  lda player1 + PREVIOUS,x
  eor #$ff
  and player1 + CURRENT,x
  sta player1 + PRESSED,x
.ifndef CNES_DISABLE_JOYPAD_PLAYER2
    cpx #0
    bne FinishedPlayer2
    ldx #(player2 - player1)
    bpl PlayerPressRelease
FinishedPlayer2:
  ldx #0
.endif

.ifndef CNES_DISABLE_JOYPAD_HELD
  lda player1 + CURRENT
  MacroCheckHeld p1_held
.ifndef CNES_DISABLE_JOYPAD_PLAYER2
  lda player2 + CURRENT
  ldx #0
  MacroCheckHeld p2_held
.endif ;CNES_DISABLE_JOYPAD_PLAYER2
.endif ;CNES_DISABLE_JOYPAD_HELD
.endproc

.proc GamepadRead
  lda #$01
  ; While the strobe bit is set, buttons will be continuously reloaded.
  ; This means that reading from JOYPAD1 will only return the state of the
  ; first button: button A.
  sta JOYPAD1
.ifndef CNES_DISABLE_JOYPAD_PLAYER2
  sta player2 + CURRENT  ; player 2's buttons double as a ring counter
.else
  sta player1 + CURRENT
.endif ;CNES_DISABLE_JOYPAD_PLAYER2
  lsr          ; now A is 0
  ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
  ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
  sta JOYPAD1
Loop:
    lda JOYPAD1
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player1 + CURRENT  ; Carry -> bit 0; bit 7 -> Carry
.ifndef CNES_DISABLE_JOYPAD_PLAYER2
    lda JOYPAD2
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player2 + CURRENT  ; Carry -> bit 0; bit 7 -> Carry
.endif ;CNES_DISABLE_JOYPAD_PLAYER2
  bcc Loop
  rts
.endproc
