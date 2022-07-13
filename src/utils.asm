SECTION "Utils Code",ROM0

; 16-bit shift left
; a: number of bits to shift
; bc: will be shifted
shift_left_16::
    or a
.loop
    jp z, .end
    sla c
    rl b
    dec a
    jp .loop
.end
    ret

; 16-bit shift right
; a: number of bits to shift
; bc: register to shift
shift_right_16:
    or a
.loop
    jp z, .end
    srl b
    rr c
    dec a
    jp .loop
.end
    ret