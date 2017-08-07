; Snek!

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
    ld sp, $FFFF
    call init
.loop:
    halt
    nop ; need a nop after halt because of a bug in the gb hardware
    ld a,[is_vblank]
    or a
    jr z,.loop
    ld a, 0
    ld [is_vblank], a
    ; TODO process user input & update game state here
    jr .loop


vblank:
    push af
    push bc
    push de
    push hl
    ld a, 1
    ld [is_vblank], a
    call $FF80
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
    call init_sprite

    ; load pallette and start lcd
    ld a, %11100100
    ld [$FF47], a
    ld [$FF48], a
    ld [$FF49], a
    ld a, %10010011
    ld [$FF40], a
    ei

    ; enable interrupts
    ld a, 1
    ld [$FFFF], a

    ; load DMA subroutine
    call load_dma
    ret


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

    ld hl, HEAD_TILE
    ld de, $8030
    ld bc, 16
    call memcpy

load_bgdata:
    ld d, $01
    ld hl, $9800
    ld bc, 32 * 32
    call memset

    ; top
    ld d, $02
    ld hl, $9800
    ld bc, 20
    call memset

    ; bottom
    ld d, $02
    ld hl, $9800 + 32 * 17
    ld bc, 20
    call memset

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
    cp 17
    jr c, .loop

    ret


init_sprite:
    ld d, $00
    ld hl, sprite_head
    ld bc, $A0
    call memset

    ld a, $50
    ld [sprite_head], a
    ld a, $48
    ld [sprite_head+1], a
    ld a, $03
    ld [sprite_head+2], a
    ld a, $00
    ld [sprite_head+3], a

load_dma:
    ld de, $FF80
    ld hl, dma_copy
    ld bc, dma_end-dma_copy
    call memcpy
    ret


dma_copy:
    ld a, sprite_head/$100
    ld [$FF46], a
    ld a, $28
.loop:
    dec a
    jr nz, .loop
    ret
dma_end:


SECTION "System RAM",WRAM0[$C000]
is_vblank:
    DS 1

SECTION "Sprite Data",WRAM0[$C100]
sprite_head:
    DS 4
