INCLUDE "src/hw.inc"
SNEK_SEGMENT_SIZE EQU 2

SECTION "Snek Code", ROM0
init_snek::
    ld a, 3
    ld [SnekPosArrayLen], a

    ld hl, SnekPosArray
    ; Segment 0
    ld a, 9
    ld [hl+], a
    ld a, 8
    ld [hl+], a
    ; Segment 1
    ld a, 9
    ld [hl+], a
    ld [hl+], a
    ; Segment 2
    ld [hl+], a
    ld a, 10
    ld [hl+], a
    ret

load_snek::
    ld a, [SnekPosArrayLen]
.loop_segments
    dec a
    push af
    ld hl, SnekPosArray

    or a
.loop_mul_segment
    jr z, .end_loop_mul_segment
    ld bc, SNEK_SEGMENT_SIZE
    add hl, bc
    dec a
    jr .loop_mul_segment
.end_loop_mul_segment

    ; load the x,y value of the segment into d, e
    ; add 1 to each because the position does not count the border tiles
    ld a, [hl+]
    inc a
    ld d, a
    ld e, [hl]
    inc e

    ld hl, TILE_MAP_0
    ; add 32 * y to the tile map address
    ld bc, 32
    or e
.loop_mul_y
    jr z, .end_loop_mul_y
    add hl, bc
    dec e
    jr .loop_mul_y
.end_loop_mul_y

    ; add x to tile map address
    ld b, $00
    ld c, d
    add hl, bc

    ; load the tile index
    ld [hl], $05

    pop af
    or a
    jr nz, .loop_segments

    ret