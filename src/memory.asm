SECTION "Memory Code",ROM0

; memcpy8
; copy a block of bytes from one area to another
;
; * c: number of bytes to copy
; * de: destination address to copy bytes to
; * hl: source address of bytes to copy
memcpy8::
    ld a, [hl+]
    ld [de], a
    inc de
    dec c
    jr nz, memcpy8
    ret


; memcpy
; copy a block of bytes from one area to another
;
; * bc: number of bytes to copy
; * de: destination address to copy bytes to
; * hl: source address of bytes to copy
memcpy16::
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, memcpy16
    ret


; memset8
; fill a block of memory with a specific byte
;
; * a: byte value to fill
; * c: number of bytes to fill - Will copy 256 bytes if set to 0
; * hl: starting address to fill
memset8::
    ld [hl+], a
    dec c
    jr nz, memset8
    ret


; memset16
; fill a block of memory with a specific byte
;
; * a: byte value to fill
; * bc: number of bytes to fill -- MUST BE AT LEAST $0100 or BAD THINGS WILL HAPPEN
;       (if you need to set 256 bytes or less use memset8!
; * hl: starting address to fill
memset16::
    ld d, a
    ld a, c
    or a
    ld a, d
    jr z, .loop
    call memcpy8
.loop
    call memset8
    dec b
    jr nz, .loop
    ret
