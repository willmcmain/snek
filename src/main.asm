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

    ; process gamepad input & update game state
    call get_input

    ; call SceneUpdate
    ld hl, .return
    push hl
    ld a, [SceneUpdate]
    ld h, a
    ld a, [SceneUpdate+1]
    ld l, a
    jp hl
.return
    jr .loop


vblank:
    push af
    push bc
    push de
    push hl
    call snek_vblank
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
    call snek_init
    ; call init_sprite
    ; zero out OAM
    ld a, $00
    ld hl, OAM_START
    ld c, OAM_END - OAM_START
    call memset8

    ; set up rng
    ldh a, [rDIV]
    ld [RNG], a
    ldh a, [rDIV]
    ld [RNG+1], a


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

    ret


get_input:
    ld a, %00010000 ; select D-pad
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    cpl
    and $0F
    swap a
    ld b, a
    ld a, %00100000 ; select buttons
    ld [rP1], a
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
    ld hl, TILE_DATA
    ld de, TILE_BLOCK_0
    ld bc, TILE_DATA_END-TILE_DATA
    call memcpy16


load_bgdata:
    ld a, $00
    ld hl, TILE_MAP_0
    ld bc, 32 * 18
    call memset16

    ; top
    ld a, $02
    ld hl, TILE_MAP_0 + 32
    ld c, 20
    call memset8

    ; bottom
    ld a, $02
    ld hl, TILE_MAP_0 + 32 * 17
    ld c, 20
    call memset8

    ; sides
    ld c, $02
    ld b, 15
    ld hl, TILE_MAP_0 + 32 * 2
.loop
    ld [hl], c
    ld de, 19
    add hl, de

    ld [hl], c
    ld de, 13
    add hl, de

    dec b
    jr nz, .loop

    ret
