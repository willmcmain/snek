; Snek!

; Interrupts
SECTION "Vblank",ROM0[$0040]
    reti
SECTION "LCDC",ROM0[$0048]
    reti
SECTION "Timer_Overflow",ROM0[$0050]
    reti
SECTION "Serial",ROM0[$0058]
    reti
SECTION "Joypad IRQ",ROM0[$0060]
    reti

SECTION "Start",ROM0[$0100]
    nop
    jp main


; Nintendo logo
DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C,$00,$0D
DB $00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6,$DD,$DD,$D9,$99
DB $BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC,$99,$9F,$BB,$B9,$33,$3E

DB "SNEK!",0,0,0,0,0,0 ; Game title, must be padded to 11 bytes
DB $00 ; $80 for Gameboy Color
DB $00 ; License code 1
DB $00 ; License code 2
DB $00 ; $03 for Super Gameboy
DB $00 ; Cartridge Type
DB $00 ; ROM Size
DB $00 ; Cart RAM Size
DB $00 ; Destination code
DB $33 ; Licensee code, must be $33
DB $00 ; Mask ROM version
DB $00 ; Compplement check
DB $00 ; Checksum


SECTION "Game Code",ROM0[$0150]
main:
    nop
    di
    ld sp, $FFFF

    ; set everything up
    call stop_lcd
    call load_tiledata
    call load_bgdata

    ; load pallette and start lcd
    ld a, %11100100
    ld [$FF47], a
    ld a, $91
    ld [$FF40], a
    ei
.loop:
    nop
    jp .loop

; Subroutines
stop_lcd:
.wait
    ld a, [$FF44] ; LY
    cp 144
    jr nz,.wait

    ld a, [$FF40] ; LCDC
    res 7,a
    ld [$FF40], a
    ret

load_tiledata:
    ld hl, EMPTY_TILE
    ld de, $8000
    ld bc, 16
    call memcpy

    ld hl, GRASS_TILE
    ld de, $8010
    ld bc, 16
    call memcpy

    ld hl, BLOCK_TILE
    ld de, $8020
    ld bc, 16
    call memcpy
    ret

load_bgdata:
    ld d, $01
    ld hl, $9800
    ld bc, 32 * 32
    call memfill

    ; top
    ld d, $02
    ld hl, $9800
    ld bc, 20
    call memfill

    ; bottom
    ld d, $02
    ld hl, $9800 + 32 * 17
    ld bc, 20
    call memfill

    ; sides
    ld b, 0
    ld de, 0
    ld hl, $9800
.loop
    ld de, 19
    add hl, de
    ld [hl], $02
    ld de, 13
    add hl, de
    ld [hl], $02

    inc b
    ld a, b
    cp 18
    jr c, .loop
    ret


SECTION "Game Data",ROM0[$2000]
EMPTY_TILE:
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

GRASS_TILE:
DB $00,$00,$40,$00,$01,$00,$20,$00,$20,$00,$04,$00,$08,$00,$00,$00

BLOCK_TILE:
DB $00,$FF,$00,$C3,$00,$BD,$00,$A5,$00,$A5,$00,$BD,$00,$C3,$00,$FF

A_TILE:
DB $3C,$3C,$66,$66,$66,$66,$00,$7E,$00,$66,$66,$00,$66,$00,$66,$00

