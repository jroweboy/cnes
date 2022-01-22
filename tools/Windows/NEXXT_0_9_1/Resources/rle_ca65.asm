;Original RLE decompressor by Shiru.
;Rewritten for use with ca65 by FrankenGraphics.

;uses 4 bytes in zero page
;decompress data from an address in X/Y to PPU_DATA


;put these 4 reservations where they belong in your project. 
;alternately, you can use any memory in zp you've defined temp vars for. 
RLE_lo:		.res 1
RLE_hi:		.res 1
RLE_tag:	.res 1
RLE_byte:	.res 1
;==========================================================

.proc decodeRLE
	stx RLE_lo
	sty RLE_hi
	ldy #0
	jsr doRLEbyte
	sta RLE_tag
L1:
	jsr doRLEbyte
	cmp RLE_tag
	beq L2
	sta PPUDATA
	sta RLE_byte
	bne L1
L2:
	jsr doRLEbyte
	cmp #0
	beq L4
	tax
	lda RLE_byte
L3:
	sta PPUDATA
	dex
	bne L3
	beq L1
L4:
	rts
.endproc

.proc doRLEbyte
	lda (RLE_lo),y
	inc RLE_lo
	bne L1
	inc RLE_hi
L1:
	rts
.endproc