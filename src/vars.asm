SECTION "System RAM",WRAM0[$C000]
IsVblank::
    DS 1
UserInput::
    DS 1
WallCollision::
    DS 1
SnekFace:: ; 0 = up, 1 = right, 2 = down, 3 = left
    DS 1

SECTION "Sprite Data",WRAM0[$C100]
SpriteHead::
    DS 4
    DS 156