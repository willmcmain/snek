SECTION "Memory Code",ROM0

; memcpy
; copy a block of bytes from one area to another
;
; * hl: source address of bytes to copy
; * de: destination address to copy bytes to
; * bc: number of bytes to copy
memcpy::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, memcpy
    ret

memcpy_reverse::
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

; memcpy8
; copy a block of bytes from one area to another
;
; * hl: source address of bytes to copy
; * de: destination address to copy bytes to
; * c: number of bytes to copy
memcpy8::
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, memcpy8
    ret

; memset
; fill a block of memory with a specific byte
;
; * hl: starting address to fill
; * bc: number of bytes to fill
; * d: byte value to fill
memset::
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, memset
    ret

; memset8
; fill a block of memory with a specific byte
;
; * hl: starting address to fill
; * c: number of bytes to fill
; * d: byte value to fill
memset8::
    ld [hl], d
    inc hl
    dec c
    jr nz, memset8
    ret
