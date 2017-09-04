SECTION "Memory Code",ROM0

; memcpy
; copy a block of bytes from one area to another
; hl: source address of bytes to copy
; de: destination address to copy bytes to
; bc: number of bytes to copy
memcpy::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, memcpy
    ret

; memset
; fill a block of memory with a specific byte
; hl: starting address to fill
; bc: number of bytes to fill
; d: byte value to fill
memset::
    ld [hl], d
    inc hl
    dec bc
    ld a, b
    or c
    jr nz, memset
    ret
