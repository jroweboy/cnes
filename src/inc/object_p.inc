
; Helper macros for generating the object loader

.ifndef CNES_OBJECT_P_INC
.define CNES_OBJECT_P_INC

.ifndef OBJECT_ATTRIBUTE_COUNT
.define OBJECT_ATTRIBUTE_COUNT 16
.endif ;OBJECT_ATTRIBUTE_COUNT

.ifndef OBJECT_SLOT_COUNT
.define OBJECT_SLOT_COUNT 32
.endif ;OBJECT_ATTRIBUTE_COUNT

.macro CNES_OBJECT_LOADER_IMPL
.import R0, R1, R2, R3

obj_slot    := R0
obj_id      := R1
obj_addr_lo := R2
obj_addr_hi := R3
obj         := object_addr_lo

.import ObjectTable

  ; Clear out the existing data in the slot
  ldx obj_slot
  lda #00
.repeat I, OBJECT_ATTRIBUTE_COUNT
  sta cnes_object_data + (I * OBJECT_SLOT_COUNT), x
.endrepeat

  ; If the object id is $ff then we exit now since we are just clearing this slot
  lda obj_id
  cmp #$ff
  bne :+
    rts

+ ; Load the pointer from the table for the object ID
  asl
  tay
  lda ObjectTable,y
  sta obj_addr_lo
  lda ObjectTable+1,y
  sta obj_addr_hi
  bcc :+
    ; The data for this object spilled over into the next page.
    lda ObjectTable + 256,y
    sta obj_addr_lo
    lda ObjectTable + 256 +1,y
    sta obj_addr_hi
+ ldy #$00
  ; Actually start filling up the object data RAM with the values from the table
  ; The object data layout is as follows:
  ; 1 byte mask - each bit represents if you need to load this attribute
  ; 0 - 8 bytes - One byte for each attribute that is selected by the mask
mask_byte := obj_id
.repeat I, (OBJECT_ATTRIBUTE_COUNT >> 3)
  lda (obj),y   ; Load the mask byte
  asl           ; shift off the left most bit to see if the first attribute exists
  sta mask_byte ; use the value in mask_byte for later shifts so we can use A to indirect load the data
  iny           ; bump the byte to look at since we already loaded the mask byte
  .repeat J, 8  ; Repeat the inner loop for each bit of the mask
    bcc :+      ; Skip this attribute if the mask value is 0
      lda (obj),y ; y points to the current offset into the object's data
      sta cnes_object_data + (I * OBJECT_SLOT_COUNT), x
      iny       ; since this attr is loaded, set y to the next byte to load
  + asl mask_byte
  .endrepeat
.endrepeat

.if ((OBJECT_ATTRIBUTE_COUNT & %00000111) != 0)
  ; If the attribute count isn't a multiple of 8, we need to cover for the remainder
  lda (obj),y
  asl
  sta mask_byte
  iny
.repeat I, (OBJECT_ATTRIBUTE_COUNT & %00000111)
    bcc :+
      lda (obj),y
      sta cnes_object_data + (I * OBJECT_SLOT_COUNT), x
      iny
  + asl mask_byte
.endrepeat

.endif

  ; all done!
  rts
.endmacro

.endif ;CNES_OBJECT_P_INC