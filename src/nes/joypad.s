.include "common.s"


.struct Gamepad
  previous .byte
  current  .byte
  pressed  .byte
  released .byte
.endstruct

.bss
player1_prev: .res 1
player1_curr: .res 1
player1_pres: .res 1
player1_rele: .res 1
.export _player1_prev=player1_prev
.export _player1_curr=player1_curr
.export _player1_pres=player1_pres
.export _player1_rele=player1_rele

.ifdef CNES_JOYPAD_PLAYER2
player2_prev: .res 1
player2_curr: .res 1
player2_pres: .res 1
player2_rele: .res 1
.export _player2_prev=player2_prev
.export _player2_curr=player2_curr
.export _player2_pres=player2_pres
.export _player2_rele=player2_rele
.endif

.code

.export _update_joypad:=GamepadSafeRead
.proc GamepadSafeRead
  ; Scratches A,X,Y
  lda player1_curr
  sta player1_prev
  tax ; store p1 previous in x

.ifdef CNES_JOYPAD_PLAYER2
  lda player2_curr
  sta player2_prev
  tay ; store p2 previous in y
.endif

  jsr GamepadReadPlayer1
Reread:
  lda player1_curr
  pha
    jsr GamepadReadPlayer1
  pla
  cmp player1_curr
  bne Reread
  ; now figure out which buttons are just pressed and which ones are just released
  txa ; A = player1.previous
  eor player1_curr
  and player1_curr
  sta player1_pres
  txa ; A = player1.previous
  eor player1_curr
  and player1_prev
  sta player1_rele
.ifdef CNES_JOYPAD_PLAYER2
  ; Now do this all over again for player 2
  tya
  eor player2_curr
  and player2_curr
  sta player2_pres
  tya
  eor player2_curr
  and player2_prev
  sta player2_rele
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
  sta player2_curr  ; player 2's buttons double as a ring counter
.else
  sta player1_curr
.endif
  lsr          ; now A is 0
  ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
  ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
  sta JOYPAD1
Loop:
    lda JOYPAD1
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player1_curr  ; Carry -> bit 0; bit 7 -> Carry
.ifdef CNES_JOYPAD_PLAYER2
    lda JOYPAD2
    and #%00000011  ; ignore bits other than controller
    cmp #$01        ; Set carry if and only if nonzero
    rol player2_curr  ; Carry -> bit 0; bit 7 -> Carry
.endif
  bcc Loop
  rts
.endproc

; .proc Player1Pressed
;   ; in[A] = buttons to check
;   and player1_pressed
;   rts
; .endproc
; .proc Player1Held
;   ; in[A] = buttons to check
;   and player1_current
;   rts
; .endproc
; .proc Player1Released
;   ; in[A] = buttons to check
;   and player1_released
;   rts
; .endproc

; .ifdef CNES_JOYPAD_PLAYER2
; .proc Player1Pressed
;   ; in[A] = buttons to check
;   and player2 + Gamepad::pressed
;   rts
; .endproc
; .proc Player1Held
;   ; in[A] = buttons to check
;   and player2 + Gamepad::current
;   rts
; .endproc
; .proc Player1Released
;   ; in[A] = buttons to check
;   and player2 + Gamepad::released
;   rts
; .endproc
; .endif
