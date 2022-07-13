INCLUDE "src/hw.inc"
SNEK_START_X EQU 9
SNEK_START_Y EQU 8
SNEK_SEGMENT_SIZE EQU 2

SECTION "Snek Code", ROM0
init_snek::
    ld a, SNEK_START_X
    ld [SnekPosX], a
    ld a, SNEK_START_Y
    ld [SnekPosY], a
    ld a, 0
    ld [SnekMvCounter], a

    ld a, 3
    ld [SnekPosArrayLen], a

    ld hl, SnekPosArray
    ; Segment 0
    ld a, SNEK_START_X
    ld [hl+], a
    ld a, SNEK_START_Y
    ld [hl+], a
    ; Segment 1
    ld a, SNEK_START_X
    ld [hl+], a
    ld a, SNEK_START_Y + 1
    ld [hl+], a
    ; Segment 2
    ld a, SNEK_START_X
    ld [hl+], a
    ld a, SNEK_START_Y + 2
    ld [hl+], a
    ; Segment 3
    ld a, SNEK_START_X
    ld [hl+], a
    ld a, SNEK_START_Y + 3
    ld [hl+], a
    ret

load_snek::
    ld a, [SnekPosArrayLen]
    ld b, a
    ld c, 0

.loop_segments
    push bc ; b = arraylen, c = counter
    ; multiply array position by segment size
    ld b, 0
    sla c
    rl b
    ld hl, SnekPosArray
    add hl, bc

    ; load the x,y value of the segment into d, e
    ; add 1 to each because the position does not count the border tiles
    ld a, [hl+]
    inc a
    ld d, a
    ld e, [hl]
    inc e

    ld hl, TILE_MAP_0
    ; y * 32 => shift left 5x
    ld b, 0
    ld c, e
    ld a, 5
    call shift_left_16
    add hl, bc

    ; add x to tile map address
    ld b, $00
    ld c, d
    add hl, bc

    ; if this is the final segment, jump to the end
    pop bc
    ld a, b
    cp a, c
    jr z, .end

    ; load snek segment tile and loop
    ld [hl], $05
    inc c
    jr .loop_segments
.end
    ; empty the final segment
    ld [hl], $01
    ret

; call each frame!
move_snek_foward::
    ; Each frame this is called, increment SnekMvCounter by one until it reaches the
    ; target number (60), then move the snake forward one tile
    ld a, [SnekMvCounter]
    inc a
    ld [SnekMvCounter], a
    ld b, 60
    cp a, b
    jp nz, .end

    ld a, 0
    ld [SnekMvCounter], a

    ; copy snake segments one segment later
    ld hl, SnekPosArray
    ld de, SnekPosArray+SNEK_SEGMENT_SIZE
    ld b, 0
    ld a, [SnekPosArrayLen]
    ld c, a
    ; multiply bytes by SNEK_SEGMENT_SIZE (=2)
    sla c
    rl b
    call memcpy_reverse

    ; decrement y to move forward
    ld a, [SnekPosY]
    dec a
    ld [SnekPosY], a

    ; create new segment at beginning
    ld a, [SnekPosX]
    ld [SnekPosArray], a
    ld a, [SnekPosY]
    ld [SnekPosArray+1], a
.end
    ret