SECTION "System RAM",WRAM0[$C000]
IsVblank::
    DS 1
UserInput::
    DS 1
WallCollision::
    DS 1
SnekMvCounter::
    DS 1
SnekFace:: ; 0 = up, 1 = right, 2 = down, 3 = left
    DS 1
SnekPosX::
    DS 1
SnekPosY::
    DS 1

; The number of current segments
SnekPosArrayLen::
    DS 1
; Array of snek segments
; Each segment is two bytes representing the x, y coordinate
; of the segment.
; 0 <= x <= 18
; 0 <= y <= 16
SnekPosArray::
    DS 2 * 256

SECTION "Sprite Data",WRAM0[$C800]
SpriteHead::
    DS 4
    DS 156