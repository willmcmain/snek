INCLUDE "src/hw.inc"

SECTION "Util Code", ROM0

;#######################################################################################
; advance the RNG value
; the RNG is a 2-byte seed value stored in memory. Call this each time you need a new
; random value
;#######################################################################################
advance_rng::
    ; Advance the rng seed s by calculating: 75 * s + 75
    ld a, [RNG]
    ld h, a
    ld a, [RNG+1]
    ld l, a
    ; multiply hl by 75 = 64 + 8 + 3
    ld b, h
    ld c, l
    add hl, hl
    add hl, hl
    add hl, hl
    ld d, h ; store 8x
    ld e, l
    add hl, hl
    add hl, hl
    add hl, hl ; * 64
    add hl, de ; + 8x
    add hl, bc
    add hl, bc
    add hl, bc ; + 3x

    ld d, 0
    ld e, 75
    add hl, de
    ld a, h
    ld [RNG], a
    ld a, l
    ld [RNG+1], a
    ret


;#######################################################################################
; divide hl by c
;
; Args:
; * hl: numerator
; * c: denominator
; Returns:
; * hl: quotient
; * a: remainder
; * c: unchanged
;#######################################################################################
divide::
    ld b, 16
    xor a
.loop
    add hl, hl
    rla
    cp c
    jr c, .end
    inc l
    sub c
.end
    dec b
    jr nz, .loop
    ret


;#######################################################################################
;#######################################################################################
get_tile_map_coordinates::
    ; multiply y by 32 and add to the tile map address
    ld h, 0
    ld l, c
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, TILE_MAP_0
    add hl, de

    ; add x to tile map address
    ld d, $00
    ld e, b
    add hl, de
    ret