SECTION "Util Code", ROM0
advance_rng::
    ; Advance the rng seed s by calculating: 75 * s + 74
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
    ld e, 74
    add hl, de
    ld a, h
    ld [RNG], a
    ld a, l
    ld [RNG+1], a
    ret