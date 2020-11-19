; INES header stuff
  .inesprg 1   ; 1 banks of PRG (16kbytes)
  .ineschr 1   ; 1 bank of CHR (8kbytes)
  .inesmir 0   ; mirroring doesn't matter
  .inesmap 0   ; we use mapper 0 (no mapper)
  
  .rsset $0000 ; set the initial value of
    ; the RS internal counter
COPY_SOURCE_ADDR .rs 2
COPY_DEST_ADDR   .rs 2

  .bank 1     ; following goes in bank 1
  .org $FFFA  ; start at $FFFA
  .dw NMI
  .dw Start
  .dw IRQ

  .bank 0
  .org $C000  ; code starts at $C000
  
Start:
  sei ; no interrupts

  ; reset stack
  ldx #$FF
  txs 
  
  lda #%00000000 ; PPU disabled
  sta PPUCTRL
  sta PPUMASK  
  jsr waitblank

  ; clean memory
  lda #$00
  sta <COPY_SOURCE_ADDR
  sta <COPY_SOURCE_ADDR+1
  ldy #$02
  ldx #$08
.loop:
  sta [COPY_SOURCE_ADDR], y
  iny
  bne .loop
  inc <COPY_SOURCE_ADDR+1
  dex
  bne .loop

  ; loading palette
load_palette:
  jsr waitblank
  lda #$3F
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldx #$00
.loop:
  lda palette, x
  sta PPUDATA
  inx
  cpx #8
  bne .loop

  ; loading nametable and attribute table to PPUCTRL @ PPU
load_nametable:
  lda #LOW(nametable)
  sta <COPY_SOURCE_ADDR
  lda #HIGH(nametable)
  sta <COPY_SOURCE_ADDR+1
  lda PPUSTATUS
  lda #$20
  sta PPUADDR
  lda #$00
  sta PPUADDR
  ldy #0
  ldx #4
.loop:
  lda [COPY_SOURCE_ADDR], y
  sta PPUDATA
  iny
  bne .loop
  inc <COPY_SOURCE_ADDR+1
  dex
  bne .loop

load_drawing_offsets:
  lda #LOW(draw_offsets)
  sta <COPY_SOURCE_ADDR
  lda #HIGH(draw_offsets) + $E0
  sta <COPY_SOURCE_ADDR+1
  lda #LOW(draw_offsets)
  sta <COPY_DEST_ADDR
  lda #HIGH(draw_offsets)
  sta <COPY_DEST_ADDR+1
  ldy #0
  ldx #32
.loop:
  lda [COPY_SOURCE_ADDR], y
  sta [COPY_DEST_ADDR], y
  iny
  dex
  bne .loop

load_drawing_routine:
  lda #LOW(draw_bits)
  sta <COPY_SOURCE_ADDR
  lda #HIGH(draw_bits) + $E0
  sta <COPY_SOURCE_ADDR+1
  lda #LOW(draw_bits)
  sta <COPY_DEST_ADDR
  lda #HIGH(draw_bits)
  sta <COPY_DEST_ADDR+1
  ldy #0
  ldx #6
.loop:
  lda [COPY_SOURCE_ADDR], y
  sta [COPY_DEST_ADDR], y
  iny
  bne .loop
  inc <COPY_SOURCE_ADDR+1
  inc <COPY_DEST_ADDR+1
  dex
  bne .loop

  ; call it
  jsr draw_bits

  ; enable PPU
  jsr waitblank
  ; show background
  lda #%00001010
  sta PPUMASK

  ; main loop        
infin:
  jsr read_controller
  jsr waitblank
  jsr draw_bits
  jsr fix_scroll
  jmp infin

read_controller:
  ; strobe
  ldx #1
  stx JOY1
  dex
  stx JOY1
  ldy #0
.loop:
  lda JOY1
  lsr A
  ldx #$8C
  bcs .joy1_0
  inx
  inx
.joy1_0:
  pha
  txa
  sta [draw_offsets], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_1
  inx
  inx
.joy1_1:
  pha
  txa
  sta [draw_offsets + 2], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_2
  inx
  inx
.joy1_2:
  pha
  txa
  sta [draw_offsets + 4], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_3
  inx
  inx
.joy1_3:
  pha
  txa
  sta [draw_offsets + 6], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_4
  inx
  inx
.joy1_4:
  pha
  txa
  sta [draw_offsets + 8], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_5
  inx
  inx
.joy1_5:
  pha
  txa
  sta [draw_offsets + 10], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_6
  inx
  inx
.joy1_6:
  pha
  txa
  sta [draw_offsets + 12], y
  pla

  lsr A
  ldx #$8C
  bcs .joy1_7
  inx
  inx
.joy1_7:
  pha
  txa
  sta [draw_offsets + 14], y
  pla

  lda JOY2

  lsr A
  ldx #$8C
  bcs .joy2_0
  inx
  inx
.joy2_0:
  pha
  txa
  sta [draw_offsets + 16], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_1
  inx
  inx
.joy2_1:
  pha
  txa
  sta [draw_offsets + 18], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_2
  inx
  inx
.joy2_2:
  pha
  txa
  sta [draw_offsets + 20], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_3
  inx
  inx
.joy2_3:
  pha
  txa
  sta [draw_offsets + 22], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_4
  inx
  inx
.joy2_4:
  pha
  txa
  sta [draw_offsets + 24], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_5
  inx
  inx
.joy2_5:
  pha
  txa
  sta [draw_offsets + 26], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_6
  inx
  inx
.joy2_6:
  pha
  txa
  sta [draw_offsets + 28], y
  pla

  lsr A
  ldx #$8C
  bcs .joy2_7
  inx
  inx
.joy2_7:
  pha
  txa
  sta [draw_offsets + 30], y
  pla

  iny
  iny
  iny
  cpy #24
  bne .not24
  iny
  iny
  iny
 .not24:
  cpy #51
  bne .not51
  iny
  iny
  iny
.not51:
  cpy #78
  beq .end
  jmp .loop  
.end:
  rts

waitblank:
  jsr fix_scroll
  pha
  bit PPUSTATUS
.loop:
  bit PPUSTATUS  ; load A with value at location PPUSTATUS
  bpl .loop  ; if bit 7 is not set (not VBlank) keep checking
  pla
  rts

fix_scroll:
  ; fix scrolling
  bit PPUSTATUS
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
  rts

IRQ:  
  rti

NMI:  
  rti

nametable:
  .incbin "bg_name_table.bin"
  .org nametable + $3C0
  .incbin "bg_attr_table.bin"
palette: 
  .incbin "palette0.bin"
  .incbin "palette1.bin"

  .bank 1
  .org $0100 - 32
draw_offsets:
  .dw draw_bits + $0013 + ($5A * 0), draw_bits + $0013 + ($5A * 1), draw_bits + $0013 + ($5A * 2), draw_bits + $0013 + ($5A * 3)
  .dw draw_bits + $0013 + ($5A * 4), draw_bits + $0013 + ($5A * 5), draw_bits + $0013 + ($5A * 6), draw_bits + $0013 + ($5A * 7)
  .dw draw_bits + $0013 + ($5A * 8), draw_bits + $0013 + ($5A * 9), draw_bits + $0013 + ($5A * 10), draw_bits + $0013 + ($5A * 11)
  .dw draw_bits + $0013 + ($5A * 12), draw_bits + $0013 + ($5A * 13), draw_bits + $0013 + ($5A * 14), draw_bits + $0013 + ($5A * 15)
  
  .org $0200
draw_bits:
  ldx #$FD
  ldy #$FE
  bit PPUSTATUS

  lda #$20
  sta PPUADDR
  lda #$84
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$20
  sta PPUADDR
  lda #$A4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$20
  sta PPUADDR
  lda #$C4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$20
  sta PPUADDR
  lda #$E4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$21
  sta PPUADDR
  lda #$04
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$21
  sta PPUADDR
  lda #$24
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$21
  sta PPUADDR
  lda #$44
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$21
  sta PPUADDR
  lda #$64
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$04
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$24
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$44
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$64
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$84
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$A4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$C4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  lda #$22
  sta PPUADDR
  lda #$E4
  sta PPUADDR
  lda #$FF
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  sta PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA
  stx PPUDATA

  rts

  .bank 2   ; switch to bank 4 (CHR bank 0)
  .org $0000  ; start at $0000
  .incbin "bg_pattern_table.bin"
  .org $0FD0
  .incbin "bits_pattern_table.bin"
