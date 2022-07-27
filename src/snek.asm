INCLUDE "src/hw.inc"
SNEK_START_X EQU 9
SNEK_START_Y EQU 8
SNEK_SEGMENT_SIZE EQU 2

SNEK_FACE_UP EQU 0
SNEK_FACE_RIGHT EQU 1
SNEK_FACE_DOWN EQU 2
SNEK_FACE_LEFT EQU 3

BUTTON_RIGHT  EQU $01
BUTTON_LEFT   EQU $02
BUTTON_UP     EQU $04
BUTTON_DOWN   EQU $08
BUTTON_A      EQU $10
BUTTON_B      EQU $20
BUTTON_SELECT EQU $40
BUTTON_START  EQU $80

; number of frames between each snek movement
SNEK_MOVEMENT EQU 20

SECTION "Snek Code", ROM0
;#######################################################################################
; initialize snek data
snek_init::
    ld hl, snek_update
    ld a, h
    ld [SceneUpdate], a
    ld a, l
    ld [SceneUpdate+1], a

    ld a, SNEK_FACE_UP
    ld [SnekFace], a
    ld [SnekNextFace], a

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

    call random_apple_pos
    ; Intentionally fall through to call snek_vblank


;#######################################################################################
; load snake tiles into VRAM each frame
;
; call once during each vblank
snek_vblank::
    ld a, [SnekPosArrayLen]
    ld b, a
    ld c, 0

.loop_segments
    push bc ; b = arraylen, c = counter
    ld b, 0
    ld hl, SnekPosArray
    ; add index * 2 for segment size
    add hl, bc
    add hl, bc

    ; load the x,y value of the segment into d, e
    ; add 1 to each because the position does not count the border tiles
    ld a, [hl+]
    inc a
    ld d, a
    ld e, [hl]
    inc e

    ; multiply y by 32 and add to the tile map address
    ld h, 0
    ld l, e
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, TILE_MAP_0
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
    ld [hl], $00

    ; draw the apple
    ; x, y position into b, c
    ld a, [ApplePosX]
    ld b, a
    ld a, [ApplePosY]
    ld c, a

    ; multiply y by 32
    ld h, 0
    ld l, c
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ; then add x
    ld d, 0
    ld e, b
    add hl, de
    ; and add to the tile map address
    ld de, TILE_MAP_0
    add hl, de
    
    ld [hl], $06
    ret


;#######################################################################################
; update snek each frame
snek_update::
    call set_direction

    ; Each frame increment SnekMvCounter by one until it reaches SNEK_MOVEMENT
    ; then move the snake forward one tile
    ld a, [SnekMvCounter]
    inc a
    ld [SnekMvCounter], a
    ld b, SNEK_MOVEMENT
    cp a, b
    ret nz

    call random_apple_pos

    ; reset counter
    ld a, 0
    ld [SnekMvCounter], a

    call shift_segments
    ; grow snake
    ; ld a, [SnekPosArrayLen]
    ; inc a
    ; ld [SnekPosArrayLen], a

    call set_next_pos

    ; create new segment at beginning
    ld a, [SnekPosX]
    ld [SnekPosArray], a
    ld a, [SnekPosY]
    ld [SnekPosArray+1], a
    ret


;#######################################################################################
set_direction:
    ; check for button direction
    ld a, [UserInput]
    ld b, a
    or a
    ret z

    ld a, b
    and BUTTON_RIGHT
    jr nz, .right

    ld a, b
    and BUTTON_LEFT
    jr nz, .left

    ld a, b
    and BUTTON_DOWN
    jr nz, .down

    ld a, b
    and BUTTON_UP
    jr nz, .up
    ret

; for each direction, we check if we're going the opposite direction before setting
; the new direction
.up
    ld a, [SnekFace]
    cp SNEK_FACE_DOWN
    ret z
    ld a, SNEK_FACE_UP
    ld [SnekNextFace], a
    ret
.right
    ld a, [SnekFace]
    cp SNEK_FACE_LEFT
    ret z
    ld a, SNEK_FACE_RIGHT
    ld [SnekNextFace], a
    ret
.down
    ld a, [SnekFace]
    cp SNEK_FACE_UP
    ret z
    ld a, SNEK_FACE_DOWN
    ld [SnekNextFace], a
    ret
.left
    ld a, [SnekFace]
    cp SNEK_FACE_RIGHT
    ret z
    ld a, SNEK_FACE_LEFT
    ld [SnekNextFace], a
    ret


;#######################################################################################
set_next_pos:
    ld a, [SnekNextFace]
    ld [SnekFace], a
    cp SNEK_FACE_UP
    jr z, .up
    cp SNEK_FACE_RIGHT
    jr z, .right
    cp SNEK_FACE_DOWN
    jr z, .down
    ; default left, decrement x
    ld hl, SnekPosX
    dec [hl]
    ret
.up ; decrement y
    ld hl, SnekPosY
    dec [hl]
    ret
.right ; increment x
    ld hl, SnekPosX
    inc [hl]
    ret
.down ; increment y
    ld hl, SnekPosY
    inc [hl]
    ret


;#######################################################################################
shift_segments:
    ; copy snake segments one segment later
    ld hl, SnekPosArray
    ld de, SnekPosArray+SNEK_SEGMENT_SIZE
    ld b, 0
    ld a, [SnekPosArrayLen]
    ld c, a
    ; multiply bytes by SNEK_SEGMENT_SIZE (=2)
    sla c
    rl b

    dec bc
    add hl, bc
    push hl
    ld h, d
    ld l, e
    add hl, bc
    ld d, h
    ld e, l
    pop hl
    inc bc
.loop
    ld a, [hl-]
    ld [de], a
    dec de
    dec bc
    ld a, b
    or c
    jr nz, .loop
    ret


;#######################################################################################
random_apple_pos:
    ; random number from 0 to 17
    ldh a, [rDIV]
    ld h, 0
    ld l, a
    ; multiply by 18: x * 16 + x + x
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld d, 0
    ld e, a
    add hl, de
    add hl, de
    ; take h by itself == hl / 256
    ld a, h
    ld [ApplePosX], a

    ; random number from 0 to 14
    ldh a, [rDIV]
    ld h, 0
    ld l, a
    ; multiply by 15
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ; equivalent to subtracting one:
    ld de, $FFFF
    add hl, de
    ; take h by itself == hl / 256
    ld a, h
    ld [ApplePosY], a
    ret