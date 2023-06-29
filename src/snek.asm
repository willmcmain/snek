INCLUDE "src/hw.inc"
INCLUDE "src/constants.inc"

SECTION "Snek Code", ROM0
;#######################################################################################
; initialize snek data
snek_init::
    SetSceneUpdate snek_update

    ld a, SNEK_FACE_UP
    ld [SnekFace], a
    ld [SnekNextFace], a

    ld a, SNEK_START_X
    ld [SnekPosX], a
    ld a, SNEK_START_Y
    ld [SnekPosY], a
    ld a, 0
    ld [SnekMvCounter], a
    ld a, 15
    ld [SnekMvSpeed], a

    ld a, 3
    ld [SnekSegmentArrayLen], a

    ld hl, SnekSegmentArray
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

    ld a, 0
    ld [Score], a
    ld [Score+1], a
    ld [AppleCount], a

    ld a, 3
    ld [Lives], a

    call random_apple_pos
    call render_snek
    call render_score
    call render_lives
    ret


;#######################################################################################
; load snake tiles into VRAM each frame
;
; call once during each vblank
snek_vblank::
    ; draw the first segment
    ld hl, SnekSegmentArray
    ld a, [hl+]
    ld b, a
    ld a, [hl]
    ld c, a
    call get_tile_map_coordinates
    ld [hl], $05

    ; delete the last tile
    ld hl, SnekSegmentArray
    ld a, [SnekSegmentArrayLen]
    ld b, 0
    ld c, a
    add hl, bc
    add hl, bc
    ld a, [hl+]
    ld b, a
    ld a, [hl]
    ld c, a
    call get_tile_map_coordinates
    ld [hl], $00

    ; draw the apple
    ; x, y position into b, c
    ld a, [ApplePosX]
    ; inc a
    ld b, a
    ld a, [ApplePosY]
    ; add a, 2
    ld c, a
    call get_tile_map_coordinates

    ld [hl], $06

    ; set lives display tiles
    ld hl, LivesDisplay
    ld a, [hl+]
    ld [TILE_MAP_0+18], a
    ld a, [hl]
    ld [TILE_MAP_0+19], a

    ; set score display tiles
    ld hl, ScoreDisplay
    ld a, [hl+]
    ld [TILE_MAP_0], a
    ld a, [hl+]
    ld [TILE_MAP_0+1], a
    ld a, [hl+]
    ld [TILE_MAP_0+2], a
    ld a, [hl+]
    ld [TILE_MAP_0+3], a
    ld a, [hl]
    ld [TILE_MAP_0+4], a

    call render_score
    ret


;#######################################################################################
; load snake tiles into VRAM
;
; call at beginning to set up snek
render_snek::
    ld a, [SnekSegmentArrayLen]
    ld b, a
    ld c, 0

.loop_segments
    push bc ; b = arraylen, c = counter
    ld b, 0
    ld hl, SnekSegmentArray
    ; add index * 2 for segment size
    add hl, bc
    add hl, bc

    ; load the x,y value of the segment into b,c
    ; add 1 to x and 2 to y because the position does not count the border tiles
    ld a, [hl+]
    ld b, a
    ld c, [hl]

    call get_tile_map_coordinates

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
    ret


;#######################################################################################


render_score:
    ; To render the score tiles, we need to get each decimal digit; each time we
    ; divide the score by 10 we get the lowest digit as the remainder, we then use that
    ; as the index of the number tile and write that to to the tile map
    ld a, [Score]
    ld h, a
    ld a, [Score+1]
    ld l, a
    ld c, 10

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [ScoreDisplay+4], a

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [ScoreDisplay+3], a

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [ScoreDisplay+2], a

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [ScoreDisplay+1], a

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [ScoreDisplay], a
    ret


render_lives:
    ld a, $00
    ld h, a
    ld a, [Lives]
    ld l, a
    ld c, 10

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [LivesDisplay+1], a

    call divide
    add (ZERO_TILE - TILE_DATA) / 16
    ld [LivesDisplay], a
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
    ld b, a

    ld a, [SnekMvSpeed]
    cp a, b
    ret nz

    ; reset counter
    ld a, 0
    ld [SnekMvCounter], a

    call shift_segments
    call set_next_pos

    ; check if we hit the apple
    ld a, [SnekPosX]
    ld b, a
    ld a, [ApplePosX]
    cp b
    jr nz, .next
    ld a, [SnekPosY]
    ld b, a
    ld a, [ApplePosY]
    cp b
    jr nz, .next

    ; we grabbed an apple
    call random_apple_pos
    ; grow snake
    ld a, [SnekSegmentArrayLen]
    inc a
    ld [SnekSegmentArrayLen], a

    ; update apple count
    ld a, [AppleCount]
    inc a
    ld [AppleCount], a
    ; every 4 apples, we increase the speed of the snek
    and a, %00000011
    jr nz, .end_speed_up
    ld a, [SnekMvSpeed]
    cp a, 2
    jr z, .end_speed_up
    dec a
    ld [SnekMvSpeed], a
.end_speed_up

    ; every 8 apples, gain another life (max 99)
    ld a, [AppleCount]
    and a, %00000111
    jr nz, .end_life_up
    ld a, [Lives]
    cp a, 99
    jr z, .end_life_up
    inc a
    ld [Lives], a
    call render_lives
.end_life_up


    ; update score
    ld a, [Score]
    ld h, a
    ld a, [Score+1]
    ld l, a
    ld a, [AppleCount]
    ld d, 0
    ld e, a
    add hl, de
    ld a, h
    ld [Score], a
    ld a, l
    ld [Score+1], a
    call render_score

.next
    ; create new segment at beginning
    ld a, [SnekPosX]
    ld [SnekSegmentArray], a
    ld a, [SnekPosY]
    ld [SnekSegmentArray+1], a
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
    ld hl, SnekSegmentArray
    ld de, SnekSegmentArray+SNEK_SEGMENT_SIZE
    ld b, 0
    ld a, [SnekSegmentArrayLen]
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
    call advance_rng
    ld a, [RNG]
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
    ; add 1 to keep it inside the play area
    inc a
    ld [ApplePosX], a

    ; random number from 0 to 14
    call advance_rng
    ld a, [RNG]
    ld h, 0
    ld l, a
    ; multiply by 15
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ; subtract original number
    ; twos complement
    ld d, $FF
    cpl
    ld e, a
    inc de
    add hl, de
    ; take h by itself == hl / 256
    ld a, h
    ; add 2 to keep it inside the play area
    add a, 2
    ld [ApplePosY], a

    ; if the apple was randomly placed on a snake tile, rerandomize
    call check_apple_overlaps_snek
    or a
    jr nz, random_apple_pos
    ret

check_apple_overlaps_snek:
    ld a, [SnekSegmentArrayLen]
    ld d, a
    inc d
    ld hl, SnekSegmentArray

.loop
    dec d
    jr z, .no_match

    ld a, [hl+]
    ld b, a
    ld a, [hl+]
    ld c, a
    ld a, [ApplePosX]
    cp b
    jr nz, .loop
    ld a, [ApplePosY]
    cp c
    jr nz, .loop
    ld a, 1 ; match
    ret
.no_match
    ld a, 0
    ret
