INCLUDE "src/constants.inc"

SECTION "System RAM",WRAM0[$C000]
ApplePosX::
    DS 1
ApplePosY::
    DS 1
AppleCount::
    DS 1
IsVblank::
    DS 1
Lives::
    DS 1
LivesDisplay::
    DS 2
RNG::
    DS 2
Score::
    DS 2
ScoreDisplay::
    DS 5
SceneUpdate::
    DS 2
SnekFace:: ; 0 = up, 1 = right, 2 = down, 3 = left
    DS 1
SnekMvCounter::
    DS 1
SnekMvSpeed::
    DS 1
SnekNextFace::
    DS 1
SnekPosX::
    DS 1
SnekPosY::
    DS 1
; Array of snek segments
; Each segment is two bytes representing the x, y coordinate
; of the segment.
; 0 <= x <= 18
; 0 <= y <= 16
SnekSegmentArray::
    DS SNEK_SEGMENT_SIZE * 256
; The number of current segments
SnekSegmentArrayLen::
    DS 1
UserInput::
    DS 1


SECTION "Sprite Data",WRAM0[$C800]
SpriteHead::
    DS 4
    DS 156
