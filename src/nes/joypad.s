.include "common.s"


.struct Gamepad
  current  .byte
  pressed  .byte
  released .byte
.endstruct

.bss
player1: .tag Gamepad

.export _update_joypad:=GamepadSafeRead
.export _player1_pressed:=Player1Pressed
.export _player1_held:=Player1Held
.export _player1_released:=Player1Released

.ifdef CNES_JOYPAD_PLAYER2
player2: .tag Gamepad
.export _player2_pressed:=Player2Pressed
.export _player2_held:=Player2Held
.export _player2_released:=Player2Released
.endif

.code

.proc GamepadSafeRead
  ; Scratches A,X,Y
  lda player1 + Gamepad::current
  tax ; store the previous frames values in x

.ifdef CNES_JOYPAD_PLAYER2
  lda player2 + Gamepad::current
  tay
.endif

  jsr GamepadReadPlayer1
Reread:
  lda player1 + Gamepad::current
  pha
    jsr GamepadReadPlayer1
  pla
  cmp player1 + Gamepad::current
  bne Reread
  txa
  ; now figure out which buttons are just pressed and which ones are just released
  ; A = previous player1.current
  eor player1 + Gamepad::pressed
  sta player1 + Gamepad::pressed
  txa
  ; A = previous player1.current
  eor #$FF ; negate the bits in A to find out which ones are just released
  eor player1 + Gamepad::released
  sta player1 + Gamepad::released
.ifdef CNES_JOYPAD_PLAYER2
  ; Now do this all over again for player 2
  tya
  ; now figure out which buttons are just pressed and which ones are just released
  ; A = previous player1.current
  eor player2 + Gamepad::pressed
  sta player2 + Gamepad::pressed
  tya
  ; A = previous player1.current
  eor #$FF ; negate the bits in A to find out which ones are just released
  eor player2 + Gamepad::released
  sta player2 + Gamepad::released
.endif
  rts
.endproc

.proc GamepadReadPlayer1
  lda #$01
  ; While the strobe bit is set, buttons will be continuously reloaded.
  ; This means that reading from JOYPAD1 will only return the state of the
  ; first button: button A.
  sta JOYPAD1
.ifdef CNES_JOYPAD_PLAYER2
  sta player2 + Gamepad::current  ; player 2's buttons double as a ring counter
.else
  sta player1 + Gamepad::current
.endif
  lsr          ; now A is 0
  ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
  ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
  sta JOYPAD1
Loop:
    lda JOYPAD1
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player1 + Gamepad::current  ; Carry -> bit 0; bit 7 -> Carry
.ifdef CNES_JOYPAD_PLAYER2
    lda JOYPAD2
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player2 + Gamepad::current  ; Carry -> bit 0; bit 7 -> Carry
.endif
  bcc Loop
  rts
.endproc

.proc Player1Pressed
  ; in[A] = buttons to check
  and player1 + Gamepad::pressed
  rts
.endproc
.proc Player1Held
  ; in[A] = buttons to check
  and player1 + Gamepad::current
  rts
.endproc
.proc Player1Released
  ; in[A] = buttons to check
  and player1 + Gamepad::released
  rts
.endproc

.ifdef CNES_JOYPAD_PLAYER2
.proc Player1Pressed
  ; in[A] = buttons to check
  and player2 + Gamepad::pressed
  rts
.endproc
.proc Player1Held
  ; in[A] = buttons to check
  and player2 + Gamepad::current
  rts
.endproc
.proc Player1Released
  ; in[A] = buttons to check
  and player2 + Gamepad::released
  rts
.endproc
.endif
