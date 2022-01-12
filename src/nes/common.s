

; General Audio defines
SONG_PAUSE      = 253
SONG_STOP       = 254
SONG_CLEAR      = 255
SONG_PAUSED_MASK= %10000000

; General Joypad defines
JOYPAD1 = $4016
JOYPAD2 = $4017

; Common PPU defines
PPUCTRL     = $2000
PPUMASK     = $2001
PPUSTATUS   = $2002
OAMADDR     = $2003
OAMDATA     = $2004
PPUSCROLL   = $2005
PPUADDR     = $2006
PPUDATA     = $2007
OAMDMA      = $4014

; MMC3 registers / banking
BANK_SELECT = $8000
BANK_DATA   = $8001
IRQLATCH    = $c000
IRQRELOAD   = $c001
IRQDISABLE  = $e000
IRQENABLE   = $e001

.macro BANK_CHR0 bank
  BANK_INNER bank, 0
.endmacro

.macro BANK_CHR8 bank
  BANK_INNER bank, 1
.endmacro

.macro BANK_CHR10 bank
  BANK_INNER bank, 2
.endmacro

.macro BANK_CHR14 bank
  BANK_INNER bank, 3
.endmacro

.macro BANK_CHR18 bank
  BANK_INNER bank, 4
.endmacro

.macro BANK_CHR1C bank
  BANK_INNER bank, 5
.endmacro

.macro BANK_PRGA bank
  BANK_INNER bank, 7
.endmacro

.macro BANK_PRGC bank
  BANK_INNER bank, 6
.endmacro

.macro BANK_INNER bank, select
  ; set fixed $8000 bank bit and CHR A12 inversion
	lda #select | (1 << 6) ; | (1 << 7) 
  sta BANK_SELECT
  .if (.match (.left (1, {arg}), #))
    lda #bank
  .else
    lda bank
  .endif
  sta BANK_DATA
.endmacro

; Hacky way to do an indirect jsr. Write this op to the byte before a word and 
; do jsr loc and it'll treat this $4c as a absolute jmp instruction with the
; following two bytes being the location to jump to.
OP_JMP_ABS  = $4c

; If we need to add some callable code into common wrap it in something like this
; .ifndef COMMON_S
; .define COMMON_S = 1
; .endif
