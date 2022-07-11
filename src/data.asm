SECTION "Game Data",ROM0[$2000]
EMPTY_TILE::
DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

GRASS_TILE::
;DB $00,$00,$40,$00,$01,$00,$20,$00,$20,$00,$04,$00,$08,$00,$00,$00
DW `00000000
DW `01000000
DW `00000001
DW `00100000
DW `00100000
DW `01001000
DW `00000100
DW `00000000

BLOCK_TILE::
DB $00,$FF,$00,$C3,$00,$BD,$00,$A5,$00,$A5,$00,$BD,$00,$C3,$00,$FF

A_TILE::
DB $3C,$3C,$66,$66,$66,$66,$00,$7E,$00,$66,$66,$00,$66,$00,$66,$00

HEAD_TILE_UP::
DB $00,$00,$3C,$00,$18,$66,$18,$66,$7E,$00,$7E,$00,$3C,$00,$3C,$00

HEAD_TILE_RIGHT::
DB $00,$00,$30,$0C,$F2,$0C,$FE,$00,$FE,$00,$F2,$0C,$30,$0C,$00,$00

SEGMENT_TILE::
DB $18,$18,$3C,$3C,$7E,$7E,$FF,$FF,$FF,$FF,$7E,$7E,$3C,$3C,$18,$18