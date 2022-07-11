INCLUDE "src/hw.inc"

KEY_RIGHT  EQU $01
KEY_LEFT   EQU $02
KEY_UP     EQU $04
KEY_DOWN   EQU $08
KEY_A      EQU $10
KEY_B      EQU $20
KEY_SELECT EQU $40
KEY_START  EQU $80

SECTION "Sprite Code", ROM0
;; Copy DMA subroutine into HRAM
load_dma::
    ld de, HRAM_START
    ld hl, dma_copy
    ld bc, dma_end-dma_copy
    call memcpy
    ret


dma_copy:
    ld a, SpriteHead/$100
    ld [rDMA], a
    ld a, 40
.loop:
    dec a
    jr nz, .loop
    ret
dma_end:


init_sprite::
    ld d, $00
    ld hl, SpriteHead
    ld bc, $A0
    call memset

    ld a, $50
    ld [SpriteHead], a
    ld a, $48
    ld [SpriteHead+1], a
    ld a, $03
    ld [SpriteHead+2], a
    ld a, $00
    ld [SpriteHead+3], a

    ; a = 0
    ld [SnekFace], a

    ld a, $02
    ld [SnekPosX], a
    ld a, $40
    ld [SnekPosX+1], a
    ld a, $02
    ld [SnekPosY], a
    ld a, $80
    ld [SnekPosY+1], a
    ret


SUBPIXELS EQU 8
SNEK_SPEED EQU 6

SR3_16: MACRO
    srl \1
    rr \2
    srl \1
    rr \2
    srl \1
    rr \2
    ENDM

UPDATE_SNEK_POSITION: MACRO
    ; move the snek subpixel pos
    ld a, [SnekPos\1]
    ld h, a
    ld a, [SnekPos\1+1]
    ld l, a
    ld b, $0
    ld c, \2
    add hl, bc
    ld a, h
    ld [SnekPos\1], a
    ld a, l
    ld [SnekPos\1+1], a
    ENDM

UPDATE_SNEK_POSITION_NEG: MACRO
    ; move the snek subpixel pos
    ld a, [SnekPos\1]
    ld h, a
    ld a, [SnekPos\1+1]
    ld l, a
    ld b, $FF
    ld c, -\2
    add hl, bc
    ld a, h
    ld [SnekPos\1], a
    ld a, l
    ld [SnekPos\1+1], a
    ENDM

move_snek:
    ; when we're in the middle of a tile, we can turn
    ld a, [SpriteHead+1]
    and $07
    jr nz, .endturn
    ld a, [SpriteHead]
    and $07
    jr nz, .endturn

    ld a, [UserInput]
    ld b, a
    and KEY_RIGHT
    jr z,.left
    ld a, 1
    ld [SnekFace], a
    ld a, $04
    ld [SpriteHead+2], a
    ld a, [SpriteHead+3]
    res 6, a
    res 5, a
    ld [SpriteHead+3], a
.left
    ld a, b
    and KEY_LEFT
    jr z,.up
    ld a, 3
    ld [SnekFace], a
    ld a, $04
    ld [SpriteHead+2], a
    ld a, [SpriteHead+3]
    res 6, a
    set 5, a
    ld [SpriteHead+3], a
.up
    ld a, b
    and KEY_UP
    jr z,.down
    ld a, 0
    ld [SnekFace], a
    ld a, $03
    ld [SpriteHead+2], a
    ld a, [SpriteHead+3]
    res 6, a
    res 5, a
    ld [SpriteHead+3], a
.down
    ld a, b
    and KEY_DOWN
    jr z,.endturn
    ld a, 2
    ld [SnekFace], a
    ld a, $03
    ld [SpriteHead+2], a
    ld a, [SpriteHead+3]
    set 6, a
    res 5, a
    ld [SpriteHead+3], a
.endturn

    ld a, [SnekFace]
    cp 0
    jr nz, .move_down

    UPDATE_SNEK_POSITION_NEG Y,SNEK_SPEED
    SR3_16 h,l
    ld a, l
    ld [SpriteHead], a
    jp .end
.move_down
    ld a, [SnekFace]
    cp 2
    jr nz, .move_left
    UPDATE_SNEK_POSITION Y,SNEK_SPEED
    SR3_16 h,l
    ld a, l
    ld [SpriteHead], a
    jr .end
.move_left
    ld a, [SnekFace]
    cp 3
    jr nz, .move_right
    UPDATE_SNEK_POSITION_NEG X,SNEK_SPEED
    SR3_16 h,l
    ld a, l
    ld [SpriteHead+1], a
    jr .end
.move_right
    ld a, [SnekFace]
    cp 1
    jr nz, .end
    UPDATE_SNEK_POSITION X,SNEK_SPEED
    SR3_16 h,l
    ld a, l
    ld [SpriteHead+1], a
    jr .end
.end
    call check_wall_collision
    ret


check_wall_collision:
    ld a, 0
    ld [WallCollision], a

    ld a, [SpriteHead+1]
    cp 16 ; 8px wall + width of sprite
    jr c, .true
    cp 152 ; 160 - 8px wall
    jr nc, .true
    
    ld a, [SpriteHead]
    cp 24 ; 8px wall + height of sprite
    jr c, .true
    cp 144
    jr nc, .true
    ret
.true:
    ld a, 1
    ld [WallCollision], a
    ret

