; Snek!
INCLUDE "src/hw.inc"

; Interrupts
SECTION "Vertical Blank IRQ",ROM0[$0040]
    jp vblank

SECTION "LCDC IRQ",ROM0[$0048]
    reti

SECTION "Timer Overflow IRQ",ROM0[$0050]
    reti

SECTION "Serial IRQ",ROM0[$0058]
    reti

SECTION "Joypad IRQ",ROM0[$0060]
    reti

SECTION "Start",ROM0[$0100]
    nop
    jp main

SECTION "Header",ROM0[$0104]
; Nintendo logo
DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

DB "SNEK!",0,0,0,0,0,0 ; Game title, must be padded to 11 bytes
DB 0,0,0,0 ; Mfg code
DB $00 ; $80 for Gameboy Color
DB $00 ; License code 1
DB $00 ; License code 2
DB $00 ; $03 for Super Gameboy
DB $00 ; Cartridge Type
DB $00 ; ROM Size
DB $00 ; Cart RAM Size
DB $01 ; Destination code
DB $33 ; Licensee code, must be $33
DB $00 ; Mask ROM version
DB $00 ; Complement check
DB $0000 ; Checksum


SECTION "Game Code",ROM0[$0150]
main:
    ld sp, $FFFF
    call init
.loop:
    halt
    nop ; need a nop after halt because of a bug in the gb hardware
    ld a,[IsVblank]
    or a
    jr z,.loop
    ld a, 0
    ld [IsVblank], a

    ; process user input & update game state
    call get_input
    jr .loop


vblank:
    push af
    push bc
    push de
    push hl
    ld a, 1
    ld [IsVblank], a
    pop hl
    pop de
    pop bc
    pop af
    reti


init:
    nop
    di

    ; set everything up
    call stop_lcd
    call load_tiledata
    call load_bgdata
    call init_snek
    call load_snek
    ; call init_sprite
    ; zero out OAM
    ld d, $00
    ld hl, OAM_START
    ld bc, OAM_END - OAM_START
    call memset

    ; load pallette and start lcd
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a
    ld [rOBP1], a
    ld a, %10010011
    ld [rLCDC], a

    ; enable interrupts
    ld a, %00010001
    ld [rIE], a
    ei

    ; load DMA subroutine
    ; call load_dma
    ret


get_input:
    ld a, %00010000 ; select P14
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and $0F
    swap a
    ld b, a
    ld a, %00100000 ; select P15
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and $0F
    or b
    ld [UserInput], a
    ret


stop_lcd:
.wait
    ld a, [rLY]
    cp 144
    jr nz,.wait

    ld a, [rLCDC]
    res 7,a
    ld [rLCDC], a
    ret


load_tiledata:
    ld hl, EMPTY_TILE
    ld de, TILE_BLOCK_0
    ld bc, 16
    call memcpy

    ld hl, GRASS_TILE
    ld de, TILE_BLOCK_0 + $10
    ld bc, 16
    call memcpy

    ld hl, BLOCK_TILE
    ld de, TILE_BLOCK_0 + $20
    ld bc, 16
    call memcpy

    ld hl, HEAD_TILE_UP
    ld de, TILE_BLOCK_0 + $30
    ld bc, 16
    call memcpy

    ld hl, HEAD_TILE_RIGHT
    ld de, TILE_BLOCK_0 + $40
    ld bc, 16
    call memcpy

    ld hl, SEGMENT_TILE
    ld de, TILE_BLOCK_0 + $50
    ld bc, 16
    call memcpy

load_bgdata:
    ld d, $00
    ld hl, TILE_MAP_0
    ld bc, 32 * 32
    call memset

    ; top
    ld d, $02
    ld hl, TILE_MAP_0
    ld bc, 20
    call memset

    ; bottom
    ld d, $02
    ld hl, TILE_MAP_0 + 32 * 17
    ld bc, 20
    call memset

    ; sides
    ld b, 0
    ld de, 0
    ld hl, TILE_MAP_0
.loop
    ld de, 19
    add hl, de
    ld [hl], $02
    ld de, 13
    add hl, de
    ld [hl], $02

    inc b
    ld a, b
    cp 17
    jr c, .loop

    ret